import 'package:flutter/material.dart' hide DateUtils;
import 'package:flutter/rendering.dart';
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
    this.physics,
    this.scrollController,
    this.listPadding = EdgeInsets.zero,
    this.initialDate,
  });

  /// the [DateTime] to start the calendar from, if no [startDate] is provided
  /// `DateTime.now()` will be used
  final DateTime? startDate;

  /// optional [DateTime] to end the calendar pagination, of no [endDate] is
  /// provided the calendar can paginate indefinitely
  final DateTime? endDate;

  /// a Builder used for month header generation. a default [MonthBuilder] is
  /// used when no custom [MonthBuilder] is provided.
  /// * [context]
  /// * [int] year: 2021
  /// * [int] month: 1-12
  final MonthBuilder? monthBuilder;

  /// a Builder used for day generation. a default [DayBuilder] is
  /// used when no custom [DayBuilder] is provided.
  /// * [context]
  /// * [DateTime] date
  final DayBuilder? dayBuilder;

  /// if the calendar should stay cached when the widget is no longer loaded.
  /// this can be used for maintaining the last state. defaults to `false`
  final bool addAutomaticKeepAlives;

  /// callback that provides the [DateTime] of the day that's been interacted
  /// with
  final ValueChanged<DateTime>? onDayPressed;

  /// callback when a new paginated month is loaded.
  final OnMonthLoaded? onMonthLoaded;

  /// called when the calendar pagination is completed. if no [endDate] is
  /// provided this method is never called
  final Function? onPaginationCompleted;

  /// how many months should be loaded outside of the view. defaults to `1`
  final int invisibleMonthsThreshold;

  /// list padding, defaults to `EdgeInsets.zero`
  final EdgeInsetsGeometry listPadding;

  /// scroll physics, defaults to matching platform conventions
  final ScrollPhysics? physics;

  /// scroll controller for making programmable scroll interactions
  final ScrollController? scrollController;

  /// the initial date displayed by the calendar. 
  /// if inititial date is nulll, the start date will be used
  final DateTime? initialDate;

  @override
  _PagedVerticalCalendarState createState() => _PagedVerticalCalendarState();
}

class _PagedVerticalCalendarState extends State<PagedVerticalCalendar> {
  late PagingController<int, Month> _pagingReplyUpController;
  late PagingController<int, Month> _pagingReplyDownController;

  final Key downListKey = UniqueKey();

  late DateTime initDate;
  late bool hideUp;

  @override
  void initState() {
    super.initState();

    if (widget.initialDate != null) {
      if (widget.endDate != null) {
        int diffDaysEndDate =
            widget.endDate!.difference(widget.initialDate!).inDays;
        if (diffDaysEndDate.isNegative) {
          initDate = widget.endDate!;
        } else {
          initDate = widget.initialDate!;
        }
      } else {
        initDate = widget.initialDate!;
      }
    } else {
      initDate = DateTime.now().removeTime();
    }

    if (widget.startDate != null) {
      int diffDaysStartDate = widget.startDate!.difference(initDate).inDays;
      if (diffDaysStartDate.isNegative) {
        hideUp = true;
      } else {
        hideUp = false;
      }
    } else {
      hideUp = true;
    }

    _pagingReplyUpController = PagingController<int, Month>(
      firstPageKey: 0,
      invisibleItemsThreshold: widget.invisibleMonthsThreshold,
    );
    _pagingReplyUpController.addPageRequestListener(_fetchUpPage);
    _pagingReplyUpController.addStatusListener(paginationStatusUp);

    _pagingReplyDownController = PagingController<int, Month>(
      firstPageKey: 0,
      invisibleItemsThreshold: widget.invisibleMonthsThreshold,
    );
    _pagingReplyDownController.addPageRequestListener(_fetchDownPage);
    _pagingReplyDownController.addStatusListener(paginationStatusDown);
  }

  void paginationStatusUp(PagingStatus state) {
    if (state == PagingStatus.completed)
      return widget.onPaginationCompleted?.call();
  }

