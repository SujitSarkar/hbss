import 'package:get_it/get_it.dart';

import 'package:maori_health/core/network/dio_client.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/storage/local_cache_service.dart';
import 'package:maori_health/core/storage/secure_storage_service.dart';
import 'package:maori_health/data/app_settings/datasources/app_settings_remote_datasource.dart';
import 'package:maori_health/data/app_settings/repositories/app_settings_repository_impl.dart';

import 'package:maori_health/data/auth/datasources/auth_local_data_source.dart';
import 'package:maori_health/data/auth/datasources/auth_remote_data_source.dart';
import 'package:maori_health/data/auth/repositories/auth_repository_impl.dart';
import 'package:maori_health/data/client/datasource/client_remote_data_source.dart';
import 'package:maori_health/data/client/repositories/client_repository_impl.dart';
import 'package:maori_health/data/asset/datasources/asset_remote_data_source.dart';
import 'package:maori_health/data/asset/repositories/asset_repository_impl.dart';
import 'package:maori_health/data/notification/datasources/notification_remote_data_source.dart';
import 'package:maori_health/data/notification/repositories/notification_repository_impl.dart';
import 'package:maori_health/data/employee/datasources/employee_remote_data_source.dart';
import 'package:maori_health/data/employee/repositories/employee_repository_impl.dart';
import 'package:maori_health/data/lookup_enums/datasources/lookup_enums_remote_data_source.dart';
import 'package:maori_health/data/lookup_enums/repositories/lookup_enums_repository_impl.dart';
import 'package:maori_health/data/schedule/datasources/schedule_remote_datasource.dart';
import 'package:maori_health/data/schedule/repositories/schedule_repository_impl.dart';
import 'package:maori_health/data/timesheet/datasources/timesheet_remote_data_source.dart';
import 'package:maori_health/data/timesheet/repositories/timesheet_repository_impl.dart';
import 'package:maori_health/data/dashboard/datasources/dashboard_remote_data_source.dart';
import 'package:maori_health/data/dashboard/repositories/dashboard_repository_impl.dart';
import 'package:maori_health/domain/app_settings/repositories/app_settings_repository.dart';
import 'package:maori_health/domain/app_settings/usecases/get_app_settings_usecase.dart';

import 'package:maori_health/domain/auth/repositories/auth_repository.dart';
import 'package:maori_health/domain/asset/repositories/asset_repository.dart';
import 'package:maori_health/domain/client/repositories/client_repository.dart';
import 'package:maori_health/domain/notification/repositories/notification_repository.dart';
import 'package:maori_health/domain/employee/repositories/employee_repository.dart';
import 'package:maori_health/domain/lookup_enums/repositories/lookup_enums_repository.dart';
import 'package:maori_health/domain/lookup_enums/usecases/get_lookup_enums_usecase.dart';
import 'package:maori_health/domain/schedule/repositories/schedule_repository.dart';
import 'package:maori_health/domain/schedule/usecases/accept_schedule_usecase.dart';
import 'package:maori_health/domain/schedule/usecases/cancel_schedule_usecase.dart';
import 'package:maori_health/domain/schedule/usecases/finish_schedule_usecase.dart';
import 'package:maori_health/domain/schedule/usecases/get_schedule_details_usecase.dart';
import 'package:maori_health/domain/schedule/usecases/get_schedules_usecase.dart';
import 'package:maori_health/domain/schedule/usecases/start_schedule_usecase.dart';
import 'package:maori_health/domain/timesheet/repositories/timesheet_repository.dart';
import 'package:maori_health/domain/dashboard/repositories/dashboard_repository.dart';

import 'package:maori_health/presentation/app/bloc/app_bloc.dart';
import 'package:maori_health/presentation/app_settings/bloc/app_settings_bloc.dart';
import 'package:maori_health/presentation/asset/bloc/asset_bloc.dart';
import 'package:maori_health/presentation/auth/bloc/auth_bloc.dart';
import 'package:maori_health/presentation/client/bloc/client_bloc.dart';
import 'package:maori_health/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:maori_health/presentation/notification/bloc/notification_bloc.dart';
import 'package:maori_health/presentation/employee/bloc/employee_bloc.dart';
import 'package:maori_health/presentation/lookup_enums/bloc/lookup_enums_bloc.dart';
import 'package:maori_health/presentation/schedule/bloc/schedule_bloc.dart';
import 'package:maori_health/presentation/timesheet/bloc/timesheet_bloc.dart';

