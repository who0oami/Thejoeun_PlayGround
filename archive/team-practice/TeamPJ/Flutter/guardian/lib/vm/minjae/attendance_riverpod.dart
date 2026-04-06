import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:guardian/model/attendance.dart';
import 'package:http/http.dart' as http;

const String apiBaseUrl = 'http://10.0.2.2:8000/minjae/attendance';

/// ✅ GetStorage Provider
final storageProvider = Provider<GetStorage>((ref) => GetStorage());

/// ✅ student_id 변화를 Riverpod에 연결 (로그인/로그아웃 반영)
final studentIdStreamProvider = StreamProvider<String?>((ref) {
  final box = ref.watch(storageProvider);
  final controller = StreamController<String?>();

  // 초기값
  controller.add(box.read('student_id')?.toString());

  // 변경 감지
  box.listenKey('student_id', (value) {
    controller.add(value?.toString());
  });

  ref.onDispose(() async {
    await controller.close();
  });

  return controller.stream.distinct();
});

/// 🔹 출결 목록 Provider (✅ storage의 student_id로 자동 조회)
final attendanceListProvider = FutureProvider<List<Attendance>>((ref) async {
  final fromStream = ref.watch(studentIdStreamProvider).value;
  final box = ref.watch(storageProvider);

  final studentIdStr = (fromStream ?? box.read('student_id')?.toString());
  if (studentIdStr == null || studentIdStr.isEmpty) {
    // 로그인 전/로그아웃 상태
    return [];
  }

  final studentId = int.tryParse(studentIdStr);
  if (studentId == null) return [];

  final uri = Uri.parse('$apiBaseUrl/select?student_id=$studentId');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    final results = decoded['results'];
    if (results == null || results is! List) return [];

    return results.map((e) => Attendance.fromJson(e)).toList();
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

    // ✅ 목록 다시 불러오기
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

    // ✅ 목록 다시 불러오기
    ref.invalidate(attendanceListProvider);
  }

  /// 출결 삭제
  Future<void> deleteAttendance(int attendanceId) async {
    final response = await http.delete(Uri.parse('$apiBaseUrl/$attendanceId'));

    if (response.statusCode != 200) {
      throw Exception('출결 삭제 실패');
    }

    // ✅ 목록 다시 불러오기
    ref.invalidate(attendanceListProvider);
  }
}

final attendanceActionProvider =
    NotifierProvider<AttendanceActionNotifier, void>(
  AttendanceActionNotifier.new,
);
