import 'package:drift/drift.dart';

import '../../../core/storage/database/app_database.dart';
import '../../../core/storage/database/daos/letters_dao.dart';
import '../../../domain/entities/letter.dart' as domain;
import '../../../domain/entities/user.dart' as domain_user;
import '../../models/letter_model.dart';

/// Sync status for offline-first architecture
enum LocalSyncStatus {
  synced,
  pendingCreate,
  pendingUpdate,
  pendingDelete,
  failed,
}

/// Local data source for Letter operations
/// Handles all SQLite database operations for letters
abstract class LetterLocalDataSource {
  /// Get letters for a circle with optional filters
  Future<List<domain.Letter>> getLetters({
    required String circleId,
    int? limit,
    int? offset,
    String? status,
    String? type,
  });

  /// Watch letters for a circle (real-time updates)
  Stream<List<domain.Letter>> watchLetters(String circleId);

  /// Get a single letter by ID
  Future<domain.Letter?> getLetterById(String id);

  /// Get letters by status
  Future<List<domain.Letter>> getLettersByStatus(
    String circleId,
    domain.LetterStatus status,
  );

  /// Get letters that can be unlocked
  Future<List<domain.Letter>> getUnlockableLetters(String circleId);

  /// Insert or update a letter
  Future<void> saveLetter(domain.Letter letter);

  /// Insert or update multiple letters (batch)
  Future<void> saveLetters(List<domain.Letter> letters);

  /// Soft delete a letter
  Future<void> deleteLetter(String id);

  /// Update letter status (seal or unlock)
  Future<void> updateLetterStatus(
    String id, {
    required domain.LetterStatus status,
    DateTime? sealedAt,
    DateTime? unlockDate,
  });

  /// Get letters pending sync
  Future<List<domain.Letter>> getPendingLetters();

  /// Update sync status for a letter
  Future<void> updateSyncStatus(String id, LocalSyncStatus status);

  /// Get letter count for a circle
  Future<int> getLetterCount(String circleId);

  /// Get letter stats (counts by status)
  Future<LetterStatsModel> getLetterStats(String circleId);

  /// Clear all letters for a circle
  Future<void> clearCircleLetters(String circleId);
}

/// Implementation of LetterLocalDataSource using Drift DAO
class LetterLocalDataSourceImpl implements LetterLocalDataSource {
  final LettersDao _lettersDao;
  final AppDatabase _database;

  LetterLocalDataSourceImpl(this._lettersDao, this._database);

  @override
  Future<List<domain.Letter>> getLetters({
    required String circleId,
    int? limit,
    int? offset,
    String? status,
    String? type,
  }) async {
    final results = await _lettersDao.getLettersForCircle(
      circleId,
      limit: limit,
      offset: offset,
      status: status,
      type: type,
    );

    return results.map(_letterWithAuthorToEntity).toList();
  }

  @override
  Stream<List<domain.Letter>> watchLetters(String circleId) {
    return _lettersDao
        .watchLettersForCircle(circleId)
        .map((list) => list.map(_letterWithAuthorToEntity).toList());
  }

  @override
  Future<domain.Letter?> getLetterById(String id) async {
    final result = await _lettersDao.getLetterById(id);
    return result != null ? _letterWithAuthorToEntity(result) : null;
  }

  @override
  Future<List<domain.Letter>> getLettersByStatus(
    String circleId,
    domain.LetterStatus status,
  ) async {
    final results = await _lettersDao.getLettersByStatus(circleId, status.name);
    return results.map(_letterWithAuthorToEntity).toList();
  }

  @override
  Future<List<domain.Letter>> getUnlockableLetters(String circleId) async {
    final results = await _lettersDao.getUnlockableLetters(circleId);
    return results.map(_letterWithAuthorToEntity).toList();
  }

  @override
  Future<void> saveLetter(domain.Letter letter) async {
    final companion = _letterToCompanion(letter);
    await _lettersDao.upsertLetter(companion);

    // Also save/update the author user if present
    if (letter.author != null) {
      await _database.getOrCreateUser(_userToCompanion(letter.author!));
    }
  }

  @override
  Future<void> saveLetters(List<domain.Letter> letters) async {
    // First, save all unique authors
    final uniqueAuthors = <String, domain_user.User>{};
    for (final letter in letters) {
      if (letter.author != null) {
        uniqueAuthors[letter.author!.id] = letter.author!;
      }
    }

    for (final author in uniqueAuthors.values) {
      await _database.getOrCreateUser(_userToCompanion(author));
    }

    // Then batch save letters
    final companions = letters.map(_letterToCompanion).toList();
    await _lettersDao.upsertLetters(companions);
  }

  @override
  Future<void> deleteLetter(String id) async {
    await _lettersDao.softDelete(id);
  }

