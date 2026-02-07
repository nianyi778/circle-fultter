// 远程同步服务实现
//
// 通过 API 与后端进行数据同步

import 'dart:async';
import '../services/api_service.dart';
import '../config/api_config.dart';
import 'sync_engine.dart';

/// 远程同步服务实现
class RemoteSyncServiceImpl implements RemoteSyncService {
  final ApiService _apiService;

  RemoteSyncServiceImpl(this._apiService);

  @override
  Future<void> pushChange(SyncItem item) async {
    final endpoint = _getEndpoint(item.entityType, item.action);

    switch (item.action) {
      case SyncAction.create:
        await _apiService.post(endpoint, data: item.data);
        break;
      case SyncAction.update:
        await _apiService.put('$endpoint/${item.entityId}', data: item.data);
        break;
      case SyncAction.delete:
        await _apiService.delete('$endpoint/${item.entityId}');
        break;
    }
  }

  @override
  Future<List<RemoteChange>> pullChanges({DateTime? since}) async {
    try {
      final response = await _apiService.get(
        ApiConfig.syncChanges,
        queryParameters: {
          if (since != null) 'lastSyncAt': since.toIso8601String(),
          'entities': ['moments', 'letters', 'comments'].join(','),
        },
      );

      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final changes = data['changes'] as List? ?? [];

        return changes.map((change) {
          final c = change as Map<String, dynamic>;
          return RemoteChange(
            entityType: c['entityType'] as String,
            entityId: c['entityId'] as String,
            action: SyncAction.values.firstWhere(
              (a) => a.name == c['action'],
              orElse: () => SyncAction.update,
            ),
            data: c['data'] as Map<String, dynamic>?,
            serverTimestamp: DateTime.parse(c['serverTimestamp'] as String),
          );
        }).toList();
      }

      return [];
    } catch (e) {
      // 如果 API 端点不存在，返回空列表
      return [];
    }
  }

  String _getEndpoint(String entityType, SyncAction action) {
    switch (entityType) {
      case 'moment':
        return '/moments';
      case 'letter':
        return '/letters';
      case 'comment':
        return '/comments';
      default:
        throw ArgumentError('Unknown entity type: $entityType');
    }
  }
}
