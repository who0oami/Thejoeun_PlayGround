/*
Description : Teacher chat providers (Firebase)
Date : 2026-1-22
Author : 이상현
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final chattingCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>(
  (ref) => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection('chatting'),
);

// 최신 카테고리 id 조회 스트림
final latestCategoryIdProvider = StreamProvider.family<int?, int>((
  ref,
  guardianId,
) {
  final col = ref.watch(chattingCollectionProvider);
  return col
      .where('guardian_id', isEqualTo: guardianId)
      .orderBy('chatting_date', descending: true)
      .limit(1)
      .snapshots()
      .map((snap) {
        if (snap.docs.isEmpty) return null;
        final data = snap.docs.first.data();
        final id = data['category_id'];
        if (id is int) return id;
        if (id == null) return null;
        return int.tryParse(id.toString());
      });
});

final selectedInquiryProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

final chatStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final inquiry = ref.watch(selectedInquiryProvider);
  if (inquiry == null) return Stream.value([]);

  final col = ref.watch(chattingCollectionProvider);
  final int? guardianId = int.tryParse(inquiry['guardian_id'].toString());
  if (guardianId == null) return Stream.value([]);

  return col
      .where('guardian_id', isEqualTo: guardianId)
      .orderBy('chatting_date', descending: false)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final d = doc.data();
            DateTime date = (d['chatting_date'] is Timestamp)
                ? (d['chatting_date'] as Timestamp).toDate()
                : DateTime.now();

            final String contents =
                (d['chatting_contents'] ?? d['chatting_content'] ?? '')
                    .toString();
            final String imageUrl = (d['chatting_image'] ?? '').toString();
            return {
              'docId': doc.id,
              'contents': contents,
              'imageUrl': imageUrl,
              'isTeacher': d['teacher_id'] != null,
              'date': date,
            };
          }).toList());
});
