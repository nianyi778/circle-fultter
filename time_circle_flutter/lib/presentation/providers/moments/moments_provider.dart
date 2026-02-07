import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/moment.dart';
import '../../../domain/repositories/moment_repository.dart';
import 'moments_state.dart';

/// Moments StateNotifier for managing timeline state
///
/// Handles:
/// - Loading and pagination
/// - CRUD operations
/// - Filtering
/// - Sync status
class MomentsNotifier extends StateNotifier<MomentsState> {
  final MomentRepository _repository;
  final String _circleId;

  MomentsNotifier({
    required MomentRepository repository,
    required String circleId,
  }) : _repository = repository,
       _circleId = circleId,
       super(MomentsState.loading()) {
    // Load initial data
    _loadMoments();
  }

  /// Load moments (initial or refresh)
  Future<void> _loadMoments({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        currentPage: 1,
        hasReachedEnd: false,
        clearError: true,
      );
    }

    final result = await _repository.getMoments(
      filter: MomentFilterParams(circleId: _circleId),
      page: 1,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
      (paginated) =>
          state = state.copyWith(
            isLoading: false,
            moments: paginated.items,
            hasReachedEnd: !paginated.hasMore,
            currentPage: 1,
            clearError: true,
          ),
    );
  }

  /// Refresh moments (pull-to-refresh)
  Future<void> refresh() async {
    await _loadMoments(refresh: true);
  }

  /// Load more moments (pagination)
  Future<void> loadMore() async {
    if (!state.canLoadMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;
    final result = await _repository.getMoments(
      filter: MomentFilterParams(circleId: _circleId),
      page: nextPage,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
      (paginated) =>
          state = state.copyWith(
            isLoadingMore: false,
            moments: [...state.moments, ...paginated.items],
            hasReachedEnd: !paginated.hasMore,
            currentPage: nextPage,
          ),
    );
  }

  /// Create a new moment
  Future<bool> createMoment(CreateMomentParams params) async {
    final result = await _repository.createMoment(params);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (moment) {
        // Add new moment to the beginning of the list
        state = state.copyWith(
          moments: [moment, ...state.moments],
          clearError: true,
        );
        return true;
      },
    );
  }

  /// Update a moment
  Future<bool> updateMoment(UpdateMomentParams params) async {
    final result = await _repository.updateMoment(params);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (updatedMoment) {
        // Replace moment in list
        final updatedList =
            state.moments.map<Moment>((m) {
              return m.id == updatedMoment.id ? updatedMoment : m;
            }).toList();

        state = state.copyWith(moments: updatedList, clearError: true);
        return true;
      },
    );
  }

  /// Delete a moment
  Future<bool> deleteMoment(String id) async {
    final result = await _repository.deleteMoment(id);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        // Remove moment from list
        final updatedList = state.moments.where((m) => m.id != id).toList();
        state = state.copyWith(moments: updatedList, clearError: true);
        return true;
      },
    );
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    // Optimistic update
    final currentMoment = state.moments.firstWhere((m) => m.id == id);
    final optimisticList =
        state.moments.map<Moment>((m) {
          return m.id == id ? m.copyWith(isFavorite: !m.isFavorite) : m;
        }).toList();
    state = state.copyWith(moments: optimisticList);

    final result = await _repository.toggleFavorite(id);

    result.fold(
      (failure) {
        // Revert on failure
        final revertedList =
            state.moments.map<Moment>((m) {
              return m.id == id ? currentMoment : m;
            }).toList();
        state = state.copyWith(
          moments: revertedList,
          errorMessage: failure.message,
        );
      },
      (updatedMoment) {
        // Confirm with server response
        final confirmedList =
            state.moments.map<Moment>((m) {
              return m.id == id ? updatedMoment : m;
            }).toList();
        state = state.copyWith(moments: confirmedList, clearError: true);
      },
    );
  }

  /// Share moment to world
  Future<bool> shareToWorld(String id, String topic) async {
    final result = await _repository.shareToWorld(id, topic);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (updatedMoment) {
        final updatedList =
            state.moments.map<Moment>((m) {
              return m.id == id ? updatedMoment : m;
            }).toList();
        state = state.copyWith(moments: updatedList, clearError: true);
        return true;
      },
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Sync pending moments
  Future<void> syncPending() async {
    state = state.copyWith(syncStatus: MomentsSyncStatus.syncing);

    final result = await _repository.syncPendingMoments();

    result.fold(
      (failure) =>
          state = state.copyWith(
            syncStatus: MomentsSyncStatus.error,
            errorMessage: failure.message,
          ),
      (syncedCount) {
        state = state.copyWith(syncStatus: MomentsSyncStatus.synced);
        if (syncedCount > 0) {
          refresh(); // Refresh to get latest data
        }
      },
    );
  }
}

