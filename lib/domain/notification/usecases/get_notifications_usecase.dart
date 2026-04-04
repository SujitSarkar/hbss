import 'package:maori_health/core/error/failures.dart';
import 'package:maori_health/core/result/result.dart';
import 'package:maori_health/data/notification/models/paginated_notification_response.dart';
import 'package:maori_health/domain/notification/repositories/notification_repository.dart';

class GetNotificationsUsecase {
  final NotificationRepository _repository;

  GetNotificationsUsecase({required NotificationRepository repository}) : _repository = repository;

  Future<Result<AppError, PaginatedNotificationResponse>> call({int page = 1}) {
    return _repository.getNotifications(page: page);
  }
}
