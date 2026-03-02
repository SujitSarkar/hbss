import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/network/network_checker.dart';
import 'package:maori_health/core/result/result.dart';

import 'package:maori_health/data/auth/datasources/auth_local_data_source.dart';
import 'package:maori_health/data/auth/datasources/auth_remote_data_source.dart';

import 'package:maori_health/domain/auth/entities/forgot_pass_response.dart';
import 'package:maori_health/domain/auth/entities/login_response.dart';
import 'package:maori_health/domain/auth/entities/user.dart';

import 'package:maori_health/data/auth/models/user_model.dart';
import 'package:maori_health/domain/auth/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkChecker _networkChecker;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required NetworkChecker networkChecker,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkChecker = networkChecker;

  @override
  Future<Result<AppError, LoginResponse>> login({required String email, required String password}) async {
    if (!await _networkChecker.hasConnection) {
      return const ErrorResult(NetworkError());
    }

    try {
      final response = await _remoteDataSource.login(email: email, password: password);

      await _localDataSource.saveAccessToken(response.accessToken);
      await _localDataSource.cacheUser(response.user as UserModel);

      return SuccessResult(response);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }

  @override
  Future<Result<AppError, User>> getLocalLogin() async {
    try {
      final isValid = await _localDataSource.isTokenValid();
      if (!isValid) {
        await _localDataSource.clearAll();
        return const ErrorResult(CacheError(errorMessage: 'Session expired!'));
      }

      final user = _localDataSource.getCachedUser();
      if (user == null) {
        return const ErrorResult(CacheError(errorMessage: 'User not found!'));
      }

      return SuccessResult(user);
    } on CacheException catch (e) {
      return ErrorResult(CacheError(errorCode: 0, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(CacheError(errorCode: 0, errorMessage: e.toString()));
    }
  }

  @override
  Future<Result<AppError, ForgotPasswordResponse>> forgotPassword({required String email}) async {
    if (!await _networkChecker.hasConnection) {
      return const ErrorResult(NetworkError());
    }
    try {
      final response = await _remoteDataSource.forgotPassword(email: email);
      return SuccessResult(response);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }

  @override
  Future<Result<AppError, ForgotPasswordResponse>> verifyOtp({required String email, required String otp}) async {
    if (!await _networkChecker.hasConnection) {
      return const ErrorResult(NetworkError());
    }
    try {
      final response = await _remoteDataSource.verifyOtp(email: email, otp: otp);
      return SuccessResult(response);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }

  @override
  Future<Result<AppError, ForgotPasswordResponse>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!await _networkChecker.hasConnection) {
      return const ErrorResult(NetworkError());
    }
    try {
      final response = await _remoteDataSource.resetPassword(
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return SuccessResult(response);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }

  @override
  Future<bool> logout() async {
    final success = await _remoteDataSource.logout();
    if (success) {
      await _localDataSource.clearAll();
    }
    return success;
  }

  @override
  Future<Result<AppError, String>> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!await _networkChecker.hasConnection) {
      return const ErrorResult(NetworkError());
    }
    try {
      final message = await _remoteDataSource.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return SuccessResult(message);
    } on ApiException catch (e) {
      return ErrorResult(ApiError(errorCode: e.statusCode, errorMessage: e.message));
    } catch (e) {
      return ErrorResult(ApiError(errorCode: 0, errorMessage: e.toString()));
    }
  }
}
