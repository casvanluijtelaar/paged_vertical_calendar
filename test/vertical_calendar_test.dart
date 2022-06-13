import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_test/flutter_test.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';

void main() {
  group('utils', () {
    test('get a month without provided dates', () {
      final month = DateUtils.getMonth(
        startDate: DateTime.now(),
        startWeekWithSunday: true,
        monthsFromStartDate: 0,
      );
      expect(month.month, DateTime.now().month);
      expect(
        month.daysInMonth,
        DateUtils.daysPerMonth(month.year)[month.month - 1],
      );
    });

    test('get a month with provided start date', () {
      final month = DateUtils.getMonth(
        startDate: DateTime(2020, 1, 1),
        monthsFromStartDate: 1,
      );

      expect(month.month, 2);
      expect(
        month.daysInMonth,
        DateUtils.daysPerMonth(month.year)[month.month - 1],
      );
      expect(month.year, 2020);
    });

    test('get a previous month with provided start date', () {
      final month = DateUtils.getMonth(
        startDate: DateTime(2020, 2, 1),
        monthsFromStartDate: -1,
      );

      expect(month.month, 1);
      expect(
        month.daysInMonth,
        DateUtils.daysPerMonth(month.year)[month.month - 1],
      );
      expect(month.year, 2020);
    });

    test('get a month with provided end date', () {
      final month = DateUtils.getMonth(
        startDate: DateTime(2020, 1, 1),
        endDate: DateTime(2020, 5, 1),
        monthsFromStartDate: 4,
      );
      expect(month, isNotNull);
      expect(month.month, 5);
      expect(month.daysInMonth,
          DateUtils.daysPerMonth(month.year)[month.month - 1]);
      expect(month.year, 2020);
    });
  });

  group('widgets', () {
    testWidgets('check 1st month generation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PagedVerticalCalendar(
              monthBuilder: (context, month, year) => Text('$year $month'),
            ),
          ),
        ),
      );

      final date = DateTime.now();

      final month = find.text('${date.year} ${date.month}');
      expect(month, findsOneWidget);
    });
  });
}
