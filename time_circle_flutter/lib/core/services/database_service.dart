import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

/// 数据库服务 - 管理本地 SQLite 数据库
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'time_circle.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建表
  Future<void> _onCreate(Database db, int version) async {
    // 用户表
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatar TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // 孩子信息表
    await db.execute('''
      CREATE TABLE child_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        birth_date TEXT NOT NULL
      )
    ''');

    // 时刻表
    await db.execute('''
      CREATE TABLE moments (
        id TEXT PRIMARY KEY,
        author_id TEXT NOT NULL,
        content TEXT NOT NULL,
        media_type TEXT NOT NULL,
        media_url TEXT,
        timestamp TEXT NOT NULL,
        child_age_label TEXT NOT NULL,
        context_tags TEXT,
        location TEXT,
        is_favorite INTEGER DEFAULT 0,
        future_message TEXT,
        is_shared_to_world INTEGER DEFAULT 0,
        world_topic TEXT,
        FOREIGN KEY (author_id) REFERENCES users (id)
      )
    ''');

    // 信件表
    await db.execute('''
      CREATE TABLE letters (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        preview TEXT NOT NULL,
        status TEXT NOT NULL,
        unlock_date TEXT,
        recipient TEXT NOT NULL,
        type TEXT NOT NULL,
        content TEXT,
        created_at TEXT,
        sealed_at TEXT
      )
    ''');

    // 世界帖子表
    await db.execute('''
      CREATE TABLE world_posts (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        tag TEXT NOT NULL,
        resonance_count INTEGER DEFAULT 0,
        bg_gradient TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        has_resonated INTEGER DEFAULT 0
      )
    ''');

    // 世界频道表
    await db.execute('''
      CREATE TABLE world_channels (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        post_count INTEGER DEFAULT 0
      )
    ''');

    // 留言表
    await db.execute('''
      CREATE TABLE comments (
        id TEXT PRIMARY KEY,
        moment_id TEXT NOT NULL,
        author_id TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        likes INTEGER DEFAULT 0,
        reply_to_id TEXT,
        FOREIGN KEY (moment_id) REFERENCES moments (id) ON DELETE CASCADE,
        FOREIGN KEY (author_id) REFERENCES users (id),
        FOREIGN KEY (reply_to_id) REFERENCES users (id)
      )
    ''');

    // 设置表
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 初始化默认数据
    await _insertDefaultData(db);
  }

  /// 插入默认数据
  Future<void> _insertDefaultData(Database db) async {
    // 默认用户
    await db.insert('users', {
      'id': 'u1',
      'name': '我',
      'avatar': '',
      'role': '', // 用户自定义角色标签，留空表示未设置
    });

    await db.insert('users', {
      'id': 'u2',
      'name': 'TA',
      'avatar': '',
      'role': '',
    });

    // 默认圈子信息
    await db.insert('child_info', {
      'name': '我们的圈子',
      'birth_date':
          DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
    });

    // 默认世界频道
    final channels = [
      {'id': 'c1', 'name': '写给未来', 'description': '写下你现在说不出口，但希望未来能被理解的话。'},
      {'id': 'c2', 'name': '今天很累', 'description': '如果你觉得累，可以在这里停一会儿。'},
      {'id': 'c3', 'name': '第一次', 'description': '那些让你惊喜或感动的第一次。'},
      {'id': 'c4', 'name': '只是爱', 'description': '不需要理由，只是想说爱你。'},
    ];

    for (final channel in channels) {
      await db.insert('world_channels', {...channel, 'post_count': 0});
    }

    // 默认世界帖子
    final posts = [
      {
        'id': 'wp1',
        'content': '有时候我躲在厕所里只是为了那 5 分钟的安静。你不是一个人。',
        'tag': '今天很累',
        'resonance_count': 128,
        'bg_gradient': 'orange',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'has_resonated': 0,
      },
      {
        'id': 'wp2',
        'content': '那天晚上，他一直不睡。我抱着他，在客厅走了 40 分钟。那一刻我突然觉得，原来我真的在当父母了。',
        'tag': '今天很累',
        'resonance_count': 256,
        'bg_gradient': 'blue',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
        'has_resonated': 0,
      },
      {
        'id': 'wp3',
        'content': '希望你长大后能理解，那些我不在场的时刻，不是因为不爱你。',
        'tag': '写给未来',
        'resonance_count': 512,
        'bg_gradient': 'violet',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'has_resonated': 0,
      },
      {
        'id': 'wp4',
        'content': '第一次看他自己走过来的时候，我愣住了好几秒。',
        'tag': '第一次',
        'resonance_count': 89,
        'bg_gradient': 'green',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'has_resonated': 0,
      },
      {
        'id': 'wp5',
        'content': '他今天说的第一句话是"妈妈抱"，我当场就哭了。',
        'tag': '只是爱',
        'resonance_count': 342,
        'bg_gradient': 'peach',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'has_resonated': 0,
      },
      {
        'id': 'wp6',
        'content': '凌晨三点喂完奶，看着窗外的月亮，突然觉得这个世界好安静，只有我们两个。',
        'tag': '今天很累',
        'resonance_count': 178,
        'bg_gradient': 'blue',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        'has_resonated': 0,
      },
      {
        'id': 'wp7',
        'content': '等你 18 岁的时候，我会把这些年的日记给你看。到时候你就知道，爸爸妈妈有多爱你。',
        'tag': '写给未来',
        'resonance_count': 421,
        'bg_gradient': 'violet',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'has_resonated': 0,
      },
      {
        'id': 'wp8',
        'content': '第一次叫"爸爸"的时候，我假装很淡定，其实心里已经放烟花了。',
        'tag': '第一次',
        'resonance_count': 267,
        'bg_gradient': 'green',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
        'has_resonated': 0,
      },
      {
        'id': 'wp9',
        'content': '你睡着的样子，是我见过最美的风景。',
        'tag': '只是爱',
        'resonance_count': 589,
        'bg_gradient': 'peach',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'has_resonated': 0,
      },
      {
        'id': 'wp10',
        'content': '今天他发烧了，我一晚上没睡。当妈的心，真的是碎了又碎，碎了又黏。',
        'tag': '今天很累',
        'resonance_count': 445,
        'bg_gradient': 'orange',
        'timestamp':
            DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
        'has_resonated': 0,
      },
    ];

    for (final post in posts) {
      await db.insert('world_posts', post);
    }
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 版本 1 -> 2: 添加 comments 表
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS comments (
          id TEXT PRIMARY KEY,
          moment_id TEXT NOT NULL,
          author_id TEXT NOT NULL,
          content TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          likes INTEGER DEFAULT 0,
          reply_to_id TEXT,
          FOREIGN KEY (moment_id) REFERENCES moments (id) ON DELETE CASCADE,
          FOREIGN KEY (author_id) REFERENCES users (id),
          FOREIGN KEY (reply_to_id) REFERENCES users (id)
        )
      ''');
    }

    // 版本 2 -> 3: 添加 comments 表缺失字段 + moments 表世界分享字段
    if (oldVersion < 3) {
      // 添加 comments 表新字段
      try {
        await db.execute(
          'ALTER TABLE comments ADD COLUMN likes INTEGER DEFAULT 0',
        );
      } catch (_) {} // 字段可能已存在
      try {
        await db.execute('ALTER TABLE comments ADD COLUMN reply_to_id TEXT');
      } catch (_) {}

      // 添加 moments 表世界分享字段
      try {
        await db.execute(
          'ALTER TABLE moments ADD COLUMN is_shared_to_world INTEGER DEFAULT 0',
        );
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE moments ADD COLUMN world_topic TEXT');
      } catch (_) {}
    }

    // 版本 3 -> 4: 添加 settings 表
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      // 插入默认设置
      final now = DateTime.now().toIso8601String();
      final defaultSettings = {
        'annual_letter_reminder': 'true',
        'face_blur_enabled': 'true',
        'default_visibility': 'private',
        'time_lock_duration': '365',
      };
      for (final entry in defaultSettings.entries) {
        try {
          await db.insert('settings', {
            'key': entry.key,
            'value': entry.value,
            'updated_at': now,
          });
        } catch (_) {}
      }
    }
  }

  // ============== 用户相关 ==============

  /// 获取所有用户
  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((map) => _mapToUser(map)).toList();
  }

  /// 获取当前用户（默认第一个）
  Future<User> getCurrentUser() async {
    final users = await getUsers();
    return users.isNotEmpty ? users.first : _defaultUser();
  }

  /// 插入用户
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      _userToMap(user),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 更新用户
  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      _userToMap(user),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ============== 圈子信息相关 ==============

  /// 获取圈子信息
  Future<CircleInfo> getCircleInfo() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'child_info',
    ); // 保持表名兼容
    if (maps.isNotEmpty) {
      return CircleInfo(
        name: maps.first['name'] as String,
        startDate: DateTime.parse(maps.first['birth_date'] as String),
      );
    }
    return CircleInfo(
      name: '我们的圈子',
      startDate: DateTime.now().subtract(const Duration(days: 365)),
    );
  }

  /// 兼容旧代码的别名
  Future<CircleInfo> getChildInfo() => getCircleInfo();

  /// 更新圈子信息
  Future<void> updateCircleInfo(CircleInfo circleInfo) async {
    final db = await database;
    await db.delete('child_info'); // 保持表名兼容
    await db.insert('child_info', {
      'name': circleInfo.name,
      'birth_date':
          circleInfo.startDate?.toIso8601String() ??
          DateTime.now().toIso8601String(),
    });
  }

  /// 兼容旧代码的别名
  Future<void> updateChildInfo(CircleInfo info) => updateCircleInfo(info);

  // ============== 时刻相关 ==============

  /// 获取所有时刻
  Future<List<Moment>> getMoments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moments',
      orderBy: 'timestamp DESC',
    );

    final users = await getUsers();
    final userMap = {for (var u in users) u.id: u};

    return maps.map((map) => _mapToMoment(map, userMap)).toList();
  }

  /// 获取单个时刻
  Future<Moment?> getMomentById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moments',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final users = await getUsers();
    final userMap = {for (var u in users) u.id: u};

    return _mapToMoment(maps.first, userMap);
  }

  /// 插入时刻
  Future<void> insertMoment(Moment moment) async {
    final db = await database;
    await db.insert(
      'moments',
      _momentToMap(moment),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 更新时刻
  Future<void> updateMoment(Moment moment) async {
    final db = await database;
    await db.update(
      'moments',
      _momentToMap(moment),
      where: 'id = ?',
      whereArgs: [moment.id],
    );
  }

  /// 删除时刻
  Future<void> deleteMoment(String id) async {
    final db = await database;
    await db.delete('moments', where: 'id = ?', whereArgs: [id]);
  }

  // ============== 信件相关 ==============

  /// 获取所有信件
  Future<List<Letter>> getLetters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'letters',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => _mapToLetter(map)).toList();
  }

  /// 获取单个信件
  Future<Letter?> getLetterById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'letters',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return _mapToLetter(maps.first);
  }

  /// 插入信件
  Future<void> insertLetter(Letter letter) async {
    final db = await database;
    await db.insert(
      'letters',
      _letterToMap(letter),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 更新信件
  Future<void> updateLetter(Letter letter) async {
    final db = await database;
    await db.update(
      'letters',
      _letterToMap(letter),
      where: 'id = ?',
      whereArgs: [letter.id],
    );
  }

  /// 删除信件
  Future<void> deleteLetter(String id) async {
    final db = await database;
    await db.delete('letters', where: 'id = ?', whereArgs: [id]);
  }

  // ============== 世界帖子相关 ==============

  /// 获取所有世界帖子
  Future<List<WorldPost>> getWorldPosts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'world_posts',
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => _mapToWorldPost(map)).toList();
  }

  /// 插入世界帖子
  Future<void> insertWorldPost(WorldPost post) async {
    final db = await database;
    await db.insert(
      'world_posts',
      _worldPostToMap(post),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 更新世界帖子
  Future<void> updateWorldPost(WorldPost post) async {
    final db = await database;
    await db.update(
      'world_posts',
      _worldPostToMap(post),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  // ============== 留言相关 ==============

  /// 获取时刻的所有留言
  Future<List<Comment>> getCommentsByMomentId(String momentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'moment_id = ?',
      whereArgs: [momentId],
      orderBy: 'timestamp ASC',
    );

    final users = await getUsers();
    final userMap = {for (var u in users) u.id: u};

    return maps.map((map) => _mapToComment(map, userMap)).toList();
  }

  /// 插入留言
  Future<void> insertComment(Comment comment) async {
    final db = await database;
    await db.insert(
      'comments',
      _commentToMap(comment),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 删除留言
  Future<void> deleteComment(String id) async {
    final db = await database;
    await db.delete('comments', where: 'id = ?', whereArgs: [id]);
  }

  /// 删除时刻的所有留言
  Future<void> deleteCommentsByMomentId(String momentId) async {
    final db = await database;
    await db.delete('comments', where: 'moment_id = ?', whereArgs: [momentId]);
  }

  // ============== 世界频道相关 ==============

  /// 获取所有世界频道
  Future<List<WorldChannel>> getWorldChannels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('world_channels');
    return maps
        .map(
          (map) => WorldChannel(
            id: map['id'] as String,
            name: map['name'] as String,
            description: map['description'] as String,
            postCount: map['post_count'] as int? ?? 0,
          ),
        )
        .toList();
  }

  // ============== 工具方法 ==============

  User _defaultUser() => const User(id: 'u1', name: '我', avatar: '');

  Map<String, dynamic> _userToMap(User user) => {
    'id': user.id,
    'name': user.name,
    'avatar': user.avatar,
    'role': user.roleLabel ?? '',
  };

  User _mapToUser(Map<String, dynamic> map) => User(
    id: map['id'] as String,
    name: map['name'] as String,
    avatar: map['avatar'] as String? ?? '',
    roleLabel:
        (map['role'] as String?)?.isNotEmpty == true
            ? map['role'] as String
            : null,
  );

  Map<String, dynamic> _momentToMap(Moment moment) => {
    'id': moment.id,
    'author_id': moment.author.id,
    'content': moment.content,
    'media_type': moment.mediaType.name,
    'media_url': moment.mediaUrl,
    'timestamp': moment.timestamp.toIso8601String(),
    'child_age_label': moment.timeLabel, // 保持数据库字段名兼容
    'context_tags': jsonEncode(
      moment.contextTags
          .map((t) => {'type': t.type.name, 'label': t.label, 'emoji': t.emoji})
          .toList(),
    ),
    'location': moment.location,
    'is_favorite': moment.isFavorite ? 1 : 0,
    'future_message': moment.futureMessage,
    'is_shared_to_world': moment.isSharedToWorld ? 1 : 0,
    'world_topic': moment.worldTopic,
  };

  Moment _mapToMoment(Map<String, dynamic> map, Map<String, User> userMap) {
    final authorId = map['author_id'] as String;
    final author = userMap[authorId] ?? _defaultUser();

    List<ContextTag> contextTags = [];
    if (map['context_tags'] != null) {
      final tagsJson = jsonDecode(map['context_tags'] as String) as List;
      contextTags =
          tagsJson.map((t) {
            // 兼容旧数据：将 parentMood 映射为 myMood，childState 映射为 atmosphere
            var typeName = t['type'] as String;
            if (typeName == 'parentMood') typeName = 'myMood';
            if (typeName == 'childState') typeName = 'atmosphere';

            return ContextTag(
              type: ContextTagType.values.firstWhere(
                (ct) => ct.name == typeName,
                orElse: () => ContextTagType.myMood,
              ),
              label: t['label'] as String,
              emoji: t['emoji'] as String,
            );
          }).toList();
    }

    return Moment(
      id: map['id'] as String,
      author: author,
      content: map['content'] as String,
      mediaType: MediaType.values.firstWhere(
        (m) => m.name == map['media_type'],
        orElse: () => MediaType.text,
      ),
      mediaUrl: map['media_url'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      timeLabel: map['child_age_label'] as String,
      contextTags: contextTags,
      location: map['location'] as String?,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      futureMessage: map['future_message'] as String?,
      isSharedToWorld: (map['is_shared_to_world'] as int? ?? 0) == 1,
      worldTopic: map['world_topic'] as String?,
    );
  }

  Map<String, dynamic> _letterToMap(Letter letter) => {
    'id': letter.id,
    'title': letter.title,
    'preview': letter.preview,
    'status': letter.status.name,
    'unlock_date': letter.unlockDate?.toIso8601String(),
    'recipient': letter.recipient,
    'type': letter.type.name,
    'content': letter.content,
    'created_at': letter.createdAt?.toIso8601String(),
    'sealed_at': letter.sealedAt?.toIso8601String(),
  };

  Letter _mapToLetter(Map<String, dynamic> map) => Letter(
    id: map['id'] as String,
    title: map['title'] as String,
    preview: map['preview'] as String,
    status: LetterStatus.values.firstWhere(
      (s) => s.name == map['status'],
      orElse: () => LetterStatus.draft,
    ),
    unlockDate:
        map['unlock_date'] != null
            ? DateTime.parse(map['unlock_date'] as String)
            : null,
    recipient: map['recipient'] as String,
    type: LetterType.values.firstWhere(
      (t) => t.name == map['type'],
      orElse: () => LetterType.annual,
    ),
    content: map['content'] as String?,
    createdAt:
        map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : null,
    sealedAt:
        map['sealed_at'] != null
            ? DateTime.parse(map['sealed_at'] as String)
            : null,
  );

  Map<String, dynamic> _worldPostToMap(WorldPost post) => {
    'id': post.id,
    'content': post.content,
    'tag': post.tag,
    'resonance_count': post.resonanceCount,
    'bg_gradient': post.bgGradient,
    'timestamp': post.timestamp.toIso8601String(),
    'has_resonated': post.hasResonated ? 1 : 0,
  };

  WorldPost _mapToWorldPost(Map<String, dynamic> map) => WorldPost(
    id: map['id'] as String,
    content: map['content'] as String,
    tag: map['tag'] as String,
    resonanceCount: map['resonance_count'] as int? ?? 0,
    bgGradient: map['bg_gradient'] as String,
    timestamp: DateTime.parse(map['timestamp'] as String),
    hasResonated: (map['has_resonated'] as int? ?? 0) == 1,
  );

  Map<String, dynamic> _commentToMap(Comment comment) => {
    'id': comment.id,
    'moment_id': comment.momentId,
    'author_id': comment.author.id,
    'content': comment.content,
    'timestamp': comment.timestamp.toIso8601String(),
    'likes': comment.likes,
    'reply_to_id': comment.replyTo?.id,
  };

  Comment _mapToComment(Map<String, dynamic> map, Map<String, User> userMap) {
    final authorId = map['author_id'] as String;
    final author = userMap[authorId] ?? _defaultUser();

    final replyToId = map['reply_to_id'] as String?;
    final replyTo = replyToId != null ? userMap[replyToId] : null;

    return Comment(
      id: map['id'] as String,
      momentId: map['moment_id'] as String,
      author: author,
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      likes: map['likes'] as int? ?? 0,
      replyTo: replyTo,
    );
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// 清空所有数据（用于测试或重置）
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('moments');
    await db.delete('letters');
    await db.delete('world_posts');
  }

  // ============== 设置相关 ==============

  /// 获取所有设置
  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('settings');
    return {for (var m in maps) m['key'] as String: m['value'] as String};
  }

  /// 获取单个设置值
  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  /// 获取设置值（带默认值）
  Future<String> getSettingWithDefault(String key, String defaultValue) async {
    final value = await getSetting(key);
    return value ?? defaultValue;
  }

  /// 获取布尔设置
  Future<bool> getBoolSetting(String key, {bool defaultValue = false}) async {
    final value = await getSetting(key);
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  /// 获取整数设置
  Future<int> getIntSetting(String key, {int defaultValue = 0}) async {
    final value = await getSetting(key);
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// 保存设置
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 保存布尔设置
  Future<void> saveBoolSetting(String key, bool value) async {
    await saveSetting(key, value.toString());
  }

  /// 保存整数设置
  Future<void> saveIntSetting(String key, int value) async {
    await saveSetting(key, value.toString());
  }

  /// 删除设置
  Future<void> deleteSetting(String key) async {
    final db = await database;
    await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  /// 删除用户
  Future<void> deleteUser(String id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  /// 获取统计信息
  Future<Map<String, int>> getStatistics() async {
    final db = await database;
    final momentCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM moments'),
        ) ??
        0;
    final letterCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM letters'),
        ) ??
        0;
    final userCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM users'),
        ) ??
        0;

    // 计算有记录的天数
    final daysResult = await db.rawQuery('''
      SELECT COUNT(DISTINCT DATE(timestamp)) as days FROM moments
    ''');
    final recordedDays =
        daysResult.isNotEmpty ? (daysResult.first['days'] as int?) ?? 0 : 0;

    return {
      'momentCount': momentCount,
      'letterCount': letterCount,
      'userCount': userCount,
      'recordedDays': recordedDays,
    };
  }
}
