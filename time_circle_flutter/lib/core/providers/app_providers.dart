import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../repositories/repositories.dart';
import 'auth_providers.dart';

// ============== Repository Providers ==============

/// Circle Repository Provider
final circleRepositoryProvider = Provider<CircleRepository>((ref) {
  return CircleRepository();
});

/// Member Repository Provider
final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository();
});

/// Moment Repository Provider
final momentRepositoryProvider = Provider<MomentRepository>((ref) {
  return MomentRepository();
});

/// Letter Repository Provider
final letterRepositoryProvider = Provider<LetterRepository>((ref) {
  return LetterRepository();
});

/// Comment Repository Provider
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository();
});

/// World Repository Provider
final worldRepositoryProvider = Provider<WorldRepository>((ref) {
  return WorldRepository();
});

/// Settings Repository Provider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

// ============== 用户相关 ==============

/// 当前用户 Provider（从认证状态获取）
final currentUserProvider = Provider<User>((ref) {
  final authState = ref.watch(authProvider);
  final user = authState.user;

  if (authState.isFullyAuthenticated && user != null) {
    return User(id: user.id, name: user.name, avatar: user.avatar ?? '');
  }
  return const User(id: 'guest', name: '我', avatar: '');
});

/// 当前用户（同步访问，向后兼容）
final currentUserSyncProvider = currentUserProvider;

/// 圈子成员 Provider（从远程 API 获取）
final circleMembersProvider = FutureProvider<List<User>>((ref) async {
  final selectedCircle = ref.watch(selectedCircleInfoProvider);
  if (selectedCircle == null || selectedCircle.id == null) {
    return [];
  }

  final repo = ref.watch(memberRepositoryProvider);
  try {
    final members = await repo.getMembers(selectedCircle.id!);
    return members.map((m) => m.toUser()).toList();
  } catch (e) {
    debugPrint('[CircleMembers] Failed to load members: $e');
    return [];
  }
});

// ============== 圈子信息相关 ==============

/// 圈子信息 Provider（异步，直接从 API 获取）
final circleInfoAsyncProvider = FutureProvider<CircleInfo>((ref) async {
  final selectedCircle = ref.watch(selectedCircleInfoProvider);

  // 如果已经有选中的圈子信息，直接使用
  if (selectedCircle != null) {
    return selectedCircle;
  }

  // 否则尝试从 API 获取用户的圈子列表
  final repo = ref.watch(circleRepositoryProvider);
  try {
    final circles = await repo.getCircles();
    if (circles.isNotEmpty) {
      return circles.first;
    }
  } catch (e) {
    debugPrint('[CircleInfo] Failed to load circles: $e');
  }

  return CircleInfo(
    name: '我们的圈子',
    startDate: DateTime.now().subtract(const Duration(days: 365)),
  );
});

/// 圈子信息（同步访问）
final circleInfoProvider = Provider<CircleInfo>((ref) {
  final asyncInfo = ref.watch(circleInfoAsyncProvider);
  return asyncInfo.when(
    data: (info) => info,
    loading:
        () => CircleInfo(
          name: '我们的圈子',
          startDate: DateTime.now().subtract(const Duration(days: 365)),
        ),
    error:
        (_, __) => CircleInfo(
          name: '我们的圈子',
          startDate: DateTime.now().subtract(const Duration(days: 365)),
        ),
  );
});

/// 向后兼容的别名
final childInfoProvider = circleInfoProvider;

// ============== 时刻相关 ==============

