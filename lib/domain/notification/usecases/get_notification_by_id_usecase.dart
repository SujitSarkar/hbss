import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/domain/notification/entities/notification_response.dart';
import 'package:maori_health/domain/notification/repositories/notification_repository.dart';

class GetNotificationByIdUsecase {
  final NotificationRepository _repository;

  GetNotificationByIdUsecase({required NotificationRepository repository}) : _repository = repository;

  Future<Result<AppError, NotificationResponse>> call(String notificationId) {
    return _repository.getNotification(notificationId);
  }
}
