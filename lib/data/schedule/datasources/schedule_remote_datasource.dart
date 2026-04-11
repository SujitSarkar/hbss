import 'package:dio/dio.dart';

import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/network/api_endpoints.dart';
import 'package:maori_health/core/network/dio_client.dart';
import 'package:maori_health/core/utils/data_parse_util.dart';
import 'package:maori_health/core/utils/date_converter.dart';

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
  Future<ScheduleModel> startSchedule({required int scheduleId, String? workStartTime});
  Future<ScheduleModel> finishSchedule({required int scheduleId, String? workStartTime, String? workEndTime});
  Future<ScheduleModel> cancelSchedule({
    required int scheduleId,
    required String cancelBy,
    required String? cancelReason,
    required int? hour,
    required int? minute,
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
  Future<ScheduleModel> startSchedule({required int scheduleId, String? workStartTime}) async {
    try {
      String? apiStart;
      if (workStartTime != null && workStartTime.trim().isNotEmpty) {
        apiStart = DateConverter.toScheduleApiDateTime(workStartTime);
        if (apiStart == null) {
          throw ApiException(message: 'Invalid work_start_time');
        }
      }
      final response = await _client.post(
        ApiEndpoints.startSchedule(scheduleId),
        data: apiStart != null ? {'work_start_time': apiStart} : null,
      );
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
  Future<ScheduleModel> finishSchedule({required int scheduleId, String? workStartTime, String? workEndTime}) async {
    try {
      final payload = <String, dynamic>{};
      if (workStartTime != null && workStartTime.trim().isNotEmpty) {
        final apiStart = DateConverter.toScheduleApiDateTime(workStartTime);
        if (apiStart == null) {
          throw ApiException(message: 'Invalid work_start_time');
        }
        payload['work_start_time'] = apiStart;
      }
      if (workEndTime != null && workEndTime.trim().isNotEmpty) {
        final apiEnd = DateConverter.toScheduleApiDateTime(workEndTime);
        if (apiEnd == null) {
          throw ApiException(message: 'Invalid work_end_time');
        }
        payload['work_end_time'] = apiEnd;
      }
      final response = await _client.post(
        ApiEndpoints.finishSchedule(scheduleId),
        data: payload.isEmpty ? null : payload,
      );
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
    required int? minute,
    required String reason,
  }) async {
    try {
      final map = <String, dynamic>{'cancel_by': cancelBy.toLowerCase(), 'reason': reason};
      if (hour != null) map['hour'] = hour;
      if (minute != null) map['minute'] = minute;
      final formData = FormData.fromMap(map);
      if (cancelReason != null) formData.fields.add(MapEntry('reason_type', cancelReason));

      final response = await _client.post(ApiEndpoints.cancelSchedule(scheduleId), data: formData);
      final data = response.data['data'];
      try {
        return ScheduleModel.fromJson(data as Map<String, dynamic>);
      } catch (_) {
        // Cancel may have succeeded but payload shape differs; refresh from details endpoint.
        return getScheduleById(scheduleId: scheduleId);
      }
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
