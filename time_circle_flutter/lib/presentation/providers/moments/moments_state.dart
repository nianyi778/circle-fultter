import 'package:flutter/foundation.dart';

import '../../../domain/entities/moment.dart';

/// State for moments list
@immutable
class MomentsState {
  final List<Moment> moments;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final int currentPage;
  final String? errorMessage;
  final MomentsSyncStatus syncStatus;

  const MomentsState({
    this.moments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.currentPage = 1,
    this.errorMessage,
    this.syncStatus = MomentsSyncStatus.idle,
  });

  /// Initial loading state
  factory MomentsState.loading() => const MomentsState(isLoading: true);

  /// Empty state
  factory MomentsState.empty() => const MomentsState(hasReachedEnd: true);

  /// Error state
  factory MomentsState.error(String message) =>
      MomentsState(errorMessage: message);

  /// Check if state has data
  bool get hasData => moments.isNotEmpty;

  /// Check if state has error
  bool get hasError => errorMessage != null;

  /// Check if initial load (no data yet)
  bool get isInitialLoad => isLoading && moments.isEmpty;

  /// Check if can load more
  bool get canLoadMore => !isLoadingMore && !hasReachedEnd && !isLoading;

  MomentsState copyWith({
    List<Moment>? moments,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    int? currentPage,
    String? errorMessage,
    MomentsSyncStatus? syncStatus,
    bool clearError = false,
  }) {
    return MomentsState(
      moments: moments ?? this.moments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MomentsState &&
        listEquals(other.moments, moments) &&
        other.isLoading == isLoading &&
        other.isLoadingMore == isLoadingMore &&
        other.hasReachedEnd == hasReachedEnd &&
        other.currentPage == currentPage &&
        other.errorMessage == errorMessage &&
        other.syncStatus == syncStatus;
  }

  @override
  int get hashCode => Object.hash(
    moments,
    isLoading,
    isLoadingMore,
    hasReachedEnd,
    currentPage,
    errorMessage,
    syncStatus,
  );
}

/// Sync status for moments
enum MomentsSyncStatus { idle, syncing, synced, error }

/// State for timeline filters
@immutable
class TimelineFilterState {
  final String? authorId;
  final int? year;
  final int? month;
  final MediaType? mediaType;
  final bool? favoritesOnly;

  const TimelineFilterState({
    this.authorId,
    this.year,
    this.month,
    this.mediaType,
    this.favoritesOnly,
  });

  /// Check if any filter is active
  bool get hasActiveFilters =>
      authorId != null ||
      year != null ||
      month != null ||
      mediaType != null ||
      favoritesOnly == true;

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (authorId != null) count++;
    if (year != null) count++;
    if (month != null) count++;
    if (mediaType != null) count++;
    if (favoritesOnly == true) count++;
    return count;
  }

  TimelineFilterState copyWith({
    String? authorId,
    int? year,
    int? month,
    MediaType? mediaType,
    bool? favoritesOnly,
    bool clearAuthor = false,
    bool clearYear = false,
    bool clearMonth = false,
    bool clearMediaType = false,
    bool clearFavorites = false,
  }) {
    return TimelineFilterState(
      authorId: clearAuthor ? null : (authorId ?? this.authorId),
      year: clearYear ? null : (year ?? this.year),
      month: clearMonth ? null : (month ?? this.month),
      mediaType: clearMediaType ? null : (mediaType ?? this.mediaType),
      favoritesOnly:
          clearFavorites ? null : (favoritesOnly ?? this.favoritesOnly),
    );
  }

  /// Clear all filters
  TimelineFilterState clear() => const TimelineFilterState();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimelineFilterState &&
        other.authorId == authorId &&
        other.year == year &&
        other.month == month &&
        other.mediaType == mediaType &&
        other.favoritesOnly == favoritesOnly;
  }

  @override
  int get hashCode =>
      Object.hash(authorId, year, month, mediaType, favoritesOnly);
}

/// Available filter options (derived from data)
@immutable
class FilterOptions {
  final List<int> availableYears;
  final List<AuthorOption> availableAuthors;

  const FilterOptions({
    this.availableYears = const [],
    this.availableAuthors = const [],
  });

  bool get isEmpty => availableYears.isEmpty && availableAuthors.isEmpty;
}

/// Author option for filter
@immutable
class AuthorOption {
  final String id;
  final String name;
  final String avatar;
  final int momentCount;

  const AuthorOption({
    required this.id,
    required this.name,
    required this.avatar,
    this.momentCount = 0,
  });
}
