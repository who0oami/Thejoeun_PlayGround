import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardian/model/emergency_alert.dart';

final emergencyAlertNotifierProvider =
    AsyncNotifierProvider<EmergencyAlertNotifier, EmergencyAlert?>(
  EmergencyAlertNotifier.new,
);
class EmergencyAlertNotifier extends AsyncNotifier<EmergencyAlert?> {
  final box = GetStorage();
  @override
  FutureOr<EmergencyAlert?> build() async {
    return await fetchEmergency();
  }
  Future<EmergencyAlert?> fetchEmergency() async {
    final guardianId = box.read('guardian_id');
    if (guardianId == null) return null;
    final snapshot = await FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection("emergency_calls")
        .get();
    if (snapshot.docs.isEmpty) return null;
    EmergencyAlert? latestAlert;
    Timestamp? latestTime;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data["guardian_id"] == guardianId && data["status"] == "ACTIVE") {
        final createdAt = data["alert_start_date"] as Timestamp?;
        if (createdAt == null) continue;
        if (latestTime == null || createdAt.compareTo(latestTime!) > 0) {
          latestTime = createdAt;
          latestAlert = EmergencyAlert.fromMap(doc.id, data);
        }
      }
    }
    return latestAlert;
  }
  Future<void> endEmergency(String alertId) async {
    await FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection("emergency_calls")
        .doc(alertId)
        .update({
      "status": "DONE",
      "alert_end_date": FieldValue.serverTimestamp(), // 선택(있으면 좋음)
    });
    await refreshEmergency();
  }
  Future<void> refreshEmergency() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await fetchEmergency());
  }
}
