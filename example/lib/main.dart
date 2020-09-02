import 'package:flutter/material.dart';
import 'package:vertical_calendar/vertical_calendar.dart';

//ignore_for_file: avoid_print
void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Vertical calendar'),
        ),
        body: VerticalCalendar(
          minDate: DateTime.now(),
          maxDate: DateTime.now().add(const Duration(days: 365)),
          onDayPressed: (DateTime date) {
            print('Date selected: $date');
          },
          onRangeSelected: (DateTime d1, DateTime d2) {
            print('Range: from $d1 to $d2');
          },
        ),
      ),
    ),
  );
}
