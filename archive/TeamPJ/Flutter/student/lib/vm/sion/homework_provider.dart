/* 
Description : Firebase HomeworkNotifier
Date : 2026-1-19
Author : 황민욱 / 정시온이랑 같이 작업!
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/model/homework.dart';


// Firestore Collection Provider
final homeworkCollectionProvider = Provider<CollectionReference>(
   (ref) => FirebaseFirestore.instanceFor(
    app: Firebase.app(), 
    databaseId: 'atti' //<<<꼭 추가!!
  ).collection('homework'),
);

// StreamProvider
final homeworkListProvider = StreamProvider<List<Homework>>(
  (ref) {
    final col = ref.watch(homeworkCollectionProvider);
    return col.snapshots().map((snapshot) {
      final list = snapshot.docs
      .map((doc) => Homework.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

      list.sort((a, b) => b.homework_insertdate.compareTo(a.homework_insertdate));

      return list;
    });
  },
);

// HomeworkActionProvider
class HomeworkActionProvider extends Notifier<void>{

  @override
  void build() {}

  CollectionReference get _homework => ref.read(homeworkCollectionProvider);

  Future<void> addHomework() async{
    await _homework.add({});
  }

  Future<void> updateHomework() async{
    await _homework.doc().update({});
  }

  Future<void> deleteHomework() async{
    await _homework.doc().delete();
  }
} // HomeworkActionProvider

final homeworkActionProvider = NotifierProvider<HomeworkActionProvider, void>(
  HomeworkActionProvider.new
);