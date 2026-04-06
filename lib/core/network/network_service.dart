import 'package:maori_health/core/network/network_checker.dart';

/// Connectivity facade over [NetworkChecker] (stream + probe) for app-wide use.
class NetworkService {
  NetworkService(this._checker);

  final NetworkChecker _checker;

  Future<bool> get hasConnection => _checker.hasConnection;

  Stream<bool> get connectivityStream => _checker.connectionStream;

  Future<bool> checkConnection() => _checker.checkConnection();
}
