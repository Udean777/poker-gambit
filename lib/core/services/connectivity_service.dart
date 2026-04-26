import 'package:connectivity_plus/connectivity_plus.dart';

abstract class IConnectivityService {
  Stream<bool> get onConnectivityChanged;
  Future<bool> get isOnline;
}

class ConnectivityService implements IConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isConnected);
  }

  @override
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((r) => r != ConnectivityResult.none);
  }
}
