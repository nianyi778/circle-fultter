import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/moment.dart';

/// Parameters for creating a new moment
class CreateMomentParams {
  final String circleId;
  final String content;
  final MediaType mediaType;
  final List<String> mediaUrls;
  final DateTime? timestamp;
  final ContextTag? contextTags;
  final String? location;
  final String? futureMessage;

  const CreateMomentParams({
    required this.circleId,
    required this.content,
    this.mediaType = MediaType.text,
    this.mediaUrls = const [],
    this.timestamp,
    this.contextTags,
    this.location,
    this.futureMessage,
  });
}

/// Parameters for updating a moment
class UpdateMomentParams {
  final String id;
  final String? content;
  final List<String>? mediaUrls;
  final ContextTag? contextTags;
  final String? location;
  final String? futureMessage;

  const UpdateMomentParams({
    required this.id,
    this.content,
    this.mediaUrls,
    this.contextTags,
    this.location,
    this.futureMessage,
  });
}

/// Parameters for filtering moments
class MomentFilterParams {
  final String circleId;
  final String? authorId;
  final int? year;
  final int? month;
  final MediaType? mediaType;
  final bool? isFavorite;

  const MomentFilterParams({
    required this.circleId,
    this.authorId,
    this.year,
    this.month,
    this.mediaType,
    this.isFavorite,
  });
}

/// Abstract repository interface for Moments
///
/// This interface defines the contract for moment data operations.
/// Implementations can be remote-only, local-only, or hybrid (offline-first).
abstract class MomentRepository {
  /// Get paginated list of moments
  ///
  /// Returns moments filtered by [filter] with pagination.
  Future<Either<Failure, PaginatedResult<Moment>>> getMoments({
    required MomentFilterParams filter,
    int page = 1,
    int limit = 20,
  });

  /// Get a single moment by ID
  Future<Either<Failure, Moment>> getMomentById(String id);

  /// Create a new moment
  ///
  /// Returns the created moment with server-assigned ID.
  Future<Either<Failure, Moment>> createMoment(CreateMomentParams params);

  /// Update an existing moment
  ///
  /// Only drafts or author's own moments can be updated.
  Future<Either<Failure, Moment>> updateMoment(UpdateMomentParams params);

  /// Delete a moment (soft delete)
  ///
  /// Marks the moment as deleted without removing from database.
  Future<Either<Failure, void>> deleteMoment(String id);

  /// Toggle favorite status
  ///
  /// Returns the updated moment with new favorite status.
  Future<Either<Failure, Moment>> toggleFavorite(String id);

  /// Share moment to world channel
  ///
  /// Creates an anonymous world post from this moment.
  Future<Either<Failure, Moment>> shareToWorld(String id, String topic);

  /// Get moments from last year on this day (memory feature)
  ///
  /// Returns moments from previous years on the same month/day.
  Future<Either<Failure, List<Moment>>> getLastYearToday(String circleId);

  /// Get random moments for memory roaming
  ///
  /// Returns [count] random moments from the circle.
  Future<Either<Failure, List<Moment>>> getRandomMoments(
    String circleId, {
    int count = 5,
  });

  /// Watch moments stream for real-time updates
  ///
  /// Returns a stream that emits when moments change.
  Stream<List<Moment>> watchMoments(String circleId);

  /// Sync pending moments with server
  ///
  /// Uploads locally created/modified moments to server.
  Future<Either<Failure, int>> syncPendingMoments();

  /// Get available years for filter
  Future<Either<Failure, List<int>>> getAvailableYears(String circleId);

  /// Get moment count by author
  Future<Either<Failure, Map<String, int>>> getMomentCountByAuthor(
    String circleId,
  );
}
