import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'letters_dao.g.dart';

/// Data Access Object for Letters
@DriftAccessor(tables: [Letters, Users])
class LettersDao extends DatabaseAccessor<AppDatabase> with _$LettersDaoMixin {
  LettersDao(super.db);

  /// Get all letters for a circle, ordered by creation time descending
  Future<List<LetterWithAuthor>> getLettersForCircle(
    String circleId, {
    int? limit,
    int? offset,
    String? status,
    String? type,
  }) {
    final query =
        select(
            letters,
          ).join([leftOuterJoin(users, users.id.equalsExp(letters.authorId))])
          ..where(letters.circleId.equals(circleId))
          ..where(letters.deletedAt.isNull())
          ..orderBy([OrderingTerm.desc(letters.createdAt)]);

    if (status != null) {
      query.where(letters.status.equals(status));
    }
    if (type != null) {
      query.where(letters.type.equals(type));
    }
    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.map((row) {
      return LetterWithAuthor(
        letter: row.readTable(letters),
        author: row.readTableOrNull(users),
      );
    }).get();
  }

  /// Get a single letter by ID with author
  Future<LetterWithAuthor?> getLetterById(String id) {
    final query =
        select(
            letters,
          ).join([leftOuterJoin(users, users.id.equalsExp(letters.authorId))])
          ..where(letters.id.equals(id))
          ..where(letters.deletedAt.isNull());

    return query.map((row) {
      return LetterWithAuthor(
        letter: row.readTable(letters),
        author: row.readTableOrNull(users),
      );
    }).getSingleOrNull();
  }

  /// Get letters by status
  Future<List<LetterWithAuthor>> getLettersByStatus(
    String circleId,
    String status,
  ) {
    final query =
        select(
            letters,
          ).join([leftOuterJoin(users, users.id.equalsExp(letters.authorId))])
          ..where(letters.circleId.equals(circleId))
          ..where(letters.status.equals(status))
          ..where(letters.deletedAt.isNull())
          ..orderBy([OrderingTerm.desc(letters.createdAt)]);

    return query.map((row) {
      return LetterWithAuthor(
        letter: row.readTable(letters),
        author: row.readTableOrNull(users),
      );
    }).get();
  }

  /// Get letters that can be unlocked (past unlock date, still sealed)
  Future<List<LetterWithAuthor>> getUnlockableLetters(String circleId) {
    final now = DateTime.now();
    final query =
        select(
            letters,
          ).join([leftOuterJoin(users, users.id.equalsExp(letters.authorId))])
          ..where(letters.circleId.equals(circleId))
          ..where(letters.status.equals('sealed'))
          ..where(letters.unlockDate.isSmallerOrEqualValue(now))
          ..where(letters.deletedAt.isNull())
          ..orderBy([OrderingTerm.asc(letters.unlockDate)]);

    return query.map((row) {
      return LetterWithAuthor(
        letter: row.readTable(letters),
        author: row.readTableOrNull(users),
      );
    }).get();
  }

  /// Get letter count for a circle
  Future<int> getLetterCount(String circleId) async {
    final count = letters.id.count();
    final query =
        selectOnly(letters)
          ..addColumns([count])
          ..where(letters.circleId.equals(circleId))
          ..where(letters.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Get letter stats (counts by status)
  Future<LetterStats> getLetterStats(String circleId) async {
    final results =
        await customSelect(
          '''
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN status = 'draft' THEN 1 ELSE 0 END) as draft,
        SUM(CASE WHEN status = 'sealed' THEN 1 ELSE 0 END) as sealed,
        SUM(CASE WHEN status = 'unlocked' THEN 1 ELSE 0 END) as unlocked
      FROM letters 
      WHERE circle_id = ? AND deleted_at IS NULL
      ''',
          variables: [Variable.withString(circleId)],
          readsFrom: {letters},
        ).getSingle();

    return LetterStats(
      total: results.read<int>('total'),
      draft: results.read<int>('draft'),
      sealed: results.read<int>('sealed'),
      unlocked: results.read<int>('unlocked'),
    );
  }

  /// Insert or update a letter
  Future<void> upsertLetter(LettersCompanion letter) {
    return into(letters).insertOnConflictUpdate(letter);
  }

  /// Insert multiple letters (batch)
  Future<void> upsertLetters(List<LettersCompanion> letterList) {
    return batch((batch) {
      batch.insertAllOnConflictUpdate(letters, letterList);
    });
  }

  /// Update letter sync status
  Future<void> updateSyncStatus(String id, int status) {
    return (update(letters)..where(
      (l) => l.id.equals(id),
    )).write(LettersCompanion(syncStatus: Value(status)));
  }

  /// Get letters pending sync
  Future<List<Letter>> getPendingLetters() {
    return (select(letters)
          ..where((l) => l.syncStatus.isBiggerThanValue(0))
          ..orderBy([(l) => OrderingTerm.asc(l.createdAt)]))
        .get();
  }

  /// Update letter status (seal or unlock)
  Future<void> updateLetterStatus(
    String id, {
    required String status,
    DateTime? sealedAt,
    DateTime? unlockDate,
  }) {
    return (update(letters)..where((l) => l.id.equals(id))).write(
      LettersCompanion(
        status: Value(status),
        sealedAt: Value(sealedAt),
        unlockDate: Value(unlockDate),
        syncStatus: const Value(2), // pendingUpdate
      ),
    );
  }

  /// Soft delete a letter
  Future<void> softDelete(String id) {
    return (update(letters)..where((l) => l.id.equals(id))).write(
      LettersCompanion(
        deletedAt: Value(DateTime.now()),
        syncStatus: const Value(3), // pendingDelete
      ),
    );
  }

  /// Watch letters for a circle (real-time updates)
  Stream<List<LetterWithAuthor>> watchLettersForCircle(String circleId) {
    final query =
        select(
            letters,
          ).join([leftOuterJoin(users, users.id.equalsExp(letters.authorId))])
          ..where(letters.circleId.equals(circleId))
          ..where(letters.deletedAt.isNull())
          ..orderBy([OrderingTerm.desc(letters.createdAt)]);

    return query.map((row) {
      return LetterWithAuthor(
        letter: row.readTable(letters),
        author: row.readTableOrNull(users),
      );
    }).watch();
  }

  /// Clear all letters for a circle
  Future<void> clearCircleLetters(String circleId) {
    return (delete(letters)..where((l) => l.circleId.equals(circleId))).go();
  }
}

/// Letter with author info
class LetterWithAuthor {
  final Letter letter;
  final User? author;

  LetterWithAuthor({required this.letter, this.author});
}

/// Letter statistics
class LetterStats {
  final int total;
  final int draft;
  final int sealed;
  final int unlocked;

  const LetterStats({
    this.total = 0,
    this.draft = 0,
    this.sealed = 0,
    this.unlocked = 0,
  });
}
