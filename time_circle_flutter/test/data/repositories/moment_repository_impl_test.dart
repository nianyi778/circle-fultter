import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:time_circle/core/errors/exceptions.dart';
import 'package:time_circle/core/errors/failures.dart';
import 'package:time_circle/data/datasources/local/moment_local_datasource.dart';
import 'package:time_circle/data/repositories/moment_repository_impl.dart';
import 'package:time_circle/domain/entities/moment.dart';
import 'package:time_circle/domain/repositories/moment_repository.dart';

import '../../mocks/mock_datasources.dart';
import '../../mocks/test_fixtures.dart';

void main() {
  late MomentRepositoryImpl repository;
  late MockMomentRemoteDataSource mockRemoteDataSource;
  late MockMomentLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUpAll(() {
    registerFallbackValue(FakeMoment());
    registerFallbackValue(FakeCacheInfo());
    registerFallbackValue(SyncStatus.synced);
  });

  setUp(() {
    mockRemoteDataSource = MockMomentRemoteDataSource();
    mockLocalDataSource = MockMomentLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = MomentRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getMoments', () {
    final filter = MomentFilterParams(circleId: TestFixtures.testCircleId);

    test('should return remote data when online and cache is stale', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockLocalDataSource.getCacheInfo(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => mockRemoteDataSource.getMoments(
          circleId: any(named: 'circleId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          authorId: any(named: 'authorId'),
          mediaType: any(named: 'mediaType'),
          favorite: any(named: 'favorite'),
          year: any(named: 'year'),
        ),
      ).thenAnswer((_) async => TestFixtures.testPaginatedResponse);
      when(
        () => mockLocalDataSource.saveMoments(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockLocalDataSource.updateCacheInfo(any()),
      ).thenAnswer((_) async {});

      // Act
      final result = await repository.getMoments(filter: filter);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (
        paginatedResult,
      ) {
        expect(paginatedResult.items.length, 2);
        expect(paginatedResult.hasMore, false);
      });

      verify(
        () => mockRemoteDataSource.getMoments(
          circleId: TestFixtures.testCircleId,
          page: 1,
          limit: 20,
          authorId: null,
          mediaType: null,
          favorite: null,
          year: null,
        ),
      ).called(1);
      verify(() => mockLocalDataSource.saveMoments(any())).called(1);
    });

    test('should return local data when offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockLocalDataSource.getCacheInfo(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => mockLocalDataSource.getMoments(
          circleId: any(named: 'circleId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          authorId: any(named: 'authorId'),
          mediaType: any(named: 'mediaType'),
          isFavorite: any(named: 'isFavorite'),
          year: any(named: 'year'),
        ),
      ).thenAnswer((_) async => TestFixtures.testMoments);
      when(
        () => mockLocalDataSource.getMomentCount(any()),
      ).thenAnswer((_) async => 3);

      // Act
      final result = await repository.getMoments(filter: filter);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (
        paginatedResult,
      ) {
        expect(paginatedResult.items.length, 3);
      });

      verifyNever(
        () => mockRemoteDataSource.getMoments(
          circleId: any(named: 'circleId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      );
    });

    test('should fall back to local data when server error occurs', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockLocalDataSource.getCacheInfo(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => mockRemoteDataSource.getMoments(
          circleId: any(named: 'circleId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          authorId: any(named: 'authorId'),
          mediaType: any(named: 'mediaType'),
          favorite: any(named: 'favorite'),
          year: any(named: 'year'),
        ),
      ).thenThrow(const ServerException(message: 'Server error'));
      when(
        () => mockLocalDataSource.getMoments(
          circleId: any(named: 'circleId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          authorId: any(named: 'authorId'),
          mediaType: any(named: 'mediaType'),
          isFavorite: any(named: 'isFavorite'),
          year: any(named: 'year'),
        ),
      ).thenAnswer((_) async => TestFixtures.testMoments);
      when(
        () => mockLocalDataSource.getMomentCount(any()),
      ).thenAnswer((_) async => 3);

      // Act
      final result = await repository.getMoments(filter: filter);

      // Assert
      expect(result.isRight(), true);
    });
  });

  group('getMomentById', () {
    test('should return local moment if exists', () async {
      // Arrange
      when(
        () => mockLocalDataSource.getMomentById(any()),
      ).thenAnswer((_) async => TestFixtures.testMoment);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.getMomentById(any()),
      ).thenAnswer((_) async => TestFixtures.testMomentModel);
      when(
        () => mockLocalDataSource.saveMoment(any()),
      ).thenAnswer((_) async {});

      // Act
      final result = await repository.getMomentById(TestFixtures.testMomentId);

      // Assert
      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (moment) {
        expect(moment.id, TestFixtures.testMomentId);
        expect(moment.content, 'Test moment content');
      });
    });

    test('should fetch from remote if not in local cache', () async {
      // Arrange
      when(
        () => mockLocalDataSource.getMomentById(any()),
      ).thenAnswer((_) async => null);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.getMomentById(any()),
      ).thenAnswer((_) async => TestFixtures.testMomentModel);
      when(
        () => mockLocalDataSource.saveMoment(any()),
      ).thenAnswer((_) async {});

      // Act
      final result = await repository.getMomentById(TestFixtures.testMomentId);

      // Assert
      expect(result.isRight(), true);
      verify(
        () => mockRemoteDataSource.getMomentById(TestFixtures.testMomentId),
      ).called(1);
      verify(() => mockLocalDataSource.saveMoment(any())).called(1);
    });

    test('should return CacheFailure when offline and not in cache', () async {
      // Arrange
      when(
        () => mockLocalDataSource.getMomentById(any()),
      ).thenAnswer((_) async => null);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.getMomentById(TestFixtures.testMomentId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (moment) => fail('Should return failure'),
      );
    });
  });

  group('toggleFavorite', () {
    test('should update local and try to sync when online', () async {
      // Arrange
      when(
        () => mockLocalDataSource.toggleFavorite(any()),
      ).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getMomentById(any())).thenAnswer(
        (_) async => TestFixtures.testMoment.copyWith(isFavorite: true),
      );
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.toggleFavorite(any()),
      ).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.getMomentById(any()),
      ).thenAnswer((_) async => TestFixtures.testMomentModel);
      when(
        () => mockLocalDataSource.saveMoment(any()),
      ).thenAnswer((_) async {});

      // Act
      final result = await repository.toggleFavorite(TestFixtures.testMomentId);

      // Assert
      expect(result.isRight(), true);
      verify(
        () => mockLocalDataSource.toggleFavorite(TestFixtures.testMomentId),
      ).called(1);
      verify(
        () => mockRemoteDataSource.toggleFavorite(TestFixtures.testMomentId),
      ).called(1);
    });
  });

  group('deleteMoment', () {
    test('should soft delete locally and sync when online', () async {
      // Arrange
      when(
        () => mockLocalDataSource.deleteMoment(any()),
      ).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.deleteMoment(any()),
      ).thenAnswer((_) async {});

      // Act
      final result = await repository.deleteMoment(TestFixtures.testMomentId);

      // Assert
      expect(result.isRight(), true);
      verify(
        () => mockLocalDataSource.deleteMoment(TestFixtures.testMomentId),
      ).called(1);
      verify(
        () => mockRemoteDataSource.deleteMoment(TestFixtures.testMomentId),
      ).called(1);
    });

    test('should still succeed when offline (queued for sync)', () async {
      // Arrange
      when(
        () => mockLocalDataSource.deleteMoment(any()),
      ).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.deleteMoment(TestFixtures.testMomentId);

      // Assert
      expect(result.isRight(), true);
      verify(
        () => mockLocalDataSource.deleteMoment(TestFixtures.testMomentId),
      ).called(1);
      verifyNever(() => mockRemoteDataSource.deleteMoment(any()));
    });
  });

  group('watchMoments', () {
    test('should return stream from local data source', () {
      // Arrange
      when(
        () => mockLocalDataSource.watchMoments(any()),
      ).thenAnswer((_) => Stream.value(TestFixtures.testMoments));

      // Act
      final stream = repository.watchMoments(TestFixtures.testCircleId);

      // Assert
      expect(stream, emits(TestFixtures.testMoments));
    });
  });
}
