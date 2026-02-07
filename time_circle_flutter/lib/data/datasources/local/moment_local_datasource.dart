import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/storage/database/app_database.dart';
import '../../../core/storage/database/daos/moments_dao.dart';
import '../../../domain/entities/moment.dart' as domain;
import '../../../domain/entities/user.dart' as domain_user;
import '../../models/moment_model.dart';

/// Local data source for Moment operations
/// Handles all SQLite database operations for moments
abstract class MomentLocalDataSource {
  /// Get moments for a circle with pagination and filters
  Future<List<domain.Moment>> getMoments({
    required String circleId,
    int? limit,
    int? offset,
    String? authorId,
    String? mediaType,
    bool? isFavorite,
    int? year,
  });

  /// Watch moments for a circle (real-time updates)
  Stream<List<domain.Moment>> watchMoments(String circleId);

  /// Get a single moment by ID
  Future<domain.Moment?> getMomentById(String id);

  /// Insert or update a moment
  Future<void> saveMoment(domain.Moment moment);

  /// Insert or update multiple moments (batch)
  Future<void> saveMoments(List<domain.Moment> moments);

  /// Soft delete a moment
  Future<void> deleteMoment(String id);

  /// Toggle favorite status
  Future<bool> toggleFavorite(String id);

  /// Get moments pending sync
  Future<List<domain.Moment>> getPendingMoments();

  /// Update sync status for a moment
  Future<void> updateSyncStatus(String id, domain.SyncStatus status);

  /// Get moment count for a circle
  Future<int> getMomentCount(String circleId);

  /// Get available years for filtering
  Future<List<int>> getAvailableYears(String circleId);

  /// Get cache info for pagination
  Future<CacheInfo?> getCacheInfo(String circleId, String filterHash);

  /// Update cache info
  Future<void> updateCacheInfo(CacheInfo info);

  /// Clear all moments for a circle
  Future<void> clearCircleMoments(String circleId);
}

/// Cache info for local pagination tracking
class CacheInfo {
  final String circleId;
  final String filterHash;
  final int currentPage;
  final int totalItems;
  final bool hasMore;
  final DateTime cachedAt;

  const CacheInfo({
    required this.circleId,
    required this.filterHash,
    required this.currentPage,
    required this.totalItems,
    required this.hasMore,
    required this.cachedAt,
  });
}

/// Implementation of MomentLocalDataSource using Drift DAO
class MomentLocalDataSourceImpl implements MomentLocalDataSource {
  final MomentsDao _momentsDao;
  final AppDatabase _database;

  MomentLocalDataSourceImpl(this._momentsDao, this._database);

  @override
  Future<List<domain.Moment>> getMoments({
    required String circleId,
    int? limit,
    int? offset,
    String? authorId,
    String? mediaType,
    bool? isFavorite,
    int? year,
  }) async {
    final results = await _momentsDao.getMomentsForCircle(
      circleId,
      limit: limit,
      offset: offset,
      authorId: authorId,
      mediaType: mediaType,
      isFavorite: isFavorite,
      year: year,
    );

    return results.map(_momentWithAuthorToEntity).toList();
  }

  @override
  Stream<List<domain.Moment>> watchMoments(String circleId) {
    return _momentsDao
        .watchMomentsForCircle(circleId)
        .map((list) => list.map(_momentWithAuthorToEntity).toList());
  }

  @override
  Future<domain.Moment?> getMomentById(String id) async {
    final result = await _momentsDao.getMomentById(id);
    return result != null ? _momentWithAuthorToEntity(result) : null;
  }

  @override
  Future<void> saveMoment(domain.Moment moment) async {
    final companion = _momentToCompanion(moment);
    await _momentsDao.upsertMoment(companion);

    // Also save/update the author user
    await _database.getOrCreateUser(_userToCompanion(moment.author));
  }

  @override
  Future<void> saveMoments(List<domain.Moment> moments) async {
    // First, save all unique authors
    final uniqueAuthors = <String, domain_user.User>{};
    for (final moment in moments) {
      uniqueAuthors[moment.author.id] = moment.author;
    }

    for (final author in uniqueAuthors.values) {
      await _database.getOrCreateUser(_userToCompanion(author));
    }

    // Then batch save moments
    final companions = moments.map(_momentToCompanion).toList();
    await _momentsDao.upsertMoments(companions);
  }

