/* 
Description : Firebase LunchNotifier
Date : 2026-1-22
Author : 황민욱
*/

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/model/lunch.dart';
import 'package:teacher/model/lunch_menu.dart';

DateTime onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

String dateKey(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

/// 기본 카테고리 템플릿
Map<String, List<String>> defaultLunchContents() => {
  '밥': [],
  '국': [],
  '반찬': [],
  '디저트': [],
  '기타': [],
};

// Firestore Collection Provider
final lunchCollectionProvider = Provider<CollectionReference>((ref) {
  return FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection('lunch');
});

final lunchMenuCollectionProvider = Provider<CollectionReference>((ref) {
  return FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection('lunch_menu');
});

// StreamProvider

/// 전체 급식표 리스트
final lunchListProvider = StreamProvider<List<Lunch>>((ref) {
  final col = ref.watch(lunchCollectionProvider);
  return col.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => Lunch.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  });
});

/// 전체 메뉴 리스트
final lunchMenuListProvider = StreamProvider<List<LunchMenu>>((ref) {
  final col = ref.watch(lunchMenuCollectionProvider);
  return col.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => LunchMenu.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  });
});

/// 날짜별 급식표 1개
final lunchByDateProvider = StreamProvider.family<Lunch?, DateTime>((ref, day) {
  final col = ref.watch(lunchCollectionProvider);
  final id = dateKey(onlyDate(day));

  return col.doc(id).snapshots().map((doc) {
    if (!doc.exists) return null;
    return Lunch.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  });
});

/// 카테고리별 메뉴 목록
final lunchMenuByCategoryProvider =
    StreamProvider.family<List<LunchMenu>, String>((ref, category) {
  final col = ref.watch(lunchMenuCollectionProvider);

  return col
      .where('lunch_menu_category', isEqualTo: category)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => LunchMenu.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  });
});


// Action Provider
class LunchActionProvider extends Notifier<void> {
  @override
  void build() {}

  CollectionReference get _lunch => ref.read(lunchCollectionProvider);
  CollectionReference get _menu => ref.read(lunchMenuCollectionProvider);

  // Lunch (급식표)
  Future<void> ensureLunch(DateTime day) async {
    final d = onlyDate(day);
    final id = dateKey(d);

    final docRef = _lunch.doc(id);
    final snap = await docRef.get();

    if (snap.exists) return;

    final lunch = Lunch(
      lunch_id: id,
      lunch_date: d,
      lunch_contents: defaultLunchContents(),
    );

    await docRef.set(lunch.toMap());
  }

  Future<void> toggleMenu({
    required DateTime day,
    required String category,
    required String menuId,
  }) async {
    final d = onlyDate(day);
    final id = dateKey(d);
    final docRef = _lunch.doc(id);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);

      // 문서 없으면 먼저 생성
      if (!snap.exists) {
        tx.set(docRef, {
          'lunch_date': Timestamp.fromDate(d),
          'lunch_contents': defaultLunchContents(),
        });
      }

      final data = (snap.data() as Map<String, dynamic>?) ?? {};
      final contents = (data['lunch_contents'] as Map<String, dynamic>?) ?? defaultLunchContents();

      final list = List<String>.from((contents[category] ?? const <String>[]));

      if (list.contains(menuId)) {
        list.remove(menuId);
      } else {
        list.add(menuId);
      }

      contents[category] = list;

      tx.update(docRef, {
        'lunch_date': Timestamp.fromDate(d),
        'lunch_contents': contents,
      });
    });
  }

  Future<void> setCategoryMenus({
    required DateTime day,
    required String category,
    required List<String> menuIds,
  }) async {
    final d = onlyDate(day);
    final id = dateKey(d);
    final docRef = _lunch.doc(id);

    await ensureLunch(d);

    await docRef.update({
      'lunch_contents.$category': menuIds,
      'lunch_date': Timestamp.fromDate(d),
    });
  }

  // Storage (LunchMenu Image)
  Future<String> uploadFoodImage({
    required File file,
  }) async {
    final app = Firebase.app();
    final storage = FirebaseStorage.instanceFor(app: app);

    final fileName = "food_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final ref = storage
        .ref()
        .child('foods')
        .child(fileName);

    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    return url;
  }

  Future<void> deleteStorageFileByUrl(String url) async {
    if (url.trim().isEmpty) return;

    final app = Firebase.app();
    final storage = FirebaseStorage.instanceFor(app: app);

    final ref = storage.refFromURL(url);
    await ref.delete();
  }

  Future<void> deleteLunch(DateTime day) async {
    final id = dateKey(onlyDate(day));
    await _lunch.doc(id).delete();
  }

  // LunchMenu
  Future<void> addMenuWithImage({
    required LunchMenu menu,
    File? imageFile,
  }) async {
    String imageUrl = menu.lunch_menu_image;

    if (imageFile != null) {
      imageUrl = await uploadFoodImage(file: imageFile);
    }

    await _menu.add({
      'lunch_menu_name': menu.lunch_menu_name,
      'lunch_menu_category': menu.lunch_menu_category,
      'lunch_menu_image': imageUrl,
    });
  }

  Future<void> updateMenuWithImage({
    required String id,
    required Map<String, dynamic> data,
    File? newImageFile,
  }) async {
    String? oldUrl;

    if (newImageFile != null) {
      final snap = await _menu.doc(id).get();
      if (snap.exists) {
        final map = snap.data() as Map<String, dynamic>;
        oldUrl = (map['lunch_menu_image'] ?? "") as String;
      }

      final newUrl = await uploadFoodImage(file: newImageFile);
      data['lunch_menu_image'] = newUrl;
    }

    await _menu.doc(id).update(data);

    if (newImageFile != null && oldUrl != null && oldUrl.trim().isNotEmpty) {
      await deleteStorageFileByUrl(oldUrl);
    }
  }

  Future<void> deleteMenuWithImage({required String id}) async {
    final snap = await _menu.doc(id).get();
    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;
    final url = (data['lunch_menu_image'] ?? "") as String;

    if (url.trim().isNotEmpty) {
      await deleteStorageFileByUrl(url);
    }

    await _menu.doc(id).delete();
  }
}

final lunchActionProvider = NotifierProvider<LunchActionProvider, void>(
  LunchActionProvider.new,
);
