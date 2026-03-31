/* 
Description : Firebase NoticeNotifier
Date : 2026-1-19
Author : 황민욱 / 정시온이랑 같이 작업!
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian/model/notice.dart';



// Firestore Collection Provider
final noticeCollectionProvider = Provider<CollectionReference>(
  (ref) => FirebaseFirestore.instanceFor(
    app: Firebase.app(), 
    databaseId: 'atti' //<<<꼭 추가해야 나옴
  ).collection('notice'),
);

// StreamProvider 부분 수정
final noticeListProvider = StreamProvider<List<Notice>>(
  (ref) {
    final col = ref.watch(noticeCollectionProvider);
    return col.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Notice.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // 최신순 정렬 추가 (내림차순)
      list.sort((a, b) => b.notice_insertdate.compareTo(a.notice_insertdate));

      return list;
    });
  },
);

// NoticeActionProvider
class NoticeActionProvider extends Notifier<void>{

  @override
  void build() {}

  CollectionReference get _notices => ref.read(noticeCollectionProvider);

  Future<void> addNotice() async{
    await _notices.add(
      {
        
      }
    );
  }

  Future<void> updateNotice() async{
    await _notices.doc().update(
      {

      }
    );
  }

  Future<void> deleteNotice() async{
    await _notices.doc().delete();
  }
} // NoticeActionProvider

final noticeActionProvider = NotifierProvider<NoticeActionProvider, void>(
  NoticeActionProvider.new
);