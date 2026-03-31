/* 
Description : Firebase HomeworkNotifier
Date : 2026-1-19
Author : 황민욱
*/

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:teacher/model/homework.dart';


// Firestore Collection Provider
final homeworkCollectionProvider = Provider<CollectionReference>(
  (ref) => FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'atti')
  .collection('homework'),
);

// 상세
final homeworkDetailProvider = StreamProvider.family<Homework?, String>((ref, docId) {
  final col = ref.watch(homeworkCollectionProvider);

  return col.doc(docId).snapshots().map((doc) {
    if (!doc.exists) return null;
    return Homework.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  });
});

// StreamProvider
final homeworkListProvider = StreamProvider<List<Homework>>(
  (ref) {
    final col = ref.watch(homeworkCollectionProvider);
    return col.orderBy('homework_insertdate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Homework.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  },
);

// 검색용 Provider
final homeworkSearchProvider = StateProvider<String>((ref) => "");

final filteredHomeworkListProvider = Provider<AsyncValue<List<Homework>>>((ref) {
  final query = ref.watch(homeworkSearchProvider).trim().toLowerCase();
  final homeworkAsync = ref.watch(homeworkListProvider);

  return homeworkAsync.whenData((list) {
    if (query.isEmpty) return list;

    return list
        .where((n) => n.homework_title.toLowerCase().contains(query))
        .toList();
  });
});

// HomeworkActionProvider
class HomeworkActionProvider extends Notifier<void>{

  @override
  void build() {}

  CollectionReference get _homework => ref.read(homeworkCollectionProvider);

  Future<List<String>> uploadHomeworkImages({
    required List<File> files,
    required int teacherId,
  }) async {
    final urls = <String>[];

    final app = Firebase.app();
    final storage = FirebaseStorage.instanceFor(app: app);

    for (final f in files) {
      final fileName = "homework_${DateTime.now().millisecondsSinceEpoch}.jpg";
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

  Future<void> addHomework(Homework homework) async{
    await _homework.add(homework.toMap());
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

  Future<void> updateHomework({required String id, required Map<String, dynamic> data}) async{
    await _homework.doc(id).update(data);
  }

  Future<void> deleteHomework({required String id}) async {
    final snap = await _homework.doc(id).get();

    if (!snap.exists) return;

    final data = snap.data() as Map<String, dynamic>;

    final List<String> urls = (data['homework_images'] == null)
        ? <String>[]
        : List<String>.from(data['homework_images']);

    if (urls.isNotEmpty) {
      await deleteStorageFilesByUrls(urls);
    }

    await _homework.doc(id).delete();
  }
} // HomeworkActionProvider

final homeworkActionProvider = NotifierProvider<HomeworkActionProvider, void>(
  HomeworkActionProvider.new
);