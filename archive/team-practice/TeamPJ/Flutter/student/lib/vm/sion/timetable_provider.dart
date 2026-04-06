import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student/model/timetable.dart';

/// 🔹 Firestore 타임테이블 컬렉션 Provider
final timetableCollectionProvider = Provider<CollectionReference>((ref) {
  return FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection('timetable');
});

/// 🔹 실시간 타임테이블 스트림 Provider
final timetableListProvider = StreamProvider<List<Timetable>>((ref) {
  final col = ref.watch(timetableCollectionProvider);
  return col.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) =>
            Timetable.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  });
});

/// 🔹 액션 Notifier
class TimetableActionNotifier extends Notifier<void> {
  @override
  void build() {}
}

/// 🔹 액션 Provider
final timetableActionProvider =
    NotifierProvider<TimetableActionNotifier, void>(
  TimetableActionNotifier.new,
);
