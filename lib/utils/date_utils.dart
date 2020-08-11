import 'package:vertical_calendar/utils/date_models.dart';

class DateUtils {
  static List<Month> extractWeeks(DateTime minDate, DateTime maxDate) {
    DateTime weekMinDate = _findDayOfWeekInMonth(minDate, DateTime.monday);
    DateTime weekMaxDate = _findDayOfWeekInMonth(maxDate, DateTime.sunday);

    DateTime firstDayOfWeek = weekMinDate;
    DateTime lastDayOfWeek = _lastDayOfWeek(weekMinDate);

    if (!lastDayOfWeek.isBefore(weekMaxDate)) {
      return <Month>[
        Month(<Week>[Week(firstDayOfWeek, lastDayOfWeek)])
      ];
    } else {
      List<Month> months = List<Month>();
      List<Week> weeks = List<Week>();

      while (lastDayOfWeek.isBefore(weekMaxDate)) {
        Week week = Week(firstDayOfWeek, lastDayOfWeek);
        weeks.add(week);

        if (week.isLastWeekOfMonth) {
          months.add(Month(weeks));
          weeks = List<Week>();

          firstDayOfWeek = firstDayOfWeek.toFirstDayOfNextMonth();
          lastDayOfWeek = _lastDayOfWeek(firstDayOfWeek);

          weeks.add(Week(firstDayOfWeek, lastDayOfWeek));
        }

        firstDayOfWeek = lastDayOfWeek.nextDay;
        lastDayOfWeek = _lastDayOfWeek(firstDayOfWeek);
      }

      if (!lastDayOfWeek.isBefore(weekMaxDate)) {
        weeks.add(Week(firstDayOfWeek, lastDayOfWeek));
      }

      months.add(Month(weeks));

      return months;
    }
  }

  static DateTime _lastDayOfWeek(DateTime firstDayOfWeek) {
    int daysInMonth = firstDayOfWeek.daysInMonth;

    if (firstDayOfWeek.day + 6 > daysInMonth) {
      return DateTime(firstDayOfWeek.year, firstDayOfWeek.month, daysInMonth);
    } else {
      return firstDayOfWeek
          .add(Duration(days: DateTime.sunday - firstDayOfWeek.weekday));
    }
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
        isLeapYear(year) ? 29 : 28,
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

  static bool isLeapYear(int year) {
    bool leapYear = false;

    bool leap = ((year % 100 == 0) && (year % 400 != 0));
    if (leap == true) {
      return false;
    } else if (year % 4 == 0) {
      return true;
    }

    return leapYear;
  }
}

extension DateUtilsExtensions on DateTime {
  bool get isLeapYear {
    bool leapYear = false;

    bool leap = ((year % 100 == 0) && (year % 400 != 0));
    if (leap == true) {
      return false;
    } else if (year % 4 == 0) {
      return true;
    }

    return leapYear;
  }

  int get daysInMonth => DateUtils.daysPerMonth(year)[month - 1];

  DateTime toFirstDayOfNextMonth() => DateTime(
        year,
        month + 1,
      );

  DateTime get nextDay => DateTime(year, month, day + 1);

  bool isSameDayOrAfter(DateTime other) => isAfter(other) || isSameDay(other);

  bool isSameDayOrBefore(DateTime other) => isBefore(other) || isSameDay(other);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime removeTime() => DateTime(year, month, day);
}
