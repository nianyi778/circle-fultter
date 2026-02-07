# TimeCircle (Aura) - Architecture Design Document

> **Mobile Design Commitment**
>
> **Project:** TimeCircle (Aura) - 私密家庭时光记录应用
> **Platform:** iOS + Android (Cross-platform)
> **Framework:** Flutter (Riverpod + GoRouter)
>
> **1. Default Pattern I will NOT use:**
> - setState() 泛滥 -> 使用 Riverpod selectors 进行精准状态订阅
> - ScrollView for lists -> 使用 ListView.builder + const 优化
>
> **2. Context-specific focus:**
> - 情感化设计：温和、安静、内敛的"时间容器"
> - 隐私优先：家庭记忆的私密性
> - 离线优先：记忆不应因网络而丢失
>
> **3. Platform-specific differences:**
> - iOS: Edge swipe back, SF Symbols fallback, Haptic Engine
> - Android: Material 3 ripple, back gesture, Android haptics
>
> **4. Performance optimization focus:**
> - Timeline 时间线的无限滚动性能
> - 图片加载和缓存策略
> - 动画性能 (60fps)
>
> **5. Unique challenge:**
> - 时间胶囊 Letters 的加密和定时解锁机制
> - 跨设备家庭成员同步
> - 情感化微交互设计

---

## 1. Architecture Overview

### 1.1 Architecture Pattern: Clean Architecture + Feature-First

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                                 │
│  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐            │
│  │   Views/Screens  │ │     Widgets      │ │   View Models    │            │
│  │  (Feature-based) │ │  (Shared/Aura)   │ │  (StateNotifier) │            │
│  └────────┬─────────┘ └────────┬─────────┘ └────────┬─────────┘            │
│           │                    │                    │                       │
│           └────────────────────┼────────────────────┘                       │
│                                │                                            │
├────────────────────────────────┼────────────────────────────────────────────┤
│                          STATE LAYER (Riverpod)                              │
│  ┌─────────────────────────────┴─────────────────────────────┐              │
│  │              Providers / StateNotifiers                    │              │
│  │    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │              │
│  │    │ Auth Provider│  │Moment Provider│  │Letter Provider│  │              │
│  │    └──────────────┘  └──────────────┘  └──────────────┘   │              │
│  └───────────────────────────────────────────────────────────┘              │
│                                │                                            │
├────────────────────────────────┼────────────────────────────────────────────┤
│                           DOMAIN LAYER                                       │
│  ┌────────────────┐ ┌────────────────┐ ┌────────────────┐                   │
│  │    Entities    │ │   Use Cases    │ │   Interfaces   │                   │
│  │  (Pure Dart)   │ │ (Business Logic)│ │  (Contracts)   │                   │
│  └────────────────┘ └────────────────┘ └────────────────┘                   │
│                                │                                            │
├────────────────────────────────┼────────────────────────────────────────────┤
│                            DATA LAYER                                        │
│  ┌────────────────┐ ┌────────────────┐ ┌────────────────┐                   │
│  │  Repositories  │ │  Data Sources  │ │     Models     │                   │
│  │ (Implementation)│ │ (Remote/Local) │ │  (DTO/Mapper)  │                   │
│  └────────────────┘ └────────────────┘ └────────────────┘                   │
│                                │                                            │
├────────────────────────────────┼────────────────────────────────────────────┤
│                          INFRASTRUCTURE                                      │
│  ┌────────────────┐ ┌────────────────┐ ┌────────────────┐                   │
│  │   API Client   │ │ Local Database │ │ Secure Storage │                   │
│  │     (Dio)      │ │    (Drift)     │ │   (Keychain)   │                   │
│  └────────────────┘ └────────────────┘ └────────────────┘                   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Directory Structure (Refactored)

