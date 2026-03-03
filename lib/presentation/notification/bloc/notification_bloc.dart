import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maori_health/core/config/app_strings.dart';
import 'package:maori_health/domain/notification/repositories/notification_repository.dart';

import 'package:maori_health/presentation/notification/bloc/bloc.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc({required NotificationRepository repository})
    : _repository = repository,
      super(const NotificationLoadingState()) {
    on<NotificationsLoadEvent>(_onNotificationsLoadEvent);
    on<NotificationLoadMoreEvent>(_onNotificationLoadMoreEvent);
    on<NotificationReadEvent>(_onNotificationReadEvent);
  }

  Future<void> _onNotificationsLoadEvent(NotificationsLoadEvent event, Emitter<NotificationState> emit) async {
    emit(const NotificationLoadingState());

    final result = await _repository.getNotifications(page: 1);
    await result.fold(
      onFailure: (error) async {
        emit(NotificationErrorState(error.errorMessage ?? AppStrings.somethingWentWrong));
      },
      onSuccess: (response) async {
        emit(
          NotificationLoadedState(
            notifications: response.notifications,
            currentPage: response.currentPage,
            lastPage: response.lastPage,
          ),
        );
      },
    );
  }

  Future<void> _onNotificationLoadMoreEvent(NotificationLoadMoreEvent event, Emitter<NotificationState> emit) async {
    final currentState = state;
    if (currentState is! NotificationLoadedState || !currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final result = await _repository.getNotifications(page: nextPage);

    await result.fold(
      onFailure: (error) async {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      onSuccess: (response) async {
        emit(
          NotificationLoadedState(
            notifications: [...currentState.notifications, ...response.notifications],
            currentPage: response.currentPage,
            lastPage: response.lastPage,
          ),
        );
      },
    );
  }

  Future<void> _onNotificationReadEvent(NotificationReadEvent event, Emitter<NotificationState> emit) async {
    final currentState = state;
    if (currentState is! NotificationLoadedState) return;

    final result = await _repository.getNotification(event.notificationId);
    await result.fold(
      onFailure: (error) async {},
      onSuccess: (updatedNotification) async {
        final latestState = state;
        if (latestState is! NotificationLoadedState) return;

        final updated = latestState.notifications.map((notification) {
          return notification.id == event.notificationId ? updatedNotification : notification;
        }).toList();
        emit(latestState.copyWith(notifications: updated));
      },
    );
  }
}
