/* 
Description : Firebase TimetableNotifier
Date : 2026-1-19
Author : 황민욱
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/model/timetable.dart';

final timetableCollectionProvider = Provider<CollectionReference<Map<String, dynamic>>>(
  (ref) => FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'atti')
      .collection('timetable'),
);

final timetableByFilterProvider = StreamProvider.family<Timetable?, ({String semester, int grade, int classNum})>(
  (ref, f) {
    return ref
        .watch(timetableCollectionProvider)
        .where('timetable_semester', isEqualTo: f.semester)
        .where('timetable_grade', isEqualTo: f.grade)
        .where('timetable_class', isEqualTo: f.classNum)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty ? null : Timetable.fromMap(s.docs.first.data(), s.docs.first.id));
  },
);

class TimetableActionProvider extends Notifier<void> {
  @override
  void build() {}

  CollectionReference<Map<String, dynamic>> get _timetable => ref.read(timetableCollectionProvider);

  Future<void> addTimetable(Timetable timetable) async {
    await _timetable.add(timetable.toMap());
  }

  Future<void> updateTimetable(String id, Map<String, dynamic> data) async {
    await _timetable.doc(id).update(data);
  }

  Future<void> deleteTimetable(String id) async {
    await _timetable.doc(id).delete();
  }

  Future<void> createDefaultIfNotExists({
    required String semester,
    required int grade,
    required int classNum,
    required int period,
    required List<String> days,
  }) async {
    final qs = await _timetable
        .where('timetable_semester', isEqualTo: semester)
        .where('timetable_grade', isEqualTo: grade)
        .where('timetable_class', isEqualTo: classNum)
        .limit(1)
        .get();

    if (qs.docs.isNotEmpty) return;

    final table = <String, List<String>>{};
    for (final d in days) {
      table[d] = List.generate(period, (_) => '');
    }

    final tt = Timetable(
      timetable_id: '',
      timetable_semester: semester,
      timetable_grade: grade,
      timetable_class: classNum,
      timetable_period: period,
      timetable_table: table,
    );

    await _timetable.add(tt.toMap());
  }

  Future<void> updateCell({
    required String timetableId,
    required String day,
    required int periodIndex,
    required String subject,
  }) async {
    final docRef = _timetable.doc(timetableId);

    await _timetable.firestore.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        throw Exception('시간표 문서가 존재하지 않음 (id=$timetableId)');
      }

      final data = snap.data() as Map<String, dynamic>;
      final rawTable = (data['timetable_table'] as Map?)?.cast<String, dynamic>() ?? {};

      final rawList = (rawTable[day] as List?)?.map((e) => e.toString()).toList() ?? <String>[];

      if (rawList.length <= periodIndex) {
        rawList.addAll(List.generate(periodIndex - rawList.length + 1, (_) => ''));
      }

      rawList[periodIndex] = subject;
      rawTable[day] = rawList;

      tx.update(docRef, {'timetable_table': rawTable});
    });
  }

} // class

final timetableActionProvider = NotifierProvider<TimetableActionProvider, void>(
  TimetableActionProvider.new,
);
