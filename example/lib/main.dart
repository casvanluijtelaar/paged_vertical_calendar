import 'dart:math';

import 'package:flutter/material.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';
import 'package:intl/intl.dart';

void main() => runApp(Home());

/// a simple example showing several ways this package can be used
/// to implement calendar related interfaces.
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Paged Vertical Calendar'),
              bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(icon: Icon(Icons.calendar_today), text: 'Custom'),
                  Tab(icon: Icon(Icons.date_range), text: 'DatePicker'),
                  Tab(icon: Icon(Icons.dns), text: 'Pagination'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                Custom(),
                DatePicker(),
                Pagination(),
              ],
            ),
          ),
        ),
      );
}

/// simple demonstration of the calendar customizability
class Custom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PagedVerticalCalendar(
      /// customize the month header look by adding a week indicator
      monthBuilder: (context, month, year) {
        return Column(
          children: [
            /// create a customized header displaying the month and year
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: Text(
                DateFormat('MMMM yyyy').format(DateTime(year, month)),
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),

            /// add a row showing the weekdays
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  weekText('Mo'),
                  weekText('Tu'),
                  weekText('We'),
                  weekText('Th'),
                  weekText('Fr'),
                  weekText('Sa'),
                  weekText('Su'),
                ],
              ),
            ),
          ],
        );
      },

      /// added a line between every week
      dayBuilder: (context, date) {
        return Column(
          children: [
            Text(DateFormat('d').format(date)),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget weekText(String text) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey, fontSize: 10),
      ),
    );
  }
}

/// simple example showing how to make a basic date range picker with
/// UI indication
class DatePicker extends StatefulWidget {
  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  /// store the selected start and end dates
  DateTime? start;
  DateTime? end;

  /// method to check wether a day is in the selected range
  /// used for highlighting those day
  bool isInRange(DateTime date) {
    // if start is null, no date has been selected yet
    if (start == null) return false;
    // if only end is null only the start should be highlighted
    if (end == null) return date == start;
    // if both start and end aren't null check if date false in the range
    return ((date == start || date.isAfter(start!)) &&
        (date == end || date.isBefore(end!)));
  }

  @override
  Widget build(BuildContext context) {
    return PagedVerticalCalendar(
      addAutomaticKeepAlives: true,
      dayBuilder: (context, date) {
        // update the days color based on if it's selected or not
        final color = isInRange(date) ? Colors.green : Colors.transparent;

        return Container(
          color: color,
          child: Center(
            child: Text(DateFormat('d').format(date)),
          ),
        );
      },
      onDayPressed: (date) {
        setState(() {
          // if start is null, assign this date to start
          if (start == null)
            start = date;
          // if only end is null assign it to the end
          else if (end == null)
            end = date;
          // if both start and end arent null, show results and reset
          else {
            print('selected range from $start to $end');
            start = null;
            end = null;
          }
        });
      },
    );
  }
}

/// simple example on how to display paginated data in the calendar and interact
/// with it.
class Pagination extends StatefulWidget {
  @override
  _PaginationState createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  /// list holding all the items we are displaying
  List<DateTime> items = [];

  /// called every time a new month is loaded
  void fetchNewEvents(int year, int month) async {
    Random random = Random();
    // this is where you would load your custom data, sync or async
    // this data does require a date so you can later filter on that
    // date
    final newItems = List<DateTime>.generate(random.nextInt(40), (i) {
      return DateTime(year, month, random.nextInt(27) + 1);
    });

    // add to all our fetched items and update UI
    setState(() => items.addAll(newItems));
  }

  @override
  Widget build(BuildContext context) {
    return PagedVerticalCalendar(
      // to prevent the data from being reset every time a user loads or
      // unloads this widget
      addAutomaticKeepAlives: true,
      // when the new month callback fires, we want to fetch the items
      // for this month
      onMonthLoaded: fetchNewEvents,
      dayBuilder: (context, date) {
        // from all our items get those that are supposed to be displayed
        // on this day
        final eventsThisDay = items.where((e) => e == date);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(DateFormat('d').format(date)),
            // for every event this day, add a small indicator dot
            Wrap(
              children: eventsThisDay.map((event) {
                return Padding(
                  padding: const EdgeInsets.all(1),
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: Colors.red,
                  ),
                );
              }).toList(),
            )
          ],
        );
      },
      onDayPressed: (day) {
        // when a day is pressed we can check which events are linked to this
        // day and do something with them. e.g. open a new page
        final eventsThisDay = items.where((e) => e == day);
        print('items this day: $eventsThisDay');
      },
    );
  }
}
