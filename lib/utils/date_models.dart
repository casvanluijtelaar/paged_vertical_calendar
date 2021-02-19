import 'package:paged_vertical_calendar/utils/date_utils.dart';

class Month {
  final int month;
  final int year;
  final int daysInMonth;
  final List<Week> weeks;

  Month(this.weeks)
      : year = weeks.first.firstDay.year,
        month = weeks.first.firstDay.month,
        daysInMonth = weeks.first.firstDay.daysInMonth;

  @override
  String toString() {
    return 'Month{month: $month, year: $year, daysInMonth: $daysInMonth, weeks: $weeks}';
  }
}

class Week {
  final DateTime firstDay;
  final DateTime lastDay;

  Week(this.firstDay, this.lastDay);

  int get duration => lastDay.day - firstDay.day;

  bool get isLastWeekOfMonth => lastDay.day == lastDay.daysInMonth;

  @override
  String toString() {
    return 'Week{firstDay: $firstDay, lastDay: $lastDay}';
  }
}
