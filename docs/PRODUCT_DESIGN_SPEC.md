# Aura 拾光 · 产品设计升级方案

> 基于现有设计系统和架构，全面提升产品体验
> 版本: 2.0 | 更新: 2026-02

---

## 目录

1. [产品愿景与定位](#一产品愿景与定位)
2. [前端架构设计](#二前端架构设计)
3. [后端架构设计](#三后端架构设计)
4. [性能优化策略](#四性能优化策略)
5. [动画系统增强](#五动画系统增强)
6. [交互设计规范](#六交互设计规范)
7. [实施路线图](#七实施路线图)

---

## 一、产品愿景与定位

### 1.1 核心理念深化

```
┌─────────────────────────────────────────────────────────────────┐
│                        Aura 拾光                                │
│                                                                 │
│   "时间会流逝，记忆会模糊，但在这里，每一刻都被温柔地保存"      │
│                                                                 │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐                 │
│   │   记录   │ →  │   封存   │ →  │   重温   │                 │
│   │  Capture │    │   Seal   │    │  Relive  │                 │
│   └──────────┘    └──────────┘    └──────────┘                 │
│                                                                 │
│   温柔 · 安静 · 克制 · 仪式感                                   │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 产品气质矩阵

| 维度 | 现有设计 | 升级方向 |
|------|---------|---------|
| 视觉 | 温暖低饱和 | + 光影层次 + 纸质质感 |
| 交互 | 克制缓慢 | + 手势丰富 + 触觉反馈 |
| 动效 | 柔和渐显 | + 物理动效 + 情绪呼应 |
| 声音 | 无 | + 环境音 + 微交互音效 |
| 触觉 | 基础震动 | + 精细触觉反馈 |

### 1.3 用户旅程优化

```
┌─────────────────────────────────────────────────────────────────────┐
│                         用户情感旅程                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  启动 ───→ 首页 ───→ 浏览 ───→ 记录 ───→ 回顾                      │
│   │         │         │         │         │                         │
│   ↓         ↓         ↓         ↓         ↓                         │
│  宁静     触动      沉浸     仪式感    感动                          │
│                                                                     │
│  [情绪曲线]                                                         │
│                                 ╭─╮                                 │
│                              ╭──╯ ╰──╮                              │
│                           ╭──╯       ╰───╮                          │
│  ──────╭───────────────────╯              ╰────────────────         │
│        启动              浏览           记录完成                     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 二、前端架构设计

### 2.1 架构总览

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Aura Flutter Architecture                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    PRESENTATION LAYER                        │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐    │   │
│  │  │   Screens   │ │   Widgets   │ │  Animation Layer    │    │   │
│  │  │  (Feature)  │ │   (Aura)    │ │  (flutter_animate)  │    │   │
│  │  └──────┬──────┘ └──────┬──────┘ └──────────┬──────────┘    │   │
│  │         └───────────────┼───────────────────┘               │   │
│  │                         ▼                                    │   │
│  │  ┌─────────────────────────────────────────────────────┐    │   │
│  │  │              STATE LAYER (Riverpod 2.0)             │    │   │
│  │  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────────┐   │    │   │
│  │  │  │ Auth   │ │ Moment │ │ Letter │ │ Sync State │   │    │   │
│  │  │  │Provider│ │Provider│ │Provider│ │  Provider  │   │    │   │
│  │  │  └────────┘ └────────┘ └────────┘ └────────────┘   │    │   │
│  │  └─────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                ▼                                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                     DOMAIN LAYER                             │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────────────┐     │   │
│  │  │  Entities  │  │  Use Cases │  │ Repository Contracts│     │   │
│  │  │(Pure Dart) │  │ (Business) │  │    (Interfaces)    │     │   │
│  │  └────────────┘  └────────────┘  └────────────────────┘     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                ▼                                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                      DATA LAYER                              │   │
│  │  ┌───────────────────────────────────────────────────────┐  │   │
│  │  │                    Repository Impl                     │  │   │
│  │  │        (Offline-First with Background Sync)            │  │   │
│  │  └───────────────────────────────────────────────────────┘  │   │
│  │         ▼                                      ▼             │   │
│  │  ┌──────────────┐                      ┌──────────────┐     │   │
│  │  │ Local Source │ ←── Sync Queue ───→  │Remote Source │     │   │
│  │  │   (Drift)    │                      │    (Dio)     │     │   │
│  │  └──────────────┘                      └──────────────┘     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                ▼                                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                   INFRASTRUCTURE                             │   │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐    │   │
│  │  │ Drift  │ │  Dio   │ │Keychain│ │ R2 CDN │ │Platform│    │   │
│  │  │Database│ │ Client │ │Storage │ │  Cache │ │Services│    │   │
│  │  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 目录结构优化

```
lib/
├── main.dart
├── app.dart
│
├── core/                           # 核心基础设施
│   ├── config/
│   │   ├── app_config.dart         # 环境配置
│   │   ├── api_config.dart         # API 端点
│   │   └── feature_flags.dart      # 功能开关 [NEW]
│   │
│   ├── di/                         # 依赖注入 [NEW]
│   │   ├── injection.dart          # 主入口
│   │   ├── providers.dart          # Provider 注册
│   │   └── modules/
│   │       ├── database_module.dart
│   │       ├── network_module.dart
│   │       └── service_module.dart
│   │
│   ├── errors/
│   │   ├── failures.dart           # 领域失败
│   │   ├── exceptions.dart         # 数据层异常
│   │   └── error_handler.dart      # 全局错误处理
│   │
│   ├── network/
│   │   ├── api_client.dart         # Dio 封装
│   │   ├── interceptors/           # [NEW] 拦截器分离
│   │   │   ├── auth_interceptor.dart
│   │   │   ├── retry_interceptor.dart
│   │   │   ├── cache_interceptor.dart
│   │   │   └── logging_interceptor.dart
│   │   └── network_info.dart
│   │
│   ├── storage/
│   │   ├── database/
│   │   │   ├── app_database.dart
│   │   │   ├── daos/
│   │   │   │   ├── moment_dao.dart
│   │   │   │   ├── letter_dao.dart
│   │   │   │   └── sync_dao.dart
│   │   │   └── migrations/         # [NEW]
│   │   │       └── migration_strategy.dart
│   │   ├── cache/                  # [NEW] 缓存层
│   │   │   ├── cache_manager.dart
│   │   │   ├── image_cache.dart
│   │   │   └── response_cache.dart
│   │   └── secure_storage.dart
│   │
│   ├── sync/                       # [NEW] 同步引擎
│   │   ├── sync_engine.dart        # 同步核心
│   │   ├── sync_queue.dart         # 同步队列
│   │   ├── conflict_resolver.dart  # 冲突解决
│   │   └── sync_status.dart        # 同步状态
│   │
│   ├── theme/                      # 设计系统
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── app_spacing.dart
│   │   ├── app_shadows.dart        # [NEW]
│   │   └── app_gradients.dart      # [NEW]
│   │
│   ├── animations/                 # [NEW] 动画系统
│   │   ├── animation_config.dart   # 动画配置
│   │   ├── page_transitions.dart   # 页面转场
│   │   ├── entrance_animations.dart# 入场动画
│   │   ├── micro_interactions.dart # 微交互
│   │   └── physics/
│   │       ├── spring_config.dart
│   │       └── gesture_physics.dart
│   │
│   ├── haptics/                    # [NEW] 触觉反馈
│   │   ├── haptic_service.dart
│   │   └── haptic_patterns.dart
│   │
│   └── router/
│       ├── app_router.dart
│       ├── routes.dart
│       ├── route_guards.dart
│       └── transitions.dart        # [NEW] 自定义转场
│
├── domain/                         # 领域层 (纯 Dart)
│   ├── entities/
│   │   ├── user.dart
│   │   ├── circle.dart
│   │   ├── moment.dart
│   │   ├── letter.dart
│   │   ├── comment.dart
│   │   └── world_post.dart
│   │
│   ├── repositories/               # 仓库接口
│   │   ├── auth_repository.dart
│   │   ├── moment_repository.dart
│   │   ├── letter_repository.dart
│   │   └── sync_repository.dart    # [NEW]
│   │
│   ├── usecases/
│   │   ├── auth/
│   │   ├── moments/
│   │   ├── letters/
│   │   └── sync/                   # [NEW]
│   │       └── sync_all_usecase.dart
│   │
│   └── value_objects/              # [NEW] 值对象
│       ├── email.dart
│       ├── password.dart
│       └── age_display.dart        # 年龄显示逻辑
│
├── data/                           # 数据层
│   ├── models/
│   ├── datasources/
│   │   ├── remote/
│   │   └── local/
│   └── repositories/
│
├── presentation/
│   ├── providers/                  # Riverpod 状态
│   │   ├── core/
│   │   │   ├── app_state_provider.dart
│   │   │   └── connectivity_provider.dart
│   │   ├── auth/
│   │   ├── moments/
│   │   ├── letters/
│   │   └── sync/                   # [NEW]
│   │
│   └── shared/
│       ├── aura/                   # Aura 设计组件库
│       │   ├── aura.dart           # Barrel export
│       │   ├── primitives/         # [NEW] 原子组件
│       │   │   ├── aura_text.dart
│       │   │   ├── aura_icon.dart
│       │   │   └── aura_gesture_detector.dart
│       │   ├── buttons/
│       │   ├── cards/
│       │   ├── inputs/
│       │   ├── feedback/
│       │   │   ├── aura_toast.dart
│       │   │   ├── aura_dialog.dart
│       │   │   ├── aura_skeleton.dart
│       │   │   ├── aura_shimmer.dart    # [NEW]
│       │   │   └── aura_haptic_button.dart # [NEW]
│       │   ├── layout/
│       │   └── animations/         # [NEW] 动画组件
│       │       ├── aura_fade_in.dart
│       │       ├── aura_slide_up.dart
│       │       ├── aura_stagger_list.dart
│       │       └── aura_breathing.dart
│       │
│       └── widgets/
│
└── features/                       # 功能模块
    ├── splash/
    │   └── views/
    │       └── splash_view.dart    # [ENHANCED] 启动动画
    ├── home/
    ├── timeline/
    ├── letters/
    ├── world/
    ├── create/
    └── settings/
```

### 2.3 状态管理最佳实践

```dart
// presentation/providers/moments/moments_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'moments_provider.g.dart';

/// Moments 状态
@freezed
class MomentsState with _$MomentsState {
  const factory MomentsState({
    @Default([]) List<Moment> moments,
    @Default(ViewStatus.initial) ViewStatus status,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasReachedEnd,
    @Default(1) int currentPage,
    String? errorMessage,
    @Default(SyncStatus.idle) SyncStatus syncStatus,
  }) = _MomentsState;
}

enum ViewStatus { initial, loading, success, error }

/// Moments Notifier - 使用 Riverpod 2.0 代码生成
@riverpod
class MomentsNotifier extends _$MomentsNotifier {
  late final GetMomentsUseCase _getMomentsUseCase;
  late final CreateMomentUseCase _createMomentUseCase;
  late final SyncEngine _syncEngine;

  @override
  MomentsState build() {
    // 依赖注入
    _getMomentsUseCase = ref.watch(getMomentsUseCaseProvider);
    _createMomentUseCase = ref.watch(createMomentUseCaseProvider);
    _syncEngine = ref.watch(syncEngineProvider);
    
    // 监听同步状态
    ref.listen(syncStatusProvider, (_, syncStatus) {
      state = state.copyWith(syncStatus: syncStatus);
    });

    // 初始加载
    _loadMoments();

    return const MomentsState(status: ViewStatus.loading);
  }

  Future<void> _loadMoments({bool refresh = false}) async {
    // ... 实现
  }

  Future<void> refresh() async {
    await _loadMoments(refresh: true);
    // 触发后台同步
    _syncEngine.syncNow();
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedEnd) return;
    // ... 实现
  }

  /// 创建 Moment (乐观更新)
  Future<Either<Failure, Moment>> createMoment(CreateMomentParams params) async {
    // 1. 乐观更新 UI
    final optimisticMoment = _createOptimisticMoment(params);
    state = state.copyWith(
      moments: [optimisticMoment, ...state.moments],
    );

    // 2. 实际创建
    final result = await _createMomentUseCase(params);

    return result.fold(
      (failure) {
        // 回滚乐观更新
        state = state.copyWith(
          moments: state.moments.where((m) => m.id != optimisticMoment.id).toList(),
          errorMessage: failure.message,
        );
        return Left(failure);
      },
      (moment) {
        // 替换乐观数据为真实数据
        state = state.copyWith(
          moments: state.moments.map((m) => 
            m.id == optimisticMoment.id ? moment : m
          ).toList(),
        );
        return Right(moment);
      },
    );
  }
}

// 派生 Provider - 使用 select 防止不必要重建
@riverpod
List<Moment> filteredMoments(FilteredMomentsRef ref) {
  final moments = ref.watch(
    momentsNotifierProvider.select((s) => s.moments),
  );
  final filter = ref.watch(timelineFilterProvider);
  
  return moments.where((m) => filter.matches(m)).toList();
}

// 单个 Moment Provider
@riverpod
Moment? momentById(MomentByIdRef ref, String id) {
  return ref.watch(
    momentsNotifierProvider.select(
      (s) => s.moments.firstWhereOrNull((m) => m.id == id),
    ),
  );
}
```

### 2.4 离线优先架构

```dart
// core/sync/sync_engine.dart

class SyncEngine {
  final SyncQueue _syncQueue;
  final NetworkInfo _networkInfo;
  final MomentRepository _momentRepository;
  final LetterRepository _letterRepository;
  
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;

  SyncEngine({
    required SyncQueue syncQueue,
    required NetworkInfo networkInfo,
    required MomentRepository momentRepository,
    required LetterRepository letterRepository,
  }) : _syncQueue = syncQueue,
       _networkInfo = networkInfo,
       _momentRepository = momentRepository,
       _letterRepository = letterRepository {
    // 监听网络状态变化
    _networkInfo.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  /// 网络恢复时自动同步
  void _onConnectivityChanged(bool isConnected) {
    if (isConnected) {
      syncNow();
    }
  }

  /// 立即同步
  Future<void> syncNow() async {
    if (!await _networkInfo.isConnected) return;
    
    _syncStatusController.add(SyncStatus.syncing);
    
    try {
      // 1. 上传本地待同步数据
      await _uploadPendingChanges();
      
      // 2. 下载远程更新
      await _downloadRemoteChanges();
      
      _syncStatusController.add(SyncStatus.synced);
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
    }
  }

  Future<void> _uploadPendingChanges() async {
    final pendingItems = await _syncQueue.getPendingItems();
    
    for (final item in pendingItems) {
      try {
        switch (item.entityType) {
          case 'moment':
            await _syncMoment(item);
            break;
          case 'letter':
            await _syncLetter(item);
            break;
        }
        await _syncQueue.markAsSynced(item.id);
      } catch (e) {
        await _syncQueue.incrementRetryCount(item.id);
      }
    }
  }

  Future<void> _downloadRemoteChanges() async {
    final lastSyncTime = await _getLastSyncTime();
    
    // 增量同步
    final remoteMoments = await _momentRepository.getMomentsSince(lastSyncTime);
    final remoteLetters = await _letterRepository.getLettersSince(lastSyncTime);
    
    // 合并到本地
    await _mergeWithLocal(remoteMoments, remoteLetters);
    
    await _updateLastSyncTime(DateTime.now());
  }
}
```

---

## 三、后端架构设计

### 3.1 Cloudflare Workers 架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Cloudflare Edge Network                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    Workers (Hono Framework)                  │   │
│  │  ┌─────────────────────────────────────────────────────┐    │   │
│  │  │                    Middleware Stack                  │    │   │
│  │  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────────┐   │    │   │
│  │  │  │  CORS  │→│  Auth  │→│Rate    │→│ Request ID │   │    │   │
│  │  │  │        │ │Verify  │ │Limiter │ │  Logger    │   │    │   │
│  │  │  └────────┘ └────────┘ └────────┘ └────────────┘   │    │   │
│  │  └─────────────────────────────────────────────────────┘    │   │
│  │                           │                                  │   │
│  │  ┌─────────────────────────────────────────────────────┐    │   │
│  │  │                    Route Handlers                    │    │   │
│  │  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────────┐   │    │   │
│  │  │  │  Auth  │ │Moments │ │Letters │ │   World    │   │    │   │
│  │  │  │ Routes │ │ Routes │ │ Routes │ │   Routes   │   │    │   │
│  │  │  └────────┘ └────────┘ └────────┘ └────────────┘   │    │   │
│  │  │  ┌────────┐ ┌────────┐ ┌────────┐                  │    │   │
│  │  │  │ Media  │ │  Sync  │ │Comments│                  │    │   │
│  │  │  │ Routes │ │ Routes │ │ Routes │                  │    │   │
│  │  │  └────────┘ └────────┘ └────────┘                  │    │   │
│  │  └─────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                           │                                         │
│  ┌────────────────────────┼────────────────────────────────────┐   │
│  │                    Storage Layer                             │   │
│  │     ▼              ▼              ▼              ▼           │   │
│  │  ┌──────┐     ┌──────┐     ┌──────┐     ┌───────────┐       │   │
│  │  │  D1  │     │  R2  │     │  KV  │     │ Durable   │       │   │
│  │  │ SQLite│     │ Blob │     │Cache │     │ Objects   │       │   │
│  │  └──────┘     └──────┘     └──────┘     └───────────┘       │   │
│  │  主数据库      媒体存储      响应缓存      实时状态           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 后端目录结构

```
backend/
├── wrangler.toml                    # Cloudflare 配置
├── package.json
├── tsconfig.json
├── vitest.config.ts                 # [NEW] 测试配置
│
├── src/
│   ├── index.ts                     # 入口
│   │
│   ├── app/                         # [NEW] 应用配置
│   │   ├── app.ts                   # Hono 实例
│   │   └── bindings.ts              # 类型绑定
│   │
│   ├── routes/                      # 路由
│   │   ├── auth.ts
│   │   ├── circles.ts
│   │   ├── moments.ts
│   │   ├── letters.ts
│   │   ├── world.ts
│   │   ├── comments.ts
│   │   ├── media.ts
│   │   └── sync.ts                  # [NEW] 同步 API
│   │
│   ├── services/                    # [NEW] 业务逻辑层
│   │   ├── auth.service.ts
│   │   ├── moment.service.ts
│   │   ├── letter.service.ts
│   │   ├── sync.service.ts
│   │   └── notification.service.ts  # [NEW]
│   │
│   ├── repositories/                # 数据访问层
│   │   ├── base.repository.ts
│   │   ├── user.repository.ts
│   │   ├── moment.repository.ts
│   │   ├── letter.repository.ts
│   │   └── sync.repository.ts       # [NEW]
│   │
│   ├── middleware/
│   │   ├── auth.ts
│   │   ├── error.ts
│   │   ├── request-id.ts
│   │   ├── rate-limit.ts            # [NEW]
│   │   └── cache.ts                 # [NEW]
│   │
│   ├── schemas/                     # Zod 验证
│   │   ├── auth.schema.ts
│   │   ├── moment.schema.ts
│   │   ├── letter.schema.ts
│   │   └── common.schema.ts
│   │
│   ├── utils/
│   │   ├── jwt.ts
│   │   ├── password.ts
│   │   ├── response.ts
│   │   ├── pagination.ts            # [NEW]
│   │   └── cache.ts                 # [NEW]
│   │
│   └── types/
│       ├── env.d.ts
│       ├── api.types.ts
│       └── db.types.ts
│
├── migrations/                      # 数据库迁移
│   ├── 0001_initial_schema.sql
│   ├── 0002_seed_data.sql
│   ├── 0003_drop_moments_time_label.sql
│   ├── 0004_migrate_media_urls.sql
│   └── 0005_add_sync_tables.sql     # [NEW]
│
└── tests/                           # [NEW] 测试
    ├── unit/
    ├── integration/
    └── fixtures/
```

### 3.3 增量同步 API

```typescript
// src/routes/sync.ts

import { Hono } from 'hono';
import { zValidator } from '@hono/zod-validator';
import { z } from 'zod';
import { authMiddleware } from '../middleware/auth';
import { SyncService } from '../services/sync.service';

const syncRoutes = new Hono<{ Bindings: Env }>();

// 获取增量变更
const syncPullSchema = z.object({
  lastSyncAt: z.string().datetime().optional(),
  entities: z.array(z.enum(['moments', 'letters', 'comments'])).default(['moments', 'letters']),
});

syncRoutes.get(
  '/pull',
  authMiddleware,
  zValidator('query', syncPullSchema),
  async (c) => {
    const { lastSyncAt, entities } = c.req.valid('query');
    const userId = c.get('userId');
    const circleId = c.get('circleId');

    const syncService = new SyncService(c.env.DB);
    
    const changes = await syncService.getChangesSince({
      userId,
      circleId,
      lastSyncAt: lastSyncAt ? new Date(lastSyncAt) : null,
      entities,
    });

    return c.json({
      success: true,
      data: {
        changes,
        serverTime: new Date().toISOString(),
      },
    });
  }
);

// 推送本地变更
const syncPushSchema = z.object({
  changes: z.array(z.object({
    entityType: z.enum(['moment', 'letter', 'comment']),
    action: z.enum(['create', 'update', 'delete']),
    entityId: z.string(),
    data: z.record(z.unknown()).optional(),
    clientTimestamp: z.string().datetime(),
  })),
});

syncRoutes.post(
  '/push',
  authMiddleware,
  zValidator('json', syncPushSchema),
  async (c) => {
    const { changes } = c.req.valid('json');
    const userId = c.get('userId');
    const circleId = c.get('circleId');

    const syncService = new SyncService(c.env.DB);
    
    const results = await syncService.applyChanges({
      userId,
      circleId,
      changes,
    });

    return c.json({
      success: true,
      data: {
        applied: results.applied,
        conflicts: results.conflicts,
        serverTime: new Date().toISOString(),
      },
    });
  }
);

export { syncRoutes };
```

### 3.4 缓存策略

```typescript
// src/middleware/cache.ts

import { Context, Next } from 'hono';

interface CacheConfig {
  ttl: number;           // 缓存时间 (秒)
  staleWhileRevalidate?: number;  // 过期后可用时间
  tags?: string[];       // 缓存标签
}

export const cache = (config: CacheConfig) => {
  return async (c: Context<{ Bindings: Env }>, next: Next) => {
    const cacheKey = `cache:${c.req.url}`;
    const kv = c.env.CACHE;

    // 尝试从缓存获取
    const cached = await kv.get(cacheKey, 'json');
    
    if (cached) {
      // 设置缓存头
      c.header('X-Cache', 'HIT');
      c.header('Cache-Control', `max-age=${config.ttl}`);
      return c.json(cached);
    }

    // 执行请求
    await next();

    // 缓存响应
    const response = c.res.clone();
    const body = await response.json();
    
    await kv.put(cacheKey, JSON.stringify(body), {
      expirationTtl: config.ttl,
      metadata: { tags: config.tags },
    });

    c.header('X-Cache', 'MISS');
  };
};

// 使用示例
// momentsRoutes.get('/', cache({ ttl: 60, tags: ['moments'] }), handler);
```

### 3.5 数据库迁移 - 同步表

```sql
-- migrations/0005_add_sync_tables.sql

-- 同步日志表
CREATE TABLE IF NOT EXISTS sync_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  circle_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,  -- 'moment', 'letter', 'comment'
  entity_id TEXT NOT NULL,
  action TEXT NOT NULL,       -- 'create', 'update', 'delete'
  data TEXT,                  -- JSON 数据
  client_timestamp TEXT,      -- 客户端时间戳
  server_timestamp TEXT DEFAULT (datetime('now')),
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (circle_id) REFERENCES circles(id)
);

-- 同步日志索引
CREATE INDEX IF NOT EXISTS idx_sync_log_user_circle 
ON sync_log(user_id, circle_id, server_timestamp);

CREATE INDEX IF NOT EXISTS idx_sync_log_entity 
ON sync_log(entity_type, entity_id);

-- 冲突记录表
CREATE TABLE IF NOT EXISTS sync_conflicts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sync_log_id INTEGER NOT NULL,
  conflict_type TEXT NOT NULL,  -- 'version_conflict', 'delete_conflict'
  local_data TEXT,
  server_data TEXT,
  resolved_at TEXT,
  resolution TEXT,              -- 'keep_local', 'keep_server', 'merge'
  
  FOREIGN KEY (sync_log_id) REFERENCES sync_log(id)
);
```

---

## 四、性能优化策略

### 4.1 性能优化矩阵

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Performance Optimization Matrix                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Layer          │ Strategy              │ Impact  │ Priority        │
│  ───────────────┼───────────────────────┼─────────┼─────────────────│
│                 │                       │         │                 │
│  UI/渲染层       │ const Widget          │ High    │ P0              │
│                 │ ListView.builder      │ High    │ P0              │
│                 │ Sliver 优化           │ Medium  │ P1              │
│                 │ RepaintBoundary       │ Medium  │ P1              │
│                 │                       │         │                 │
│  状态管理        │ select() 精准订阅     │ High    │ P0              │
│                 │ family 缓存           │ Medium  │ P1              │
│                 │ autoDispose           │ Medium  │ P1              │
│                 │                       │         │                 │
│  图片/媒体       │ cached_network_image  │ High    │ P0              │
│                 │ 渐进式加载            │ High    │ P0              │
│                 │ 缩略图策略            │ High    │ P0              │
│                 │ 预加载               │ Medium  │ P1              │
│                 │                       │         │                 │
│  数据/网络       │ 离线优先             │ High    │ P0              │
│                 │ 增量同步             │ High    │ P0              │
│                 │ 响应缓存             │ Medium  │ P1              │
│                 │ 请求去重             │ Medium  │ P1              │
│                 │                       │         │                 │
│  动画           │ 60fps 保证           │ High    │ P0              │
│                 │ 减弱动效模式          │ Medium  │ P1              │
│                 │ GPU 加速             │ Medium  │ P1              │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 列表性能优化

```dart
// features/timeline/views/timeline_view.dart

class TimelineView extends ConsumerWidget {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      // 物理效果优化
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        // AppBar
        const _TimelineAppBar(),
        
        // 时间头部
        const SliverToBoxAdapter(
          child: TimeHeader(),
        ),
        
        // Moment 列表 - 使用 SliverList.builder
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          sliver: _MomentSliverList(),
        ),
        
        // 加载更多指示器
        const _LoadMoreIndicator(),
      ],
    );
  }
}

class _MomentSliverList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(filteredMomentsProvider);
    
    return SliverList.builder(
      itemCount: moments.length,
      itemBuilder: (context, index) {
        final moment = moments[index];
        
        // 使用 RepaintBoundary 隔离重绘
        return RepaintBoundary(
          child: FeedCard(
            key: ValueKey(moment.id),
            moment: moment,
            // 延迟构建详情部分
            detailBuilder: () => _MomentDetail(moment: moment),
          ),
        );
      },
    );
  }
}

// 优化的 FeedCard
class FeedCard extends StatelessWidget {
  final Moment moment;
  final Widget Function()? detailBuilder;

  const FeedCard({
    super.key,
    required this.moment,
    this.detailBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: _FeedCardContent(moment: moment),
    );
  }
}

// 分离内容为独立 Widget，便于 const 优化
class _FeedCardContent extends StatelessWidget {
  final Moment moment;
  
  const _FeedCardContent({required this.moment});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.paper,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(author: moment.author, timestamp: moment.timestamp),
          if (moment.content.isNotEmpty) 
            _Content(content: moment.content),
          if (moment.mediaUrls.isNotEmpty)
            _MediaSection(urls: moment.mediaUrls, type: moment.mediaType),
          _Footer(moment: moment),
        ],
      ),
    );
  }
}
```

### 4.3 图片加载优化

```dart
// core/storage/cache/image_cache.dart

class AuraImageCache {
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int maxCacheEntries = 500;

  /// 获取优化后的图片 URL
  static String getOptimizedUrl(String originalUrl, {
    int? width,
    int? height,
    int quality = 80,
  }) {
    // Cloudflare R2 + Image Resizing
    final uri = Uri.parse(originalUrl);
    final params = <String, String>{
      if (width != null) 'w': width.toString(),
      if (height != null) 'h': height.toString(),
      'q': quality.toString(),
      'f': 'auto', // WebP/AVIF 自动选择
    };
    
    return uri.replace(queryParameters: params).toString();
  }

  /// 预加载图片
  static Future<void> precacheImages(
    BuildContext context, 
    List<String> urls,
  ) async {
    for (final url in urls) {
      await precacheImage(
        CachedNetworkImageProvider(
          getOptimizedUrl(url, width: 600),
        ),
        context,
      );
    }
  }
}

// 使用示例
class OptimizedImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const OptimizedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final cacheWidth = width != null 
        ? (width! * devicePixelRatio).toInt() 
        : null;

    return CachedNetworkImage(
      imageUrl: AuraImageCache.getOptimizedUrl(
        url,
        width: cacheWidth,
      ),
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth,
      fadeInDuration: AppDurations.fast,
      fadeInCurve: AppCurves.standard,
      placeholder: (_, __) => const AuraShimmer(),
      errorWidget: (_, __, ___) => const _ImageErrorPlaceholder(),
    );
  }
}
```

### 4.4 启动性能优化

```dart
// main.dart

Future<void> main() async {
  // 1. 最小化启动时初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. 并行初始化关键服务
  await Future.wait([
    _initDatabase(),
    _initSecureStorage(),
  ]);

  // 3. 启动应用
  runApp(
    const ProviderScope(
      child: AuraApp(),
    ),
  );
  
  // 4. 延迟初始化非关键服务
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initDeferredServices();
  });
}

Future<void> _initDatabase() async {
  // 数据库初始化...
}

Future<void> _initSecureStorage() async {
  // 安全存储初始化...
}

void _initDeferredServices() {
  // 延迟初始化：
  // - 分析服务
  // - 推送通知
  // - 后台同步
}
```

---

## 五、动画系统增强

### 5.1 动画架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Aura Animation System                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                     Animation Config Layer                     │ │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────────────────┐ │ │
│  │  │Duration │ │ Curves  │ │ Physics │ │ Accessibility Check │ │ │
│  │  │ Tokens  │ │ Tokens  │ │ Config  │ │  (Reduce Motion)    │ │ │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────────────────┘ │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                │                                    │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                   Animation Primitives                        │ │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │ │
│  │  │  Fade    │ │  Slide   │ │  Scale   │ │     Shimmer      │ │ │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────────────┘ │ │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │ │
│  │  │ Rotation │ │  Blur    │ │ Tint     │ │    Breathing     │ │ │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────────────┘ │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                │                                    │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                  Composite Animations                          │ │
│  │  ┌─────────────┐ ┌─────────────┐ ┌───────────────────────┐   │ │
│  │  │   Entrance  │ │    Exit     │ │     Transition        │   │ │
│  │  │  Animations │ │  Animations │ │     Animations        │   │ │
│  │  └─────────────┘ └─────────────┘ └───────────────────────┘   │ │
│  │  ┌─────────────┐ ┌─────────────┐ ┌───────────────────────┐   │ │
│  │  │   Stagger   │ │  Breathing  │ │      Ceremony         │   │ │
│  │  │    List     │ │    Pulse    │ │     Animations        │   │ │
│  │  └─────────────┘ └─────────────┘ └───────────────────────┘   │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                │                                    │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                   Application Layer                           │ │
│  │  ┌────────────┐ ┌────────────┐ ┌──────────────────────────┐  │ │
│  │  │   Page     │ │   Card     │ │       Micro              │  │ │
│  │  │ Transitions│ │ Animations │ │    Interactions          │  │ │
│  │  └────────────┘ └────────────┘ └──────────────────────────┘  │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 5.2 动画配置系统

```dart
// core/animations/animation_config.dart

/// 动画配置中心
class AuraAnimationConfig {
  /// 检查是否应该禁用动画
  static bool shouldReduceMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// 根据无障碍设置调整时长
  static Duration adaptedDuration(BuildContext context, Duration duration) {
    if (shouldReduceMotion(context)) {
      return duration ~/ 2; // 减半
    }
    return duration;
  }

  /// 根据无障碍设置调整曲线
  static Curve adaptedCurve(BuildContext context, Curve curve) {
    if (shouldReduceMotion(context)) {
      return Curves.linear;
    }
    return curve;
  }
}

/// 动画时长 Token
class AuraDurations {
  static const instant = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const pageTransition = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 400);
  static const ceremony = Duration(milliseconds: 600);
  static const entrance = Duration(milliseconds: 800);
  static const breathing = Duration(milliseconds: 2000);
}

/// 动画曲线 Token
class AuraCurves {
  static const standard = Curves.easeOutCubic;
  static const enter = Cubic(0.0, 0.0, 0.2, 1.0);
  static const exit = Cubic(0.4, 0.0, 1.0, 1.0);
  static const breathing = Cubic(0.4, 0.0, 0.6, 1.0);
  static const gentle = Cubic(0.34, 1.56, 0.64, 1.0);
  static const smooth = Curves.easeInOutCubic;
}

/// 弹簧物理配置
class AuraSpringConfig {
  /// 轻柔弹簧 - 用于微交互
  static const gentle = SpringDescription(
    mass: 1.0,
    stiffness: 300.0,
    damping: 20.0,
  );

  /// 标准弹簧 - 用于页面转场
  static const standard = SpringDescription(
    mass: 1.0,
    stiffness: 400.0,
    damping: 25.0,
  );

  /// 响应弹簧 - 用于按钮反馈
  static const responsive = SpringDescription(
    mass: 1.0,
    stiffness: 600.0,
    damping: 30.0,
  );
}
```

### 5.3 入场动画组件

```dart
// presentation/shared/aura/animations/aura_stagger_list.dart

/// 交错入场列表
class AuraStaggerList extends StatelessWidget {
  final List<Widget> children;
  final Duration baseDelay;
  final Duration itemDuration;
  final int maxDelayItems;
  final Offset slideOffset;

  const AuraStaggerList({
    super.key,
    required this.children,
    this.baseDelay = const Duration(milliseconds: 60),
    this.itemDuration = const Duration(milliseconds: 400),
    this.maxDelayItems = 5,
    this.slideOffset = const Offset(0.03, 0),
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AuraAnimationConfig.shouldReduceMotion(context);

    return Column(
      children: [
        for (var i = 0; i < children.length; i++)
          _StaggerItem(
            index: i,
            baseDelay: baseDelay,
            duration: itemDuration,
            maxDelayItems: maxDelayItems,
            slideOffset: slideOffset,
            reduceMotion: reduceMotion,
            child: children[i],
          ),
      ],
    );
  }
}

class _StaggerItem extends StatefulWidget {
  final int index;
  final Duration baseDelay;
  final Duration duration;
  final int maxDelayItems;
  final Offset slideOffset;
  final bool reduceMotion;
  final Widget child;

  const _StaggerItem({
    required this.index,
    required this.baseDelay,
    required this.duration,
    required this.maxDelayItems,
    required this.slideOffset,
    required this.reduceMotion,
    required this.child,
  });

  @override
  State<_StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<_StaggerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.reduceMotion ? Duration.zero : widget.duration,
    );

    final delayIndex = widget.index.clamp(0, widget.maxDelayItems);
    final delay = widget.baseDelay * delayIndex;

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AuraCurves.enter,
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AuraCurves.enter,
    ));

    // 延迟启动动画
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reduceMotion) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
```

### 5.4 仪式感动画

```dart
// presentation/shared/aura/animations/aura_ceremony.dart

/// 封存信件动画
class LetterSealAnimation extends StatefulWidget {
  final VoidCallback onComplete;
  final Widget child;

  const LetterSealAnimation({
    super.key,
    required this.onComplete,
    required this.child,
  });

  @override
  State<LetterSealAnimation> createState() => _LetterSealAnimationState();
}

class _LetterSealAnimationState extends State<LetterSealAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _glowController;
  
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _translateAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // 主动画控制器
    _mainController = AnimationController(
      vsync: this,
      duration: AuraDurations.ceremony,
    );

    // 光效控制器
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // 缩小动画
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: AuraCurves.gentle),
    ));

    // 下沉动画
    _translateAnimation = Tween<double>(
      begin: 0,
      end: 20,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: AuraCurves.gentle),
    ));

    // 淡出动画
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.6, 1.0, curve: AuraCurves.exit),
    ));

    // 光效动画
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOut,
    ));

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // 触觉反馈
    HapticFeedback.mediumImpact();
    
    // 播放光效
    await _glowController.forward();
    
    // 播放主动画
    await _mainController.forward();
    
    // 最终反馈
    HapticFeedback.heavyImpact();
    
    widget.onComplete();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _glowController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 光效层
            if (_glowAnimation.value > 0)
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(
                        0.3 * _glowAnimation.value * (1 - _opacityAnimation.value),
                      ),
                      blurRadius: 60 * _glowAnimation.value,
                      spreadRadius: 20 * _glowAnimation.value,
                    ),
                  ],
                ),
              ),
            
            // 信件内容
            Transform.translate(
              offset: Offset(0, _translateAnimation.value),
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: widget.child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
```

### 5.5 呼吸动效

```dart
// presentation/shared/aura/animations/aura_breathing.dart

/// 呼吸动效 - 用于轻柔吸引注意力
class AuraBreathing extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;
  final bool enabled;

  const AuraBreathing({
    super.key,
    required this.child,
    this.minScale = 0.96,
    this.maxScale = 1.0,
    this.duration = AuraDurations.breathing,
    this.enabled = true,
  });

  @override
  State<AuraBreathing> createState() => _AuraBreathingState();
}

class _AuraBreathingState extends State<AuraBreathing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.maxScale,
      end: widget.minScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AuraCurves.breathing,
    ));

    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AuraBreathing oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 无障碍模式下禁用呼吸动效
    if (AuraAnimationConfig.shouldReduceMotion(context) || !widget.enabled) {
      return widget.child;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
```

### 5.6 页面转场动画

```dart
// core/router/transitions.dart

/// Aura 自定义页面转场
class AuraPageTransitions {
  /// 标准向前导航 - 柔和上滑 + 渐显
  static Page<T> slideUp<T>({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: AuraDurations.pageTransition,
      reverseTransitionDuration: AuraDurations.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final reduceMotion = AuraAnimationConfig.shouldReduceMotion(context);
        
        if (reduceMotion) {
          return FadeTransition(opacity: animation, child: child);
        }

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AuraCurves.enter,
        ));

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: AuraCurves.enter,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// 模态页面 - 从底部弹起
  static Page<T> modal<T>({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      opaque: false,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      transitionDuration: AuraDurations.pageTransition,
      reverseTransitionDuration: AuraDurations.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AuraCurves.enter,
          reverseCurve: AuraCurves.exit,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }

  /// 共享元素转场 - Hero 动画增强
  static Page<T> hero<T>({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: AuraDurations.slow,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.5),
          ),
          child: child,
        );
      },
    );
  }
}

// 在 GoRouter 中使用
GoRoute(
  path: '/moment/:id',
  pageBuilder: (context, state) {
    return AuraPageTransitions.slideUp(
      key: state.pageKey,
      child: MomentDetailView(id: state.pathParameters['id']!),
    );
  },
),
```

---

## 六、交互设计规范

### 6.1 触觉反馈系统

```dart
// core/haptics/haptic_service.dart

/// 触觉反馈服务
class HapticService {
  /// 轻触反馈 - 按钮点击
  static Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  /// 中等反馈 - 切换、选择
  static Future<void> mediumTap() async {
    await HapticFeedback.mediumImpact();
  }

  /// 重度反馈 - 重要操作完成
  static Future<void> heavyTap() async {
    await HapticFeedback.heavyImpact();
  }

  /// 选择反馈 - 列表项选择
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// 成功反馈 - 操作成功
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  /// 警告反馈 - 需要注意
  static Future<void> warning() async {
    await HapticFeedback.heavyImpact();
  }

  /// 错误反馈 - 操作失败
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }

  /// 仪式感反馈 - 封存、发布
  static Future<void> ceremony() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();
  }
}
```

### 6.2 手势交互

```dart
// core/animations/physics/gesture_physics.dart

/// 手势物理配置
class GesturePhysics {
  /// 下拉刷新物理
  static const refreshPhysics = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );

  /// 页面滑动返回阈值
  static const swipeBackThreshold = 0.3; // 30% 屏幕宽度

  /// 删除滑动阈值
  static const dismissThreshold = 0.4; // 40% 宽度

  /// 速度阈值 (像素/秒)
  static const velocityThreshold = 700.0;
}

/// 可滑动删除卡片
class SwipeToDismissCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onDismissed;
  final Widget? background;

  const SwipeToDismissCard({
    super.key,
    required this.child,
    required this.onDismissed,
    this.background,
  });

  @override
  State<SwipeToDismissCard> createState() => _SwipeToDismissCardState();
}

class _SwipeToDismissCardState extends State<SwipeToDismissCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _opacityAnimation;
  
  double _dragExtent = 0;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: AuraDurations.normal,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AuraCurves.exit,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.delta.dx;
      _dragExtent = _dragExtent.clamp(-double.infinity, 0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dragRatio = _dragExtent.abs() / screenWidth;
    final velocity = details.velocity.pixelsPerSecond.dx;

    if (dragRatio > GesturePhysics.dismissThreshold ||
        velocity < -GesturePhysics.velocityThreshold) {
      // 触发删除
      HapticService.warning();
      _controller.forward().then((_) {
        widget.onDismissed();
      });
    } else {
      // 回弹
      setState(() {
        _dragExtent = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: Stack(
        children: [
          // 背景 (删除提示)
          if (widget.background != null && _dragExtent < 0)
            Positioned.fill(
              child: widget.background!,
            ),
          
          // 内容
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              if (_controller.isAnimating) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: widget.child,
                  ),
                );
              }
              
              return Transform.translate(
                offset: Offset(_dragExtent, 0),
                child: Opacity(
                  opacity: 1 - (_dragExtent.abs() / screenWidth * 0.5),
                  child: widget.child,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### 6.3 空状态设计

```dart
// presentation/shared/aura/display/aura_empty_state.dart

/// 空状态组件
class AuraEmptyState extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? icon;
  final Widget? action;
  final EmptyStateType type;

  const AuraEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.action,
    this.type = EmptyStateType.generic,
  });

  /// 首页无记录
  const AuraEmptyState.noMoments({super.key})
      : title = '这里会慢慢被时间填满',
        description = '记录第一个瞬间吧',
        icon = null,
        action = null,
        type = EmptyStateType.noMoments;

  /// 搜索无结果
  const AuraEmptyState.noSearchResults({super.key})
      : title = '没有找到相关记忆',
        description = '试试其他关键词',
        icon = null,
        action = null,
        type = EmptyStateType.noSearchResults;

  /// 信件箱空
  const AuraEmptyState.noLetters({super.key})
      : title = '还没有信件',
        description = '写一封给未来的信吧',
        icon = null,
        action = null,
        type = EmptyStateType.noLetters;

  /// 去年今天无内容
  const AuraEmptyState.noMemoryToday({super.key})
      : title = '去年的今天，你还没有记录',
        description = '等明年，它会出现的',
        icon = null,
        action = null,
        type = EmptyStateType.noMemoryToday;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标/插画
            _buildIcon(),
            const SizedBox(height: AppSpacing.lg),
            
            // 标题
            Text(
              title,
              style: AppTypography.subtitle.copyWith(
                color: AppColors.warmGray700,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 描述
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                style: AppTypography.body.copyWith(
                  color: AppColors.warmGray500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // 操作按钮
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(duration: AuraDurations.slow, curve: AuraCurves.enter)
    .slideY(begin: 0.02, curve: AuraCurves.enter);
  }

  Widget _buildIcon() {
    if (icon != null) return icon!;

    // 根据类型返回默认图标
    final iconData = switch (type) {
      EmptyStateType.noMoments => Icons.schedule_outlined,
      EmptyStateType.noSearchResults => Icons.search_off_outlined,
      EmptyStateType.noLetters => Icons.mail_outline,
      EmptyStateType.noMemoryToday => Icons.today_outlined,
      EmptyStateType.generic => Icons.inbox_outlined,
    };

    return Icon(
      iconData,
      size: 64,
      color: AppColors.warmGray300,
    );
  }
}

enum EmptyStateType {
  generic,
  noMoments,
  noSearchResults,
  noLetters,
  noMemoryToday,
}
```

---

## 七、实施路线图

### 7.1 Phase 1: 基础设施 (2周)

```
Week 1-2: 核心架构搭建
├── [ ] 依赖注入系统 (core/di/)
├── [ ] 同步引擎基础 (core/sync/)
├── [ ] 动画配置系统 (core/animations/)
├── [ ] 触觉反馈服务 (core/haptics/)
└── [ ] 后端同步 API

验收标准:
- [ ] 离线创建 Moment 可在恢复网络后同步
- [ ] 动画系统支持无障碍模式
- [ ] 触觉反馈在 iOS/Android 正常工作
```

### 7.2 Phase 2: UI 组件升级 (2周)

```
Week 3-4: Aura 组件库增强
├── [ ] 入场动画组件 (AuraFadeIn, AuraSlideUp)
├── [ ] 交错列表组件 (AuraStaggerList)
├── [ ] 呼吸动效组件 (AuraBreathing)
├── [ ] 骨架屏增强 (AuraShimmer)
├── [ ] 触觉按钮 (AuraHapticButton)
└── [ ] 空状态组件优化 (AuraEmptyState)

验收标准:
- [ ] 所有列表使用交错入场动画
- [ ] 骨架屏有 shimmer 效果
- [ ] 按钮点击有触觉反馈
```

### 7.3 Phase 3: 页面优化 (2周)

```
Week 5-6: 页面体验升级
├── [ ] 启动页动画优化
├── [ ] 首页时间感知增强
├── [ ] 时间轴滚动性能优化
├── [ ] 信件封存仪式动画
├── [ ] 页面转场动画统一
└── [ ] 图片加载优化

验收标准:
- [ ] 冷启动 < 2秒
- [ ] 列表滚动 60fps
- [ ] 封存动画流畅且有仪式感
```

### 7.4 Phase 4: 性能调优 (1周)

```
Week 7: 性能优化
├── [ ] Riverpod select 优化
├── [ ] 图片缓存策略
├── [ ] 内存使用分析
├── [ ] 网络请求优化
└── [ ] 性能监控埋点

验收标准:
- [ ] 内存占用 < 150MB
- [ ] 列表项重建次数最小化
- [ ] 图片加载有渐进效果
```

### 7.5 Phase 5: 打磨 & 发布 (1周)

```
Week 8: 最终打磨
├── [ ] 全面 UI 审查
├── [ ] 动画细节调整
├── [ ] 无障碍测试
├── [ ] 性能回归测试
└── [ ] 文档更新

验收标准:
- [ ] 通过设计评审
- [ ] 无障碍模式可用
- [ ] 无性能回归
```

---

## 附录

### A. 设计系统 Quick Reference

```
Colors:
  primary: #DF8020 (拾光橙)
  bg: #FAF9F7 (时间米白)
  text: #1C1917 / #57534E / #78716C (暖灰900/700/600)

Spacing:
  sm: 8  |  md: 12  |  lg: 16  |  xl: 24  |  xxl: 32

Radius:
  sm: 12  |  md: 16  |  card: 20  |  button: 24

Duration:
  fast: 150ms  |  normal: 250ms  |  slow: 400ms  |  ceremony: 600ms

Curves:
  standard: easeOutCubic
  enter: Cubic(0.0, 0.0, 0.2, 1.0)
  exit: Cubic(0.4, 0.0, 1.0, 1.0)
```

### B. 文件命名规范

```
目录: snake_case
文件: snake_case.dart
类: UpperCamelCase
变量/函数: lowerCamelCase
常量: lowerCamelCase
私有: _前缀
Provider: xxxProvider
```

### C. 参考资源

- [Flutter 性能最佳实践](https://docs.flutter.dev/perf/best-practices)
- [Riverpod 2.0 文档](https://riverpod.dev/)
- [Cloudflare Workers 文档](https://developers.cloudflare.com/workers/)
- [Material Design 3](https://m3.material.io/)

---

> **记住：**
> 这不只是一个 App，这是一个"时间容器"。
> 每一个像素、每一帧动画、每一次触感，
> 都在传递着"时间被温柔对待"的信息。
