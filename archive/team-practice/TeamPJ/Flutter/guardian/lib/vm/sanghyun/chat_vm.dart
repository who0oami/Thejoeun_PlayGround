/*
Description : Guardian chat providers (Firebase)
Date : 2026-1-22
Author : 이상현
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final guardianChatCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>(
  (ref) => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection('chatting'),
);

final guardianChatStreamProvider =
    StreamProvider.autoDispose.family<List<Map<String, dynamic>>, int>((
  ref,
  guardianId,
) {
  final col = ref.watch(guardianChatCollectionProvider);
  return col
      .where('guardian_id', isEqualTo: guardianId)
      .orderBy('chatting_date', descending: false)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final d = doc.data();
            DateTime date;
            if (d['chatting_date'] is Timestamp) {
              date = (d['chatting_date'] as Timestamp).toDate();
            } else if (d['chatting_date'] is String) {
              date = DateTime.tryParse(d['chatting_date']) ?? DateTime.now();
            } else {
              date = DateTime.now();
            }

            final String contents =
                (d['chatting_contents'] ?? d['chatting_content'] ?? '')
                    .toString();
            final String imageUrl = (d['chatting_image'] ?? '').toString();
            return {
              'docId': doc.id,
              'contents': contents,
              'imageUrl': imageUrl,
              'isMe': d['teacher_id'] == null,
              'date': date,
            };
          }).toList());
});
