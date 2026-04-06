import 'package:flutter_riverpod/flutter_riverpod.dart';

//  CalendarProvider
/*
  Created in: 18/01/2026 15:53
  Author: Chansol, Park
  Description: CalendarProvider for Calendar usage
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
*/

final calendarDateProvider = NotifierProvider<CalendarDateProvider, DateTime>(
  CalendarDateProvider.new,
);

class CalendarDateProvider extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setSelectedDay(DateTime day) {
    state = DateTime(day.year, day.month, day.day);
  }

  void resetToToday() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month, now.day);
  }
}
