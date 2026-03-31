/*
Description : Schedule Firestore + Riverpod + Schedule Form + BottomSheet
Date : 2026-01-22
Author : 황민욱
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:teacher/model/schedule.dart';

/// Firestore 컬렉션 Provider
final scheduleCollectionProvider = Provider<CollectionReference>((ref) {
  return FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection('schedule');
});

/// 스케줄 리스트 StreamProvider
final scheduleListProvider = StreamProvider<List<Schedule>>((ref) {
  final col = ref.watch(scheduleCollectionProvider);

  return col.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return Schedule.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  });
});

/// 날짜만 비교용
DateTime onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// 날짜별 스케줄 Map (캘린더용)
final scheduleMapProvider = Provider<Map<DateTime, List<Schedule>>>((ref) {
  final schedulesAsync = ref.watch(scheduleListProvider);

  return schedulesAsync.when(
    data: (schedules) {
      final Map<DateTime, List<Schedule>> map = {};

      for (final s in schedules) {
        final start = onlyDate(s.schedule_startdate);
        final end = onlyDate(s.schedule_enddate);

        // start~end 기간을 하루씩 펼침
        for (DateTime d = start;
            !d.isAfter(end);
            d = d.add(const Duration(days: 1))) {
          map.putIfAbsent(d, () => []);
          map[d]!.add(s);
        }
      }

      return map;
    },
    loading: () => <DateTime, List<Schedule>>{},
    error: (_, __) => <DateTime, List<Schedule>>{},
  );
});


// ScheduleActionProvider
class ScheduleActionProvider extends Notifier<void> {
  @override
  void build() {}

  CollectionReference get _schedule => ref.read(scheduleCollectionProvider);

  Future<void> addSchedule(Schedule schedule) async {
    await _schedule.add(schedule.toMap());
  }

  Future<void> updateSchedule(String id, Map<String, dynamic> data) async {
    await _schedule.doc(id).update(data);
  }

  Future<void> deleteSchedule(String id) async {
    await _schedule.doc(id).delete();
  }
} // class

final scheduleActionProvider = NotifierProvider<ScheduleActionProvider, void>(
  ScheduleActionProvider.new,
);

enum ScheduleFormMode { add, edit }

class ScheduleFormState {
  final ScheduleFormMode mode;
  final String? scheduleId;
  final int teacherId;
  final DateTime start;
  final DateTime end;
  final String title;
  final String contents;

  const ScheduleFormState({
    required this.mode,
    required this.teacherId,
    required this.start,
    required this.end,
    required this.title,
    required this.contents,
    this.scheduleId,
  });

  ScheduleFormState copyWith({
    ScheduleFormMode? mode,
    String? scheduleId,
    int? teacherId,
    DateTime? start,
    DateTime? end,
    String? title,
    String? contents,
  }) {
    return ScheduleFormState(
      mode: mode ?? this.mode,
      scheduleId: scheduleId ?? this.scheduleId,
      teacherId: teacherId ?? this.teacherId,
      start: start ?? this.start,
      end: end ?? this.end,
      title: title ?? this.title,
      contents: contents ?? this.contents,
    );
  }
} // class

class ScheduleFormNotifier extends Notifier<ScheduleFormState> {
  @override
  ScheduleFormState build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return ScheduleFormState(
      mode: ScheduleFormMode.add,
      teacherId: 1, // 임시
      start: today,
      end: today,
      title: '',
      contents: '',
    );
  }

  void initForAdd({required DateTime day, required int teacherId}) {
    final d = DateTime(day.year, day.month, day.day);
    state = ScheduleFormState(
      mode: ScheduleFormMode.add,
      scheduleId: null,
      teacherId: teacherId,
      start: d,
      end: d,
      title: '',
      contents: '',
    );
  }

  void initForEdit(Schedule s) {
    state = ScheduleFormState(
      mode: ScheduleFormMode.edit,
      scheduleId: s.schedule_id,
      teacherId: s.teacher_id,
      start: DateTime(s.schedule_startdate.year, s.schedule_startdate.month, s.schedule_startdate.day),
      end: DateTime(s.schedule_enddate.year, s.schedule_enddate.month, s.schedule_enddate.day),
      title: s.schedule_title,
      contents: s.schedule_contents,
    );
  }

  void setTeacherId(int v) => state = state.copyWith(teacherId: v);
  void setTitle(String v) => state = state.copyWith(title: v);
  void setContents(String v) => state = state.copyWith(contents: v);

  void setStart(DateTime d) {
    final nd = DateTime(d.year, d.month, d.day);
    final newEnd = state.end.isBefore(nd) ? nd : state.end;
    state = state.copyWith(start: nd, end: newEnd);
  }

  void setEnd(DateTime d) {
    final nd = DateTime(d.year, d.month, d.day);
    final newStart = nd.isBefore(state.start) ? nd : state.start;
    state = state.copyWith(start: newStart, end: nd);
  }
} // class

final scheduleFormProvider = NotifierProvider<ScheduleFormNotifier, ScheduleFormState>(
  ScheduleFormNotifier.new
);
