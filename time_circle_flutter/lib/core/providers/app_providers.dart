import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';

/// 当前用户
final currentUserProvider = Provider<User>((ref) {
  return const User(
    id: 'u1',
    name: '爸爸',
    avatar: 'https://picsum.photos/seed/dad/100/100',
    role: UserRole.dad,
  );
});

/// 孩子信息
final childInfoProvider = Provider<ChildInfo>((ref) {
  return ChildInfo(
    name: '米洛',
    birthDate: DateTime(2021, 5, 15),
  );
});

/// 家庭成员
final familyMembersProvider = Provider<List<User>>((ref) {
  return const [
    User(
      id: 'u1',
      name: '爸爸',
      avatar: 'https://picsum.photos/seed/dad/100/100',
      role: UserRole.dad,
    ),
    User(
      id: 'u2',
      name: '妈妈',
      avatar: 'https://picsum.photos/seed/mom/100/100',
      role: UserRole.mom,
    ),
  ];
});

/// 时刻/记录列表
final momentsProvider = StateNotifierProvider<MomentsNotifier, List<Moment>>((ref) {
  final childInfo = ref.watch(childInfoProvider);
  final currentUser = ref.watch(currentUserProvider);
  final mom = const User(
    id: 'u2',
    name: '妈妈',
    avatar: 'https://picsum.photos/seed/mom/100/100',
    role: UserRole.mom,
  );
  
  return MomentsNotifier([
    Moment(
      id: 'm1',
      author: currentUser,
      content: '他终于知道怎么把方形积木放进方形孔里了。那得意的表情真是无价。',
      mediaType: MediaType.video,
      mediaUrl: 'https://picsum.photos/seed/video1/400/300',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      childAgeLabel: childInfo.ageLabel,
      contextTags: const [
        ContextTag(type: ContextTagType.parentMood, label: '骄傲', emoji: '🥹'),
        ContextTag(type: ContextTagType.childState, label: '专注', emoji: '🧐'),
      ],
      isFavorite: true,
    ),
    Moment(
      id: 'm2',
      author: mom,
      content: '一个安静的早晨，读读书。就是这种时刻我想永远定格。',
      mediaType: MediaType.image,
      mediaUrl: 'https://picsum.photos/seed/reading/400/400',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      childAgeLabel: childInfo.ageLabel,
      contextTags: const [
        ContextTag(type: ContextTagType.parentMood, label: '平静', emoji: '😌'),
        ContextTag(type: ContextTagType.childState, label: '黏人', emoji: '🐨'),
      ],
    ),
    Moment(
      id: 'm3',
      author: currentUser,
      content: '只是今天他笑的声音。',
      mediaType: MediaType.audio,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      childAgeLabel: '${childInfo.ageLabel.split(' ').first} 4 个月',
      contextTags: const [
        ContextTag(type: ContextTagType.parentMood, label: '开心', emoji: '😊'),
      ],
    ),
    Moment(
      id: 'm4',
      author: mom,
      content: '今天第一次自己穿上了鞋子，虽然穿反了，但是那个自豪的小表情，让我心都化了。',
      mediaType: MediaType.image,
      mediaUrl: 'https://picsum.photos/seed/shoes/400/500',
      timestamp: DateTime.now().subtract(const Duration(days: 10)),
      childAgeLabel: childInfo.ageLabel,
      contextTags: const [
        ContextTag(type: ContextTagType.parentMood, label: '开心', emoji: '😊'),
        ContextTag(type: ContextTagType.childState, label: '在进步', emoji: '🧠'),
      ],
      futureMessage: '原来你也会长这么快',
    ),
  ]);
});

class MomentsNotifier extends StateNotifier<List<Moment>> {
  MomentsNotifier(super.state);
  
  void addMoment(Moment moment) {
    state = [moment, ...state];
  }
  
  void toggleFavorite(String id) {
    state = state.map((m) {
      if (m.id == id) {
        return m.copyWith(isFavorite: !m.isFavorite);
      }
      return m;
    }).toList();
  }
  
