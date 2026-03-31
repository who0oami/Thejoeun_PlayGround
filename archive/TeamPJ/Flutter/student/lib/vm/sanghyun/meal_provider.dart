import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student/model/lunch_menu.dart';

/// 🔹 Firestore 컬렉션 Provider
final lunchCollectionProvider = Provider<CollectionReference>((ref) {
  return FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection('lunch_menu');
});

/// 🔹 실시간 점심 식단 스트림 Provider
final lunchmenuListProvider = StreamProvider<List<LunchMenu>>((ref) {
  final col = ref.watch(lunchCollectionProvider);
  return col.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => LunchMenu.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  });
});

/// 🔹 식단 액션용 Notifier (추가/수정 등 용도)
class LunchMenuActionNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addLunchMenu(LunchMenu menu) async {
    final col = FirebaseFirestore.instance.collection('lunch_menu');
    await col.add({
      // 'lunch_category_id': menu.lunch_category_id,/
      'lunch_menu_name': menu.lunch_menu_name,
      'lunch_menu_image': menu.lunch_menu_image,
    });
  }
}

/// 🔹 액션 Provider
final lunchmenuActionProvider =
    NotifierProvider<LunchMenuActionNotifier, void>(
  LunchMenuActionNotifier.new,
);
