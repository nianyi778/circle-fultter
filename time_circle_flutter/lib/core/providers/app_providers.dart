import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/database_service.dart';

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
    loading: () => const User(
      id: 'u1',
      name: '爸爸',
      avatar: '',
      role: UserRole.dad,
    ),
    error: (_, __) => const User(
      id: 'u1',
      name: '爸爸',
      avatar: '',
      role: UserRole.dad,
    ),
  );
});

/// 家庭成员 Provider
final familyMembersProvider = FutureProvider<List<User>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getUsers();
});

// ============== 孩子信息相关 ==============

/// 孩子信息 Provider（异步）
final childInfoAsyncProvider = FutureProvider<ChildInfo>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return await db.getChildInfo();
});

/// 孩子信息（同步访问）
final childInfoProvider = Provider<ChildInfo>((ref) {
  final asyncChild = ref.watch(childInfoAsyncProvider);
  return asyncChild.when(
    data: (child) => child,
    loading: () => ChildInfo(
      name: '宝贝',
      birthDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
    ),
    error: (_, __) => ChildInfo(
      name: '宝贝',
      birthDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
    ),
  );
});

// ============== 时刻相关 ==============

/// 时刻列表 Provider
final momentsProvider = StateNotifierProvider<MomentsNotifier, List<Moment>>((ref) {
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
    await _db.insertMoment(moment);
    state = [moment, ...state];
  }

  Future<void> toggleFavorite(String id) async {
    final index = state.indexWhere((m) => m.id == id);
    if (index == -1) return;
    
    final moment = state[index];
    final updated = moment.copyWith(isFavorite: !moment.isFavorite);
    await _db.updateMoment(updated);
    
    state = [
      ...state.sublist(0, index),
      updated,
      ...state.sublist(index + 1),
    ];
  }

  Future<void> deleteMoment(String id) async {
    await _db.deleteMoment(id);
    state = state.where((m) => m.id != id).toList();
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
final lettersProvider = StateNotifierProvider<LettersNotifier, List<Letter>>((ref) {
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
    await _db.insertLetter(letter);
    state = [letter, ...state];
  }

  Future<void> updateLetter(Letter letter) async {
    await _db.updateLetter(letter);
    state = state.map((l) {
      if (l.id == letter.id) {
        return letter;
      }
      return l;
    }).toList();
  }

  Future<void> sealLetter(String id) async {
    final index = state.indexWhere((l) => l.id == id);
    if (index == -1) return;
    
    final letter = state[index];
    final updated = letter.copyWith(
      status: LetterStatus.sealed,
      sealedAt: DateTime.now(),
    );
    await _db.updateLetter(updated);
    
    state = [
      ...state.sublist(0, index),
      updated,
      ...state.sublist(index + 1),
    ];
  }

  Future<void> deleteLetter(String id) async {
    await _db.deleteLetter(id);
    state = state.where((l) => l.id != id).toList();
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
final worldPostsProvider = StateNotifierProvider<WorldPostsNotifier, List<WorldPost>>((ref) {
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
      resonanceCount: post.hasResonated 
          ? post.resonanceCount - 1 
          : post.resonanceCount + 1,
    );
    await _db.updateWorldPost(updated);
    
    state = [
      ...state.sublist(0, index),
      updated,
      ...state.sublist(index + 1),
    ];
  }
}

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
    loading: () => const [
      WorldChannel(id: 'c1', name: '写给未来', description: '写下你现在说不出口，但希望未来能被理解的话。'),
      WorldChannel(id: 'c2', name: '今天很累', description: '如果你觉得累，可以在这里停一会儿。'),
      WorldChannel(id: 'c3', name: '第一次', description: '那些让你惊喜或感动的第一次。'),
      WorldChannel(id: 'c4', name: '只是爱', description: '不需要理由，只是想说爱你。'),
    ],
    error: (_, __) => const [],
  );
});
