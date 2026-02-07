import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../core/usecases/usecase.dart';
import '../../domain/entities/moment.dart';
import '../../domain/repositories/moment_repository.dart';
import '../datasources/remote/moment_remote_datasource.dart';
import '../datasources/local/moment_local_datasource.dart';
import '../models/moment_model.dart';

/// Implementation of MomentRepository
///
/// Implements offline-first strategy:
/// 1. READ: Return local data immediately, sync with server in background
/// 2. WRITE: Save locally first, sync to server when online
/// 3. DELETE: Mark as pending delete locally, sync when online
class MomentRepositoryImpl implements MomentRepository {
  final MomentRemoteDataSource _remoteDataSource;
  final MomentLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  MomentRepositoryImpl({
    required MomentRemoteDataSource remoteDataSource,
    required MomentLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, PaginatedResult<Moment>>> getMoments({
    required MomentFilterParams filter,
    int page = 1,
    int limit = 20,
  }) async {
    final filterHash = _generateFilterHash(filter);

    // Check if we have valid cache
    final cacheInfo = await _localDataSource.getCacheInfo(
      filter.circleId,
      filterHash,
    );

    final isOnline = await _networkInfo.isConnected;
    final shouldFetchRemote =
        isOnline &&
        (cacheInfo == null ||
            page > (cacheInfo.currentPage) ||
            _isCacheStale(cacheInfo.cachedAt));

    if (shouldFetchRemote) {
      try {
        // Fetch from remote
        final response = await _remoteDataSource.getMoments(
          circleId: filter.circleId,
          page: page,
          limit: limit,
          authorId: filter.authorId,
          mediaType: filter.mediaType?.name,
          favorite: filter.isFavorite,
          year: filter.year,
        );

        // Save to local cache
        final moments = response.data.map((m) => m.toEntity()).toList();
        await _localDataSource.saveMoments(moments);

        // Update cache info
        await _localDataSource.updateCacheInfo(
          CacheInfo(
            circleId: filter.circleId,
            filterHash: filterHash,
            currentPage: page,
            totalItems: response.total,
            hasMore: response.hasMore,
            cachedAt: DateTime.now(),
          ),
        );

        return Right(
          PaginatedResult(
            items: moments,
            page: response.page,
            limit: response.limit,
            total: response.total,
            hasMore: response.hasMore,
          ),
        );
      } on ServerException catch (e) {
        debugPrint('[MomentRepo] Server error, falling back to local: $e');
        // Fall through to local data
      } on NetworkException {
        debugPrint('[MomentRepo] Network error, falling back to local');
        // Fall through to local data
      } catch (e) {
        debugPrint('[MomentRepo] Unexpected error: $e');
        // Fall through to local data
      }
    }

    // Return local data
    try {
      final offset = (page - 1) * limit;
      final localMoments = await _localDataSource.getMoments(
        circleId: filter.circleId,
        limit: limit,
        offset: offset,
        authorId: filter.authorId,
        mediaType: filter.mediaType?.name,
        isFavorite: filter.isFavorite,
        year: filter.year,
      );

      final totalCount = await _localDataSource.getMomentCount(filter.circleId);
      final hasMore = offset + localMoments.length < totalCount;

      return Right(
        PaginatedResult(
          items: localMoments,
          page: page,
          limit: limit,
          total: totalCount,
          hasMore: hasMore,
        ),
      );
    } catch (e) {
      return Left(CacheFailure('Failed to load local moments: $e'));
    }
  }

  @override
  Future<Either<Failure, Moment>> getMomentById(String id) async {
    // Try local first
    try {
      final localMoment = await _localDataSource.getMomentById(id);
      if (localMoment != null) {
        // Refresh from server in background if online
        _refreshMomentInBackground(id);
        return Right(localMoment);
      }
    } catch (e) {
      debugPrint('[MomentRepo] Local lookup failed: $e');
    }

    // Fetch from server
    if (await _networkInfo.isConnected) {
      try {
        final moment = await _remoteDataSource.getMomentById(id);
        final entity = moment.toEntity();

        // Cache locally
        await _localDataSource.saveMoment(entity);

        return Right(entity);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException {
        return const Left(NetworkFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }

    return const Left(CacheFailure('Moment not found'));
  }

  @override
  Future<Either<Failure, Moment>> createMoment(
    CreateMomentParams params,
  ) async {
    // Try to sync immediately if online
    if (await _networkInfo.isConnected) {
      try {
        final request = CreateMomentRequest(
          content: params.content,
          mediaType: params.mediaType.name,
          mediaUrls: params.mediaUrls,
          timestamp: params.timestamp,
          contextTags:
              params.contextTags != null
                  ? _contextTagToModels(params.contextTags!)
                  : null,
          location: params.location,
          futureMessage: params.futureMessage,
        );

        final remoteMoment = await _remoteDataSource.createMoment(
          circleId: params.circleId,
          request: request,
        );

        final syncedMoment = remoteMoment.toEntity();

        // Cache locally
        await _localDataSource.saveMoment(syncedMoment);

        return Right(syncedMoment);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException {
        return const Left(NetworkFailure());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }

    // Offline: Cannot create without server (need author info from session)
    return const Left(NetworkFailure('Cannot create moment while offline'));
  }

  @override
  Future<Either<Failure, Moment>> updateMoment(
    UpdateMomentParams params,
  ) async {
    // Get existing moment
    final existingResult = await getMomentById(params.id);

    return existingResult.fold((failure) => Left(failure), (existing) async {
      // Update local with pending status
      final updatedMoment = existing.copyWith(
        content: params.content ?? existing.content,
        mediaUrls: params.mediaUrls ?? existing.mediaUrls,
        contextTags: params.contextTags ?? existing.contextTags,
        location: params.location ?? existing.location,
        futureMessage: params.futureMessage ?? existing.futureMessage,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pendingUpdate,
      );

      await _localDataSource.saveMoment(updatedMoment);

      // Try to sync immediately if online
      if (await _networkInfo.isConnected) {
        try {
          final request = UpdateMomentRequest(
            content: params.content,
            mediaUrls: params.mediaUrls,
            contextTags:
                params.contextTags != null
                    ? _contextTagToModels(params.contextTags!)
                    : null,
            location: params.location,
            futureMessage: params.futureMessage,
          );

          final remoteMoment = await _remoteDataSource.updateMoment(
            id: params.id,
            request: request,
          );

          final syncedMoment = remoteMoment.toEntity();
          await _localDataSource.saveMoment(syncedMoment);

          return Right(syncedMoment);
        } catch (e) {
          debugPrint('[MomentRepo] Failed to sync update: $e');
          return Right(updatedMoment);
        }
      }

      return Right(updatedMoment);
    });
  }

  @override
  Future<Either<Failure, void>> deleteMoment(String id) async {
    // Mark as pending delete locally
    await _localDataSource.deleteMoment(id);

    // Try to sync immediately if online
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.deleteMoment(id);
      } catch (e) {
        debugPrint('[MomentRepo] Failed to sync delete: $e');
        // Will sync later via syncPendingMoments
      }
    }

    return const Right(null);
  }

  @override
  Future<Either<Failure, Moment>> toggleFavorite(String id) async {
    // Update locally first
    await _localDataSource.toggleFavorite(id);

    // Get updated moment
    final momentResult = await getMomentById(id);

    // Try to sync if online
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.toggleFavorite(id);
      } catch (e) {
        debugPrint('[MomentRepo] Failed to sync favorite: $e');
      }
    }

    return momentResult;
  }

  @override
  Future<Either<Failure, Moment>> shareToWorld(String id, String topic) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('Cannot share when offline'));
    }

    try {
      await _remoteDataSource.shareToWorld(momentId: id, tag: topic);
      final moment = await _remoteDataSource.getMomentById(id);
      final entity = moment.toEntity();

      await _localDataSource.saveMoment(entity);

      return Right(entity);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Moment>>> getLastYearToday(
    String circleId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final moments = await _remoteDataSource.getMemoryMoments(
          circleId: circleId,
        );
        return Right(moments.map((m) => m.toEntity()).toList());
      } catch (e) {
        debugPrint('[MomentRepo] Failed to get memory moments: $e');
      }
    }

    // Calculate last year today locally
    final now = DateTime.now();
    final lastYearToday = DateTime(now.year - 1, now.month, now.day);
    final nextDay = lastYearToday.add(const Duration(days: 1));

    try {
      final moments = await _localDataSource.getMoments(
        circleId: circleId,
        year: lastYearToday.year,
      );

      // Filter to just this day
      final filtered =
          moments
              .where(
                (m) =>
                    m.timestamp.isAfter(
                      lastYearToday.subtract(const Duration(days: 1)),
                    ) &&
                    m.timestamp.isBefore(nextDay),
              )
              .toList();

      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Moment>>> getRandomMoments(
    String circleId, {
    int count = 5,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final moments = await _remoteDataSource.getRandomMoments(
          circleId: circleId,
          count: count,
        );
        return Right(moments.map((m) => m.toEntity()).toList());
      } catch (e) {
        debugPrint('[MomentRepo] Failed to get random moments: $e');
      }
    }

    // Get random moments locally
    try {
      final allMoments = await _localDataSource.getMoments(circleId: circleId);

      if (allMoments.isEmpty) return const Right([]);

      allMoments.shuffle();
      return Right(allMoments.take(count).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> getAvailableYears(String circleId) async {
    // Try local first
    try {
      final localYears = await _localDataSource.getAvailableYears(circleId);
      if (localYears.isNotEmpty) {
        // Refresh from server in background
        _refreshYearsInBackground(circleId);
        return Right(localYears);
      }
    } catch (e) {
      debugPrint('[MomentRepo] Local years lookup failed: $e');
    }

    // Fetch from server
    if (await _networkInfo.isConnected) {
      try {
        final years = await _remoteDataSource.getAvailableYears(circleId);
        return Right(years);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    }

    return const Right([]);
  }

  @override
  Future<Either<Failure, Map<String, int>>> getMomentCountByAuthor(
    String circleId,
  ) async {
    // TODO: Implement with aggregation
    return const Right({});
  }

  @override
  Stream<List<Moment>> watchMoments(String circleId) {
    return _localDataSource.watchMoments(circleId);
  }

  @override
  Future<Either<Failure, int>> syncPendingMoments() async {
    if (!await _networkInfo.isConnected) {
      return const Right(0);
    }

    try {
      final pending = await _localDataSource.getPendingMoments();
      int syncedCount = 0;

      for (final moment in pending) {
        try {
          switch (moment.syncStatus) {
            case SyncStatus.pendingCreate:
              final request = CreateMomentRequest(
                content: moment.content,
                mediaType: moment.mediaType.name,
                mediaUrls: moment.mediaUrls,
                timestamp: moment.timestamp,
                location: moment.location,
                futureMessage: moment.futureMessage,
              );

              final created = await _remoteDataSource.createMoment(
                circleId: moment.circleId,
                request: request,
              );

              // Update local with server ID
              await _localDataSource.deleteMoment(moment.id);
              await _localDataSource.saveMoment(created.toEntity());
              syncedCount++;
              break;

            case SyncStatus.pendingUpdate:
              final request = UpdateMomentRequest(
                content: moment.content,
                mediaUrls: moment.mediaUrls,
                location: moment.location,
                futureMessage: moment.futureMessage,
              );

              await _remoteDataSource.updateMoment(
                id: moment.id,
                request: request,
              );

              await _localDataSource.updateSyncStatus(
                moment.id,
                SyncStatus.synced,
              );
              syncedCount++;
              break;

            case SyncStatus.pendingDelete:
              await _remoteDataSource.deleteMoment(moment.id);
              // Actually remove from local DB
              syncedCount++;
              break;

            default:
              break;
          }
        } catch (e) {
          debugPrint('[MomentRepo] Failed to sync moment ${moment.id}: $e');
          await _localDataSource.updateSyncStatus(moment.id, SyncStatus.failed);
        }
      }

      return Right(syncedCount);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ============== Helper Methods ==============

  /// Generate a hash for filter parameters to use as cache key
  String _generateFilterHash(MomentFilterParams filter) {
    final data = {
      'authorId': filter.authorId ?? '',
      'mediaType': filter.mediaType?.name ?? '',
      'isFavorite': filter.isFavorite?.toString() ?? '',
      'year': filter.year?.toString() ?? '',
    };
    final bytes = utf8.encode(jsonEncode(data));
    return md5.convert(bytes).toString();
  }

  /// Check if cache is stale (older than 5 minutes)
  bool _isCacheStale(DateTime cachedAt) {
    return DateTime.now().difference(cachedAt).inMinutes > 5;
  }

  /// Refresh a moment from server in background
  void _refreshMomentInBackground(String id) {
    Future(() async {
      if (await _networkInfo.isConnected) {
        try {
          final moment = await _remoteDataSource.getMomentById(id);
          await _localDataSource.saveMoment(moment.toEntity());
        } catch (e) {
          debugPrint('[MomentRepo] Background refresh failed: $e');
        }
      }
    });
  }

  /// Refresh years from server in background
  void _refreshYearsInBackground(String circleId) {
    Future(() async {
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.getAvailableYears(circleId);
        } catch (e) {
          debugPrint('[MomentRepo] Background years refresh failed: $e');
        }
      }
    });
  }

  /// Convert domain ContextTag to list of ContextTagModel
  List<ContextTagModel> _contextTagToModels(ContextTag tag) {
    final models = <ContextTagModel>[];

    if (tag.myMood != null) {
      final parts = tag.myMood!.split(' ');
      if (parts.length >= 2) {
        models.add(
          ContextTagModel(
            type: 'mood',
            emoji: parts[0],
            label: parts.sublist(1).join(' '),
          ),
        );
      }
    }

    if (tag.atmosphere != null) {
      final parts = tag.atmosphere!.split(' ');
      if (parts.length >= 2) {
        models.add(
          ContextTagModel(
            type: 'atmosphere',
            emoji: parts[0],
            label: parts.sublist(1).join(' '),
          ),
        );
      }
    }

    return models;
  }
}