```
lib/
├── main.dart                           # App entry point
├── app.dart                            # App widget with providers
│
├── core/                               # Core infrastructure (shared across features)
│   ├── config/
│   │   ├── app_config.dart             # Environment config
│   │   ├── api_config.dart             # API endpoints
│   │   └── storage_keys.dart           # Storage key constants
│   │
│   ├── constants/
│   │   ├── app_constants.dart          # App-wide constants
│   │   ├── duration_constants.dart     # Animation durations
│   │   └── spacing_constants.dart      # Design spacing
│   │
│   ├── errors/
│   │   ├── failures.dart               # Domain failures
│   │   ├── exceptions.dart             # Data layer exceptions
│   │   └── error_handler.dart          # Global error handling
│   │
│   ├── extensions/
│   │   ├── context_extensions.dart
│   │   ├── datetime_extensions.dart
│   │   ├── string_extensions.dart
│   │   └── widget_extensions.dart
│   │
│   ├── network/
│   │   ├── api_client.dart             # Dio client wrapper
│   │   ├── api_interceptors.dart       # Auth, logging interceptors
│   │   ├── network_info.dart           # Connectivity checker
│   │   └── api_response.dart           # Generic response wrapper
│   │
│   ├── storage/
│   │   ├── local_storage.dart          # SharedPreferences wrapper
│   │   ├── secure_storage.dart         # Flutter Secure Storage
│   │   └── database/
│   │       ├── app_database.dart       # Drift database
│   │       ├── daos/                   # Data Access Objects
│   │       └── tables/                 # Drift table definitions
│   │
│   ├── router/
│   │   ├── app_router.dart             # GoRouter configuration
│   │   ├── routes.dart                 # Route definitions
│   │   └── route_guards.dart           # Auth guards
│   │
│   ├── theme/
│   │   ├── app_theme.dart              # ThemeData
│   │   ├── app_colors.dart             # Color palette
│   │   ├── app_typography.dart         # Text styles
│   │   ├── app_spacing.dart            # Spacing system
│   │   └── app_animations.dart         # Animation configs
│   │
│   └── utils/
│       ├── date_utils.dart
│       ├── image_utils.dart
│       ├── validators.dart
│       └── haptic_utils.dart           # Platform haptics
│
├── domain/                             # Pure business logic (no dependencies)
│   ├── entities/
│   │   ├── user.dart
│   │   ├── circle.dart
│   │   ├── moment.dart
│   │   ├── letter.dart
│   │   ├── comment.dart
│   │   └── world_post.dart
│   │
│   ├── repositories/                   # Abstract interfaces
│   │   ├── auth_repository.dart
│   │   ├── circle_repository.dart
│   │   ├── moment_repository.dart
│   │   ├── letter_repository.dart
│   │   └── world_repository.dart
│   │
│   ├── usecases/                       # Business logic operations
│   │   ├── auth/
│   │   │   ├── login_usecase.dart
│   │   │   ├── register_usecase.dart
│   │   │   └── logout_usecase.dart
│   │   ├── moments/
│   │   │   ├── get_moments_usecase.dart
│   │   │   ├── create_moment_usecase.dart
│   │   │   └── delete_moment_usecase.dart
│   │   └── letters/
│   │       ├── seal_letter_usecase.dart
│   │       └── unlock_letter_usecase.dart
│   │
│   └── value_objects/                  # Immutable domain types
│       ├── email.dart
│       ├── password.dart
│       └── moment_content.dart
│
├── data/                               # Data layer implementation
│   ├── models/                         # Data Transfer Objects
│   │   ├── user_model.dart
│   │   ├── moment_model.dart
│   │   ├── letter_model.dart
│   │   └── mappers/                    # Entity <-> Model mappers
│   │
│   ├── datasources/
│   │   ├── remote/
│   │   │   ├── auth_remote_datasource.dart
│   │   │   ├── moment_remote_datasource.dart
│   │   │   └── letter_remote_datasource.dart
│   │   └── local/
│   │       ├── auth_local_datasource.dart
│   │       ├── moment_local_datasource.dart
│   │       └── letter_local_datasource.dart
│   │
│   └── repositories/                   # Repository implementations
│       ├── auth_repository_impl.dart
│       ├── moment_repository_impl.dart
│       └── letter_repository_impl.dart
│
├── presentation/                       # UI Layer
│   ├── providers/                      # Riverpod providers
│   │   ├── auth/
│   │   │   ├── auth_provider.dart
│   │   │   └── auth_state.dart
│   │   ├── moments/
│   │   │   ├── moments_provider.dart
│   │   │   ├── moments_state.dart
│   │   │   └── timeline_filter_provider.dart
│   │   ├── letters/
│   │   │   ├── letters_provider.dart
│   │   │   └── letters_state.dart
│   │   └── common/
│   │       ├── connectivity_provider.dart
│   │       └── theme_provider.dart
│   │
│   └── shared/                         # Shared UI components
│       ├── aura/                       # Design System
│       │   ├── aura.dart               # Barrel export
│       │   ├── buttons/
│       │   │   ├── aura_button.dart
│       │   │   ├── aura_icon_button.dart
│       │   │   └── aura_text_button.dart
│       │   ├── cards/
│       │   │   ├── aura_card.dart
│       │   │   └── aura_elevated_card.dart
│       │   ├── inputs/
│       │   │   ├── aura_text_field.dart
│       │   │   ├── aura_search_bar.dart
│       │   │   └── aura_date_picker.dart
│       │   ├── feedback/
│       │   │   ├── aura_toast.dart
│       │   │   ├── aura_dialog.dart
│       │   │   ├── aura_skeleton.dart
│       │   │   └── aura_loading.dart
│       │   ├── layout/
│       │   │   ├── aura_scaffold.dart
│       │   │   ├── aura_app_bar.dart
│       │   │   └── aura_bottom_nav.dart
│       │   └── display/
│       │       ├── aura_avatar.dart
│       │       ├── aura_tag.dart
│       │       └── aura_empty_state.dart
│       │
│       ├── widgets/                    # Feature-agnostic widgets
│       │   ├── cached_network_image.dart
│       │   ├── animated_list_item.dart
│       │   ├── pull_to_refresh.dart
│       │   └── media_viewer.dart
│       │
│       └── layouts/
│           ├── main_scaffold.dart
│           └── responsive_layout.dart
│
├── features/                           # Feature modules
│   ├── auth/
│   │   ├── views/
│   │   │   ├── login_view.dart
│   │   │   ├── register_view.dart
│   │   │   └── circle_setup_view.dart
│   │   └── widgets/
│   │       └── auth_form.dart
│   │
│   ├── home/
│   │   ├── views/
│   │   │   └── home_view.dart
│   │   └── widgets/
│   │       ├── time_header.dart
│   │       ├── memory_card.dart
│   │       ├── annual_letter_card.dart
│   │       └── daily_quote_card.dart
│   │
│   ├── timeline/
│   │   ├── views/
│   │   │   ├── timeline_view.dart
│   │   │   └── moment_detail_view.dart
│   │   └── widgets/
│   │       ├── feed_card.dart
│   │       ├── filter_drawer.dart
│   │       └── comment_drawer.dart
│   │
│   ├── letters/
│   │   ├── views/
│   │   │   ├── letters_view.dart
│   │   │   ├── letter_detail_view.dart
│   │   │   └── letter_editor_view.dart
│   │   └── widgets/
│   │       ├── letter_card.dart
│   │       └── seal_animation.dart
│   │
│   ├── world/
│   │   ├── views/
│   │   │   └── world_view.dart
│   │   └── widgets/
│   │       ├── world_post_card.dart
│   │       └── channel_filter.dart
│   │
│   ├── create/
│   │   ├── views/
│   │   │   └── create_moment_modal.dart
│   │   └── widgets/
│   │       ├── media_picker.dart
│   │       ├── context_tag_selector.dart
│   │       └── location_picker.dart
│   │
│   └── settings/
│       ├── views/
│       │   ├── settings_view.dart
│       │   ├── profile_edit_view.dart
│       │   └── members_view.dart
│       └── widgets/
│           └── settings_section.dart
│
└── l10n/                               # Internationalization
    ├── app_en.arb
    └── app_zh.arb
```

---

## 2. Domain Layer Design

### 2.1 Entities (Pure Dart Classes)

```dart
// domain/entities/moment.dart

import 'package:equatable/equatable.dart';

enum MediaType { text, image, video, audio }

class ContextTag extends Equatable {
  final String? myMood;
  final String? atmosphere;

  const ContextTag({this.myMood, this.atmosphere});

  @override
  List<Object?> get props => [myMood, atmosphere];
}

class Moment extends Equatable {
  final String id;
  final String circleId;
  final User author;
  final String content;
  final MediaType mediaType;
  final List<String> mediaUrls;
  final DateTime timestamp;
  final ContextTag contextTags;
  final String? location;
  final bool isFavorite;
  final String? futureMessage;
  final bool isSharedToWorld;
  final String? worldTopic;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Moment({
    required this.id,
    required this.circleId,
    required this.author,
    required this.content,
    required this.mediaType,
    required this.mediaUrls,
    required this.timestamp,
    required this.contextTags,
    this.location,
    this.isFavorite = false,
    this.futureMessage,
    this.isSharedToWorld = false,
    this.worldTopic,
    required this.createdAt,
    this.updatedAt,
  });

  Moment copyWith({
    String? id,
    String? circleId,
    User? author,
    String? content,
    MediaType? mediaType,
    List<String>? mediaUrls,
    DateTime? timestamp,
    ContextTag? contextTags,
    String? location,
    bool? isFavorite,
    String? futureMessage,
    bool? isSharedToWorld,
    String? worldTopic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Moment(
      id: id ?? this.id,
      circleId: circleId ?? this.circleId,
      author: author ?? this.author,
      content: content ?? this.content,
      mediaType: mediaType ?? this.mediaType,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      timestamp: timestamp ?? this.timestamp,
      contextTags: contextTags ?? this.contextTags,
      location: location ?? this.location,
      isFavorite: isFavorite ?? this.isFavorite,
      futureMessage: futureMessage ?? this.futureMessage,
      isSharedToWorld: isSharedToWorld ?? this.isSharedToWorld,
      worldTopic: worldTopic ?? this.worldTopic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, circleId, author, content, mediaType, mediaUrls,
        timestamp, contextTags, location, isFavorite,
        futureMessage, isSharedToWorld, worldTopic,
        createdAt, updatedAt,
      ];
}
```

