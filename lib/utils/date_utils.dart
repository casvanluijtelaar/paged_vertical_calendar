import 'package:paged_vertical_calendar/utils/date_models.dart';

class DateUtils {
  static Month getMonth(DateTime? minDate, DateTime? maxDate, int monthPage) {
    DateTime startDate = (minDate ?? DateTime.now()).removeTime();
    if (monthPage > 0)
      startDate = DateTime(startDate.year, startDate.month + monthPage, 1);

    DateTime weekMinDate = _findDayOfWeekInMonth(startDate, startDate.weekday);

    DateTime firstDayOfWeek = weekMinDate;
    DateTime lastDayOfWeek = _lastDayOfWeek(weekMinDate);

    List<Week> weeks = [];

    while (true) {
      if (maxDate != null && lastDayOfWeek.isAfter(maxDate)) {
        Week week = Week(firstDayOfWeek, maxDate);
        weeks.add(week);
        break;
      }

      Week week = Week(firstDayOfWeek, lastDayOfWeek);
      weeks.add(week);

      if (week.isLastWeekOfMonth) break;

      firstDayOfWeek = lastDayOfWeek.nextDay;
      lastDayOfWeek = _lastDayOfWeek(firstDayOfWeek);
    }

    return Month(weeks);
  }

  static DateTime _lastDayOfWeek(DateTime firstDayOfWeek) {
    int daysInMonth = firstDayOfWeek.daysInMonth;

    final restOfWeek = (DateTime.daysPerWeek - firstDayOfWeek.weekday);

    return firstDayOfWeek.day + restOfWeek > daysInMonth
        ? DateTime(firstDayOfWeek.year, firstDayOfWeek.month, daysInMonth)
        : firstDayOfWeek.add(Duration(days: restOfWeek));
  }

  static DateTime _findDayOfWeekInMonth(DateTime date, int dayOfWeek) {
    date = DateTime(date.year, date.month, date.day);

    if (date.weekday == DateTime.monday) {
      return date;
    } else {
      return date.subtract(Duration(days: date.weekday - dayOfWeek));
    }
  }

  static List<int> daysPerMonth(int year) => <int>[
        31,
        _isLeapYear(year) ? 29 : 28,
        31,
        30,
        31,
        30,
        31,
        31,
        30,
        31,
        30,
        31,
      ];

  static bool _isLeapYear(int year) {
    return (year & 3) == 0 && ((year % 25) != 0 || (year & 15) == 0);
  }
}

extension DateUtilsExtensions on DateTime {
  int get daysInMonth => DateUtils.daysPerMonth(year)[month - 1];

  DateTime get nextDay => DateTime(year, month, day + 1);

  bool isSameDayOrAfter(DateTime other) => isAfter(other) || isSameDay(other);

  bool isSameDayOrBefore(DateTime other) => isBefore(other) || isSameDay(other);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime removeTime() => DateTime(year, month, day);
}
