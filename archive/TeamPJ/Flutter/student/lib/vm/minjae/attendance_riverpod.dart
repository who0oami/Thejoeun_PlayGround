import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:student/model/attendance.dart';
import 'dart:convert';


const String apiBaseUrl = 'http://10.0.2.2:8000/minjae/attendance';

/// 🔹 출결 목록 Provider
final attendanceListProvider =
    FutureProvider.family<List<Attendance>, int>((ref, studentId) async {
  final uri = Uri.parse('$apiBaseUrl/select?student_id=$studentId');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final List<dynamic> data = decoded['results'];

    return data.map((e) => Attendance.fromJson(e)).toList();
  } else {
    throw Exception('출결 데이터를 불러올 수 없습니다');
  }
});

/// 🔹 출결 액션 Notifier
class AttendanceActionNotifier extends Notifier<void> {
  @override
  void build() {}

  /// 출결 추가
  Future<void> addAttendance(Attendance attendance) async {
    final response = await http.post(
      Uri.parse(apiBaseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(attendance.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('출결 추가 실패');
    }

    ref.invalidate(attendanceListProvider);
  }

  /// 출결 상태/사유 수정
  Future<void> updateAttendance(
      int attendanceId, String status, String? content) async {
    final response = await http.put(
      Uri.parse('$apiBaseUrl/$attendanceId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'attendance_status': status,
        'attendance_content': content,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('출결 수정 실패');
    }

    ref.invalidate(attendanceListProvider);
  }

  /// 출결 삭제
  Future<void> deleteAttendance(int attendanceId) async {
    final response =
        await http.delete(Uri.parse('$apiBaseUrl/$attendanceId'));

    if (response.statusCode != 200) {
      throw Exception('출결 삭제 실패');
    }

    ref.invalidate(attendanceListProvider);
  }
}

final attendanceActionProvider =
    NotifierProvider<AttendanceActionNotifier, void>(
  AttendanceActionNotifier.new,
);