### 2.2 Repository Interfaces (Contracts)

```dart
// domain/repositories/moment_repository.dart

import 'package:dartz/dartz.dart';
import '../entities/moment.dart';
import '../../core/errors/failures.dart';

abstract class MomentRepository {
  /// Get moments with pagination
  Future<Either<Failure, List<Moment>>> getMoments({
    required String circleId,
    int page = 1,
    int limit = 20,
    String? authorId,
    int? year,
    MediaType? mediaType,
  });

  /// Get a single moment by ID
  Future<Either<Failure, Moment>> getMomentById(String id);

  /// Create a new moment
  Future<Either<Failure, Moment>> createMoment(CreateMomentParams params);

  /// Update an existing moment
  Future<Either<Failure, Moment>> updateMoment(UpdateMomentParams params);

  /// Delete a moment (soft delete)
  Future<Either<Failure, void>> deleteMoment(String id);

  /// Toggle favorite status
  Future<Either<Failure, Moment>> toggleFavorite(String id);

  /// Share moment to world
  Future<Either<Failure, Moment>> shareToWorld(String id, String topic);

  /// Stream of moments (for real-time updates)
  Stream<List<Moment>> watchMoments(String circleId);
}
```

### 2.3 Use Cases

```dart
// domain/usecases/moments/get_moments_usecase.dart

import 'package:dartz/dartz.dart';
import '../../entities/moment.dart';
import '../../repositories/moment_repository.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';

class GetMomentsUseCase implements UseCase<List<Moment>, GetMomentsParams> {
  final MomentRepository repository;

  GetMomentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Moment>>> call(GetMomentsParams params) async {
    return repository.getMoments(
      circleId: params.circleId,
      page: params.page,
      limit: params.limit,
      authorId: params.authorId,
      year: params.year,
      mediaType: params.mediaType,
    );
  }
}

class GetMomentsParams extends Equatable {
  final String circleId;
  final int page;
  final int limit;
  final String? authorId;
  final int? year;
  final MediaType? mediaType;

  const GetMomentsParams({
    required this.circleId,
    this.page = 1,
    this.limit = 20,
    this.authorId,
    this.year,
    this.mediaType,
  });

  @override
  List<Object?> get props => [circleId, page, limit, authorId, year, mediaType];
}
```

---

## 3. Data Layer Design

### 3.1 Data Models (DTOs)

```dart
// data/models/moment_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/moment.dart';

part 'moment_model.g.dart';

@JsonSerializable()
class MomentModel {
  final String id;
  @JsonKey(name: 'circle_id')
  final String circleId;
  final UserModel author;
  final String content;
  @JsonKey(name: 'media_type')
  final String mediaType;
  @JsonKey(name: 'media_urls')
  final List<String> mediaUrls;
  final String timestamp;
  @JsonKey(name: 'context_tags')
  final ContextTagModel? contextTags;
  final String? location;
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @JsonKey(name: 'future_message')
  final String? futureMessage;
  @JsonKey(name: 'is_shared_to_world')
  final bool isSharedToWorld;
  @JsonKey(name: 'world_topic')
  final String? worldTopic;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const MomentModel({
    required this.id,
    required this.circleId,
    required this.author,
    required this.content,
    required this.mediaType,
    required this.mediaUrls,
    required this.timestamp,
    this.contextTags,
    this.location,
    this.isFavorite = false,
    this.futureMessage,
    this.isSharedToWorld = false,
    this.worldTopic,
    required this.createdAt,
    this.updatedAt,
  });

  factory MomentModel.fromJson(Map<String, dynamic> json) =>
      _$MomentModelFromJson(json);

  Map<String, dynamic> toJson() => _$MomentModelToJson(this);

  // Mapper to Domain Entity
  Moment toEntity() => Moment(
        id: id,
        circleId: circleId,
        author: author.toEntity(),
        content: content,
        mediaType: MediaType.values.firstWhere(
          (e) => e.name == mediaType,
          orElse: () => MediaType.text,
        ),
        mediaUrls: mediaUrls,
        timestamp: DateTime.parse(timestamp),
        contextTags: contextTags?.toEntity() ?? const ContextTag(),
        location: location,
        isFavorite: isFavorite,
        futureMessage: futureMessage,
        isSharedToWorld: isSharedToWorld,
        worldTopic: worldTopic,
        createdAt: DateTime.parse(createdAt),
        updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      );

  // Factory from Domain Entity
  factory MomentModel.fromEntity(Moment entity) => MomentModel(
        id: entity.id,
        circleId: entity.circleId,
        author: UserModel.fromEntity(entity.author),
        content: entity.content,
        mediaType: entity.mediaType.name,
        mediaUrls: entity.mediaUrls,
        timestamp: entity.timestamp.toIso8601String(),
        contextTags: ContextTagModel.fromEntity(entity.contextTags),
        location: entity.location,
        isFavorite: entity.isFavorite,
        futureMessage: entity.futureMessage,
        isSharedToWorld: entity.isSharedToWorld,
        worldTopic: entity.worldTopic,
        createdAt: entity.createdAt.toIso8601String(),
        updatedAt: entity.updatedAt?.toIso8601String(),
      );
}
```

### 3.2 Repository Implementation (Offline-First)

```dart
// data/repositories/moment_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/moment.dart';
import '../../domain/repositories/moment_repository.dart';
import '../datasources/local/moment_local_datasource.dart';
import '../datasources/remote/moment_remote_datasource.dart';

class MomentRepositoryImpl implements MomentRepository {
  final MomentRemoteDataSource remoteDataSource;
  final MomentLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  MomentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Moment>>> getMoments({
    required String circleId,
    int page = 1,
    int limit = 20,
    String? authorId,
    int? year,
    MediaType? mediaType,
  }) async {
    // OFFLINE-FIRST: Always try local first
    try {
      final localMoments = await localDataSource.getMoments(
        circleId: circleId,
        page: page,
        limit: limit,
        authorId: authorId,
        year: year,
        mediaType: mediaType,
      );

      // If online, sync in background
      if (await networkInfo.isConnected) {
        _syncMomentsInBackground(circleId);
      }

      return Right(localMoments.map((m) => m.toEntity()).toList());
    } on CacheException {
      // No local data, fetch from remote
      return _fetchFromRemote(circleId, page, limit, authorId, year, mediaType);
    }
  }

  Future<Either<Failure, List<Moment>>> _fetchFromRemote(
    String circleId,
    int page,
    int limit,
    String? authorId,
    int? year,
    MediaType? mediaType,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final remoteMoments = await remoteDataSource.getMoments(
        circleId: circleId,
        page: page,
        limit: limit,
        authorId: authorId,
        year: year,
        mediaType: mediaType?.name,
      );

      // Cache for offline access
      await localDataSource.cacheMoments(remoteMoments);

      return Right(remoteMoments.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  void _syncMomentsInBackground(String circleId) async {
    try {
      final remoteMoments = await remoteDataSource.getMoments(
        circleId: circleId,
        page: 1,
        limit: 100,
      );
      await localDataSource.cacheMoments(remoteMoments);
    } catch (_) {
      // Silent fail for background sync
    }
  }

  @override
  Future<Either<Failure, Moment>> createMoment(CreateMomentParams params) async {
    // Optimistic local creation
    final localMoment = await localDataSource.createPendingMoment(params);

    if (await networkInfo.isConnected) {
      try {
        final remoteMoment = await remoteDataSource.createMoment(params);
        await localDataSource.updateMomentSyncStatus(
          localMoment.id,
          remoteMoment.id,
          SyncStatus.synced,
        );
        return Right(remoteMoment.toEntity());
      } on ServerException catch (e) {
        // Mark as pending sync
        await localDataSource.updateMomentSyncStatus(
          localMoment.id,
          localMoment.id,
          SyncStatus.pendingSync,
        );
        return Right(localMoment.toEntity());
      }
    } else {
      // Queue for later sync
      await localDataSource.queueForSync(localMoment.id);
      return Right(localMoment.toEntity());
    }
  }

  @override
  Stream<List<Moment>> watchMoments(String circleId) {
    return localDataSource.watchMoments(circleId).map(
          (models) => models.map((m) => m.toEntity()).toList(),
        );
  }
}
```