  @override
  Future<void> deleteMoment(String id) async {
    await _momentsDao.softDelete(id);
  }

  @override
  Future<bool> toggleFavorite(String id) async {
    return _momentsDao.toggleFavorite(id);
  }

  @override
  Future<List<domain.Moment>> getPendingMoments() async {
    final results = await _momentsDao.getPendingMoments();
    // Note: getPendingMoments returns database Moment type,
    // we need to convert without author join
    return results.map(_dbMomentToEntity).toList();
  }

  @override
  Future<void> updateSyncStatus(String id, domain.SyncStatus status) async {
    await _momentsDao.updateSyncStatus(id, status.index);
  }

  @override
  Future<int> getMomentCount(String circleId) async {
    return _momentsDao.getMomentCount(circleId);
  }

  @override
  Future<List<int>> getAvailableYears(String circleId) async {
    return _momentsDao.getAvailableYears(circleId);
  }

  @override
  Future<CacheInfo?> getCacheInfo(String circleId, String filterHash) async {
    final result = await _momentsDao.getCacheInfo(circleId, filterHash);
    if (result == null) return null;

    return CacheInfo(
      circleId: result.circleId,
      filterHash: result.filterHash,
      currentPage: result.currentPage,
      totalItems: result.totalItems,
      hasMore: result.hasMore,
      cachedAt: result.cachedAt,
    );
  }

  @override
  Future<void> updateCacheInfo(CacheInfo info) async {
    await _momentsDao.updateCacheInfo(
      MomentCacheInfoCompanion(
        circleId: Value(info.circleId),
        filterHash: Value(info.filterHash),
        currentPage: Value(info.currentPage),
        totalItems: Value(info.totalItems),
        hasMore: Value(info.hasMore),
        cachedAt: Value(info.cachedAt),
      ),
    );
  }

  @override
  Future<void> clearCircleMoments(String circleId) async {
    await _momentsDao.clearCircleMoments(circleId);
  }

  // ============ Conversion Helpers ============

  /// Convert MomentWithAuthor (DAO result) to domain Moment entity
  domain.Moment _momentWithAuthorToEntity(MomentWithAuthor result) {
    final moment = result.moment;
    final author = result.author;

    return domain.Moment(
      id: moment.id,
      circleId: moment.circleId,
      author:
          author != null
              ? _userToEntity(author)
              : domain_user.User(
                id: moment.authorId,
                name: 'Unknown',
                avatar: '',
                email: '',
                createdAt: DateTime.now(),
              ),
      content: moment.content,
      mediaType: domain.MediaType.fromString(moment.mediaType),
      mediaUrls: _parseJsonList(moment.mediaUrls),
      timestamp: moment.timestamp,
      contextTags: _parseContextTags(moment.contextTags),
      location: moment.location,
      isFavorite: moment.isFavorite,
      futureMessage: moment.futureMessage,
      isSharedToWorld: moment.isSharedToWorld,
      worldTopic: moment.worldTopic,
      createdAt: moment.createdAt,
      updatedAt: moment.updatedAt,
      deletedAt: moment.deletedAt,
      syncStatus: domain.SyncStatus.values[moment.syncStatus],
    );
  }

  /// Convert database Moment to domain entity (without author join)
  domain.Moment _dbMomentToEntity(Moment dbMoment) {
    return domain.Moment(
      id: dbMoment.id,
      circleId: dbMoment.circleId,
      author: domain_user.User(
        id: dbMoment.authorId,
        name: 'Unknown',
        avatar: '',
        email: '',
        createdAt: DateTime.now(),
      ),
      content: dbMoment.content,
      mediaType: domain.MediaType.fromString(dbMoment.mediaType),
      mediaUrls: _parseJsonList(dbMoment.mediaUrls),
      timestamp: dbMoment.timestamp,
      contextTags: _parseContextTags(dbMoment.contextTags),
      location: dbMoment.location,
      isFavorite: dbMoment.isFavorite,
      futureMessage: dbMoment.futureMessage,
      isSharedToWorld: dbMoment.isSharedToWorld,
      worldTopic: dbMoment.worldTopic,
      createdAt: dbMoment.createdAt,
      updatedAt: dbMoment.updatedAt,
      deletedAt: dbMoment.deletedAt,
      syncStatus: domain.SyncStatus.values[dbMoment.syncStatus],
    );
  }

