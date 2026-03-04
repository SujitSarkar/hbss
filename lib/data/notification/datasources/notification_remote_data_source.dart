import 'package:dio/dio.dart';

import 'package:maori_health/core/error/exceptions.dart';
import 'package:maori_health/core/network/api_endpoints.dart';
import 'package:maori_health/core/network/dio_client.dart';
import 'package:maori_health/core/utils/data_parse_util.dart';

import 'package:maori_health/data/notification/models/notification_response_model.dart';

class PaginatedNotificationResponse {
  final List<NotificationResponseModel> notifications;
  final int unreadCount;
  final int currentPage;
  final int lastPage;

  const PaginatedNotificationResponse({
    required this.notifications,
    required this.unreadCount,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;
}

abstract class NotificationRemoteDataSource {
  Future<PaginatedNotificationResponse> getNotifications({int page = 1});
  Future<NotificationResponseModel> readNotification(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient _client;

  NotificationRemoteDataSourceImpl({required DioClient client}) : _client = client;

  @override
  Future<PaginatedNotificationResponse> getNotifications({int page = 1}) async {
    try {
      final response = await _client.get(ApiEndpoints.notifications, queryParameters: {'page': page});
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw ApiException(
          statusCode: response.statusCode,
          message: body['message']?.toString() ?? 'Failed to fetch notifications',
        );
      }

      final responseBody = body['data'] as Map<String, dynamic>;
      final list = responseBody['notifications']?['data'] as List<dynamic>? ?? [];

      return PaginatedNotificationResponse(
        notifications: list.map((e) => NotificationResponseModel.fromJson(e as Map<String, dynamic>)).toList(),
        currentPage: DataParseUtil.parseInt(responseBody['notifications']?['current_page'], defaultValue: 1),
        lastPage: DataParseUtil.parseInt(responseBody['notifications']?['last_page'], defaultValue: 1),
        unreadCount: DataParseUtil.parseInt(responseBody['unread']),
      );
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to fetch notifications',
      );
    }
  }

  @override
  Future<NotificationResponseModel> readNotification(String notificationId) async {
    try {
      final response = await _client.get(ApiEndpoints.readNotification(notificationId));
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        throw ApiException(
          statusCode: response.statusCode,
          message: body['message']?.toString() ?? 'Failed to retrieve notification',
        );
      }
      return NotificationResponseModel.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = (e.response?.data is Map) ? (e.response!.data as Map)['message']?.toString() : null;
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: message ?? e.message ?? 'Failed to retrieve notification',
      );
    }
  }
}
