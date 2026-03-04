import 'package:equatable/equatable.dart';

import 'package:maori_health/domain/notification/entities/notification_response.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationLoadingState extends NotificationState {
  const NotificationLoadingState();
}

class NotificationLoadedState extends NotificationState {
  final List<NotificationResponse> notifications;
  final int unreadCount;
  final int currentPage;
  final int lastPage;

  final bool isLoadingMore;

  const NotificationLoadedState({
    required this.notifications,
    required this.unreadCount,
    required this.currentPage,
    required this.lastPage,
    this.isLoadingMore = false,
  });

  bool get hasMore => currentPage < lastPage;

  NotificationLoadedState copyWith({
    List<NotificationResponse>? notifications,
    int? unreadCount,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return NotificationLoadedState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [notifications, unreadCount, currentPage, lastPage, isLoadingMore];
}

class NotificationErrorState extends NotificationState {
  final String errorMessage;

  const NotificationErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
