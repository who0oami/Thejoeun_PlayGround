import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:student/util/config.dart' as config;

//  Attendance Provider
/*
  Created in: 20/01/2026 11:05
  Author: Chansol, Park
  Description: Attendance Provider for attend
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
*/

final attendProvider = AsyncNotifierProvider<AttendProvider, bool>(
  AttendProvider.new,
);

class AttendProvider extends AsyncNotifier<bool> {
  String get _baseUrl =>
      'http://${config.getSafeForwardIp()}:${config.forwardport}/restitutor';

  int _readStudentId() {
    final box = GetStorage();
    dynamic raw = box.read('p_userid');
    if (raw is String && raw.isEmpty) {
      raw = null;
    }
    raw ??= box.read('student_id');
    if (raw is String && raw.isEmpty) {
      raw = null;
    }
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw) ?? 1;
    return 1;
  }

  @override
  Future<bool> build() async {
    final studentId = _readStudentId();
    await attendInit(studentId: studentId);
    return await attendStatus(studentId: studentId);
  }

  Future<void> attendInit({required int studentId}) async {
    final uri = Uri.parse('$_baseUrl/attend/init?student_id=$studentId');

    final res = await http.post(uri);
    if (res.statusCode != 200) {
      throw Exception('Attend init error ${res.statusCode}: ${res.body}');
    }
  }

  Future<bool> attendStatus({required int studentId}) async {
    final uri = Uri.parse('$_baseUrl/attend/status?student_id=$studentId');

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Attend status error ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    return decoded["checked"] == true;
  }

  Future<void> attendCheck({
    required int studentId,
    required String attendanceStatus,
  }) async {
    final now = DateTime.now().toIso8601String();

    final uri = Uri.parse(
      '$_baseUrl/attend/check'
      '?student_id=$studentId'
      '&attendance_status=${Uri.encodeQueryComponent(attendanceStatus)}'
      '&attendance_end_time=${Uri.encodeQueryComponent(now)}',
    );

    final res = await http.post(uri);
    if (res.statusCode != 200) {
      throw Exception('Attend check error ${res.statusCode}: ${res.body}');
    }

    state = const AsyncLoading();
    state = AsyncData(await attendStatus(studentId: studentId));
  }

  Future<void> refreshAttend({required int studentId}) async {
    state = const AsyncLoading();
    await attendInit(studentId: studentId);
    state = AsyncData(await attendStatus(studentId: studentId));
  }
}

final attendQueryProvider =
    AsyncNotifierProvider<AttendQueryProvider, List<Map<String, dynamic>>>(
      AttendQueryProvider.new,
    );

class AttendQueryProvider extends AsyncNotifier<List<Map<String, dynamic>>> {
  String get _baseUrl =>
      'http://${config.getForwardIP()}:${config.forwardport}/restitutor';

  @override
  Future<List<Map<String, dynamic>>> build() async {
    return queryAttend(studentId: 1);
  }

  Future<List<Map<String, dynamic>>> queryAttend({
    required int studentId,
  }) async {
    final uri = Uri.parse('$_baseUrl/attend/query?student_id=$studentId');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Attend query error ${res.statusCode}: ${res.body}');
    }

    final decoded = jsonDecode(utf8.decode(res.bodyBytes));

    final items = decoded.cast<Map<String, dynamic>>();

    return items;
  }
}