  void deleteMoment(String id) {
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

/// 信件列表
final lettersProvider = StateNotifierProvider<LettersNotifier, List<Letter>>((ref) {
  return LettersNotifier([
    Letter(
      id: 'l1',
      title: '给 4 岁的米洛',
      preview: '这一年过得太快了。我还记得...',
      status: LetterStatus.draft,
      recipient: '米洛',
      type: LetterType.annual,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Letter(
      id: 'l2',
      title: '在你上幼儿园的第一天',
      preview: '你今天真勇敢。你甚至没有回头...',
      status: LetterStatus.sealed,
      unlockDate: DateTime(2039, 5, 15),
      recipient: '米洛',
      type: LetterType.milestone,
      sealedAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
    Letter(
      id: 'l3',
      title: '给 2 岁的米洛',
      preview: '我们挺过了可怕的两岁！大部分时候吧。',
      status: LetterStatus.unlocked,
      recipient: '米洛',
      type: LetterType.annual,
      content: '''亲爱的米洛：

当你读到这封信时，你可能已经长大了，不记得两岁时的样子。

那是我们最"艰难"也最甜蜜的一年。你学会了说"不"，学会了自己穿鞋（虽然总是穿反），还学会了在睡前给我们一个湿漉漉的吻。

记得有一次，你因为冰淇淋掉在地上哭了好久，那时候我觉得好累，但现在回想起来，你哭鼻子的样子也那么可爱。我们作为新手父母，也在这一年里学到了很多：耐心不是天生的，是为你练出来的。

希望未来的你，依然保持这份对世界的好奇，哪怕偶尔会跌倒，也没关系。

爱你的，
爸爸妈妈''',
      sealedAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
  ]);
});

class LettersNotifier extends StateNotifier<List<Letter>> {
  LettersNotifier(super.state);
  
  void addLetter(Letter letter) {
    state = [letter, ...state];
  }
  
  void updateLetter(Letter letter) {
    state = state.map((l) {
      if (l.id == letter.id) {
        return letter;
      }
      return l;
    }).toList();
  }
  
  void sealLetter(String id) {
    state = state.map((l) {
      if (l.id == id) {
        return l.copyWith(
          status: LetterStatus.sealed,
          sealedAt: DateTime.now(),
        );
      }
      return l;
    }).toList();
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

/// 世界频道帖子
final worldPostsProvider = StateNotifierProvider<WorldPostsNotifier, List<WorldPost>>((ref) {
  return WorldPostsNotifier([
    WorldPost(
      id: 'wp1',
      content: '有时候我躲在厕所里只是为了那 5 分钟的安静。你不是一个人。',
      tag: '今天很累',
      bgGradient: 'orange',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    WorldPost(
      id: 'wp2',
      content: '那天晚上，他一直不睡。我抱着他，在客厅走了 40 分钟。那一刻我突然觉得，原来我真的在当父母了。',
      tag: '今天很累',
      bgGradient: 'blue',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    WorldPost(
      id: 'wp3',
      content: '希望你长大后能理解，那些我不在场的时刻，不是因为不爱你。',
      tag: '写给未来',
      bgGradient: 'violet',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    WorldPost(
      id: 'wp4',
      content: '第一次看他自己走过来的时候，我愣住了好几秒。',
      tag: '第一次',
      bgGradient: 'green',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    WorldPost(
      id: 'wp5',
      content: '他今天说的第一句话是"妈妈抱"，我当场就哭了。',
      tag: '只是爱',
      bgGradient: 'peach',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ]);
});

class WorldPostsNotifier extends StateNotifier<List<WorldPost>> {
  WorldPostsNotifier(super.state);
  
  void toggleResonance(String id) {
    state = state.map((p) {
      if (p.id == id) {
        return p.copyWith(
          hasResonated: !p.hasResonated,
          resonanceCount: p.hasResonated 
              ? p.resonanceCount - 1 
              : p.resonanceCount + 1,
        );
      }
      return p;
    }).toList();
  }
}

/// 世界频道主题
final worldChannelsProvider = Provider<List<WorldChannel>>((ref) {
  return const [
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
    WorldChannel(
      id: 'c3',
      name: '第一次',
      description: '那些让你惊喜或感动的第一次。',
    ),
    WorldChannel(
      id: 'c4',
      name: '只是爱',
      description: '不需要理由，只是想说爱你。',
    ),
  ];
});
