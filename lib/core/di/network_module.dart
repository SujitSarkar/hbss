import 'package:get_it/get_it.dart';

import 'package:maori_health/core/network/dio_client.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/network/network_service.dart';
import 'package:maori_health/core/storage/local_cache_service.dart';
import 'package:maori_health/core/storage/secure_storage_service.dart';

void registerNetworkModule(GetIt getIt) {
  getIt
    ..registerLazySingleton<NetworkChecker>(() => NetworkChecker()..initialize())
    ..registerLazySingleton<NetworkService>(() => NetworkService(getIt<NetworkChecker>()))
    ..registerLazySingleton<DioClient>(
      () => DioClient(secureStorage: getIt<SecureStorageService>(), cache: getIt<LocalCacheService>()),
    );
}