### 3.3 Local Database (Drift)

```dart
// core/storage/database/app_database.dart

import 'package:drift/drift.dart';

part 'app_database.g.dart';

class Moments extends Table {
  TextColumn get id => text()();
  TextColumn get circleId => text().named('circle_id')();
  TextColumn get authorId => text().named('author_id')();
  TextColumn get content => text()();
  TextColumn get mediaType => text().named('media_type')();
  TextColumn get mediaUrls => text().named('media_urls')(); // JSON array
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get contextTags => text().named('context_tags').nullable()(); // JSON
  TextColumn get location => text().nullable()();
  BoolColumn get isFavorite => boolean().named('is_favorite').withDefault(const Constant(false))();
  TextColumn get futureMessage => text().named('future_message').nullable()();
  BoolColumn get isSharedToWorld => boolean().named('is_shared_to_world').withDefault(const Constant(false))();
  TextColumn get worldTopic => text().named('world_topic').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
  IntColumn get syncStatus => integer().named('sync_status').withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get avatar => text()();
  TextColumn get roleLabel => text().named('role_label').nullable()();
  DateTimeColumn get joinedAt => dateTime().named('joined_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();
  TextColumn get action => text()(); // create, update, delete
  TextColumn get payload => text()(); // JSON
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  IntColumn get retryCount => integer().named('retry_count').withDefault(const Constant(0))();
}

@DriftDatabase(tables: [Moments, Users, SyncQueue])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Handle migrations
        },
      );
}
```

---

## 4. Presentation Layer (Riverpod)

### 4.1 State Classes

```dart
// presentation/providers/moments/moments_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/moment.dart';

part 'moments_state.freezed.dart';

@freezed
class MomentsState with _$MomentsState {
  const factory MomentsState({
    @Default([]) List<Moment> moments,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasReachedEnd,
    @Default(1) int currentPage,
    String? errorMessage,
    @Default(SyncStatus.idle) SyncStatus syncStatus,
  }) = _MomentsState;
}

enum SyncStatus { idle, syncing, synced, error }
```

### 4.2 Providers (Riverpod 2.0 Best Practices)

```dart
// presentation/providers/moments/moments_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/moment.dart';
import '../../../domain/usecases/moments/get_moments_usecase.dart';
import '../../../domain/usecases/moments/create_moment_usecase.dart';
import 'moments_state.dart';

part 'moments_provider.g.dart';

@riverpod
class MomentsNotifier extends _$MomentsNotifier {
  late final GetMomentsUseCase _getMomentsUseCase;
  late final CreateMomentUseCase _createMomentUseCase;

  @override
  MomentsState build() {
    _getMomentsUseCase = ref.watch(getMomentsUseCaseProvider);
    _createMomentUseCase = ref.watch(createMomentUseCaseProvider);

    // Initial load
    _loadMoments();

    return const MomentsState(isLoading: true);
  }

  Future<void> _loadMoments({bool refresh = false}) async {
    final circleId = ref.read(currentCircleIdProvider);
    if (circleId == null) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        currentPage: 1,
        hasReachedEnd: false,
      );
    }

    final result = await _getMomentsUseCase(GetMomentsParams(
      circleId: circleId,
      page: state.currentPage,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (moments) => state = state.copyWith(
        isLoading: false,
        moments: refresh ? moments : [...state.moments, ...moments],
        hasReachedEnd: moments.length < 20,
        errorMessage: null,
      ),
    );
  }

  Future<void> refresh() => _loadMoments(refresh: true);

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedEnd) return;

    state = state.copyWith(
      isLoadingMore: true,
      currentPage: state.currentPage + 1,
    );

    await _loadMoments();

    state = state.copyWith(isLoadingMore: false);
  }

  Future<void> createMoment(CreateMomentParams params) async {
    final result = await _createMomentUseCase(params);

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (moment) => state = state.copyWith(
        moments: [moment, ...state.moments],
      ),
    );
  }
}

// Derived providers with selectors (prevents unnecessary rebuilds)
@riverpod
List<Moment> filteredMoments(FilteredMomentsRef ref) {
  final moments = ref.watch(momentsNotifierProvider.select((s) => s.moments));
  final filter = ref.watch(timelineFilterProvider);

  return moments.where((moment) {
    if (filter.authorId != null && moment.author.id != filter.authorId) {
      return false;
    }
    if (filter.year != null && moment.timestamp.year != filter.year) {
      return false;
    }
    if (filter.mediaType != null && moment.mediaType != filter.mediaType) {
      return false;
    }
    return true;
  }).toList();
}

@riverpod
Moment? momentById(MomentByIdRef ref, String id) {
  return ref.watch(momentsNotifierProvider.select(
    (s) => s.moments.firstWhereOrNull((m) => m.id == id),
  ));
}
```

### 4.3 Timeline Filter Provider

```dart
// presentation/providers/moments/timeline_filter_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/moment.dart';

part 'timeline_filter_provider.g.dart';

@freezed
class TimelineFilter with _$TimelineFilter {
  const factory TimelineFilter({
    String? authorId,
    int? year,
    MediaType? mediaType,
  }) = _TimelineFilter;

  const TimelineFilter._();

  bool get hasActiveFilters =>
      authorId != null || year != null || mediaType != null;
}

@riverpod
class TimelineFilterNotifier extends _$TimelineFilterNotifier {
  @override
  TimelineFilter build() => const TimelineFilter();

  void setAuthor(String? authorId) {
    state = state.copyWith(authorId: authorId);
  }

  void setYear(int? year) {
    state = state.copyWith(year: year);
  }

  void setMediaType(MediaType? type) {
    state = state.copyWith(mediaType: type);
  }

  void clearFilters() {
    state = const TimelineFilter();
  }
}
```

