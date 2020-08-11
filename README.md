# Vertical Flutter Calendar

[![Pub](https://img.shields.io/pub/v/vertical_calendar.svg)](https://pub.dartlang.org/packages/vertical_calendar)

A really simple calendar with a vertical scroll.

<p align="center">
  <img src="https://raw.githubusercontent.com/g123k/flutter_vertical_calendar/master/assets/vertical_calendar.gif" style="margin:auto" width="400" 
height="711">
</p>

## Getting Started

First, you just have to import the package in your dart files with:
```dart
import 'package:vertical_calendar/vertical_calendar.dart';
```

Then you can use the Widget directly in your hierarchy. Mandatory fields are `minDate` and `maxDate`.
```dart
VerticalCalendar(
  minDate: DateTime.now(),
  maxDate: DateTime.now().add(const Duration(days: 365)),
  onDayPressed: (DateTime date) {
    print('Date selected: $date');
  },
  onRangeSelected: (DateTime d1, DateTime d2) {
    print('Range: from $d1 to $d2');
  },
)
```

## Day selected
To be notified when the user clicks on a date, just provide a callback:

```dart
VerticalCalendar(
  minDate: DateTime.now(),
  maxDate: DateTime.now().add(const Duration(days: 365)),
  onDayPressed: (DateTime date) {
    print('Date selected: $date');
  },
)
```

## Range selection

<p align="center">
  <img src="https://raw.githubusercontent.com/g123k/flutter_vertical_calendar/master/assets/range_selection.gif" style="margin:auto" width="540" 
height="372">
</p>

When `onRangeSelected` callback is provided, automatically the range selector feature will be enabled. 

```dart
VerticalCalendar(
  minDate: DateTime.now(),
  maxDate: DateTime.now().add(const Duration(days: 365)),
  onRangeSelected: (DateTime d1, DateTime d2) {
      print('Range: from $d1 to $d2');
  },
)
```

Note: if `onDayPressed` is not null, it will still be called.

## Customization

It is possible to change the Widget used for a month:
```dart
VerticalCalendar(
  minDate: DateTime.now(),
  maxDate: DateTime.now().add(const Duration(days: 365)),
  monthBuilder: (BuildContext context, int month, int year) {
    return Text('$month $year');
  },  
)
```

And also for a day:
```dart
VerticalCalendar(
  minDate: DateTime.now(),
  maxDate: DateTime.now().add(const Duration(days: 365)),
  dayBuilder: (BuildContext context, DateTime date, {bool isSelected}) {
    return Text(date.day.toString());
  },
)
```

`isSelected` allows you to know if this date is selected during a range selection.
 
Note: `isSelected` will always be null, when `onRangeSelected` is null.