/// Provider for current circle ID
final currentCircleIdProvider = StateProvider<String?>((ref) => null);

/// Provider for MomentsNotifier
///
/// Depends on repository and current circle ID.
/// Auto-disposes when circle changes.
final momentsNotifierProvider =
    StateNotifierProvider.autoDispose<MomentsNotifier, MomentsState>((ref) {
      final circleId = ref.watch(currentCircleIdProvider);
      if (circleId == null) {
        throw StateError('Circle ID is required');
      }

      final repository = ref.watch(momentRepositoryProvider);

      return MomentsNotifier(repository: repository, circleId: circleId);
    });

/// Provider for filtered moments
///
/// Applies filter state to moments list.
final filteredMomentsProvider = Provider.autoDispose<List<Moment>>((ref) {
  final momentsState = ref.watch(momentsNotifierProvider);
  final filter = ref.watch(timelineFilterProvider);

  if (!filter.hasActiveFilters) {
    return momentsState.moments;
  }

  return momentsState.moments.where((moment) {
    // Filter by author
    if (filter.authorId != null && moment.author.id != filter.authorId) {
      return false;
    }

    // Filter by year
    if (filter.year != null && moment.timestamp.year != filter.year) {
      return false;
    }

    // Filter by month
    if (filter.month != null && moment.timestamp.month != filter.month) {
      return false;
    }

    // Filter by media type
    if (filter.mediaType != null && moment.mediaType != filter.mediaType) {
      return false;
    }

    // Filter favorites only
    if (filter.favoritesOnly == true && !moment.isFavorite) {
      return false;
    }

    return true;
  }).toList();
});

/// Provider for single moment by ID
final momentByIdProvider = Provider.autoDispose.family<Moment?, String>((
  ref,
  id,
) {
  final momentsState = ref.watch(momentsNotifierProvider);
  try {
    return momentsState.moments.firstWhere((m) => m.id == id);
  } catch (_) {
    return null;
  }
});

/// Provider for timeline filter state
final timelineFilterProvider =
    StateNotifierProvider<TimelineFilterNotifier, TimelineFilterState>((ref) {
      return TimelineFilterNotifier();
    });

/// Notifier for timeline filter
class TimelineFilterNotifier extends StateNotifier<TimelineFilterState> {
  TimelineFilterNotifier() : super(const TimelineFilterState());

  void setAuthor(String? authorId) {
    state = state.copyWith(authorId: authorId, clearAuthor: authorId == null);
  }

  void setYear(int? year) {
    state = state.copyWith(year: year, clearYear: year == null);
  }

  void setMonth(int? month) {
    state = state.copyWith(month: month, clearMonth: month == null);
  }

  void setMediaType(MediaType? mediaType) {
    state = state.copyWith(
      mediaType: mediaType,
      clearMediaType: mediaType == null,
    );
  }

  void setFavoritesOnly(bool? value) {
    state = state.copyWith(favoritesOnly: value, clearFavorites: value == null);
  }

  void clearFilters() {
    state = state.clear();
  }
}

/// Placeholder for repository provider
/// This should be overridden with actual implementation
final momentRepositoryProvider = Provider<MomentRepository>((ref) {
  throw UnimplementedError('momentRepositoryProvider must be overridden');
});
