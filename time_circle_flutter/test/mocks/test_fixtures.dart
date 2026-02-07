import 'package:time_circle/domain/entities/moment.dart';
import 'package:time_circle/domain/entities/user.dart';
import 'package:time_circle/data/models/moment_model.dart';
import 'package:time_circle/data/models/user_model.dart';
import 'package:time_circle/data/datasources/remote/moment_remote_datasource.dart';

/// Test fixtures for unit tests
class TestFixtures {
  static const testCircleId = 'circle-123';
  static const testUserId = 'user-456';
  static const testMomentId = 'moment-789';

  static User get testUser => const User(
    id: testUserId,
    name: 'Test User',
    avatar: 'https://example.com/avatar.png',
    email: 'test@example.com',
    createdAt: null,
  );

  static Moment get testMoment => Moment(
    id: testMomentId,
    circleId: testCircleId,
    author: testUser,
    content: 'Test moment content',
    mediaType: MediaType.text,
    mediaUrls: const [],
    timestamp: DateTime(2024, 1, 15, 10, 30),
    contextTags: const ContextTag(myMood: '😊 开心'),
    location: 'Beijing',
    isFavorite: false,
    createdAt: DateTime(2024, 1, 15, 10, 30),
    syncStatus: SyncStatus.synced,
  );

  static List<Moment> get testMoments => [
    testMoment,
    testMoment.copyWith(
      id: 'moment-2',
      content: 'Second moment',
      timestamp: DateTime(2024, 1, 14, 9, 0),
    ),
    testMoment.copyWith(
      id: 'moment-3',
      content: 'Third moment with image',
      mediaType: MediaType.image,
      mediaUrls: ['https://example.com/image.jpg'],
      timestamp: DateTime(2024, 1, 13, 15, 30),
    ),
  ];

  static MomentModel get testMomentModel => MomentModel(
    id: testMomentId,
    circleId: testCircleId,
    authorId: testUserId,
    content: 'Test moment content',
    mediaType: 'text',
    mediaUrls: const [],
    timestamp: DateTime(2024, 1, 15, 10, 30),
    contextTags: const [
      ContextTagModel(type: 'mood', label: '开心', emoji: '😊'),
    ],
    location: 'Beijing',
    isFavorite: false,
    createdAt: DateTime(2024, 1, 15, 10, 30),
    author: const AuthorModel(
      id: testUserId,
      name: 'Test User',
      avatar: 'https://example.com/avatar.png',
    ),
  );

  static List<MomentModel> get testMomentModels => [
    testMomentModel,
    MomentModel(
      id: 'moment-2',
      circleId: testCircleId,
      authorId: testUserId,
      content: 'Second moment',
      mediaType: 'text',
      mediaUrls: const [],
      timestamp: DateTime(2024, 1, 14, 9, 0),
      contextTags: const [],
      createdAt: DateTime(2024, 1, 14, 9, 0),
    ),
  ];

  static PaginatedResponse<MomentModel> get testPaginatedResponse =>
      PaginatedResponse(
        data: testMomentModels,
        page: 1,
        limit: 20,
        total: 2,
        totalPages: 1,
        hasMore: false,
      );
}