  void paginationStatusDown(PagingStatus state) {
    if (state == PagingStatus.completed)
      return widget.onPaginationCompleted?.call();
  }

  /// fetch a new [Month] object based on the [pageKey] which is the Nth month
  /// from the start date
  void _fetchUpPage(int pageKey) async {
    // DateTime startDateUp = widget.startDate != null
    //     ? DateTime(widget.startDate!.year,
    //         widget.startDate!.month + initialIndex, widget.startDate!.day)
    //     : DateTime.now();

    // DateTime initDateUp =
    //     Jiffy(DateTime(initialDate.year, initialDate.month, 1))
    //         .subtract(months: 1)
    //         .dateTime;

    try {
      final month = DateUtils.getMonth(
          DateTime(initDate.year, initDate.month - 1, 1),
          widget.startDate,
          pageKey,
          true);

      WidgetsBinding.instance?.addPostFrameCallback(
        (_) => widget.onMonthLoaded?.call(month.year, month.month),
      );

      final newItems = [month];
      final isLastPage = widget.startDate != null &&
          widget.startDate!.isSameDayOrAfter(month.weeks.first.firstDay);

      if (isLastPage) {
        return _pagingReplyUpController.appendLastPage(newItems);
      }

      final nextPageKey = pageKey + newItems.length;
      _pagingReplyUpController.appendPage(newItems, nextPageKey);
    } catch (_) {
      _pagingReplyUpController.error;
    }
  }

  void _fetchDownPage(int pageKey) async {
    try {
      final month = DateUtils.getMonth(
        DateTime(initDate.year, initDate.month, 1),
        widget.endDate,
        pageKey,
        false,
      );

      WidgetsBinding.instance?.addPostFrameCallback(
        (_) => widget.onMonthLoaded?.call(month.year, month.month),
      );

      final newItems = [month];
      final isLastPage = widget.endDate != null &&
          widget.endDate!.isSameDayOrBefore(month.weeks.last.lastDay);

      if (isLastPage) {
        return _pagingReplyDownController.appendLastPage(newItems);
      }

      final nextPageKey = pageKey + newItems.length;
      _pagingReplyDownController.appendPage(newItems, nextPageKey);
    } catch (_) {
      _pagingReplyDownController.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      viewportBuilder: (BuildContext context, ViewportOffset position) {
        return Viewport(
          offset: position,
          center: downListKey,
          slivers: [
            if (hideUp)
              PagedSliverList(
                pagingController: _pagingReplyUpController,
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
            PagedSliverList(
              key: downListKey,
              pagingController: _pagingReplyDownController,
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
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pagingReplyUpController.dispose();
    _pagingReplyDownController.dispose();
    super.dispose();
  }
}

class _MonthView extends StatelessWidget {
  _MonthView({
    required this.month,
    this.monthBuilder,
    this.dayBuilder,
    this.onDayPressed,
  });

  final Month month;
  final MonthBuilder? monthBuilder;
  final DayBuilder? dayBuilder;
  final ValueChanged<DateTime>? onDayPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        /// display the default month header if none is provided
        monthBuilder?.call(context, month.month, month.year) ??
            _DefaultMonthView(
              month: month.month,
              year: month.year,
            ),
        Table(
          children: month.weeks.map((Week week) {
            return _generateWeekRow(context, week);
          }).toList(growable: false),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  TableRow _generateWeekRow(BuildContext context, Week week) {
    DateTime firstDay = week.firstDay;

    return TableRow(
      children: List<Widget>.generate(
        DateTime.daysPerWeek,
        (int position) {
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
                onTap: onDayPressed == null ? null : () => onDayPressed!(day),
                child: dayBuilder?.call(context, day) ??
                    _DefaultDayView(date: day),
              ),
            );
          }
        },
        growable: false,
      ),
    );
  }
}

class _DefaultMonthView extends StatelessWidget {
  final int month;
  final int year;

  _DefaultMonthView({required this.month, required this.year});

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

  _DefaultDayView({required this.date});

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
