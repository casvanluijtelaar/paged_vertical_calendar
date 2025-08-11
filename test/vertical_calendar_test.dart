import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter_test/flutter_test.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';
import 'package:paged_vertical_calendar/utils/date_utils.dart';

void main() {
  group('utils', () {
    test('get a month without provided dates', () {
      final month = DateUtils.getMonth(null, null, 0, true);
      expect(month, isNotNull);
      expect(month.month, DateTime.now().month);
      expect(month.daysInMonth,
          DateUtils.daysPerMonth(month.year)[month.month - 1]);
    });

    test('get a month with provided start date', () {
      final month = DateUtils.getMonth(DateTime(2020, 1, 1), null, 0, true);
      expect(month, isNotNull);
      expect(month.month, 1);
      expect(month.daysInMonth,
          DateUtils.daysPerMonth(month.year)[month.month - 1]);
      expect(month.year, 2020);
    });

    test('get a month with provided end date', () {
      final month = DateUtils.getMonth(
          DateTime(2020, 1, 1), DateTime(2020, 5, 1), 4, false);
      expect(month, isNotNull);
      expect(month.month, 4);
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

      // Wait for the widget to build and load the first page
      await tester.pumpAndSettle();

      // The calendar shows the current month, so we should look for that
      // Find the month header text (it will be in format "Month Year")
      final monthHeaders = find.byWidgetPredicate((widget) {
        if (widget is Text) {
          final text = widget.data ?? '';
          // Check if it's a month header (contains a year)
          return text.contains('2025');
        }
        return false;
      });

      expect(monthHeaders, findsOneWidget);
    });
  });
}
