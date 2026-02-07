import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tables.dart';

part 'moments_dao.g.dart';

/// Data Access Object for Moments
@DriftAccessor(tables: [Moments, Users, MomentCacheInfo])
class MomentsDao extends DatabaseAccessor<AppDatabase> with _$MomentsDaoMixin {
  MomentsDao(super.db);

  /// Get all moments for a circle, ordered by timestamp descending
  Future<List<MomentWithAuthor>> getMomentsForCircle(
    String circleId, {
    int? limit,
    int? offset,
    String? authorId,
    String? mediaType,
    bool? isFavorite,
    int? year,
  }) {
    final query =
        select(
            moments,
          ).join([leftOuterJoin(users, users.id.equalsExp(moments.authorId))])
          ..where(moments.circleId.equals(circleId))
          ..where(moments.deletedAt.isNull())
          ..orderBy([OrderingTerm.desc(moments.timestamp)]);

    if (authorId != null) {
      query.where(moments.authorId.equals(authorId));
    }
    if (mediaType != null) {
      query.where(moments.mediaType.equals(mediaType));
    }
    if (isFavorite == true) {
      query.where(moments.isFavorite.equals(true));
    }
    if (year != null) {
      // Filter by year using SQLite strftime
      query.where(moments.timestamp.year.equals(year));
    }
    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.map((row) {
      return MomentWithAuthor(
        moment: row.readTable(moments),
        author: row.readTableOrNull(users),
      );
    }).get();
  }

  /// Get a single moment by ID with author
  Future<MomentWithAuthor?> getMomentById(String id) {
    final query =
        select(
            moments,
          ).join([leftOuterJoin(users, users.id.equalsExp(moments.authorId))])
          ..where(moments.id.equals(id))
          ..where(moments.deletedAt.isNull());

    return query.map((row) {
      return MomentWithAuthor(
        moment: row.readTable(moments),
        author: row.readTableOrNull(users),
      );
    }).getSingleOrNull();
  }

  /// Get moment count for a circle
  Future<int> getMomentCount(String circleId) async {
    final count = moments.id.count();
    final query =
        selectOnly(moments)
          ..addColumns([count])
          ..where(moments.circleId.equals(circleId))
          ..where(moments.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Insert or update a moment
  Future<void> upsertMoment(MomentsCompanion moment) {
    return into(moments).insertOnConflictUpdate(moment);
  }

  /// Insert multiple moments (batch)
  Future<void> upsertMoments(List<MomentsCompanion> momentList) {
    return batch((batch) {
      batch.insertAllOnConflictUpdate(moments, momentList);
    });
  }

  /// Update moment sync status
  Future<void> updateSyncStatus(String id, int status) {
    return (update(moments)..where(
      (m) => m.id.equals(id),
    )).write(MomentsCompanion(syncStatus: Value(status)));
  }

  /// Get moments pending sync
  Future<List<Moment>> getPendingMoments() {
    return (select(moments)
          ..where((m) => m.syncStatus.isBiggerThanValue(0))
          ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
        .get();
  }

  /// Soft delete a moment
  Future<void> softDelete(String id) {
    return (update(moments)..where((m) => m.id.equals(id))).write(
      MomentsCompanion(
        deletedAt: Value(DateTime.now()),
        syncStatus: const Value(3), // pendingDelete
      ),
    );
  }

  /// Toggle favorite
  Future<bool> toggleFavorite(String id) async {
    final moment =
        await (select(moments)
          ..where((m) => m.id.equals(id))).getSingleOrNull();
    if (moment == null) return false;

    final newValue = !moment.isFavorite;
    await (update(moments)..where((m) => m.id.equals(id))).write(
      MomentsCompanion(
        isFavorite: Value(newValue),
        syncStatus: const Value(2), // pendingUpdate
      ),
    );
    return newValue;
  }

  /// Watch moments for a circle (real-time updates)
  Stream<List<MomentWithAuthor>> watchMomentsForCircle(String circleId) {
    final query =
        select(
            moments,
          ).join([leftOuterJoin(users, users.id.equalsExp(moments.authorId))])
          ..where(moments.circleId.equals(circleId))
          ..where(moments.deletedAt.isNull())
          ..orderBy([OrderingTerm.desc(moments.timestamp)]);

    return query.map((row) {
      return MomentWithAuthor(
        moment: row.readTable(moments),
        author: row.readTableOrNull(users),
      );
    }).watch();
  }

  /// Get available years for filtering
  Future<List<int>> getAvailableYears(String circleId) async {
    final query = customSelect(
      'SELECT DISTINCT strftime(\'%Y\', timestamp) as year FROM moments '
      'WHERE circle_id = ? AND deleted_at IS NULL ORDER BY year DESC',
      variables: [Variable.withString(circleId)],
      readsFrom: {moments},
    );

    final results = await query.get();
    return results.map((row) => int.parse(row.read<String>('year'))).toList();
  }

  /// Update cache info
  Future<void> updateCacheInfo(MomentCacheInfoCompanion info) {
    return into(momentCacheInfo).insertOnConflictUpdate(info);
  }

  /// Get cache info
  Future<MomentCacheInfoData?> getCacheInfo(
    String circleId,
    String filterHash,
  ) {
    return (select(momentCacheInfo)
          ..where((c) => c.circleId.equals(circleId))
          ..where((c) => c.filterHash.equals(filterHash)))
        .getSingleOrNull();
  }

  /// Clear all moments for a circle
  Future<void> clearCircleMoments(String circleId) {
    return (delete(moments)..where((m) => m.circleId.equals(circleId))).go();
  }
}

/// Moment with author info
class MomentWithAuthor {
  final Moment moment;
  final User? author;

  MomentWithAuthor({required this.moment, this.author});
}
