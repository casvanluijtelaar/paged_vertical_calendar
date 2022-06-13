
import 'extensions.dart';

class Month {
  const Month(this.weeks);

  final List<Week> weeks;

  int get year => weeks.first.firstDay.year;
  int get month => weeks.first.firstDay.month;
  int get daysInMonth => weeks.first.firstDay.daysInMonth;

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
