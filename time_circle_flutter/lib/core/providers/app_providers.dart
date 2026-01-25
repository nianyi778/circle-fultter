import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/models.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import 'auth_providers.dart';

/// 数据库服务 Provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// ============== 用户相关 ==============

/// 当前用户 Provider（异步）
final currentUserProvider = FutureProvider<User>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getCurrentUser();
});

/// 当前用户（同步访问，需要先加载）
final currentUserSyncProvider = Provider<User>((ref) {
  final asyncUser = ref.watch(currentUserProvider);
  return asyncUser.when(
    data: (user) => user,
    loading: () => const User(id: 'u1', name: '我', avatar: ''),
    error: (_, __) => const User(id: 'u1', name: '我', avatar: ''),
  );
});

/// 圈子成员 Provider
final circleMembersProvider = FutureProvider<List<User>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getUsers();
});

// ============== 圈子信息相关 ==============

/// 圈子信息 Provider（异步）
final circleInfoAsyncProvider = FutureProvider<CircleInfo>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  final selectedCircle = ref.watch(selectedCircleInfoProvider);

  if (selectedCircle != null) {
    await db.updateCircleInfo(selectedCircle);
    await db.backfillCircleId(selectedCircle.id ?? 'cir_default');
  }

  return await db.getCircleInfo();
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

/// 时刻列表 Provider
final momentsProvider = StateNotifierProvider<MomentsNotifier, List<Moment>>((
  ref,
) {
  final db = ref.watch(databaseServiceProvider);
  return MomentsNotifier(db);
});

class MomentsNotifier extends StateNotifier<List<Moment>> {
  final DatabaseService _db;
  bool _initialized = false;

  MomentsNotifier(this._db) : super([]) {
    _loadMoments();
  }

  Future<void> _loadMoments() async {
    if (_initialized) return;
    final moments = await _db.getMoments();
    state = moments;
    _initialized = true;
  }

  Future<void> refresh() async {
    final moments = await _db.getMoments();
    state = moments;
  }

  Future<void> addMoment(Moment moment) async {
    final now = DateTime.now();
    final persisted = moment.copyWith(
      createdAt: moment.createdAt ?? now,
      updatedAt: moment.updatedAt ?? now,
    );
    await _db.insertMoment(persisted);
    state = [persisted, ...state];
    // 记录同步
    SyncService.instance.recordMomentCreate(persisted);
  }

  Future<void> toggleFavorite(String id) async {
    final index = state.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final moment = state[index];
    final updated = moment.copyWith(
      isFavorite: !moment.isFavorite,
      updatedAt: DateTime.now(),
    );
    await _db.updateMoment(updated);

    state = [...state.sublist(0, index), updated, ...state.sublist(index + 1)];
    // 记录同步
    SyncService.instance.recordMomentUpdate(updated);
  }

  Future<void> deleteMoment(String id) async {
    final index = state.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final moment = state[index];
    final deleted = moment.copyWith(deletedAt: DateTime.now());
    await _db.updateMoment(deleted);
    state = state.where((m) => m.id != id).toList();
    // 记录同步
    SyncService.instance.recordMomentDelete(id);
  }

  /// 分享到世界
  Future<void> shareToWorld(String momentId, String topic) async {
    final index = state.indexWhere((m) => m.id == momentId);
    if (index == -1) return;

    final moment = state[index];

    // 更新 Moment 状态
    final updated = moment.copyWith(
      isSharedToWorld: true,
      worldTopic: topic,
      updatedAt: DateTime.now(),
    );
    await _db.updateMoment(updated);

    // 创建 WorldPost
    final worldPost = WorldPost(
      id: const Uuid().v4(),
      momentId: momentId,
      content: moment.content,
      tag: topic,
      bgGradient: _getGradientForTopic(topic),
      timestamp: DateTime.now(),
    );
    await _db.insertWorldPost(worldPost);

    state = [...state.sublist(0, index), updated, ...state.sublist(index + 1)];
    // 记录同步
    SyncService.instance.recordMomentUpdate(updated);
  }

  /// 从世界撤回
  Future<void> withdrawFromWorld(String momentId) async {
    final index = state.indexWhere((m) => m.id == momentId);
    if (index == -1) return;

    final moment = state[index];

    // 更新 Moment 状态
    final updated = moment.copyWith(
      isSharedToWorld: false,
      worldTopic: null,
      updatedAt: DateTime.now(),
    );
    await _db.updateMoment(updated);

    // 删除 WorldPost
    await _db.deleteWorldPostByMomentId(momentId);

    state = [...state.sublist(0, index), updated, ...state.sublist(index + 1)];
    // 记录同步
    SyncService.instance.recordMomentUpdate(updated);
  }

  /// 根据话题获取背景渐变色
  String _getGradientForTopic(String topic) {
    switch (topic) {
      case '写给未来':
        return 'violet';
      case '今天很累':
        return 'blue';
      case '第一次':
        return 'green';
      case '只是爱':
        return 'peach';
      default:
        return 'orange';
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
  final db = ref.watch(databaseServiceProvider);
  return LettersNotifier(db);
});

class LettersNotifier extends StateNotifier<List<Letter>> {
  final DatabaseService _db;
  bool _initialized = false;

  LettersNotifier(this._db) : super([]) {
    _loadLetters();
  }

  Future<void> _loadLetters() async {
    if (_initialized) return;
    final letters = await _db.getLetters();
    state = letters;
    _initialized = true;
  }

  Future<void> refresh() async {
    final letters = await _db.getLetters();
    state = letters;
  }

