import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chattingCollectionProvider =
    Provider<CollectionReference<Map<String, dynamic>>>(
  (ref) => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection('chatting'),
);