/// 时刻列表状态
class MomentsState {
  final List<Moment> moments;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const MomentsState({
    this.moments = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  MomentsState copyWith({
    List<Moment>? moments,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return MomentsState(
      moments: moments ?? this.moments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// 时刻列表 Provider
final momentsProvider = StateNotifierProvider<MomentsNotifier, List<Moment>>((
  ref,
) {
  final repo = ref.watch(momentRepositoryProvider);
  final worldRepo = ref.watch(worldRepositoryProvider);
  final selectedCircle = ref.watch(selectedCircleInfoProvider);
  return MomentsNotifier(repo, worldRepo, selectedCircle?.id);
});

class MomentsNotifier extends StateNotifier<List<Moment>> {
  final MomentRepository _repo;
  final WorldRepository _worldRepo;
  final String? _circleId;
  bool _initialized = false;
  bool _hasMore = true;
  int _currentPage = 1;

  MomentsNotifier(this._repo, this._worldRepo, this._circleId) : super([]) {
    _loadMoments();
  }

  Future<void> _loadMoments() async {
    final circleId = _circleId;
    if (_initialized || circleId == null) return;

    try {
      final result = await _repo.getMoments(circleId, page: 1, limit: 50);
      state = result.moments;
      _hasMore = result.hasMore;
      _currentPage = 1;
      _initialized = true;
    } catch (e) {
      debugPrint('[Moments] Failed to initialize: $e');
    }
  }

  Future<void> refresh() async {
    final circleId = _circleId;
    if (circleId == null) return;

    try {
      final result = await _repo.getMoments(circleId, page: 1, limit: 50);
      state = result.moments;
      _hasMore = result.hasMore;
      _currentPage = 1;
    } catch (e) {
      debugPrint('[Moments] Failed to refresh: $e');
    }
  }

  Future<void> loadMore() async {
    final circleId = _circleId;
    if (circleId == null || !_hasMore) return;

    try {
      final result = await _repo.getMoments(
        circleId,
        page: _currentPage + 1,
        limit: 50,
      );
      state = [...state, ...result.moments];
      _hasMore = result.hasMore;
      _currentPage++;
    } catch (e) {
      debugPrint('[Moments] Failed to load more: $e');
    }
  }

  Future<void> addMoment(Moment moment) async {
    final circleId = _circleId;
    if (circleId == null) return;

    try {
      final created = await _repo.createMoment(
        circleId: circleId,
        content: moment.content,
        mediaType: moment.mediaType,
        timeLabel: moment.timeLabel,
        mediaUrl: moment.mediaUrl,
        timestamp: moment.timestamp,
        contextTags: moment.contextTags,
        location: moment.location,
        futureMessage: moment.futureMessage,
      );
      state = [created, ...state];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final isFavorite = await _repo.toggleFavorite(id);
      state =
          state.map((m) {
            if (m.id == id) {
              return m.copyWith(isFavorite: isFavorite);
            }
            return m;
          }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMoment(String id) async {
    try {
      await _repo.deleteMoment(id);
      state = state.where((m) => m.id != id).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> shareToWorld(String momentId, String topic) async {
    // 找到要分享的 moment
    final moment = state.firstWhere(
      (m) => m.id == momentId,
      orElse: () => throw Exception('Moment not found'),
    );

    try {
      // 调用 WorldRepository 创建帖子
      await _worldRepo.createPost(
        content: moment.content,
        tag: topic,
        bgGradient: 'orange', // 默认渐变色
        momentId: momentId,
      );

      // 更新本地 moment 状态
      state =
          state.map((m) {
            if (m.id == momentId) {
              return m.copyWith(isSharedToWorld: true, worldTopic: topic);
            }
            return m;
          }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> withdrawFromWorld(String momentId) async {
    // 找到要撤回的 moment
    final moment = state.firstWhere(
      (m) => m.id == momentId,
      orElse: () => throw Exception('Moment not found'),
    );

    if (!moment.isSharedToWorld) return;

    try {
      // 后端删除 world post 时会自动更新 moment 状态
      // 需要先获取关联的 world post ID，但后端 API 会处理
      // 调用 moment repository 来撤回
      await _repo.withdrawFromWorld(momentId);

      // 更新本地 moment 状态
      state =
          state.map((m) {
            if (m.id == momentId) {
              return m.copyWith(isSharedToWorld: false, worldTopic: null);
            }
            return m;
          }).toList();
    } catch (e) {
      rethrow;
    }
  }
}

/// 获取单个时刻
final momentByIdProvider = Provider.family<Moment?, String>((ref, id) {
  final moments = ref.watch(momentsProvider);
  try {
    return moments.firstWhere((m) => m.id == id);
  } catch (_) {
    return null;
  }
});

// ============== 信件相关 ==============

/// 信件列表 Provider
final lettersProvider = StateNotifierProvider<LettersNotifier, List<Letter>>((
  ref,
) {
  final repo = ref.watch(letterRepositoryProvider);
  final selectedCircle = ref.watch(selectedCircleInfoProvider);
  return LettersNotifier(repo, selectedCircle?.id);
});

class LettersNotifier extends StateNotifier<List<Letter>> {
  final LetterRepository _repo;
  final String? _circleId;
  bool _initialized = false;

  LettersNotifier(this._repo, this._circleId) : super([]) {
    _loadLetters();
  }

  Future<void> _loadLetters() async {
    final circleId = _circleId;
    if (_initialized || circleId == null) return;

    try {
      final letters = await _repo.getLetters(circleId);
      state = letters;
      _initialized = true;
    } catch (e) {
      debugPrint('[Letters] Failed to load letters: $e');
    }
  }

  Future<void> refresh() async {
    final circleId = _circleId;
    if (circleId == null) return;

    try {
      final letters = await _repo.getLetters(circleId);
      state = letters;
    } catch (e) {
      debugPrint('[Letters] Failed to refresh: $e');
    }
  }

  Future<void> addLetter(Letter letter) async {
    final circleId = _circleId;
    if (circleId == null) return;

    try {
      final created = await _repo.createLetter(
        circleId: circleId,
        title: letter.title,
        type: letter.type,
        recipient: letter.recipient,
        content: letter.content,
      );
      state = [created, ...state];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLetter(Letter letter) async {
    try {
      final updated = await _repo.updateLetter(
        letterId: letter.id,
        title: letter.title,
        content: letter.content,
        recipient: letter.recipient,
      );
      state =
          state.map((l) {
            if (l.id == updated.id) {
              return updated;
            }
            return l;
          }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sealLetter(String id, DateTime unlockDate) async {
    try {
      final sealed = await _repo.sealLetter(
        letterId: id,
        unlockDate: unlockDate,
      );
      state =
          state.map((l) {
            if (l.id == id) {
              return sealed;
            }
            return l;
          }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteLetter(String id) async {
    try {
      await _repo.deleteLetter(id);
      state = state.where((l) => l.id != id).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUnlockDate(String id, DateTime newDate) async {
    // TODO: 后端暂不支持修改已封存信件的解锁日期
    // 需要在后端添加 PUT /letters/:id/unlock-date 接口
    debugPrint(
      '[Letters] updateUnlockDate called for $id with date: $newDate (not implemented)',
    );
  }
}

/// 获取单个信件
final letterByIdProvider = Provider.family<Letter?, String>((ref, id) {
  final letters = ref.watch(lettersProvider);
  try {
    return letters.firstWhere((l) => l.id == id);
  } catch (_) {
    return null;
  }
});

/// 年度信草稿
final annualDraftLetterProvider = Provider<Letter?>((ref) {
  final letters = ref.watch(lettersProvider);
  try {
    return letters.firstWhere(
      (l) => l.status == LetterStatus.draft && l.type == LetterType.annual,
    );
  } catch (_) {
    return null;
  }
});

// ============== 世界频道相关 ==============

/// 世界帖子 Provider
final worldPostsProvider =
    StateNotifierProvider<WorldPostsNotifier, List<WorldPost>>((ref) {
      final repo = ref.watch(worldRepositoryProvider);
      return WorldPostsNotifier(repo);
    });

class WorldPostsNotifier extends StateNotifier<List<WorldPost>> {
  final WorldRepository _repo;
  bool _initialized = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _currentTag;

  WorldPostsNotifier(this._repo) : super([]) {
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    if (_initialized) return;

    try {
      final result = await _repo.getPosts(page: 1, limit: 20);
      state = result.posts;
      _hasMore = result.hasMore;
      _currentPage = 1;
      _initialized = true;
    } catch (e) {
      debugPrint('[WorldPosts] Failed to load posts: $e');
    }
  }

  Future<void> refresh({String? tag}) async {
    try {
      _currentTag = tag;
      final result = await _repo.getPosts(tag: tag, page: 1, limit: 20);
      state = result.posts;
      _hasMore = result.hasMore;
      _currentPage = 1;
    } catch (e) {
      debugPrint('[WorldPosts] Failed to refresh: $e');
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;

    try {
      final result = await _repo.getPosts(
        tag: _currentTag,
        page: _currentPage + 1,
        limit: 20,
      );
      state = [...state, ...result.posts];
      _hasMore = result.hasMore;
      _currentPage++;
    } catch (e) {
      debugPrint('[WorldPosts] Failed to load more: $e');
    }
  }

  Future<void> addPost(WorldPost post) async {
    try {
      final created = await _repo.createPost(
        content: post.content,
        tag: post.tag,
        bgGradient: post.bgGradient,
        momentId: post.momentId,
      );
      state = [created, ...state];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleResonance(String id) async {
    final index = state.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final post = state[index];

    try {
      final result =
          post.hasResonated
              ? await _repo.unresonate(id)
              : await _repo.resonate(id);

      final updated = post.copyWith(
        hasResonated: result.hasResonated,
        resonanceCount: result.resonanceCount,
      );
      state = [
        ...state.sublist(0, index),
        updated,
        ...state.sublist(index + 1),
      ];
    } catch (e) {
      debugPrint('[WorldPosts] Failed to toggle resonance: $e');
    }
  }

  Future<void> deletePost(String id) async {
    try {
      await _repo.deletePost(id);
      state = state.where((p) => p.id != id).toList();
    } catch (e) {
      rethrow;
    }
  }
}

// ============== 时间线筛选相关 ==============

/// 筛选排序方式
enum SortOrder { desc, asc }

/// 时间线筛选状态
class TimelineFilterState {
  final String filterYear;
  final String filterAuthor;
  final String filterType;
  final SortOrder sortOrder;

  const TimelineFilterState({
    this.filterYear = 'ALL',
    this.filterAuthor = 'ALL',
    this.filterType = 'ALL',
    this.sortOrder = SortOrder.desc,
  });

  TimelineFilterState copyWith({
    String? filterYear,
    String? filterAuthor,
    String? filterType,
    SortOrder? sortOrder,
  }) {
    return TimelineFilterState(
      filterYear: filterYear ?? this.filterYear,
      filterAuthor: filterAuthor ?? this.filterAuthor,
      filterType: filterType ?? this.filterType,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  bool get isFiltering =>
      filterYear != 'ALL' || filterAuthor != 'ALL' || filterType != 'ALL';
}

/// 时间线筛选 Provider
final timelineFilterProvider =
    StateNotifierProvider<TimelineFilterNotifier, TimelineFilterState>((ref) {
      return TimelineFilterNotifier();
    });

class TimelineFilterNotifier extends StateNotifier<TimelineFilterState> {
  TimelineFilterNotifier() : super(const TimelineFilterState());

  void setYear(String year) => state = state.copyWith(filterYear: year);
  void setAuthor(String author) => state = state.copyWith(filterAuthor: author);
  void setType(String type) => state = state.copyWith(filterType: type);
  void setSortOrder(SortOrder order) =>
      state = state.copyWith(sortOrder: order);
  void reset() => state = const TimelineFilterState();
}

/// 过滤后的时刻列表
final filteredMomentsProvider = Provider<List<Moment>>((ref) {
  final moments = ref.watch(momentsProvider);
  final filter = ref.watch(timelineFilterProvider);

  var result = [...moments];

  // 按年份筛选
  if (filter.filterYear != 'ALL') {
    result =
        result.where((m) {
          return m.timestamp.year.toString() == filter.filterYear;
        }).toList();
  }

  // 按作者筛选
  if (filter.filterAuthor != 'ALL') {
    result = result.where((m) => m.author.id == filter.filterAuthor).toList();
  }

  // 按类型筛选
  if (filter.filterType != 'ALL') {
    result =
        result.where((m) {
          return m.mediaType.name.toUpperCase() == filter.filterType;
        }).toList();
  }

  // 排序
  result.sort((a, b) {
    return filter.sortOrder == SortOrder.desc
        ? b.timestamp.compareTo(a.timestamp)
        : a.timestamp.compareTo(b.timestamp);
  });

  return result;
});

/// 去年今天的时刻（用于首页回忆卡片）
final lastYearTodayMomentsProvider = Provider<List<Moment>>((ref) {
  final moments = ref.watch(momentsProvider);
  final now = DateTime.now();
  final lastYear = now.year - 1;

  return moments.where((m) {
    return m.timestamp.year == lastYear &&
        m.timestamp.month == now.month &&
        m.timestamp.day == now.day;
  }).toList();
});

/// 是否有足够的历史数据
final hasLastYearDataProvider = Provider<bool>((ref) {
  final circleInfo = ref.watch(circleInfoProvider);
  if (circleInfo.startDate == null) return false;

  final daysSinceStart =
      DateTime.now().difference(circleInfo.startDate!).inDays;
  return daysSinceStart >= 365;
});

/// 是否有足够的记录数据
final hasEnoughMomentsProvider = Provider<bool>((ref) {
  final moments = ref.watch(momentsProvider);
  return moments.length >= 5;
});

/// 是否有任何记录
final hasAnyMomentsProvider = Provider<bool>((ref) {
  final moments = ref.watch(momentsProvider);
  return moments.isNotEmpty;
});

/// 可用的筛选年份列表
final availableYearsProvider = Provider<List<String>>((ref) {
  final moments = ref.watch(momentsProvider);
  final years =
      moments.map((m) => m.timestamp.year.toString()).toSet().toList();
  years.sort((a, b) => b.compareTo(a));
  return years;
});

/// 可用的作者列表
final availableAuthorsProvider = Provider<List<User>>((ref) {
  final moments = ref.watch(momentsProvider);
  final authorsMap = <String, User>{};
  for (final m in moments) {
    authorsMap[m.author.id] = m.author;
  }
  return authorsMap.values.toList();
});

/// 世界频道 Provider
final worldChannelsProvider = FutureProvider<List<WorldChannel>>((ref) async {
  final repo = ref.watch(worldRepositoryProvider);
  try {
    return await repo.getChannels();
  } catch (e) {
    return const [];
  }
});

/// 世界频道（同步访问）
final worldChannelsSyncProvider = Provider<List<WorldChannel>>((ref) {
  final asyncChannels = ref.watch(worldChannelsProvider);
  return asyncChannels.when(
    data: (channels) => channels,
    loading:
        () => const [
          WorldChannel(
            id: 'c1',
            name: '写给未来',
            description: '写下你现在说不出口，但希望未来能被理解的话。',
          ),
          WorldChannel(
            id: 'c2',
            name: '今天很累',
            description: '如果你觉得累，可以在这里停一会儿。',
          ),
          WorldChannel(id: 'c3', name: '第一次', description: '那些让你惊喜或感动的第一次。'),
          WorldChannel(id: 'c4', name: '只是爱', description: '不需要理由，只是想说爱你。'),
        ],
    error: (_, __) => const [],
  );
});

// ============== 留言相关 ==============

/// 评论 Provider 的参数类型
typedef CommentProviderKey = (String targetId, CommentTargetType targetType);

/// 评论 Provider (按 targetId 和 targetType 获取)
final commentsProvider = StateNotifierProvider.family<
  CommentsNotifier,
  List<Comment>,
  CommentProviderKey
>((ref, key) {
  final repo = ref.watch(commentRepositoryProvider);
  return CommentsNotifier(repo, key.$1, key.$2);
});

class CommentsNotifier extends StateNotifier<List<Comment>> {
  final CommentRepository _repo;
  final String targetId;
  final CommentTargetType targetType;
  bool _initialized = false;

  CommentsNotifier(this._repo, this.targetId, this.targetType) : super([]) {
    _loadComments();
  }

  Future<void> _loadComments() async {
    if (_initialized) return;

    try {
      final result =
          targetType == CommentTargetType.moment
              ? await _repo.getMomentComments(targetId)
              : await _repo.getWorldPostComments(targetId);
      state = result.comments;
      _initialized = true;
    } catch (e) {
      debugPrint('[Comments] Failed to load comments: $e');
    }
  }

  Future<void> refresh() async {
    try {
      final result =
          targetType == CommentTargetType.moment
              ? await _repo.getMomentComments(targetId)
              : await _repo.getWorldPostComments(targetId);
      state = result.comments;
    } catch (e) {
      debugPrint('[Comments] Failed to refresh: $e');
    }
  }

  Future<void> addComment(Comment comment) async {
    try {
      final created =
          targetType == CommentTargetType.moment
              ? await _repo.addMomentComment(
                momentId: targetId,
                content: comment.content,
              )
              : await _repo.addWorldPostComment(
                postId: targetId,
                content: comment.content,
              );
      state = [...state, created];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteComment(String id) async {
    try {
      await _repo.deleteComment(id);
      state = state.where((c) => c.id != id).toList();
    } catch (e) {
      rethrow;
    }
  }
}

// ============== 向后兼容：保留 databaseServiceProvider ==============
// 注意: 这个 Provider 已废弃，仅为保持编译通过
// 后续应该逐步移除对它的依赖

/// @deprecated 使用 Repository Providers 代替
final databaseServiceProvider = Provider<_DeprecatedDatabaseService>((ref) {
  return _DeprecatedDatabaseService();
});

class _DeprecatedDatabaseService {
  Future<void> init() async {}
}
