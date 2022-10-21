import 'package:paged_vertical_calendar/utils/date_models.dart';

abstract class DateUtils {
  /// generates a [Month] object from the Nth index from the startdate
  static Month getMonth(
    DateTime? minDate,
    DateTime? maxDate,
    int monthPage,
    bool up, {
    bool startWeekWithSunday = false,
  }) {
    // if no start date is provided use the current date
    DateTime startDate = (minDate ?? DateTime.now()).removeTime();

    // if this is not the first month in this calendar then calculate a new
    // start date for this month
    if (monthPage > 0) {
      if (up) {
        // fetsch up: month will be subtructed
        startDate = DateTime(startDate.year, startDate.month - monthPage, 1);
      } else {
        // fetch down: month will be added
        startDate = DateTime(startDate.year, startDate.month + monthPage, 1);
      }
    }

    // find the first day of the first week in this month
    final weekMinDate = _findDayOfWeekInMonth(
      startDate,
      getWeekDay(startDate, startWeekWithSunday),
      startWeekWithSunday: startWeekWithSunday,
    );

    // every week has a start and end date, calculate them once for the start
    // of the month then reuse these variables for every other week in
    // month
    DateTime firstDayOfWeek = weekMinDate;
    DateTime lastDayOfWeek = _lastDayOfWeek(weekMinDate, startWeekWithSunday);

    List<Week> weeks = [];

    // we don't know when this month ends until we reach it, so we have to use
    // an indefinate loop
    while (true) {
      // if an endDate is provided we need to check if the current week extends
      // beyond this date. if it does, cap the week to the endDate and stop the
      // loop

      if (up) {
        // fetching up
        Week week;
        if (maxDate != null && firstDayOfWeek.isBefore(maxDate)) {
          week = Week(maxDate, lastDayOfWeek);
        } else {
          week = Week(firstDayOfWeek, lastDayOfWeek);
        }

        if (maxDate != null && lastDayOfWeek.isSameDayOrAfter(maxDate)) {
          weeks.add(week);
        } else if (maxDate == null) {
          weeks.add(week);
        }
        if (week.isLastWeekOfMonth) break;
      } else {
        // fetching down
        if (maxDate != null && lastDayOfWeek.isSameDayOrAfter(maxDate)) {
          Week week = Week(firstDayOfWeek, maxDate);
          weeks.add(week);
          break;
        }

        Week week = Week(firstDayOfWeek, lastDayOfWeek);
        weeks.add(week);

        if (week.isLastWeekOfMonth) break;
      }

      firstDayOfWeek = lastDayOfWeek.nextDay;
      lastDayOfWeek = _lastDayOfWeek(firstDayOfWeek, startWeekWithSunday);
    }

    return Month(weeks);
  }

  static int getWeekDay(DateTime _date, bool startWeekWithSunday) {
    if (startWeekWithSunday) {
      return _date.weekday == DateTime.sunday ? 1 : _date.weekday + 1;
    } else {
      return _date.weekday;
    }
  }

  /// calculates the last of the week by calculating the remaining days in a
  /// standard week and evaluating if this week extends beyond the total days
  /// in that month, and capping it to the end of the month if it does
  static DateTime _lastDayOfWeek(
    DateTime firstDayOfWeek,
    bool startWeekWithSunday,
  ) {
    int daysInMonth = firstDayOfWeek.daysInMonth;

    final dayOfWeek = getWeekDay(firstDayOfWeek, startWeekWithSunday);
    final restOfWeek = DateTime.daysPerWeek - dayOfWeek;

    return firstDayOfWeek.day + restOfWeek > daysInMonth
        ? DateTime(firstDayOfWeek.year, firstDayOfWeek.month, daysInMonth)
        : firstDayOfWeek.add(Duration(days: restOfWeek));
  }

  static DateTime _findDayOfWeekInMonth(
    DateTime date,
    int dayOfWeek, {
    bool startWeekWithSunday = false,
  }) {
    date = date.removeTime();

    if (date.weekday ==
        (startWeekWithSunday ? DateTime.sunday : DateTime.monday)) {
      return date;
    } else {
      return date.subtract(
          Duration(days: getWeekDay(date, startWeekWithSunday) - dayOfWeek));
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

  /// efficient leapyear calcualtion transcribed from a C stackoverflow answer
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

  bool isSameMonth(DateTime other) =>
      other.year == year && other.month == month;
}
