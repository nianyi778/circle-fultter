# Database Performance Guide

## Overview

This document outlines performance best practices for the Drift SQLite database in the TimeCircle Flutter app.

## Index Strategy

### Moments Table
```sql
-- Primary index (automatic)
PRIMARY KEY (id)

-- Query patterns require these indexes:
CREATE INDEX idx_moments_circle_timestamp ON moments(circle_id, timestamp DESC);
CREATE INDEX idx_moments_circle_author ON moments(circle_id, author_id);
CREATE INDEX idx_moments_sync_status ON moments(sync_status) WHERE sync_status > 0;
```

### Letters Table
```sql
PRIMARY KEY (id)

CREATE INDEX idx_letters_circle_status ON letters(circle_id, status);
CREATE INDEX idx_letters_unlock_date ON letters(unlock_date) WHERE status = 'sealed';
```

## Query Optimization

### 1. Pagination with Keyset (Recommended)

Instead of OFFSET-based pagination which degrades with large datasets:

```dart
// BAD: OFFSET pagination
query.limit(20, offset: page * 20);

// GOOD: Keyset pagination
query
  ..where(moments.timestamp.isSmallerThanValue(lastTimestamp))
  ..limit(20);
```

### 2. Select Only Needed Columns

```dart
// BAD: Select all columns
select(moments).get();

// GOOD: Select only needed
selectOnly(moments)
  ..addColumns([moments.id, moments.content, moments.timestamp]);
```

### 3. Batch Operations

```dart
// BAD: Individual inserts
for (final moment in moments) {
  await into(db.moments).insert(moment);
}

// GOOD: Batch insert
await batch((batch) {
  batch.insertAll(db.moments, moments);
});
```

### 4. Use Transactions

```dart
// Wrap related operations
await db.transaction(() async {
  await deleteOldMoments(circleId);
  await insertNewMoments(moments);
  await updateCacheInfo(cacheInfo);
});
```

## Cache Strategy

### Cache Metadata Table
```dart
class MomentCacheInfo extends Table {
  TextColumn get circleId => text()();
  TextColumn get filterHash => text()();  // Hash of filter params
  IntColumn get currentPage => integer()();
  IntColumn get totalItems => integer()();
  BoolColumn get hasMore => boolean()();
  DateTimeColumn get cachedAt => dateTime()();
}
```

### Cache Invalidation Rules
1. **Time-based**: Cache expires after 5 minutes
2. **Write-through**: Local writes invalidate affected cache
3. **Filter-based**: Different filters have separate cache entries

## Memory Management

### Stream Management
```dart
// GOOD: Dispose streams properly
late final StreamSubscription _subscription;

@override
void dispose() {
  _subscription.cancel();
  super.dispose();
}
```

### Database Connection
- Single database instance (singleton)
- Close on app terminate
- Use `LazyDatabase` for deferred initialization

## Monitoring

### Query Timing
```dart
extension QueryTiming<T> on Future<T> {
  Future<T> timed(String label) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await this;
    } finally {
      debugPrint('[$label] ${stopwatch.elapsedMilliseconds}ms');
    }
  }
}

// Usage
await getMoments(circleId).timed('getMoments');
```

### Slow Query Detection
Add logging for queries exceeding threshold:
```dart
const slowQueryThreshold = Duration(milliseconds: 100);

if (elapsed > slowQueryThreshold) {
  debugPrint('SLOW QUERY: $queryName took ${elapsed.inMilliseconds}ms');
}
```

## Recommended Indexes

Add to AppDatabase migration:
```dart
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Create indexes
      await customStatement(
        'CREATE INDEX idx_moments_circle_timestamp '
        'ON moments(circle_id, timestamp DESC)'
      );
      await customStatement(
        'CREATE INDEX idx_moments_sync '
        'ON moments(sync_status) WHERE sync_status > 0'
      );
    },
  );
}
```

## Benchmarks

Target performance metrics:
- First page load: < 50ms
- Subsequent pages: < 30ms
- Single moment fetch: < 10ms
- Batch insert (100 items): < 200ms
- Watch stream update: < 20ms

## Troubleshooting

### Slow List Loading
1. Check if indexes exist
2. Verify pagination uses keyset
3. Reduce columns in SELECT
4. Consider pagination size

### High Memory Usage
1. Limit watch stream batch size
2. Use pagination instead of loading all
3. Clear old cached data periodically

### Sync Bottleneck
1. Batch sync operations
2. Use background isolate for large syncs
3. Implement incremental sync (delta only)
