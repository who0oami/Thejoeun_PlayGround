/*
Description : 파이어 베이스 연결로 점심이 날짜별로 보이게 설정
Date : 2026-1-22
Author : 이상현
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/model/lunch.dart';
import 'package:student/model/lunch_menu.dart';

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

final lunchCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>(
  (ref) => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection('lunch'),
);

final lunchMenuCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>(
  (ref) => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection('lunch_menu'),
);

final lunchListProvider = StreamProvider<List<Lunch>>((ref) {
  final col = ref.watch(lunchCollectionProvider);
  return col.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => Lunch.fromMap(doc.data(), doc.id))
        .toList();
  });
});

final lunchMenuMapProvider = StreamProvider<Map<String, LunchMenu>>((ref) {
  final col = ref.watch(lunchMenuCollectionProvider);
  return col.snapshots().map((snapshot) {
    final Map<String, LunchMenu> map = {};
    for (final doc in snapshot.docs) {
      map[doc.id] = LunchMenu.fromMap(doc.data(), doc.id);
    }
    return map;
  });
});

final lunchMenusByDateProvider =
    Provider.family<AsyncValue<List<LunchMenu>>, DateTime>((ref, date) {
  final lunchesAsync = ref.watch(lunchListProvider);
  final menuMapAsync = ref.watch(lunchMenuMapProvider);

  if (lunchesAsync.isLoading || menuMapAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (lunchesAsync.hasError) {
    return AsyncValue.error(
      lunchesAsync.error!,
      lunchesAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (menuMapAsync.hasError) {
    return AsyncValue.error(
      menuMapAsync.error!,
      menuMapAsync.stackTrace ?? StackTrace.current,
    );
  }

  final lunches = lunchesAsync.value ?? const <Lunch>[];
  final menuMap = menuMapAsync.value ?? const <String, LunchMenu>{};
  final targetDate = _dateOnly(date);
  final lunch = lunches.firstWhere(
    (item) => _dateOnly(item.lunch_date) == targetDate,
    orElse: () => Lunch(lunch_id: '', lunch_date: targetDate, lunch_contents: {}),
  );

  if (lunch.lunch_contents.isEmpty) {
    return const AsyncValue.data(<LunchMenu>[]);
  }

  final List<String> menuIds = lunch.lunch_contents.values
      .expand((items) => items)
      .toSet()
      .toList();

  final menus = menuIds
      .map((id) => menuMap[id])
      .whereType<LunchMenu>()
      .toList();

  return AsyncValue.data(menus);
});
