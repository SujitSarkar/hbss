import 'package:get_it/get_it.dart';
import 'package:maori_health/core/services/orientation_service.dart';

import 'package:maori_health/core/storage/secure_storage_service.dart';
import 'package:maori_health/core/storage/local_cache_service.dart';
import 'package:maori_health/data/objectbox/objectbox_stores.dart';

Future<void> registerServiceModule(GetIt getIt) async {
  final localCache = await LocalCacheService.init();
  final objectBoxStores = await ObjectBoxStores.create();

  getIt
    ..registerLazySingleton<OrientationService>(() => OrientationService())
    ..registerLazySingleton<SecureStorageService>(() => SecureStorageService())
    ..registerSingleton<LocalCacheService>(localCache)
    ..registerSingleton<ObjectBoxStores>(objectBoxStores);
}
