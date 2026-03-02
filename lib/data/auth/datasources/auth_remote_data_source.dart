import 'dart:io';

import 'package:dio/dio.dart';

import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/network/api_endpoints.dart';
import 'package:maori_health/core/network/dio_client.dart';
import 'package:maori_health/data/auth/models/forgot_pass_response_model.dart';
import 'package:maori_health/data/auth/models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({required String email, required String password});
  Future<String> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
  Future<ForgotPasswordResponseModel> forgotPassword({required String email});
  Future<ForgotPasswordResponseModel> verifyOtp({required String email, required String otp});
  Future<ForgotPasswordResponseModel> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  });
  Future<bool> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl({required DioClient client}) : _client = client;

  @override
  Future<LoginResponseModel> login({required String email, required String password}) async {
    try {
      final response = await _client.post(
        ApiEndpoints.login,
        data: FormData.fromMap({'email': email, 'password': password}),
      );

      final body = response.data as Map<String, dynamic>;

      if (body['success'] != true) {
        throw ApiException(statusCode: response.statusCode, message: body['message']?.toString() ?? 'Login failed');
      }

      return LoginResponseModel.fromJson(body);
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(statusCode: e.response?.statusCode, message: message ?? e.message ?? 'Login failed');
    }
  }

  @override
  Future<String> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.updatePassword,
        data: FormData.fromMap({
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw ApiException(
          statusCode: response.statusCode,
          message: body['message']?.toString() ?? 'Failed to update password',
        );
      }
      return body['message']?.toString() ?? 'Password updated successfully';
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to update password',
      );
    }
  }

  @override
  Future<ForgotPasswordResponseModel> forgotPassword({required String email}) async {
    try {
      final response = await _client.post(ApiEndpoints.forgotPassword, data: FormData.fromMap({'email': email}));
      if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.created) {
        return ForgotPasswordResponseModel.fromJson(response.data);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: response.data['message']?.toString() ?? 'Failed to send forgot password email',
        );
      }
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to send forgot password email',
      );
    }
  }

  @override
  Future<ForgotPasswordResponseModel> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _client.post(ApiEndpoints.verifyOtp, data: FormData.fromMap({'email': email, 'otp': otp}));
      if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.created) {
        return ForgotPasswordResponseModel.fromJson(response.data);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: response.data['message']?.toString() ?? 'Failed to send forgot password email',
        );
      }
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to send forgot password email',
      );
    }
  }

  @override
  Future<ForgotPasswordResponseModel> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.resetPassword,
        data: FormData.fromMap({'email': email, 'new_password': newPassword, 'confirm_password': confirmPassword}),
      );
      if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.created) {
        return ForgotPasswordResponseModel.fromJson(response.data);
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: response.data['message']?.toString() ?? 'Failed to reset password',
        );
      }
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to reset password',
      );
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final response = await _client.post(ApiEndpoints.logout);
      final body = response.data as Map<String, dynamic>;
      return body['success'] == true;
    } on DioException {
      return false;
    }
  }
}