---

## 5. UI Component Design (Aura Design System)

### 5.1 Design Tokens

```dart
// core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AuraColors {
  // Brand Colors
  static const primary = Color(0xFFD97706);      // Warm amber
  static const primaryLight = Color(0xFFF59E0B);
  static const primaryDark = Color(0xFFB45309);

  // Background
  static const background = Color(0xFFF8F6F3);   // Warm beige (time beige)
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF3F0EB);

  // Text (Warm Gray Palette)
  static const textPrimary = Color(0xFF1F2937);    // warmGray-800
  static const textSecondary = Color(0xFF6B7280);  // warmGray-500
  static const textTertiary = Color(0xFF9CA3AF);   // warmGray-400
  static const textDisabled = Color(0xFFD1D5DB);   // warmGray-300

  // Emotion Colors
  static const calmBlue = Color(0xFF64748B);
  static const warmPeach = Color(0xFFFDBA74);
  static const softGreen = Color(0xFF86EFAC);
  static const mutedViolet = Color(0xFFC4B5FD);

  // Semantic
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Dark Theme
  static const darkBackground = Color(0xFF0F0F0F);  // True black for OLED
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkSurfaceVariant = Color(0xFF262626);
}
```

```dart
// core/theme/app_spacing.dart

class AuraSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Page layout
  static const double pagePadding = 20;
  static const double cardPadding = 20;
  static const double sectionGap = 32;

  // Touch targets (Minimum 48px for Android, 44pt for iOS)
  static const double minTouchTarget = 48;
  static const double touchTargetSpacing = 8;
}
```

```dart
// core/theme/app_typography.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuraTypography {
  // Serif for titles (calm, emotional)
  static TextStyle _serifStyle([TextStyle? style]) =>
      GoogleFonts.notoSerifSc(textStyle: style);

  // Sans for body (readable)
  static TextStyle _sansStyle([TextStyle? style]) =>
      GoogleFonts.notoSansSc(textStyle: style);

  // Headlines
  static TextStyle displayLarge = _serifStyle(const TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
    height: 1.2,
  ));

  static TextStyle displayMedium = _serifStyle(const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.25,
  ));

  static TextStyle titleLarge = _serifStyle(const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.3,
  ));

  static TextStyle titleMedium = _sansStyle(const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  ));

  // Body
  static TextStyle bodyLarge = _sansStyle(const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  ));

  static TextStyle bodyMedium = _sansStyle(const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ));

  // Caption
  static TextStyle caption = _sansStyle(const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: Color(0xFF9CA3AF),
  ));

  static TextStyle label = _sansStyle(const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ));
}
```

```dart
// core/theme/app_animations.dart

class AuraDurations {
  static const instant = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 350);
  static const page = Duration(milliseconds: 400);
  static const breathing = Duration(milliseconds: 2000);
}

class AuraCurves {
  static const standard = Curves.easeOutCubic;
  static const gentle = Curves.easeInOutCubic;
  static const bounce = Curves.elasticOut;
  static const breathing = Curves.easeInOut;
}
```

### 5.2 Core Components

```dart
// presentation/shared/aura/buttons/aura_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

enum AuraButtonVariant { primary, secondary, ghost, danger }
enum AuraButtonSize { small, medium, large }

class AuraButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AuraButtonVariant variant;
  final AuraButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AuraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AuraButtonVariant.primary,
    this.size = AuraButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: _getHeight(),
      child: AnimatedContainer(
        duration: AuraDurations.fast,
        child: Material(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(_getBorderRadius()),
          child: InkWell(
            onTap: onPressed != null && !isLoading
                ? () {
                    // Haptic feedback
                    HapticFeedback.lightImpact();
                    onPressed!();
                  }
                : null,
            borderRadius: BorderRadius.circular(_getBorderRadius()),
            child: Padding(
              padding: _getPadding(),
              child: Row(
                mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(_getTextColor(context)),
                      ),
                    )
                  else ...[
                    if (icon != null) ...[
                      Icon(icon, size: _getIconSize(), color: _getTextColor(context)),
                      const SizedBox(width: AuraSpacing.sm),
                    ],
                    Text(
                      label,
                      style: _getTextStyle(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (size) {
      case AuraButtonSize.small:
        return 36;
      case AuraButtonSize.medium:
        return 48; // Min touch target
      case AuraButtonSize.large:
        return 56;
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case AuraButtonSize.small:
        return 8;
      case AuraButtonSize.medium:
        return 12;
      case AuraButtonSize.large:
        return 16;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AuraButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AuraButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case AuraButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AuraButtonSize.small:
        return 16;
      case AuraButtonSize.medium:
        return 20;
      case AuraButtonSize.large:
        return 24;
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    if (onPressed == null) return AuraColors.textDisabled;

    switch (variant) {
      case AuraButtonVariant.primary:
        return AuraColors.primary;
      case AuraButtonVariant.secondary:
        return AuraColors.surfaceVariant;
      case AuraButtonVariant.ghost:
        return Colors.transparent;
      case AuraButtonVariant.danger:
        return AuraColors.error;
    }
  }

  Color _getTextColor(BuildContext context) {
    if (onPressed == null) return AuraColors.textTertiary;

    switch (variant) {
      case AuraButtonVariant.primary:
      case AuraButtonVariant.danger:
        return Colors.white;
      case AuraButtonVariant.secondary:
      case AuraButtonVariant.ghost:
        return AuraColors.textPrimary;
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    return AuraTypography.label.copyWith(
      color: _getTextColor(context),
      fontSize: size == AuraButtonSize.small ? 13 : 15,
    );
  }
}
```

### 5.3 List Item Component (Performance Optimized)

