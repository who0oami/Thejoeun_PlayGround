/* 
Description : Firebase NoticeNotifier
Date : 2026-1-19
Author : 황민욱
*/

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:teacher/model/notice.dart';


// Firestore Collection Provider
final noticeCollectionProvider = Provider<CollectionReference>(
  (ref) => FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'atti')
  .collection('notice'),
);

// 상세
final noticeDetailProvider = StreamProvider.family<Notice?, String>((ref, docId) {
  final col = ref.watch(noticeCollectionProvider);

  return col.doc(docId).snapshots().map((doc) {
    if (!doc.exists) return null;
    return Notice.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  });
});

// StreamProvider
final noticeListProvider = StreamProvider<List<Notice>>(
  (ref) {
    final col = ref.watch(noticeCollectionProvider);
    return col.orderBy('notice_insertdate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Notice.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  },
);

// 검색용 Provider
final noticeSearchProvider = StateProvider<String>((ref) => "");

final filteredNoticeListProvider = Provider<AsyncValue<List<Notice>>>((ref) {
  final query = ref.watch(noticeSearchProvider).trim().toLowerCase();
  final noticesAsync = ref.watch(noticeListProvider);

  return noticesAsync.whenData((list) {
    if (query.isEmpty) return list;

    return list
        .where((n) => n.notice_title.toLowerCase().contains(query))
        .toList();
  });
});

// NoticeActionProvider
class NoticeActionProvider extends Notifier<void>{

  @override
  void build() {}

  CollectionReference get _notices => ref.read(noticeCollectionProvider);

  Future<List<String>> uploadNoticeImages({
    required List<File> files,
    required int teacherId,
  }) async {
    final urls = <String>[];

    final app = Firebase.app();
    final storage = FirebaseStorage.instanceFor(app: app);

    for (final f in files) {
      final fileName = "notice_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final ref = storage
          .ref()
          .child('images')
          .child('teacher_$teacherId')
          .child(fileName);

        await ref.putFile(f);
        final url = await ref.getDownloadURL();
        urls.add(url);
    }

    return urls;
  }

  Future<void> addNotice(Notice notice) async{
    await _notices.add(notice.toMap());
  }

  Future<void> deleteStorageFilesByUrls(List<String> urls) async {
    if (urls.isEmpty) return;

    final app = Firebase.app();
    final storage = FirebaseStorage.instanceFor(app: app);

    for (final url in urls) {
      final ref = storage.refFromURL(url);
      await ref.delete();
    }
  }

  Future<void> updateNotice({required String id, required Map<String, dynamic> data}) async{
    await _notices.doc(id).update(data);
  }

  Future<void> deleteNotice({required String id}) async {
    final snap = await _notices.doc(id).get();

    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;

    final List<String> urls = (data['notice_images'] == null)
        ? <String>[]
        : List<String>.from(data['notice_images']);

    if (urls.isNotEmpty) {
      await deleteStorageFilesByUrls(urls);
    }

    await _notices.doc(id).delete();
  }

} // NoticeActionProvider

final noticeActionProvider = NotifierProvider<NoticeActionProvider, void>(
  NoticeActionProvider.new
);