  Future<void> addLetter(Letter letter) async {
    final now = DateTime.now();
    final persisted = letter.copyWith(
      createdAt: letter.createdAt ?? now,
      updatedAt: letter.updatedAt ?? now,
    );
    await _db.insertLetter(persisted);
    state = [persisted, ...state];
    // 记录同步
    SyncService.instance.recordLetterCreate(persisted);
  }

  Future<void> updateLetter(Letter letter) async {
    final updated = letter.copyWith(updatedAt: DateTime.now());
    await _db.updateLetter(updated);
    state =
        state.map((l) {
          if (l.id == updated.id) {
            return updated;
          }
          return l;
        }).toList();
    // 记录同步
    SyncService.instance.recordLetterUpdate(updated);
  }

  Future<void> sealLetter(String id) async {
    final index = state.indexWhere((l) => l.id == id);
    if (index == -1) return;

    final letter = state[index];
    final updated = letter.copyWith(
      status: LetterStatus.sealed,
      sealedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _db.updateLetter(updated);

    state = [...state.sublist(0, index), updated, ...state.sublist(index + 1)];
    // 记录同步
    SyncService.instance.recordLetterUpdate(updated);
  }

  Future<void> deleteLetter(String id) async {
    final index = state.indexWhere((l) => l.id == id);
    if (index == -1) return;

    final letter = state[index];
    final deleted = letter.copyWith(
      deletedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _db.updateLetter(deleted);
    state = state.where((l) => l.id != id).toList();
    // 记录同步
    SyncService.instance.recordLetterDelete(id);
  }

  Future<void> updateUnlockDate(String id, DateTime newDate) async {
    final index = state.indexWhere((l) => l.id == id);
    if (index == -1) return;

    final letter = state[index];
    final updated = letter.copyWith(
      unlockDate: newDate,
      updatedAt: DateTime.now(),
    );
    await _db.updateLetter(updated);

    state = [...state.sublist(0, index), updated, ...state.sublist(index + 1)];
    // 记录同步
    SyncService.instance.recordLetterUpdate(updated);
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
      final db = ref.watch(databaseServiceProvider);
      return WorldPostsNotifier(db);
    });

class WorldPostsNotifier extends StateNotifier<List<WorldPost>> {
  final DatabaseService _db;
  bool _initialized = false;

  WorldPostsNotifier(this._db) : super([]) {
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    if (_initialized) return;
    final posts = await _db.getWorldPosts();
    state = posts;
    _initialized = true;
  }

  Future<void> refresh() async {
    final posts = await _db.getWorldPosts();
    state = posts;
  }

  Future<void> addPost(WorldPost post) async {
    await _db.insertWorldPost(post);
    state = [post, ...state];
  }

  Future<void> toggleResonance(String id) async {
    final index = state.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final post = state[index];
    final updated = post.copyWith(
      hasResonated: !post.hasResonated,
      resonanceCount:
          post.hasResonated ? post.resonanceCount - 1 : post.resonanceCount + 1,
    );
    await _db.updateWorldPost(updated);

    state = [...state.sublist(0, index), updated, ...state.sublist(index + 1)];
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

  // 筛选去年同月同日的时刻
  return moments.where((m) {
    return m.timestamp.year == lastYear &&
        m.timestamp.month == now.month &&
        m.timestamp.day == now.day;
  }).toList();
});

/// 是否有足够的历史数据（用于判断是否显示某些区域）
/// 当圈子创建满一年时返回 true
final hasLastYearDataProvider = Provider<bool>((ref) {
  final circleInfo = ref.watch(circleInfoProvider);
  if (circleInfo.startDate == null) return false;

  final daysSinceStart =
      DateTime.now().difference(circleInfo.startDate!).inDays;
  // 圈子创建至少满一年
  return daysSinceStart >= 365;
});

/// 是否有足够的记录数据（用于显示统计区域）
final hasEnoughMomentsProvider = Provider<bool>((ref) {
  final moments = ref.watch(momentsProvider);
  // 至少需要 5 条记录才显示统计区域
  return moments.length >= 5;
});

/// 是否有任何记录（用于判断是否是全新用户）
final hasAnyMomentsProvider = Provider<bool>((ref) {
  final moments = ref.watch(momentsProvider);
  return moments.isNotEmpty;
});

/// 可用的筛选年份列表
final availableYearsProvider = Provider<List<String>>((ref) {
  final moments = ref.watch(momentsProvider);
  final years =
      moments.map((m) => m.timestamp.year.toString()).toSet().toList();
  years.sort((a, b) => b.compareTo(a)); // 降序
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
  final db = ref.watch(databaseServiceProvider);
  return await db.getWorldChannels();
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
  final db = ref.watch(databaseServiceProvider);
  return CommentsNotifier(db, key.$1, key.$2);
});

class CommentsNotifier extends StateNotifier<List<Comment>> {
  final DatabaseService _db;
  final String targetId;
  final CommentTargetType targetType;
  bool _initialized = false;

  CommentsNotifier(this._db, this.targetId, this.targetType) : super([]) {
    _loadComments();
  }

  Future<void> _loadComments() async {
    if (_initialized) return;
    final comments = await _db.getCommentsByTarget(targetId, targetType);
    state = comments;
    _initialized = true;
  }

  Future<void> refresh() async {
    final comments = await _db.getCommentsByTarget(targetId, targetType);
    state = comments;
  }

  Future<void> addComment(Comment comment) async {
    await _db.insertComment(comment);
    state = [...state, comment]; // 追加到末尾
  }

  Future<void> deleteComment(String id) async {
    await _db.deleteComment(id);
    state = state.where((c) => c.id != id).toList();
  }
}