  /// Convert domain User to database Companion
  UsersCompanion _userToCompanion(domain_user.User user) {
    return UsersCompanion(
      id: Value(user.id),
      name: Value(user.name),
      email: Value(user.email ?? ''),
      avatar: Value(user.avatar),
      createdAt: Value(user.createdAt ?? DateTime.now()),
    );
  }

  /// Convert database User to domain entity
  domain_user.User _userToEntity(User dbUser) {
    return domain_user.User(
      id: dbUser.id,
      name: dbUser.name,
      avatar: dbUser.avatar ?? '',
      email: dbUser.email,
      createdAt: dbUser.createdAt,
    );
  }

  /// Convert domain Moment to database Companion
  MomentsCompanion _momentToCompanion(domain.Moment moment) {
    return MomentsCompanion(
      id: Value(moment.id),
      circleId: Value(moment.circleId),
      authorId: Value(moment.author.id),
      content: Value(moment.content),
      mediaType: Value(moment.mediaType.name),
      mediaUrls: Value(jsonEncode(moment.mediaUrls)),
      timestamp: Value(moment.timestamp),
      contextTags: Value(_encodeContextTags(moment.contextTags)),
      location: Value(moment.location),
      isFavorite: Value(moment.isFavorite),
      futureMessage: Value(moment.futureMessage),
      isSharedToWorld: Value(moment.isSharedToWorld),
      worldTopic: Value(moment.worldTopic),
      createdAt: Value(moment.createdAt),
      updatedAt: Value(moment.updatedAt),
      deletedAt: Value(moment.deletedAt),
      syncStatus: Value(moment.syncStatus.index),
    );
  }

  /// Parse JSON array string to List<String>
  List<String> _parseJsonList(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Parse context tags JSON string to ContextTag entity
  domain.ContextTag _parseContextTags(String? json) {
    if (json == null || json.isEmpty) return const domain.ContextTag();
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return domain.ContextTag.fromJson(decoded);
      }
      // Handle array format from API
      if (decoded is List) {
        String? myMood;
        String? atmosphere;
        for (final tag in decoded) {
          if (tag is Map) {
            final type = tag['type'] as String?;
            final emoji = tag['emoji'] as String? ?? '';
            final label = tag['label'] as String? ?? '';
            if (type == 'mood') {
              myMood = '$emoji $label';
            } else if (type == 'atmosphere') {
              atmosphere = '$emoji $label';
            }
          }
        }
        return domain.ContextTag(myMood: myMood, atmosphere: atmosphere);
      }
      return const domain.ContextTag();
    } catch (e) {
      return const domain.ContextTag();
    }
  }

  /// Encode ContextTag entity to JSON string
  String? _encodeContextTags(domain.ContextTag tags) {
    if (tags.isEmpty) return null;
    return jsonEncode(tags.toJson());
  }
}

/// Extension to convert MomentModel to domain entity with sync status
extension MomentModelExtension on MomentModel {
  /// Convert to domain entity with specified sync status
  domain.Moment toEntityWithSyncStatus(domain.SyncStatus syncStatus) {
    return domain.Moment(
      id: id,
      circleId: circleId,
      author:
          author?.toEntity() ??
          domain_user.User(
            id: authorId,
            name: 'Unknown',
            avatar: '',
            email: '',
            createdAt: DateTime.now(),
          ),
      content: content,
      mediaType: domain.MediaType.fromString(mediaType),
      mediaUrls: mediaUrls,
      timestamp: timestamp,
      contextTags: _contextTagsToEntity(),
      location: location,
      isFavorite: isFavorite,
      futureMessage: futureMessage,
      isSharedToWorld: isSharedToWorld,
      worldTopic: worldTopic,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncStatus: syncStatus,
    );
  }

  domain.ContextTag _contextTagsToEntity() {
    String? myMood;
    String? atmosphere;

    for (final tag in contextTags) {
      if (tag.type == 'mood') {
        myMood = '${tag.emoji} ${tag.label}';
      } else if (tag.type == 'atmosphere') {
        atmosphere = '${tag.emoji} ${tag.label}';
      }
    }

    return domain.ContextTag(myMood: myMood, atmosphere: atmosphere);
  }
}
