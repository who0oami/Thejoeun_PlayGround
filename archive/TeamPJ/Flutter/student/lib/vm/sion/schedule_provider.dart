/*
Description : Schedule Firestore + Riverpod (날짜 비교용 Map 제공)
Date : 2026-01-21
Author : 시온
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/model/schedule.dart';
import 'package:firebase_core/firebase_core.dart';

/// 🔹 날짜만 비교용 유틸 함수
DateTime onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// 🔹 Firestore 컬렉션 Provider
final scheduleCollectionProvider = Provider<CollectionReference>((ref) {
  return FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection('schedule');
});

/// 🔹 스케줄 리스트 StreamProvider (실시간)
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

/// 🔹 날짜별 스케줄 Map (캘린더용)
final scheduleMapProvider = Provider<Map<DateTime, List<Schedule>>>((ref) {
  final schedulesAsync = ref.watch(scheduleListProvider);

  return schedulesAsync.when(
    data: (schedules) {
      final Map<DateTime, List<Schedule>> map = {};

      for (final schedule in schedules) {
        /// ⭐ 핵심: 날짜만 잘라서 key 생성
        final dateKey = onlyDate(schedule.schedule_startdate);

        map.putIfAbsent(dateKey, () => []);
        map[dateKey]!.add(schedule);
      }

      return map;
    },
    loading: () => <DateTime, List<Schedule>>{},
    error: (_, __) => <DateTime, List<Schedule>>{},
  );
});
