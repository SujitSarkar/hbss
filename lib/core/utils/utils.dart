import 'package:flutter/services.dart';

class Utils {
  static void hideKeyboard() => SystemChannels.textInput.invokeMethod('TextInput.hide');

  static String getNotificationBadgeLabel(int unreadCount) {
    // if (unreadCount > 99) return '99+';
    return unreadCount.toString();
  }
}
