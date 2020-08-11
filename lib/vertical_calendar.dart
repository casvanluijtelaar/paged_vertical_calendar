import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vertical_calendar/utils/date_models.dart';
import 'package:vertical_calendar/utils/date_utils.dart';

class VerticalCalendar extends StatefulWidget {
  final DateTime minDate;
  final DateTime maxDate;
  final MonthBuilder monthBuilder;
  final DayBuilder dayBuilder;
  final ValueChanged<DateTime> onDayPressed;
  final PeriodChanged onRangeSelected;
  final EdgeInsetsGeometry listPadding;

  VerticalCalendar(
      {@required this.minDate,
      @required this.maxDate,
      this.monthBuilder,
      this.dayBuilder,
      this.onDayPressed,
      this.onRangeSelected,
      this.listPadding})
      : assert(minDate != null),
        assert(maxDate != null),
        assert(minDate.isBefore(maxDate));

  @override
  _VerticalCalendarState createState() => _VerticalCalendarState();
}

class _VerticalCalendarState extends State<VerticalCalendar> {
  DateTime _minDate;
  DateTime _maxDate;
  List<Month> _months;
  DateTime rangeMinDate;
  DateTime rangeMaxDate;

  @override
  void initState() {
    super.initState();
    _months = DateUtils.extractWeeks(widget.minDate, widget.maxDate);
    _minDate = widget.minDate.removeTime();
    _maxDate = widget.maxDate.removeTime();
  }

  @override
  void didUpdateWidget(VerticalCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.minDate != widget.minDate ||
        oldWidget.maxDate != widget.maxDate) {
      _months = DateUtils.extractWeeks(widget.minDate, widget.maxDate);
      _minDate = widget.minDate.removeTime();
      _maxDate = widget.maxDate.removeTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
              cacheExtent:
                  (MediaQuery.of(context).size.width / DateTime.daysPerWeek) *
                      6,
              padding: widget.listPadding ?? EdgeInsets.zero,
              itemCount: _months.length,
              itemBuilder: (BuildContext context, int position) {
                return _MonthView(
                    month: _months[position],
                    minDate: _minDate,
                    maxDate: _maxDate,
                    monthBuilder: widget.monthBuilder,
                    dayBuilder: widget.dayBuilder,
                    onDayPressed: widget.onRangeSelected != null
                        ? (DateTime date) {
                            if (rangeMinDate == null || rangeMaxDate != null) {
                              setState(() {
                                rangeMinDate = date;
                                rangeMaxDate = null;
                              });
                            } else if (date.isBefore(rangeMinDate)) {
                              setState(() {
                                rangeMaxDate = rangeMinDate;
                                rangeMinDate = rangeMinDate;
                              });
                            } else {
                              setState(() {
                                rangeMaxDate = date;
                              });
                            }

                            widget.onRangeSelected(rangeMinDate, rangeMaxDate);

                            if (widget.onDayPressed != null) {
                              widget.onDayPressed(date);
                            }
                          }
                        : widget.onDayPressed,
                    rangeMinDate: rangeMinDate,
                    rangeMaxDate: rangeMaxDate);
              }),
        ),
      ],
    );
  }
}

class _MonthView extends StatelessWidget {
  final Month month;
  final DateTime minDate;
  final DateTime maxDate;
  final MonthBuilder monthBuilder;
  final DayBuilder dayBuilder;
  final ValueChanged<DateTime> onDayPressed;
  final DateTime rangeMinDate;
  final DateTime rangeMaxDate;

  _MonthView(
      {@required this.month,
      @required this.minDate,
      @required this.maxDate,
      this.monthBuilder,
      this.dayBuilder,
      this.onDayPressed,
      this.rangeMinDate,
      this.rangeMaxDate,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        monthBuilder != null
            ? monthBuilder(context, month.month, month.year)
            : _DefaultMonthView(month: month.month, year: month.year),
        Table(
          children: month.weeks
              .map((Week week) => _generateFor(context, week))
              .toList(growable: false),
        ),
      ],
    );
  }

  TableRow _generateFor(BuildContext context, Week week) {
    DateTime firstDay = week.firstDay;
    bool rangeFeatureEnabled = rangeMinDate != null;

    return TableRow(
        children: List<Widget>.generate(DateTime.daysPerWeek, (int position) {
      DateTime day = DateTime(week.firstDay.year, week.firstDay.month,
          firstDay.day + (position - (firstDay.weekday - 1)));

      if ((position + 1) < week.firstDay.weekday ||
          (position + 1) > week.lastDay.weekday ||
          day.isBefore(minDate) ||
          day.isAfter(maxDate)) {
        return const SizedBox();
      } else {
        bool isSelected = false;

        if (rangeFeatureEnabled) {
          if (rangeMinDate != null && rangeMaxDate != null) {
            isSelected = day.isSameDayOrAfter(rangeMinDate) &&
                day.isSameDayOrBefore(rangeMaxDate);
          } else {
            isSelected = day.isAtSameMomentAs(rangeMinDate);
          }
        }

        return AspectRatio(
            aspectRatio: 1.0,
            child: GestureDetector(
              onTap: onDayPressed != null
                  ? () {
                      if (onDayPressed != null) {
                        onDayPressed(day);
                      }
                    }
                  : null,
              child: dayBuilder != null
                  ? dayBuilder(context, day, isSelected: isSelected)
                  : _DefaultDayView(date: day, isSelected: isSelected),
            ));
      }
    }, growable: false));
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
        style: Theme.of(context).textTheme.headline5,
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
    return Ink(
      decoration: BoxDecoration(
          color: isSelected == true ? Colors.red : Colors.green,
          shape: BoxShape.circle),
      child: Center(
        child: Text(
          DateFormat('d').format(date),
        ),
      ),
    );
  }
}

typedef MonthBuilder = Widget Function(
    BuildContext context, int month, int year);
typedef DayBuilder = Widget Function(BuildContext context, DateTime date,
    {bool isSelected});
typedef PeriodChanged = void Function(DateTime minDate, DateTime maxDate);
