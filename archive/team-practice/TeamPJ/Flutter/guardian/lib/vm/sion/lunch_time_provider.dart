/* 
Description : Firebase HomeworkNotifier
Date : 2026-1-21
Author : 정시온이랑 같이 작업!
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:guardian/model/lunch.dart';


/// 🔹 Firestore 컬렉션 Provider
final lunchCollectionProvider = Provider<CollectionReference>((ref) {
  return FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection('lunch');
});

/// 🔹 실시간 점심 식단 스트림 Provider
final lunchListProvider = StreamProvider<List<Lunch>>((ref) {
  final col = ref.watch(lunchCollectionProvider);
  return col.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => Lunch.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  });
});

/// 🔹 식단 액션용 Notifier (추가/수정 등 용도)
class LunchActionNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addLunchMenu(Lunch lunch) async {
    final col = FirebaseFirestore.instance.collection('lunch');
    await col.add({
      // 'lunch_category_id': lunch.lunch_category_id,
      'lunch_date': lunch.lunch_date,
      // 'lunch_menu_id': lunch.lunch_menu_id,
    });
  }
}

/// 🔹 액션 Provider
final lunchActionProvider =
    NotifierProvider<LunchActionNotifier, void>(
  LunchActionNotifier.new,
);
