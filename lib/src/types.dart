import 'package:flutter/widgets.dart';

/// A builder method that provides the [month] and
/// [year] on which this builder will act 
typedef MonthBuilder = Widget Function(
  BuildContext context,
  int month,
  int year,
);

/// A builder that provides the [date]
/// on which this builder will act
typedef DayBuilder = Widget Function(
  BuildContext context,
  DateTime date,
);

/// Callback that provides you with a [month]
/// and [year]
typedef OnMonthLoaded = void Function(
  int year,
  int month,
);
