import 'extensions.dart';
import 'models.dart';

class DateUtils {
  /// calculates a month X months away from the start date
  ///
  /// * startDate: the date from which to start counting
  /// * endDate: optional endDate which will end the month early at this
  ///   day when reached
  /// * monthsFromStartDate: the number of months from the startDate of
  ///   which we want to calcukate the month can be negative for
  ///   previous months
  /// * startWeekWithSunday: in some parts of the world the week starts with sunday
  ///   we need to indicate that as such for correct month calculation
  static Month getMonth({
    required DateTime startDate,
    DateTime? endDate,
    required int monthsFromStartDate,
    bool startWeekWithSunday = false,
  }) {
    /// we calculate a new start date for this month by making use of a handy
    /// feature in Dart's [DateTime] where months added beyond 12 automatically
    /// get converted into extra years + months
    startDate = DateTime(
      startDate.year,
      startDate.month + monthsFromStartDate,
      1,
    );

    /// find the first day of the first week in this month
    final weekMinDate = _findDayOfWeekInMonth(
      startDate,
      getWeekDay(startDate, startWeekWithSunday),
      startWeekWithSunday: startWeekWithSunday,
    );

    /// every week has a start and end date, calculate them once for the start
    /// of the month then reuse these variables for every other week in month
    DateTime firstDayOfWeek = weekMinDate;
    DateTime lastDayOfWeek = calculateLastDayOfWeek(
      weekMinDate,
      startWeekWithSunday,
    );

    List<Week> weeks = [];

    /// we don't know when this month ends until we reach it, so we have to use
    /// an indefinate loop
    while (true) {
      /// if endDate is not null, check if we have reached the endDate this week
      if (endDate != null) {
        /// are we fetching previous months from the startDate or next months?
        final backwards = monthsFromStartDate.isNegative;

        /// when fetching previous months, we reach the end if the first day of
        /// the week false on the same day or falls before the endDate
        /// whilst for next months we need to check if the last dat falls after
        /// the endDate
        final reachedEnd = backwards
            ? firstDayOfWeek.isSameDayOrBefore(endDate)
            : lastDayOfWeek.isSameDayOrAfter(endDate);

        if (reachedEnd) {
          /// create a new week that for previous months starts with the endDate
          /// and for next months, ends with the endDate
          Week week = Week(
            backwards ? endDate : firstDayOfWeek,
            backwards ? lastDayOfWeek : endDate,
          );
          weeks.add(week);
          break;
        }
      }

      /// create a new week from the previously calculated
      /// firstDayOfWeek and lastDayOfWeek
      Week week = Week(firstDayOfWeek, lastDayOfWeek);
      weeks.add(week);

      /// if we see we reached the end of this month,
      /// we can stop the loop
      if (week.isLastWeekOfMonth) break;

      /// if we haven't reached the end of the month yet,
      /// calculate a new first and last day for next week
      /// based on the end of this week
      firstDayOfWeek = lastDayOfWeek.nextDay;
      lastDayOfWeek = calculateLastDayOfWeek(
        firstDayOfWeek,
        startWeekWithSunday,
      );
    }

    /// create a new month from the generated weeks
    return Month(weeks);
  }

  /// returns the day of the week keeping in mind that in sone
  /// countries the week can start on sunday
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
  static DateTime calculateLastDayOfWeek(
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

    final firstDay = startWeekWithSunday ? DateTime.sunday : DateTime.monday;
    if (date.weekday == firstDay) {
      return date;
    } else {
      return date.subtract(
        Duration(days: getWeekDay(date, startWeekWithSunday) - dayOfWeek),
      );
    }
  }

  /// returns a [List] containing the length of
  /// every month that year
  static List<int> daysPerMonth(int year) => <int>[
        31,
        isLeapYear(year) ? 29 : 28,
        ...[31, 30, 31, 30, 31],
        ...[31, 30, 31, 30, 31],
      ];

  /// efficient leapyear calcualtion transcribed from a C stackoverflow answer
  static bool isLeapYear(int year) {
    return (year & 3) == 0 && ((year % 25) != 0 || (year & 15) == 0);
  }
}
