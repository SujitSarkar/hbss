import 'package:intl/intl.dart';

abstract class DateConverter {
  static String formatDate(DateTime date) => DateFormat('dd-MM-yyyy').format(date);

  static String formatDateTime(DateTime date) => DateFormat('dd-MM-yyyy | h:mm a').format(date);

  static String toIsoDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  static String toWeekDay(DateTime date) => DateFormat('EEEE, dd MMM').format(date);

  static String toWeekMonthDay(DateTime date) => DateFormat('EEEE, MMM dd').format(date);

  static ({int day, int hour, int minute}) minutesToDhm(int totalMinutes) {
    return (day: totalMinutes ~/ 1440, hour: (totalMinutes % 1440) ~/ 60, minute: totalMinutes % 60);
  }

  static String formatTime(String time) {
    try {
      final parsed = DateFormat('HH:mm:ss').parseStrict(time);
      return DateFormat('hh:mm a').format(parsed);
    } catch (_) {
      try {
        final parsed = DateFormat('HH:mm').parseStrict(time);
        return DateFormat('hh:mm a').format(parsed);
      } catch (_) {
        return time;
      }
    }
  }

  static String toDisplayTime(DateTime dateTime, {String? locale}) {
    return DateFormat('hh:mm a', locale).format(dateTime);
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  static String formatIsoDateTime(String? isoDate, {String pattern = 'dd-MM-yyyy | h:mm a'}) {
    if (isoDate == null || isoDate.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat(pattern).format(dt);
    } catch (_) {
      return isoDate;
    }
  }
}
