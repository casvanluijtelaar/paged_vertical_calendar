import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:paged_vertical_calendar/utils/date_models.dart';
import 'package:paged_vertical_calendar/utils/date_utils.dart';

/// a minimalistic paginated calendar widget providing infinite customisation
/// options and usefull paginated callbacks. all paremeters are optional.
///
/// ```
/// PagedVerticalCalendar(
///       startDate: DateTime(2021, 1, 1),
///       endDate: DateTime(2021, 12, 31),
///       onDayPressed: (day) {
///            print('Date selected: $day');
///          },
///          onMonthLoaded: (year, month) {
///            print('month loaded: $month-$year');
///          },
///          onPaginationCompleted: () {
///            print('end reached');
///          },
///        ),
/// ```
class PagedVerticalCalendar extends StatefulWidget {
  PagedVerticalCalendar({
    this.startDate,
    this.endDate,
    this.monthBuilder,
    this.dayBuilder,
    this.addAutomaticKeepAlives = false,
    this.onDayPressed,
    this.onMonthLoaded,
    this.onPaginationCompleted,
    this.invisibleMonthsThreshold = 1,
    this.listPadding = EdgeInsets.zero,
  });

  /// the [DateTime] to start the calendar from, if no [startDate] is provided
  /// `DateTime.now()` will be used
  final DateTime startDate;

  /// optional [DateTime] to end the calendar pagination, of no [endDate] is
  /// provided the calendar can paginate indefinitely
  final DateTime endDate;

  /// a Builder used for month header generation. a default [MonthBuilder] is
  /// used when no custom [MonthBuilder] is provided.
  /// * [context]
  /// * [int] year: 2021
  /// * [int] month: 1-12
  final MonthBuilder monthBuilder;

  /// a Builder used for day generation. a default [DayBuilder] is
  /// used when no custom [DayBuilder] is provided.
  /// * [context]
  /// * [DateTime] date
  final DayBuilder dayBuilder;

  /// if the calendar should stay cached when the widget is no longer loaded.
  /// this can be used for maintaining the last state. defaults to `false`
  final bool addAutomaticKeepAlives;

  /// callback that provides the [DateTime] of the day that's been interacted
  /// with
  final ValueChanged<DateTime> onDayPressed;

  /// callback when a new paginated month is loaded.
  final OnMonthLoaded onMonthLoaded;

  /// called when the calendar pagination is completed. if no [endDate] is
  /// provided this method is never called
  final Function onPaginationCompleted;

  /// how many months should be loaded outside of the view. defaults to `1`
  final int invisibleMonthsThreshold;

  /// list padding, defaults to `EdgeInsets.zero`
  final EdgeInsetsGeometry listPadding;

  @override
  _PagedVerticalCalendarState createState() => _PagedVerticalCalendarState();
}

class _PagedVerticalCalendarState extends State<PagedVerticalCalendar> {
  PagingController<int, Month> controller;

  @override
  void initState() {
    super.initState();
    controller = PagingController<int, Month>(
      firstPageKey: 0,
      invisibleItemsThreshold: widget.invisibleMonthsThreshold,
    );
    controller.addPageRequestListener(fetchItems);
    controller.addStatusListener(paginationStatus);
  }

  void paginationStatus(PagingStatus state) {
    if (state == PagingStatus.completed) return widget.onPaginationCompleted();
  }

  void fetchItems(int pageKey) async {
    try {
      final month = DateUtils.getMonth(
        widget.startDate,
        widget.endDate,
        pageKey,
      );

      if (widget.onMonthLoaded != null)
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.onMonthLoaded(month.year, month.month));

      final newItems = [month];
      final isLastPage = widget.endDate != null &&
          widget.endDate.isSameDayOrBefore(month.weeks.last.lastDay);

      if (isLastPage) return controller.appendLastPage(newItems);

      final nextPageKey = pageKey + newItems.length;
      controller.appendPage(newItems, nextPageKey);
    } catch (_) {
      controller.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: PagedListView<int, Month>(
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        padding: widget.listPadding,
        pagingController: controller,
        builderDelegate: PagedChildBuilderDelegate<Month>(
          itemBuilder: (BuildContext context, Month month, int index) {
            return _MonthView(
              month: month,
              monthBuilder: widget.monthBuilder,
              dayBuilder: widget.dayBuilder,
              onDayPressed: widget.onDayPressed,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _MonthView extends StatelessWidget {
  _MonthView({
    @required this.month,
    this.monthBuilder,
    this.dayBuilder,
    this.onDayPressed,
  });

  final Month month;
  final MonthBuilder monthBuilder;
  final DayBuilder dayBuilder;
  final ValueChanged<DateTime> onDayPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        monthBuilder != null
            ? monthBuilder(context, month.month, month.year)
            : _DefaultMonthView(month: month.month, year: month.year),
        Table(
          children: month.weeks.map((Week week) {
            return _generateFor(context, week);
          }).toList(growable: false),
        ),
      ],
    );
  }

  TableRow _generateFor(BuildContext context, Week week) {
    DateTime firstDay = week.firstDay;

    return TableRow(
      children: List<Widget>.generate(DateTime.daysPerWeek, (int position) {
        DateTime day = DateTime(
          week.firstDay.year,
          week.firstDay.month,
          firstDay.day + (position - (firstDay.weekday - 1)),
        );

        if ((position + 1) < week.firstDay.weekday ||
            (position + 1) > week.lastDay.weekday) {
          return const SizedBox();
        } else {
          return AspectRatio(
            aspectRatio: 1.0,
            child: InkWell(
              onTap: onDayPressed == null ? null : () => onDayPressed(day),
              child: dayBuilder != null
                  ? dayBuilder(context, day)
                  : _DefaultDayView(date: day),
            ),
          );
        }
      }, growable: false),
    );
  }
}

class _DefaultMonthView extends StatelessWidget {
  final int month;
  final int year;

  _DefaultMonthView({@required this.month, @required this.year});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        DateFormat('MMMM yyyy').format(DateTime(year, month)),
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }
}

class _DefaultDayView extends StatelessWidget {
  final DateTime date;
  final bool isSelected;

  _DefaultDayView({@required this.date, this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        DateFormat('d').format(date),
      ),
    );
  }
}

typedef MonthBuilder = Widget Function(
    BuildContext context, int month, int year);
typedef DayBuilder = Widget Function(BuildContext context, DateTime date);

typedef OnMonthLoaded = void Function(int year, int month);