import 'package:dio/dio.dart';

import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/network/api_endpoints.dart';
import 'package:maori_health/core/network/dio_client.dart';
import 'package:maori_health/core/utils/data_parse_util.dart';

import 'package:maori_health/data/dashboard/models/schedule_model.dart';
import 'package:maori_health/data/schedule/models/paginated_schedule_response.dart';

abstract class ScheduleRemoteDataSource {
  Future<PaginatedScheduleResponse> getSchedules({
    required int page,
    int? clientUserId,
    String? startDate,
    String? endDate,
  });
  Future<ScheduleModel> getScheduleById({required int scheduleId});
  Future<ScheduleModel> acceptSchedule({required int scheduleId});
  Future<ScheduleModel> startSchedule({required int scheduleId});
  Future<ScheduleModel> finishSchedule({required int scheduleId});
  Future<ScheduleModel> cancelSchedule({
    required int scheduleId,
    required String cancelBy,
    required String? cancelReason,
    required int? hour,
    required int minute,
    required String reason,
  });
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final DioClient _client;

  ScheduleRemoteDataSourceImpl({required DioClient client}) : _client = client;

  @override
  Future<PaginatedScheduleResponse> getSchedules({
    required int page,
    int? clientUserId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (clientUserId != null) queryParams['client_user_id'] = clientUserId;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _client.get(ApiEndpoints.schedules, queryParameters: queryParams);
      return PaginatedScheduleResponse(
        schedules: (response.data['data']?['data'] as List).map((e) => ScheduleModel.fromJson(e)).toList(),
        currentPage: DataParseUtil.parseInt(response.data['data']?['current_page'], defaultValue: 1),
        lastPage: DataParseUtil.parseInt(response.data['data']?['last_page'], defaultValue: 1),
      );
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to fetch schedules',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<ScheduleModel> getScheduleById({required int scheduleId}) async {
    try {
      final response = await _client.get(ApiEndpoints.scheduleById(scheduleId));
      return ScheduleModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to fetch schedule details',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<ScheduleModel> acceptSchedule({required int scheduleId}) async {
    try {
      final response = await _client.post(ApiEndpoints.acceptSchedule(scheduleId));
      return ScheduleModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to accept schedule',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<ScheduleModel> startSchedule({required int scheduleId}) async {
    try {
      final response = await _client.post(ApiEndpoints.startSchedule(scheduleId));
      return ScheduleModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to start schedule',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<ScheduleModel> finishSchedule({required int scheduleId}) async {
    try {
      final response = await _client.post(ApiEndpoints.finishSchedule(scheduleId));
      return ScheduleModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to finish schedule',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  @override
  Future<ScheduleModel> cancelSchedule({
    required int scheduleId,
    required String cancelBy,
    required String? cancelReason,
    required int? hour,
    required int minute,
    required String reason,
  }) async {
    try {
      final formData = FormData.fromMap({
        'cancel_by': cancelBy.toLowerCase(),
        'reason': reason,
        'hour': ?hour,
        'minute': minute,
      });
      if (cancelReason != null) formData.fields.add(MapEntry('reason_type', cancelReason));

      final response = await _client.post(ApiEndpoints.cancelSchedule(scheduleId), data: formData);
      return ScheduleModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to cancel schedule',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}
