import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/core/storage/local_cache_service.dart';

import 'package:maori_health/data/client/datasource/client_remote_data_source.dart';
import 'package:maori_health/domain/client/entities/client.dart';
import 'package:maori_health/domain/client/repositories/client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource _remoteDataSource;
  final NetworkChecker _networkChecker;
  final LocalCacheService _localCache;

  ClientRepositoryImpl({
    required ClientRemoteDataSource remoteDataSource,
    required NetworkChecker networkChecker,
    required LocalCacheService localCache,
  }) : _remoteDataSource = remoteDataSource,
       _networkChecker = networkChecker,
       _localCache = localCache;

  @override
  Future<Result<AppError, List<Client>>> getClients({int page = 1}) async {
    if (!await _networkChecker.hasConnection) {
      final cached = _localCache.getCachedClients();
      if (cached != null && cached.isNotEmpty) {
        return SuccessResult(cached);
      }
      return const ErrorResult(NetworkError());
    }
    try {
      final clients = await _remoteDataSource.getClients(page: page);
      await _localCache.setCachedClients(clients);
      return SuccessResult(clients);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }
}