```dart
// features/timeline/widgets/feed_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FeedCard extends StatelessWidget {
  final Moment moment;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const FeedCard({
    super.key,
    required this.moment,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AuraSpacing.pagePadding,
          vertical: AuraSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AuraColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            // Content
            if (moment.content.isNotEmpty) _buildContent(),

            // Media
            if (moment.mediaUrls.isNotEmpty) _buildMedia(),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AuraSpacing.base),
      child: Row(
        children: [
          // Avatar (const to prevent rebuilds)
          const AuraAvatar(
            url: moment.author.avatar,
            size: 40,
          ),
          const SizedBox(width: AuraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moment.author.name,
                  style: AuraTypography.label,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(moment.timestamp),
                  style: AuraTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.base),
      child: Text(
        moment.content,
        style: AuraTypography.bodyMedium,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMedia() {
    final urls = moment.mediaUrls;
    final count = urls.length;

    return Padding(
      padding: const EdgeInsets.all(AuraSpacing.base),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: count == 1
            ? _buildSingleImage(urls.first)
            : _buildImageGrid(urls),
      ),
    );
  }

  Widget _buildSingleImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      height: 200,
      width: double.infinity,
      memCacheWidth: 600, // Cache at reasonable resolution
      placeholder: (_, __) => const AuraSkeleton(height: 200),
      errorWidget: (_, __, ___) => const Icon(Icons.error),
    );
  }

  Widget _buildImageGrid(List<String> urls) {
    // Grid layout based on image count
    return GridView.count(
      crossAxisCount: urls.length == 2 ? 2 : 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: urls.take(9).map((url) {
        return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          memCacheWidth: 300,
          placeholder: (_, __) => const AuraSkeleton(),
          errorWidget: (_, __, ___) => const Icon(Icons.error),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(AuraSpacing.base),
      child: Row(
        children: [
          // Context tags
          if (moment.contextTags.myMood != null)
            AuraTag(label: moment.contextTags.myMood!),

          const Spacer(),

          // Actions
          _ActionButton(
            icon: Icons.favorite_border,
            isActive: moment.isFavorite,
            activeIcon: Icons.favorite,
            onTap: () {},
          ),
          const SizedBox(width: AuraSpacing.md),
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays == 0) {
      return '今天 ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${timestamp.month}月${timestamp.day}日';
    }
  }
}

// Extracted action button for reuse
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    this.activeIcon,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: SizedBox(
        width: 44, // Min touch target
        height: 44,
        child: Center(
          child: Icon(
            isActive ? (activeIcon ?? icon) : icon,
            size: 22,
            color: isActive ? AuraColors.primary : AuraColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
```

---

## 6. Performance Optimization

### 6.1 ListView Optimization

```dart
// features/timeline/views/timeline_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimelineView extends ConsumerWidget {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use selectors to minimize rebuilds
    final isLoading = ref.watch(
      momentsNotifierProvider.select((s) => s.isLoading),
    );
    final moments = ref.watch(filteredMomentsProvider);
    final hasReachedEnd = ref.watch(
      momentsNotifierProvider.select((s) => s.hasReachedEnd),
    );

    if (isLoading && moments.isEmpty) {
      return const _TimelineSkeleton();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(momentsNotifierProvider.notifier).refresh(),
      child: ListView.builder(
        // PERFORMANCE: Always use ListView.builder, never ListView(children: [])
        itemCount: moments.length + (hasReachedEnd ? 0 : 1),
        // PERFORMANCE: Provide item extent for fixed-height items
        // If variable height, remove this line
        // itemExtent: 300,
        // PERFORMANCE: Cache extent for smoother scrolling
        cacheExtent: 500,
        itemBuilder: (context, index) {
          // Load more trigger
          if (index == moments.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(momentsNotifierProvider.notifier).loadMore();
            });
            return const _LoadingIndicator();
          }

          final moment = moments[index];
          // PERFORMANCE: Use key for efficient updates
          return FeedCard(
            key: ValueKey(moment.id),
            moment: moment,
            onTap: () => context.push('/moment/${moment.id}'),
            onLongPress: () => _showOptions(context, moment),
          );
        },
      ),
    );
  }
}

// PERFORMANCE: const skeleton for loading state
class _TimelineSkeleton extends StatelessWidget {
  const _TimelineSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AuraSpacing.pagePadding,
          vertical: AuraSpacing.sm,
        ),
        child: AuraSkeleton(height: 200, borderRadius: 16),
      ),
    );
  }
}
```

### 6.2 Image Caching Strategy

```dart
// core/utils/image_utils.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AuraImageCacheManager {
  static const key = 'aura_image_cache';

  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  static Widget cachedImage({
    required String url,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // Calculate cache dimensions (2x for retina)
    final cacheWidth = width != null ? (width * 2).toInt() : null;
    final cacheHeight = height != null ? (height * 2).toInt() : null;

    return CachedNetworkImage(
      imageUrl: url,
      cacheManager: instance,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: (_, __) =>
          placeholder ?? const AuraSkeleton(),
      errorWidget: (_, __, ___) =>
          errorWidget ?? const Icon(Icons.broken_image),
      fadeInDuration: AuraDurations.fast,
    );
  }
}
```

### 6.3 Animation Best Practices

```dart
// presentation/shared/widgets/animated_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedListItem extends StatelessWidget {
  final int index;
  final Widget child;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // PERFORMANCE: Only animate visible items
    // Stagger delay for list entrance
    return child
        .animate(
          delay: Duration(milliseconds: 50 * (index.clamp(0, 10))),
        )
        // PERFORMANCE: Only animate transform and opacity (GPU-accelerated)
        .fadeIn(duration: AuraDurations.normal, curve: AuraCurves.standard)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: AuraDurations.normal,
          curve: AuraCurves.standard,
        );
  }
}
```

---

## 7. Backend Architecture (Cloudflare Workers)

### 7.1 API Structure

```typescript
// backend/src/index.ts

import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import { jwt } from 'hono/jwt'
import { authRoutes } from './routes/auth'
import { circleRoutes } from './routes/circles'
import { momentRoutes } from './routes/moments'
import { letterRoutes } from './routes/letters'
import { worldRoutes } from './routes/world'
import { mediaRoutes } from './routes/media'
import { syncRoutes } from './routes/sync'

type Bindings = {
  DB: D1Database
  R2: R2Bucket
  JWT_SECRET: string
  ENCRYPTION_KEY: string
}

const app = new Hono<{ Bindings: Bindings }>()

// Middleware
app.use('*', logger())
app.use('*', cors({
  origin: '*',
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowHeaders: ['Content-Type', 'Authorization'],
}))

// Public routes
app.route('/api/v1/auth', authRoutes)

// Protected routes
app.use('/api/v1/*', jwt({ secret: (c) => c.env.JWT_SECRET }))
app.route('/api/v1/circles', circleRoutes)
app.route('/api/v1/moments', momentRoutes)
app.route('/api/v1/letters', letterRoutes)
app.route('/api/v1/world', worldRoutes)
app.route('/api/v1/media', mediaRoutes)
app.route('/api/v1/sync', syncRoutes)

// Health check
app.get('/health', (c) => c.json({ status: 'ok', timestamp: Date.now() }))

export default app
```

### 7.2 Database Schema (D1)

