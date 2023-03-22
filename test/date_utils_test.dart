import 'package:flutter_test/flutter_test.dart';
import 'package:paged_vertical_calendar/utils/date_utils.dart';

void main() {
  setUp(() {});
  tearDown(() {});
  group('DateUtils ', () {
    test(
      '''should return correct value [listOfValidDatesInMonth] of when there is 
      days to hide ''',
      () async {
        //Arrange
        final month = DateUtils.getMonth(DateTime(2023), null, 0, false);

        //Act
        final value = DateUtils.listOfValidDatesInMonth(
            month, [DateTime.sunday, DateTime.saturday]);

        //Assert
        expect(value.length, 22);
        expect(value.first.day, 2);
      },
    );
    test(
      '''should return total no of month value [listOfValidDatesInMonth] when 
      there is no days to hide for month January 2023''',
      () async {
        //Arrange
        final month = DateUtils.getMonth(DateTime(2023), null, 0, false);

        //Act
        final value = DateUtils.listOfValidDatesInMonth(month, []);

        //Assert
        expect(value.length, 31);
        expect(value.first.day, 1);
      },
    );
    test(
      '''should return total no of month value 
      [getNoOfSpaceRequiredBeforeFirstValidDate] when there is no days to hide 
      for month January 2023''',
      () async {
        //Arrange
        final month = DateUtils.getMonth(DateTime(2023), null, 0, false);
        final daysToHide = <int>[];
        final isSundayFirstDayOfWeek = true;
        //Act
        final value = DateUtils.listOfValidDatesInMonth(month, daysToHide);
        final firstValidDay = value.isNotEmpty ? value.first.weekday : 0;
        final noOfEmptySpaceBeforeValidDate =
            DateUtils.getNoOfSpaceRequiredBeforeFirstValidDate(
                daysToHide, firstValidDay, isSundayFirstDayOfWeek);

        //Assert
        expect(noOfEmptySpaceBeforeValidDate, 0);
      },
    );
    test(
      '''should return total no of month value 
      [getNoOfSpaceRequiredBeforeFirstValidDate] when Tuesday and Wednesday are
      hidden for month January 2023''',
      () async {
        final month = DateUtils.getMonth(DateTime(2023), null, 0, false);
        final weekdaysToHide = <int>[DateTime.tuesday, DateTime.wednesday];
        //Act
        final value = DateUtils.listOfValidDatesInMonth(month, weekdaysToHide);
        final firstValidDay = value.isNotEmpty ? value.first.weekday : 0;
        final noOfEmptySpaceBeforeValidDate =
            DateUtils.getNoOfSpaceRequiredBeforeFirstValidDate(
                weekdaysToHide, firstValidDay);

        //Assert
        expect(noOfEmptySpaceBeforeValidDate, 4);
      },
    );
    test(
      '''should return total no of month value 
      [getNoOfSpaceRequiredBeforeFirstValidDate] when there is no days to hide 
      for month January 2023 and week start is Monday''',
      () async {
        final month = DateUtils.getMonth(DateTime(2023), null, 0, false);
        final weekdaysToHide = <int>[];
        //Act
        final value = DateUtils.listOfValidDatesInMonth(month, weekdaysToHide);
        final firstValidDay = value.isNotEmpty ? value.first.weekday : 0;
        final noOfEmptySpaceBeforeValidDate =
            DateUtils.getNoOfSpaceRequiredBeforeFirstValidDate(
                weekdaysToHide, firstValidDay);

        //Assert
        expect(noOfEmptySpaceBeforeValidDate, 6);
      },
    );
  });
}