  @override
  Future<void> updateLetterStatus(
    String id, {
    required domain.LetterStatus status,
    DateTime? sealedAt,
    DateTime? unlockDate,
  }) async {
    await _lettersDao.updateLetterStatus(
      id,
      status: status.name,
      sealedAt: sealedAt,
      unlockDate: unlockDate,
    );
  }

  @override
  Future<List<domain.Letter>> getPendingLetters() async {
    final results = await _lettersDao.getPendingLetters();
    return results.map(_dbLetterToEntity).toList();
  }

  @override
  Future<void> updateSyncStatus(String id, LocalSyncStatus status) async {
    await _lettersDao.updateSyncStatus(id, status.index);
  }

  @override
  Future<int> getLetterCount(String circleId) async {
    return _lettersDao.getLetterCount(circleId);
  }

  @override
  Future<LetterStatsModel> getLetterStats(String circleId) async {
    final stats = await _lettersDao.getLetterStats(circleId);
    return LetterStatsModel(
      total: stats.total,
      draft: stats.draft,
      sealed: stats.sealed,
      unlocked: stats.unlocked,
    );
  }

  @override
  Future<void> clearCircleLetters(String circleId) async {
    await _lettersDao.clearCircleLetters(circleId);
  }

  // ============ Conversion Helpers ============

  /// Convert LetterWithAuthor (DAO result) to domain Letter entity
  domain.Letter _letterWithAuthorToEntity(LetterWithAuthor result) {
    final letter = result.letter;
    final author = result.author;

    return domain.Letter(
      id: letter.id,
      circleId: letter.circleId,
      author: author != null ? _userToEntity(author) : null,
      title: letter.title,
      preview: letter.preview,
      content: letter.content,
      status: domain.LetterStatus.fromString(letter.status),
      type: domain.LetterType.fromString(letter.type),
      recipient: letter.recipient,
      unlockDate: letter.unlockDate,
      createdAt: letter.createdAt,
      sealedAt: letter.sealedAt,
      updatedAt: letter.updatedAt,
    );
  }

  /// Convert database Letter to domain entity (without author join)
  domain.Letter _dbLetterToEntity(Letter dbLetter) {
    return domain.Letter(
      id: dbLetter.id,
      circleId: dbLetter.circleId,
      author: null,
      title: dbLetter.title,
      preview: dbLetter.preview,
      content: dbLetter.content,
      status: domain.LetterStatus.fromString(dbLetter.status),
      type: domain.LetterType.fromString(dbLetter.type),
      recipient: dbLetter.recipient,
      unlockDate: dbLetter.unlockDate,
      createdAt: dbLetter.createdAt,
      sealedAt: dbLetter.sealedAt,
      updatedAt: dbLetter.updatedAt,
    );
  }

  /// Convert domain User to database Companion
  UsersCompanion _userToCompanion(domain_user.User user) {
    return UsersCompanion(
      id: Value(user.id),
      name: Value(user.name),
      email: Value(user.email ?? ''),
      avatar: Value(user.avatar.isNotEmpty ? user.avatar : null),
      createdAt: Value(user.createdAt ?? DateTime.now()),
    );
  }

  /// Convert database User to domain entity
  domain_user.User _userToEntity(User dbUser) {
    return domain_user.User(
      id: dbUser.id,
      name: dbUser.name,
      avatar: dbUser.avatar ?? '',
      email: dbUser.email,
      createdAt: dbUser.createdAt,
    );
  }

  /// Convert domain Letter to database Companion
  LettersCompanion _letterToCompanion(domain.Letter letter) {
    return LettersCompanion(
      id: Value(letter.id),
      circleId: Value(letter.circleId),
      authorId: Value(letter.author?.id ?? ''),
      title: Value(letter.title),
      preview: Value(letter.preview ?? ''),
      content: Value(letter.content),
      status: Value(letter.status.name),
      type: Value(letter.type.name),
      recipient: Value(letter.recipient ?? ''),
      unlockDate: Value(letter.unlockDate),
      createdAt: Value(letter.createdAt),
      sealedAt: Value(letter.sealedAt),
      updatedAt: Value(letter.updatedAt),
    );
  }
}

/// Extension to convert LetterModel to domain entity
extension LetterModelExtension on LetterModel {
  /// Convert to domain entity
  domain.Letter toEntityWithDefaults() {
    return domain.Letter(
      id: id,
      circleId: circleId,
      author: author?.toEntity(),
      title: title,
      preview: preview,
      content: content,
      status: status.toEntity(),
      type: type.toEntity(),
      recipient: recipient,
      unlockDate: unlockDate,
      createdAt: createdAt,
      sealedAt: sealedAt,
      updatedAt: updatedAt,
    );
  }
}
