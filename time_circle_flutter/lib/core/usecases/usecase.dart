import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

/// Base UseCase interface
///
/// All use cases should implement this interface.
/// Use cases encapsulate single business operations.
///
/// Type parameters:
/// - [T] The return type on success
/// - [Params] The parameters required for execution
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use case that doesn't require parameters
abstract class UseCaseNoParams<T> {
  Future<Either<Failure, T>> call();
}

/// Use case that returns a Stream instead of Future
abstract class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

/// Use case that returns a Stream without parameters
abstract class StreamUseCaseNoParams<T> {
  Stream<Either<Failure, T>> call();
}

/// Marker class for use cases that don't need parameters
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Pagination parameters for list-based use cases
class PaginationParams extends Equatable {
  final int page;
  final int limit;

  const PaginationParams({this.page = 1, this.limit = 20});

  /// Create next page params
  PaginationParams nextPage() => PaginationParams(page: page + 1, limit: limit);

  /// Create first page params
  PaginationParams firstPage() => PaginationParams(page: 1, limit: limit);

  /// Calculate offset for database queries
  int get offset => (page - 1) * limit;

  @override
  List<Object?> get props => [page, limit];
}

/// Result wrapper for paginated data
class PaginatedResult<T> extends Equatable {
  final List<T> items;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  /// Create empty result
  factory PaginatedResult.empty() => const PaginatedResult(
    items: [],
    page: 1,
    limit: 20,
    total: 0,
    hasMore: false,
  );

  /// Calculate total pages
  int get totalPages => (total / limit).ceil();

  /// Check if this is the first page
  bool get isFirstPage => page == 1;

  /// Check if this is the last page
  bool get isLastPage => !hasMore;

  @override
  List<Object?> get props => [items, page, limit, total, hasMore];
}
