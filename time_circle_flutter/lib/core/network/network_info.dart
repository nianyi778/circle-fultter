import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity information service
///
/// Provides methods to check network status and listen to connectivity changes.
/// Used by repositories to decide between local/remote data sources.
abstract class NetworkInfo {
  /// Check if device is currently connected to the internet
  Future<bool> get isConnected;

  /// Stream of connectivity status changes
  Stream<bool> get onConnectivityChanged;

  /// Current connectivity type (wifi, mobile, none, etc.)
  Future<List<ConnectivityResult>> get connectivityStatus;
}

/// Implementation of [NetworkInfo] using connectivity_plus
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  // Cache the stream controller for efficiency
  StreamController<bool>? _controller;

  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  @override
  Future<List<ConnectivityResult>> get connectivityStatus async {
    return _connectivity.checkConnectivity();
  }

  @override
  Stream<bool> get onConnectivityChanged {
    _controller ??= StreamController<bool>.broadcast(
      onListen: () {
        _connectivity.onConnectivityChanged.listen((results) {
          _controller?.add(_hasConnection(results));
        });
      },
      onCancel: () {
        _controller?.close();
        _controller = null;
      },
    );
    return _controller!.stream;
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    // Check if any connectivity type indicates internet access
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn,
    );
  }
}

/// Mock implementation for testing
class MockNetworkInfo implements NetworkInfo {
  bool _isConnected;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  MockNetworkInfo({bool isConnected = true}) : _isConnected = isConnected;

  @override
  Future<bool> get isConnected async => _isConnected;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  Future<List<ConnectivityResult>> get connectivityStatus async {
    return _isConnected ? [ConnectivityResult.wifi] : [ConnectivityResult.none];
  }

  /// Set connection status (for testing)
  void setConnected(bool connected) {
    _isConnected = connected;
    _controller.add(connected);
  }

  void dispose() {
    _controller.close();
  }
}

/// Extension methods for connectivity checks
extension NetworkInfoX on NetworkInfo {
  /// Execute action only if connected, otherwise return fallback
  Future<T> executeIfConnected<T>({
    required Future<T> Function() action,
    required T Function() fallback,
  }) async {
    if (await isConnected) {
      return action();
    }
    return fallback();
  }

  /// Execute action with connectivity-aware error handling
  Future<T> withConnectivityCheck<T>({
    required Future<T> Function() onConnected,
    required Future<T> Function() onDisconnected,
  }) async {
    if (await isConnected) {
      return onConnected();
    }
    return onDisconnected();
  }
}
