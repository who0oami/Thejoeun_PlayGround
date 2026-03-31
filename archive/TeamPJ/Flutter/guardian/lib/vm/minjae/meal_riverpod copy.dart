import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:guardian/model/lunch_menu.dart';



/// =======================================================
/// 🔹 Firestore Provider (atti DB 공통)
/// =======================================================
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  );
});


/// =======================================================
/// 🔹 lunch_menu 컬렉션 Provider
/// =======================================================
final lunchMenuCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('lunch_menu');
});


/// =======================================================
/// 🔹 lunch_menu 전체 목록 (관리자/등록용)
/// =======================================================
final lunchMenuListProvider = StreamProvider<List<LunchMenu>>((ref) {
  final col = ref.watch(lunchMenuCollectionProvider);

  return col.snapshots().map((snapshot) {
    return snapshot.docs
        .map(
          (doc) => LunchMenu.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  });
});


/// =======================================================
/// 🔹 날짜별 급식 Provider
/// lunch/{yyyy-MM-dd}
/// lunch_contents 안에 있는 ID → lunch_menu 조회
/// =======================================================
final lunchByDateProvider = FutureProvider.family<
    Map<String, List<LunchMenu>>, String>((ref, date) async {
  final firestore = ref.watch(firestoreProvider);

  // 1️⃣ lunch/날짜 문서 가져오기
  final lunchDoc = await firestore.collection('lunch').doc(date).get();

  if (!lunchDoc.exists) {
    return {};
  }

  final data = lunchDoc.data() as Map<String, dynamic>;
  final contents =
      data['lunch_contents'] as Map<String, dynamic>? ?? {};

  final Map<String, List<LunchMenu>> result = {};

  // 2️⃣ 카테고리별 처리 (밥, 반찬, 국, 디저트 ...)
  for (final entry in contents.entries) {
    final String category = entry.key;
    final List<dynamic> rawIds = entry.value;

    final List<String> ids =
        rawIds.map((e) => e.toString()).toList();

    if (ids.isEmpty) {
      result[category] = [];
      continue;
    }

    final List<LunchMenu> menus = [];

    // Firestore whereIn 최대 10개 제한 대응
    const chunkSize = 10;
    for (int i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(
        i,
        i + chunkSize > ids.length ? ids.length : i + chunkSize,
      );

      final snap = await firestore
          .collection('lunch_menu')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      menus.addAll(
        snap.docs.map(
          (doc) => LunchMenu.fromMap(
            doc.data(),
            doc.id,
          ),
        ),
      );
    }

    result[category] = menus;
  }

  return result;
});


/// =======================================================
/// 🔹 lunch_menu 추가/수정 액션 Notifier
/// =======================================================
class LunchMenuActionNotifier extends Notifier<void> {
  @override
  void build() {}

  /// 메뉴 추가
  Future<void> addLunchMenu(LunchMenu menu) async {
    final firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'atti',
    );

    await firestore.collection('lunch_menu').add({
      'lunch_menu_name': menu.lunch_menu_name,
      'lunch_menu_image': menu.lunch_menu_image,
      'lunch_menu_category': menu.lunch_menu_category, // 밥/반찬/국 등
    });
  }

  /// 메뉴 삭제
  Future<void> deleteLunchMenu(String menuId) async {
    final firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'atti',
    );

    await firestore.collection('lunch_menu').doc(menuId).delete();
  }
}


/// =======================================================
/// 🔹 액션 Provider
/// =======================================================
final lunchMenuActionProvider =
    NotifierProvider<LunchMenuActionNotifier, void>(
  LunchMenuActionNotifier.new,
);