```sql
-- backend/migrations/001_initial.sql

-- Users
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  avatar TEXT DEFAULT '',
  role_label TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Circles (Family Groups)
CREATE TABLE circles (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  invite_code TEXT UNIQUE NOT NULL,
  start_date DATETIME,
  created_by TEXT REFERENCES users(id),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Circle Members
CREATE TABLE circle_members (
  id TEXT PRIMARY KEY,
  circle_id TEXT REFERENCES circles(id) ON DELETE CASCADE,
  user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'member',
  joined_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(circle_id, user_id)
);

-- Moments
CREATE TABLE moments (
  id TEXT PRIMARY KEY,
  circle_id TEXT REFERENCES circles(id) ON DELETE CASCADE,
  author_id TEXT REFERENCES users(id),
  content TEXT NOT NULL,
  media_type TEXT DEFAULT 'text',
  media_urls TEXT DEFAULT '[]',  -- JSON array
  timestamp DATETIME NOT NULL,
  context_tags TEXT DEFAULT '{}', -- JSON object
  location TEXT,
  is_favorite INTEGER DEFAULT 0,
  future_message TEXT,
  is_shared_to_world INTEGER DEFAULT 0,
  world_topic TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME
);

-- Letters (Time Capsules)
CREATE TABLE letters (
  id TEXT PRIMARY KEY,
  circle_id TEXT REFERENCES circles(id) ON DELETE CASCADE,
  author_id TEXT REFERENCES users(id),
  title TEXT NOT NULL,
  content_encrypted TEXT NOT NULL, -- AES-256 encrypted
  preview TEXT,
  status TEXT DEFAULT 'draft',
  unlock_date DATETIME,
  recipient TEXT,
  letter_type TEXT DEFAULT 'free',
  encryption_key_hash TEXT, -- For verification
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- World Posts (Anonymous Sharing)
CREATE TABLE world_posts (
  id TEXT PRIMARY KEY,
  moment_id TEXT REFERENCES moments(id),
  content TEXT NOT NULL,
  tag TEXT NOT NULL,
  bg_gradient TEXT DEFAULT 'default',
  resonance_count INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Comments
CREATE TABLE comments (
  id TEXT PRIMARY KEY,
  target_id TEXT NOT NULL,
  target_type TEXT NOT NULL, -- 'moment' or 'world_post'
  author_id TEXT REFERENCES users(id),
  content TEXT NOT NULL,
  reply_to_id TEXT REFERENCES comments(id),
  likes INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Resonances (World Post Likes)
CREATE TABLE resonances (
  id TEXT PRIMARY KEY,
  post_id TEXT REFERENCES world_posts(id) ON DELETE CASCADE,
  user_id TEXT REFERENCES users(id),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(post_id, user_id)
);

-- Sync Queue (for offline-first)
CREATE TABLE sync_log (
  id TEXT PRIMARY KEY,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  action TEXT NOT NULL,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  circle_id TEXT REFERENCES circles(id)
);

-- Indexes
CREATE INDEX idx_moments_circle ON moments(circle_id);
CREATE INDEX idx_moments_timestamp ON moments(timestamp DESC);
CREATE INDEX idx_moments_author ON moments(author_id);
CREATE INDEX idx_letters_circle ON letters(circle_id);
CREATE INDEX idx_letters_status ON letters(status);
CREATE INDEX idx_comments_target ON comments(target_id, target_type);
CREATE INDEX idx_world_posts_tag ON world_posts(tag);
CREATE INDEX idx_sync_log_circle ON sync_log(circle_id, timestamp DESC);
```

### 7.3 Moment Routes Implementation

