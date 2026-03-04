import 'package:dio/dio.dart';

import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/network/api_endpoints.dart';
import 'package:maori_health/core/network/dio_client.dart';

import 'package:maori_health/data/dashboard/models/job_model.dart';

abstract class ScheduleRemoteDataSource {
  Future<JobModel> getScheduleById({required int scheduleId});
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final DioClient _client;

  ScheduleRemoteDataSourceImpl({required DioClient client}) : _client = client;

  @override
  Future<JobModel> getScheduleById({required int scheduleId}) async {
    try {
      final response = await _client.get(ApiEndpoints.scheduleById(scheduleId));
      return JobModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to fetch schedule',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}
