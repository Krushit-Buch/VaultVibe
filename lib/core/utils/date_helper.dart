import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Date formatting and utility helpers.
class DateHelper {
  DateHelper._();

  static String format(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat(AppConstants.monthYearFormat).format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat(AppConstants.shortDateFormat).format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat(AppConstants.timeFormat).format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  static DateTime get startOfToday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime get startOfThisWeek {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - now.weekday + 1);
  }

  static DateTime get startOfThisMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  static DateTime get startOfLastMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 1, 1);
  }

  static DateTime get endOfLastMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 0, 23, 59, 59);
  }

  static DateTime get startOfThisYear {
    return DateTime(DateTime.now().year, 1, 1);
  }
}