void registerFeatureModule(GetIt getIt) {
  // ── App
  getIt.registerFactory<AppBloc>(() => AppBloc(cache: getIt<LocalCacheService>()));

  // ── Auth
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(client: getIt<DioClient>()))
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(secureStorage: getIt<SecureStorageService>(), cache: getIt<LocalCacheService>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt<AuthRemoteDataSource>(),
        localDataSource: getIt<AuthLocalDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
      ),
    )
    ..registerFactory<AuthBloc>(() => AuthBloc(authRepository: getIt<AuthRepository>()));

  // ── App Settings
  getIt
    ..registerLazySingleton<AppSettingsRemoteDataSource>(() => AppSettingsRemoteDataSource(client: getIt<DioClient>()))
    ..registerLazySingleton<AppSettingsRepository>(
      () => AppSettingsRepositoryImpl(
        remoteDataSource: getIt<AppSettingsRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
      ),
    )
    ..registerLazySingleton<GetAppSettingsUsecase>(
      () => GetAppSettingsUsecase(repository: getIt<AppSettingsRepository>()),
    )
    ..registerFactory<AppSettingsBloc>(() => AppSettingsBloc(getAppSettingsUsecase: getIt<GetAppSettingsUsecase>()));

  // ── Lookup Enums
  getIt
    ..registerLazySingleton<LookupEnumsRemoteDataSource>(
      () => LookupEnumsRemoteDataSourceImpl(client: getIt<DioClient>()),
    )
    ..registerLazySingleton<LookupEnumsRepository>(
      () => LookupEnumsRepositoryImpl(
        remoteDataSource: getIt<LookupEnumsRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
      ),
    )
    ..registerLazySingleton<GetLookupEnumsUsecase>(
      () => GetLookupEnumsUsecase(repository: getIt<LookupEnumsRepository>()),
    )
    ..registerFactory<LookupEnumsBloc>(() => LookupEnumsBloc(getLookupEnumsUsecase: getIt<GetLookupEnumsUsecase>()));

  // -- Client
  getIt
    ..registerLazySingleton<ClientRemoteDataSource>(() => ClientRemoteDataSourceImpl(client: getIt<DioClient>()))
    ..registerLazySingleton<ClientRepository>(
      () => ClientRepositoryImpl(
        remoteDataSource: getIt<ClientRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
      ),
    )
    ..registerFactory<ClientBloc>(() => ClientBloc(getIt<ClientRepository>()));

  // ── Employee
  getIt
    ..registerLazySingleton<EmployeeRemoteDataSource>(() => EmployeeRemoteDataSourceImpl(client: getIt<DioClient>()))
    ..registerLazySingleton<EmployeeRepository>(
      () => EmployeeRepositoryImpl(
        remoteDataSource: getIt<EmployeeRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
      ),
    )
    ..registerFactory<EmployeeBloc>(() => EmployeeBloc(repository: getIt<EmployeeRepository>()));

  // ── Asset
  getIt
    ..registerLazySingleton<AssetRemoteDataSource>(() => AssetRemoteDataSourceImpl(client: getIt<DioClient>()))
    ..registerLazySingleton<AssetRepository>(
      () => AssetRepositoryImpl(
        remoteDataSource: getIt<AssetRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
      ),
    )
    ..registerFactory<AssetBloc>(() => AssetBloc(assetRepository: getIt<AssetRepository>()));

  // ── Notification
  getIt
    ..registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(client: getIt<DioClient>()),
    )
    ..registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(
        remoteDataSource: getIt<NotificationRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
      ),
    )
    ..registerFactory<NotificationBloc>(() => NotificationBloc(repository: getIt<NotificationRepository>()));

  // ── TimeSheet
  getIt
    ..registerLazySingleton<TimeSheetRemoteDataSource>(() => TimeSheetRemoteDataSourceImpl(client: getIt<DioClient>()))
    ..registerLazySingleton<TimeSheetRepository>(
      () => TimeSheetRepositoryImpl(
        remoteDataSource: getIt<TimeSheetRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
      ),
    )
    ..registerFactory<TimeSheetBloc>(() => TimeSheetBloc(repository: getIt<TimeSheetRepository>()));

  // ── Dashboard
  getIt
    ..registerLazySingleton<DashboardRemoteDataSource>(() => DashboardRemoteDataSourceImpl(client: getIt<DioClient>()))
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(
        remoteDataSource: getIt<DashboardRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
      ),
    )
    ..registerFactory<DashboardBloc>(() => DashboardBloc(repository: getIt<DashboardRepository>()));

  // ── Schedule
  getIt
    ..registerLazySingleton<ScheduleRemoteDataSource>(() => ScheduleRemoteDataSourceImpl(client: getIt<DioClient>()))
    ..registerLazySingleton<ScheduleRepository>(
      () => ScheduleRepositoryImpl(
        remoteDataSource: getIt<ScheduleRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
      ),
    )
    ..registerLazySingleton<GetScheduleDetailsUsecase>(
      () => GetScheduleDetailsUsecase(repository: getIt<ScheduleRepository>()),
    )
    ..registerLazySingleton<GetSchedulesUsecase>(() => GetSchedulesUsecase(repository: getIt<ScheduleRepository>()))
    ..registerLazySingleton<AcceptScheduleUsecase>(() => AcceptScheduleUsecase(repository: getIt<ScheduleRepository>()))
    ..registerLazySingleton<StartScheduleUsecase>(() => StartScheduleUsecase(repository: getIt<ScheduleRepository>()))
    ..registerLazySingleton<FinishScheduleUsecase>(() => FinishScheduleUsecase(repository: getIt<ScheduleRepository>()))
    ..registerLazySingleton<CancelScheduleUsecase>(() => CancelScheduleUsecase(repository: getIt<ScheduleRepository>()))
    ..registerFactory<ScheduleBloc>(
      () => ScheduleBloc(
        getSchedulesUsecase: getIt<GetSchedulesUsecase>(),
        getScheduleDetailsUsecase: getIt<GetScheduleDetailsUsecase>(),
        acceptScheduleUsecase: getIt<AcceptScheduleUsecase>(),
        startScheduleUsecase: getIt<StartScheduleUsecase>(),
        finishScheduleUsecase: getIt<FinishScheduleUsecase>(),
        cancelScheduleUsecase: getIt<CancelScheduleUsecase>(),
      ),
    );
}