```typescript
// backend/src/routes/moments.ts

import { Hono } from 'hono'
import { nanoid } from 'nanoid'
import type { Bindings } from '../types'

const moments = new Hono<{ Bindings: Bindings }>()

// GET /api/v1/moments - List moments
moments.get('/', async (c) => {
  const userId = c.get('jwtPayload').sub
  const { circle_id, page = '1', limit = '20', author_id, year, media_type } = c.req.query()

  // Validate circle membership
  const membership = await c.env.DB
    .prepare('SELECT * FROM circle_members WHERE circle_id = ? AND user_id = ?')
    .bind(circle_id, userId)
    .first()

  if (!membership) {
    return c.json({ error: 'Not a member of this circle' }, 403)
  }

  // Build query
  let query = `
    SELECT m.*, u.id as author_id, u.name as author_name, u.avatar as author_avatar
    FROM moments m
    JOIN users u ON m.author_id = u.id
    WHERE m.circle_id = ? AND m.deleted_at IS NULL
  `
  const params: any[] = [circle_id]

  if (author_id) {
    query += ' AND m.author_id = ?'
    params.push(author_id)
  }

  if (year) {
    query += ' AND strftime("%Y", m.timestamp) = ?'
    params.push(year)
  }

  if (media_type) {
    query += ' AND m.media_type = ?'
    params.push(media_type)
  }

  query += ' ORDER BY m.timestamp DESC LIMIT ? OFFSET ?'
  const pageNum = parseInt(page)
  const limitNum = parseInt(limit)
  params.push(limitNum, (pageNum - 1) * limitNum)

  const results = await c.env.DB
    .prepare(query)
    .bind(...params)
    .all()

  const moments = results.results.map(row => ({
    id: row.id,
    circle_id: row.circle_id,
    content: row.content,
    media_type: row.media_type,
    media_urls: JSON.parse(row.media_urls as string || '[]'),
    timestamp: row.timestamp,
    context_tags: JSON.parse(row.context_tags as string || '{}'),
    location: row.location,
    is_favorite: Boolean(row.is_favorite),
    future_message: row.future_message,
    is_shared_to_world: Boolean(row.is_shared_to_world),
    world_topic: row.world_topic,
    created_at: row.created_at,
    updated_at: row.updated_at,
    author: {
      id: row.author_id,
      name: row.author_name,
      avatar: row.author_avatar,
    },
  }))

  return c.json({
    data: moments,
    meta: {
      page: pageNum,
      limit: limitNum,
      total: results.results.length,
    },
  })
})

// POST /api/v1/moments - Create moment
moments.post('/', async (c) => {
  const userId = c.get('jwtPayload').sub
  const body = await c.req.json()

  const {
    circle_id,
    content,
    media_type = 'text',
    media_urls = [],
    timestamp,
    context_tags = {},
    location,
    future_message,
  } = body

  // Validate circle membership
  const membership = await c.env.DB
    .prepare('SELECT * FROM circle_members WHERE circle_id = ? AND user_id = ?')
    .bind(circle_id, userId)
    .first()

  if (!membership) {
    return c.json({ error: 'Not a member of this circle' }, 403)
  }

  const id = nanoid()
  const now = new Date().toISOString()

  await c.env.DB
    .prepare(`
      INSERT INTO moments (
        id, circle_id, author_id, content, media_type, media_urls,
        timestamp, context_tags, location, future_message, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `)
    .bind(
      id,
      circle_id,
      userId,
      content,
      media_type,
      JSON.stringify(media_urls),
      timestamp || now,
      JSON.stringify(context_tags),
      location,
      future_message,
      now,
      now
    )
    .run()

  // Log for sync
  await c.env.DB
    .prepare('INSERT INTO sync_log (id, entity_type, entity_id, action, circle_id) VALUES (?, ?, ?, ?, ?)')
    .bind(nanoid(), 'moment', id, 'create', circle_id)
    .run()

  // Fetch created moment with author
  const moment = await c.env.DB
    .prepare(`
      SELECT m.*, u.name as author_name, u.avatar as author_avatar
      FROM moments m
      JOIN users u ON m.author_id = u.id
      WHERE m.id = ?
    `)
    .bind(id)
    .first()

  return c.json({
    data: {
      ...moment,
      media_urls: JSON.parse(moment!.media_urls as string),
      context_tags: JSON.parse(moment!.context_tags as string),
      is_favorite: Boolean(moment!.is_favorite),
      is_shared_to_world: Boolean(moment!.is_shared_to_world),
      author: {
        id: userId,
        name: moment!.author_name,
        avatar: moment!.author_avatar,
      },
    },
  }, 201)
})

// PUT /api/v1/moments/:id/favorite - Toggle favorite
moments.put('/:id/favorite', async (c) => {
  const userId = c.get('jwtPayload').sub
  const id = c.req.param('id')

  const moment = await c.env.DB
    .prepare('SELECT * FROM moments WHERE id = ?')
    .bind(id)
    .first()

  if (!moment) {
    return c.json({ error: 'Moment not found' }, 404)
  }

  const newFavorite = moment.is_favorite ? 0 : 1
  const now = new Date().toISOString()

  await c.env.DB
    .prepare('UPDATE moments SET is_favorite = ?, updated_at = ? WHERE id = ?')
    .bind(newFavorite, now, id)
    .run()

  return c.json({
    data: { is_favorite: Boolean(newFavorite) },
  })
})

// DELETE /api/v1/moments/:id - Soft delete
moments.delete('/:id', async (c) => {
  const userId = c.get('jwtPayload').sub
  const id = c.req.param('id')

  const moment = await c.env.DB
    .prepare('SELECT * FROM moments WHERE id = ?')
    .bind(id)
    .first()

  if (!moment) {
    return c.json({ error: 'Moment not found' }, 404)
  }

  if (moment.author_id !== userId) {
    return c.json({ error: 'Not authorized' }, 403)
  }

  const now = new Date().toISOString()

  await c.env.DB
    .prepare('UPDATE moments SET deleted_at = ? WHERE id = ?')
    .bind(now, id)
    .run()

  // Log for sync
  await c.env.DB
    .prepare('INSERT INTO sync_log (id, entity_type, entity_id, action, circle_id) VALUES (?, ?, ?, ?, ?)')
    .bind(nanoid(), 'moment', id, 'delete', moment.circle_id)
    .run()

  return c.json({ success: true })
})

export { moments as momentRoutes }
```

---

## 8. Testing Strategy

### 8.1 Unit Tests

```dart
// test/domain/usecases/get_moments_usecase_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([MomentRepository])
void main() {
  late GetMomentsUseCase useCase;
  late MockMomentRepository mockRepository;

  setUp(() {
    mockRepository = MockMomentRepository();
    useCase = GetMomentsUseCase(mockRepository);
  });

  final tMoments = [
    Moment(
      id: '1',
      circleId: 'circle-1',
      author: const User(id: 'user-1', name: 'Test', avatar: ''),
      content: 'Test content',
      mediaType: MediaType.text,
      mediaUrls: [],
      timestamp: DateTime.now(),
      contextTags: const ContextTag(),
      createdAt: DateTime.now(),
    ),
  ];

  test('should get moments from repository', () async {
    // Arrange
    when(mockRepository.getMoments(
      circleId: anyNamed('circleId'),
      page: anyNamed('page'),
      limit: anyNamed('limit'),
    )).thenAnswer((_) async => Right(tMoments));

    // Act
    final result = await useCase(
      const GetMomentsParams(circleId: 'circle-1'),
    );

    // Assert
    expect(result, Right(tMoments));
    verify(mockRepository.getMoments(
      circleId: 'circle-1',
      page: 1,
      limit: 20,
    ));
  });

  test('should return failure when repository fails', () async {
    // Arrange
    when(mockRepository.getMoments(
      circleId: anyNamed('circleId'),
      page: anyNamed('page'),
      limit: anyNamed('limit'),
    )).thenAnswer((_) async => Left(ServerFailure('Error')));

    // Act
    final result = await useCase(
      const GetMomentsParams(circleId: 'circle-1'),
    );

    // Assert
    expect(result, Left(ServerFailure('Error')));
  });
}
```

### 8.2 Widget Tests

```dart
// test/presentation/features/timeline/widgets/feed_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tMoment = Moment(
    id: '1',
    circleId: 'circle-1',
    author: const User(id: 'user-1', name: 'Test User', avatar: ''),
    content: 'Test moment content',
    mediaType: MediaType.text,
    mediaUrls: [],
    timestamp: DateTime.now(),
    contextTags: const ContextTag(myMood: 'Happy'),
    createdAt: DateTime.now(),
  );

  testWidgets('FeedCard displays moment content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedCard(
            moment: tMoment,
            onTap: () {},
            onLongPress: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test moment content'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('Happy'), findsOneWidget);
  });

  testWidgets('FeedCard triggers onTap callback', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedCard(
            moment: tMoment,
            onTap: () => tapped = true,
            onLongPress: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FeedCard));
    expect(tapped, true);
  });
}
```

### 8.3 Integration Tests

```dart
// integration_test/timeline_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Timeline Flow', () {
    testWidgets('User can view and create moments', (tester) async {
      // Launch app
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // Navigate to timeline
      await tester.tap(find.byIcon(Icons.timeline));
      await tester.pumpAndSettle();

      // Verify timeline loaded
      expect(find.byType(FeedCard), findsWidgets);

      // Create new moment
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter content
      await tester.enterText(
        find.byType(TextField),
        'Integration test moment',
      );

      // Submit
      await tester.tap(find.text('发布'));
      await tester.pumpAndSettle();

      // Verify moment created
      expect(find.text('Integration test moment'), findsOneWidget);
    });
  });
}
```

---

## 9. Summary

### Key Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Architecture** | Clean Architecture + Feature-First | Separation of concerns, testability, scalability |
| **State Management** | Riverpod 2.0 | Type-safe, code generation, excellent selectors |
| **Navigation** | GoRouter | Declarative, deep linking, guards |
| **Local Database** | Drift | Type-safe SQL, reactive queries, migrations |
| **HTTP Client** | Dio | Interceptors, error handling, cancellation |
| **Backend** | Cloudflare Workers + D1 | Edge computing, global, cost-effective |
| **Offline Strategy** | Offline-First | Core UX requirement for memory app |

### Performance Targets

| Metric | Target |
|--------|--------|
| Cold Start | < 2s |
| Timeline Scroll | 60fps |
| Image Load | < 1s (cached) |
| API Response | < 300ms |
| Memory Usage | < 200MB |

### Next Steps

1. **Phase 1: Core Infrastructure** (Week 1-2)
   - Set up project structure
   - Implement core layer (network, storage, theme)
   - Set up Drift database

2. **Phase 2: Domain & Data** (Week 2-3)
   - Define entities and value objects
   - Implement repositories
   - Implement use cases

3. **Phase 3: Presentation** (Week 3-4)
   - Implement Riverpod providers
   - Build Aura Design System components
   - Implement feature views

4. **Phase 4: Backend** (Week 4-5)
   - Migrate to Hono framework
   - Implement D1 database
   - Add R2 media storage

5. **Phase 5: Testing & Polish** (Week 5-6)
   - Unit and widget tests
   - Integration tests
   - Performance optimization
