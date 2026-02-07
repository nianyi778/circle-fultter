// 网络信息服务实现
//
// 使用 connectivity_plus 检测网络状态

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'sync_engine.dart';

/// NetworkInfo 实现
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  StreamController<bool>? _connectivityController;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnectedFromResult(result);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    _connectivityController ??= StreamController<bool>.broadcast(
      onListen: () {
        _connectivity.onConnectivityChanged.listen((results) {
          final isConnected = _isConnectedFromResult(results);
          _connectivityController?.add(isConnected);
        });
      },
      onCancel: () {
        _connectivityController?.close();
        _connectivityController = null;
      },
    );
    return _connectivityController!.stream;
  }

  bool _isConnectedFromResult(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;

    // 检查是否有任何有效的连接
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet,
    );
  }
}
