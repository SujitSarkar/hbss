import 'package:dio/dio.dart';

import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/network/api_endpoints.dart';
import 'package:maori_health/core/network/dio_client.dart';
import 'package:maori_health/data/app_settings/models/app_settings_model.dart';

class AppSettingsRemoteDataSource {
  final DioClient _client;

  AppSettingsRemoteDataSource({required DioClient client}) : _client = client;

  Future<AppSettingsModel> getAppSettings() async {
    try {
      final response = await _client.get(ApiEndpoints.settings);
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw ApiException(
          statusCode: response.statusCode,
          message: body['message']?.toString() ?? 'Failed to fetch App Settings',
        );
      }
      final data = body['data'] as Map<String, dynamic>;
      return AppSettingsModel.fromJson(data);
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to fetch App Settings',
      );
    }
  }
}
