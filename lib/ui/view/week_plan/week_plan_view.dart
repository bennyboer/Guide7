import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/connect/week_plan/week_plan_repository.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:guide7/ui/view/week_plan/event/week_plan_event_widget.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';

/// View showing the week plan of the student.
class WeekPlanView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WeekPlanViewState();
}

/// State of the week plan view.
class _WeekPlanViewState extends State<WeekPlanView> {
  /// Background color of the date badge.
  static const Color _dateBackgroundColor = Color(0xFFF9F9F9);

  /// Background color of the current date badge.
  static const Color _dateBackgroundHighlightColor = Color(0xFFDDF3FF);

  /// Controller to load week plan event page wise.
  PagewiseLoadController _pageLoadController;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();

    _pageLoadController = PagewiseLoadController(
      pageSize: 7,
      pageFuture: (int pageIndex) {
        return _fetchWeekEvents(now.add(Duration(days: 7 * pageIndex)));
      },
    );
  }

  @override
  void dispose() {
    _pageLoadController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(
          children: <Widget>[
            _buildAppBar(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      );

  /// Build the views app bar.
  Widget _buildAppBar() => AppBar(
        title: Text(AppLocalizations.of(context).weekPlan),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh, color: CustomColors.slateGrey),
            tooltip: AppLocalizations.of(context).refresh,
            onPressed: () {
              _onRefresh();
            },
          ),
        ],
      );

  /// Build the views content.
  Widget _buildContent() {
    DateFormat weekDayFormat = DateFormat.E(Localizations.localeOf(context).languageCode);
    DateFormat dayFormat = DateFormat.d(Localizations.localeOf(context).languageCode);
    DateFormat monthFormat = DateFormat.MMM(Localizations.localeOf(context).languageCode);

    DateTime now = DateTime.now();
    now = DateTime(now.year, now.month, now.day);

    Size size = MediaQuery.of(context).size;
    double fixedColumnWidth;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      fixedColumnWidth = size.width / 5;
    } else {
      fixedColumnWidth = size.width / 9;
    }
    double eventColumnWidth = size.width - fixedColumnWidth;

    return PagewiseListView(
      padding: EdgeInsets.all(15.0),
      pageLoadController: _pageLoadController,
      itemBuilder: (BuildContext context, value, int index) {
        _DayInfo dayInfo = value as _DayInfo;

        if (dayInfo.date.isBefore(now)) {
          return Container();
        } else {
          return StickyHeaderBuilder(
            overlapHeaders: true,
            builder: (BuildContext context, double stuckAmount) {
              stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);

              return _buildDateHeader(fixedColumnWidth, weekDayFormat, dayFormat, monthFormat, dayInfo.date);
            },
            content: _buildEventsContainer(dayInfo.events, eventColumnWidth, fixedColumnWidth),
          );
        }
      },
    );
  }

  /// Build the fixed date header widget.
  Widget _buildDateHeader(double size, DateFormat weekDayFormat, DateFormat dayFormat, DateFormat monthFormat, DateTime date) {
    DateTime now = DateTime.now();
    bool isSameDay = date.year == now.year && date.month == now.month && date.day == now.day;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: isSameDay ? _dateBackgroundHighlightColor : _dateBackgroundColor, borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.only(bottom: 5),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AutoSizeText(
                  weekDayFormat.format(date).toUpperCase(),
                  style: TextStyle(color: Colors.black54),
                ),
                AutoSizeText(
                  dayFormat.format(date),
                  minFontSize: 25.0,
                ),
              ],
            ),
            RotatedBox(
              quarterTurns: 3,
              child: AutoSizeText(
                monthFormat.format(date),
                style: TextStyle(color: CustomColors.slateGrey),
                minFontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build container for events.
  Widget _buildEventsContainer(List<WeekPlanEvent> events, double width, double xOffset) {
    WeekPlanEvent nextEvent = _getDaysNextEvent(events);

    return Container(
      margin: EdgeInsets.only(left: xOffset),
      width: width,
      constraints: BoxConstraints(minHeight: 150),
      child: events.isEmpty
          ? Center(
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.thumb_up,
                    color: CustomColors.slateGrey,
                  ),
                  Text(
                    AppLocalizations.of(context).noEntries,
                    style: TextStyle(
                      fontFamily: "NotoSerifTC",
                      color: CustomColors.slateGrey,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Column(
                children: List.generate(events.length, (index) {
                  final event = events[index];

                  return Container(
                    child: WeekPlanEventWidget(
                      event: event,
                      isNextEvent: event == nextEvent,
                    ),
                  );
                }),
              ),
            ),
    );
  }

  /// Find the next event in the passed list of all events on the same day.
  WeekPlanEvent _getDaysNextEvent(List<WeekPlanEvent> dayEvents) {
    DateTime now = DateTime.now();
    now = now.subtract(Duration(hours: 1));

    for (WeekPlanEvent event in dayEvents) {
      if (event.start.isAfter(now) && event.start.year == now.year && event.start.month == now.month && event.start.day == now.day) {
        return event;
      }
    }

    return null;
  }

  /// Fetch all events in a week defined by the passed [date].
  Future<List<_DayInfo>> _fetchWeekEvents(DateTime date) async {
    int distanceToMonday = date.weekday - 1;
    DateTime monday = DateTime(date.year, date.month, date.day - distanceToMonday);

    Repository repo = Repository();
    WeekPlanRepository weekPlanRepository = repo.getWeekPlanRepository();

    List<WeekPlanEvent> events = await weekPlanRepository.getEvents(
      fromServer: false,
      date: monday,
    );

    // Map events to weekdays.
    Map<int, _DayInfo> weekdayMapping = Map();
    for (int i = 0; i < 7; i++) {
      weekdayMapping[i + 1] = _DayInfo(monday.add(Duration(days: i)));
    }

    for (WeekPlanEvent event in events) {
      int weekday = event.start.weekday;

      weekdayMapping[weekday].events.add(event);
    }

    List<_DayInfo> result = weekdayMapping.values.toList(growable: false);

    /// Sort events per day.
    for (_DayInfo info in result) {
      info.events.sort((event1, event2) => event1.start.compareTo(event2.start));
    }

    return result;
  }

  /// Clear all cached week plan entries.
  Future<void> _clearCachedEntries() async {
    Repository repo = Repository();
    await repo.getWeekPlanRepository().clearCache();
  }

  /// What to do on refreshing the week plan entries.
  Future<void> _onRefresh() async {
    await _clearCachedEntries();
    _pageLoadController.reset();
  }
}

class _DayInfo {
  final DateTime date;
  final List<WeekPlanEvent> events = List<WeekPlanEvent>();

  _DayInfo(this.date);
}
