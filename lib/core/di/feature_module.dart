import 'package:get_it/get_it.dart';

import 'package:maori_health/core/network/dio_client.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/storage/local_cache_service.dart';
import 'package:maori_health/data/app/repositories/theme_preference_repository_impl.dart';
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
import 'package:maori_health/data/local_storage/local_storage_data_source.dart';
import 'package:maori_health/data/local_storage/local_storage_data_source_impl.dart';
import 'package:maori_health/data/offline/repositories/offline_sync_repository_impl.dart';
import 'package:maori_health/data/dashboard/datasources/dashboard_remote_data_source.dart';
import 'package:maori_health/data/dashboard/repositories/dashboard_repository_impl.dart';
import 'package:maori_health/data/objectbox/objectbox_stores.dart';
import 'package:maori_health/data/offline/offline_schedule_queue_data_source.dart';
import 'package:maori_health/domain/app/repositories/theme_preference_repository.dart';
import 'package:maori_health/domain/app/usecases/get_saved_theme_mode_usecase.dart';
import 'package:maori_health/domain/app/usecases/persist_theme_mode_usecase.dart';
import 'package:maori_health/domain/app_settings/repositories/app_settings_repository.dart';
import 'package:maori_health/domain/app_settings/usecases/get_app_settings_usecase.dart';

import 'package:maori_health/domain/auth/repositories/auth_repository.dart';
import 'package:maori_health/domain/auth/usecases/forgot_password_usecase.dart';
import 'package:maori_health/domain/auth/usecases/get_local_login_usecase.dart';
import 'package:maori_health/domain/auth/usecases/login_usecase.dart';
import 'package:maori_health/domain/auth/usecases/logout_usecase.dart';
import 'package:maori_health/domain/auth/usecases/reset_password_usecase.dart';
import 'package:maori_health/domain/auth/usecases/update_password_usecase.dart';
import 'package:maori_health/domain/auth/usecases/verify_otp_usecase.dart';
import 'package:maori_health/domain/asset/repositories/asset_repository.dart';
import 'package:maori_health/domain/asset/usecases/accept_asset_usecase.dart';
import 'package:maori_health/domain/asset/usecases/get_assets_usecase.dart';
import 'package:maori_health/domain/client/repositories/client_repository.dart';
import 'package:maori_health/domain/client/usecases/get_clients_usecase.dart';
import 'package:maori_health/domain/notification/repositories/notification_repository.dart';
import 'package:maori_health/domain/notification/usecases/get_notification_by_id_usecase.dart';
import 'package:maori_health/domain/notification/usecases/get_notifications_usecase.dart';
import 'package:maori_health/domain/employee/repositories/employee_repository.dart';
import 'package:maori_health/domain/employee/usecases/get_employees_usecase.dart';
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
import 'package:maori_health/domain/timesheet/usecases/get_timesheets_usecase.dart';
import 'package:maori_health/domain/dashboard/repositories/dashboard_repository.dart';
import 'package:maori_health/domain/dashboard/usecases/get_dashboard_usecase.dart';
import 'package:maori_health/domain/offline_sync/repositories/offline_sync_repository.dart';
import 'package:maori_health/domain/offline_sync/usecases/has_pending_offline_sync_usecase.dart';
import 'package:maori_health/domain/offline_sync/usecases/sync_offline_pending_usecase.dart';

import 'package:maori_health/presentation/app/bloc/app_bloc.dart';
import 'package:maori_health/presentation/app_settings/bloc/app_settings_bloc.dart';
import 'package:maori_health/presentation/asset/bloc/asset_bloc.dart';
import 'package:maori_health/presentation/auth/bloc/auth_bloc.dart';
import 'package:maori_health/presentation/client/bloc/client_bloc.dart';
import 'package:maori_health/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:maori_health/presentation/notification/bloc/notification_bloc.dart';
import 'package:maori_health/presentation/employee/bloc/employee_bloc.dart';
import 'package:maori_health/presentation/lookup_enums/bloc/lookup_enums_bloc.dart';
import 'package:maori_health/presentation/offline_sync/bloc/offline_sync_bloc.dart';
import 'package:maori_health/presentation/schedule/bloc/schedule_bloc.dart';
import 'package:maori_health/presentation/timesheet/bloc/timesheet_bloc.dart';

void registerFeatureModule(GetIt getIt) {
  // ── App (theme preferences)
  getIt
    ..registerLazySingleton<ThemePreferenceRepository>(
      () => ThemePreferenceRepositoryImpl(cache: getIt<LocalCacheService>()),
    )
    ..registerLazySingleton<GetSavedThemeModeUsecase>(
      () => GetSavedThemeModeUsecase(repository: getIt<ThemePreferenceRepository>()),
    )
    ..registerLazySingleton<PersistThemeModeUsecase>(
      () => PersistThemeModeUsecase(repository: getIt<ThemePreferenceRepository>()),
    )
    ..registerFactory<AppBloc>(
      () => AppBloc(
        getSavedThemeModeUsecase: getIt<GetSavedThemeModeUsecase>(),
        persistThemeModeUsecase: getIt<PersistThemeModeUsecase>(),
      ),
    );

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
    ..registerLazySingleton<LoginUsecase>(() => LoginUsecase(repository: getIt<AuthRepository>()))
    ..registerLazySingleton<GetLocalLoginUsecase>(() => GetLocalLoginUsecase(repository: getIt<AuthRepository>()))
    ..registerLazySingleton<UpdatePasswordUsecase>(() => UpdatePasswordUsecase(repository: getIt<AuthRepository>()))
    ..registerLazySingleton<ForgotPasswordUsecase>(() => ForgotPasswordUsecase(repository: getIt<AuthRepository>()))
    ..registerLazySingleton<VerifyOtpUsecase>(() => VerifyOtpUsecase(repository: getIt<AuthRepository>()))
    ..registerLazySingleton<ResetPasswordUsecase>(() => ResetPasswordUsecase(repository: getIt<AuthRepository>()))
    ..registerLazySingleton<LogoutUsecase>(() => LogoutUsecase(repository: getIt<AuthRepository>()))
    ..registerFactory<AuthBloc>(
      () => AuthBloc(
        getLocalLoginUsecase: getIt<GetLocalLoginUsecase>(),
        loginUsecase: getIt<LoginUsecase>(),
        updatePasswordUsecase: getIt<UpdatePasswordUsecase>(),
        forgotPasswordUsecase: getIt<ForgotPasswordUsecase>(),
        verifyOtpUsecase: getIt<VerifyOtpUsecase>(),
        resetPasswordUsecase: getIt<ResetPasswordUsecase>(),
        logoutUsecase: getIt<LogoutUsecase>(),
      ),
    );

  // ── App Settings
  getIt
    ..registerLazySingleton<AppSettingsRemoteDataSource>(() => AppSettingsRemoteDataSource(client: getIt<DioClient>()))
    ..registerLazySingleton<AppSettingsRepository>(
      () => AppSettingsRepositoryImpl(
        remoteDataSource: getIt<AppSettingsRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
        localCache: getIt<LocalCacheService>(),
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
        localCache: getIt<LocalCacheService>(),
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
        localCache: getIt<LocalCacheService>(),
      ),
    )
    ..registerLazySingleton<GetClientsUsecase>(() => GetClientsUsecase(repository: getIt<ClientRepository>()))
    ..registerFactory<ClientBloc>(() => ClientBloc(getIt<GetClientsUsecase>()));

  // ── Employee
  getIt
    ..registerLazySingleton<EmployeeRemoteDataSource>(() => EmployeeRemoteDataSourceImpl(client: getIt<DioClient>()))
    ..registerLazySingleton<EmployeeRepository>(
      () => EmployeeRepositoryImpl(
        remoteDataSource: getIt<EmployeeRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
        localCache: getIt<LocalCacheService>(),
      ),
    )
    ..registerLazySingleton<GetEmployeesUsecase>(() => GetEmployeesUsecase(repository: getIt<EmployeeRepository>()))
    ..registerFactory<EmployeeBloc>(() => EmployeeBloc(getEmployeesUsecase: getIt<GetEmployeesUsecase>()));

  // ── Asset
  getIt
    ..registerLazySingleton<AssetRemoteDataSource>(() => AssetRemoteDataSourceImpl(client: getIt<DioClient>()))
    ..registerLazySingleton<AssetRepository>(
      () => AssetRepositoryImpl(
        remoteDataSource: getIt<AssetRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
      ),
    )
    ..registerLazySingleton<GetAssetsUsecase>(() => GetAssetsUsecase(repository: getIt<AssetRepository>()))
    ..registerLazySingleton<AcceptAssetUsecase>(() => AcceptAssetUsecase(repository: getIt<AssetRepository>()))
    ..registerFactory<AssetBloc>(
      () => AssetBloc(getAssetsUsecase: getIt<GetAssetsUsecase>(), acceptAssetUsecase: getIt<AcceptAssetUsecase>()),
    );

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
    ..registerLazySingleton<GetNotificationsUsecase>(
      () => GetNotificationsUsecase(repository: getIt<NotificationRepository>()),
    )
    ..registerLazySingleton<GetNotificationByIdUsecase>(
      () => GetNotificationByIdUsecase(repository: getIt<NotificationRepository>()),
    )
    ..registerFactory<NotificationBloc>(
      () => NotificationBloc(
        getNotificationsUsecase: getIt<GetNotificationsUsecase>(),
        getNotificationByIdUsecase: getIt<GetNotificationByIdUsecase>(),
      ),
    );

  // ── TimeSheet
  getIt
    ..registerLazySingleton<TimeSheetRemoteDataSource>(() => TimeSheetRemoteDataSourceImpl(client: getIt<DioClient>()))
    ..registerLazySingleton<TimeSheetRepository>(
      () => TimeSheetRepositoryImpl(
        remoteDataSource: getIt<TimeSheetRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
      ),
    )
    ..registerLazySingleton<GetTimeSheetsUsecase>(() => GetTimeSheetsUsecase(repository: getIt<TimeSheetRepository>()))
    ..registerFactory<TimeSheetBloc>(() => TimeSheetBloc(getTimeSheetsUsecase: getIt<GetTimeSheetsUsecase>()));

  // ── Dashboard / Schedule (ObjectBox local storage, schedule remote, offline sync)
  getIt
    ..registerLazySingleton<LocalStorageDataSource>(() => LocalStorageDataSourceImpl(getIt<ObjectBoxStores>()))
    ..registerLazySingleton<OfflineScheduleQueueDataSource>(
      () => OfflineScheduleQueueDataSourceImpl(getIt<ObjectBoxStores>()),
    )
    ..registerLazySingleton<ScheduleRemoteDataSource>(() => ScheduleRemoteDataSourceImpl(client: getIt<DioClient>()))
    ..registerLazySingleton<OfflineSyncRepository>(
      () => OfflineSyncRepositoryImpl(
        networkChecker: getIt<NetworkChecker>(),
        queue: getIt<OfflineScheduleQueueDataSource>(),
        remote: getIt<ScheduleRemoteDataSource>(),
        localStorage: getIt<LocalStorageDataSource>(),
      ),
    )
    ..registerLazySingleton<HasPendingOfflineSyncUsecase>(
      () => HasPendingOfflineSyncUsecase(repository: getIt<OfflineSyncRepository>()),
    )
    ..registerLazySingleton<SyncOfflinePendingUsecase>(
      () => SyncOfflinePendingUsecase(repository: getIt<OfflineSyncRepository>()),
    )
    ..registerLazySingleton<OfflineSyncBloc>(
      () => OfflineSyncBloc(
        networkChecker: getIt<NetworkChecker>(),
        hasPendingOfflineSyncUsecase: getIt<HasPendingOfflineSyncUsecase>(),
        syncOfflinePendingUsecase: getIt<SyncOfflinePendingUsecase>(),
      ),
    )
    ..registerLazySingleton<DashboardRemoteDataSource>(() => DashboardRemoteDataSourceImpl(client: getIt<DioClient>()))
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(
        remoteDataSource: getIt<DashboardRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
        localStorage: getIt<LocalStorageDataSource>(),
      ),
    )
    ..registerLazySingleton<GetDashboardUsecase>(() => GetDashboardUsecase(repository: getIt<DashboardRepository>()))
    ..registerFactory<DashboardBloc>(() => DashboardBloc(getDashboardUsecase: getIt<GetDashboardUsecase>()));

  // ── Schedule
  getIt
    ..registerLazySingleton<ScheduleRepository>(
      () => ScheduleRepositoryImpl(
        remoteDataSource: getIt<ScheduleRemoteDataSource>(),
        networkChecker: getIt<NetworkChecker>(),
        localStorage: getIt<LocalStorageDataSource>(),
        offlineQueue: getIt<OfflineScheduleQueueDataSource>(),
        authRepository: getIt<AuthRepository>(),
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
