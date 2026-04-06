import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:guardian/vm/minjae/guardian_riverpod.dart';

String _resolveBaseUrl() {
  if (Platform.isAndroid) return 'http://10.0.2.2:8000';
  return 'http://127.0.0.1:8000';
}

final String studentApiBase = '${_resolveBaseUrl()}/sanghyun/student';

String normalizePhone(String? v) =>
    (v ?? '').replaceAll(RegExp(r'[^0-9]'), ''); // 숫자만 남김

/// ✅ 1) 학생 전체 목록 불러오기 Provider (Student.fromJson 안 씀)
/// 응답: {"results":[...]} 또는 [...] 둘 다 처리
final studentRawListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final uri = Uri.parse(studentApiBase);
  final res = await http.get(uri);

  if (res.statusCode != 200) {
    throw Exception('학생 목록 불러오기 실패: ${res.statusCode}');
  }

  final decoded = jsonDecode(utf8.decode(res.bodyBytes));

  final List<dynamic> list = (decoded is Map && decoded['results'] is List)
      ? decoded['results'] as List
      : (decoded is List ? decoded : <dynamic>[]);

  return list
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
});

/// ✅ 2) "내 보호자 전화번호"로 (grade,class)에서 매칭되는 학생 이름 Provider
final matchedStudentNameProvider =
    FutureProvider.family<String?, ({int grade, int classNum})>((ref, p) async {
  // guardian 정보
  final guardians = await ref.watch(guardianNotifierProvider.future);
  if (guardians.isEmpty) return null;

  final guardianPhone = normalizePhone(guardians.first.guardian_phone);
  if (guardianPhone.isEmpty) return null;

  // 학생 전체 목록 (raw map)
  final students = await ref.watch(studentRawListProvider.future);

  for (final s in students) {
    // ✅ grade/class가 서버 응답에 있으면 필터, 없으면 그냥 통과
    final sg = int.tryParse(s['student_grade']?.toString() ?? '');
    final sc = int.tryParse(s['student_class']?.toString() ?? '');
    if (sg != null && sc != null) {
      final sameClass = (sg == p.grade && sc == p.classNum);
      if (!sameClass) continue;
    }

    final studentGuardianPhone =
        normalizePhone(s['student_guardian_phone']?.toString());

    if (studentGuardianPhone.isNotEmpty &&
        studentGuardianPhone == guardianPhone) {
      return s['student_name']?.toString();
    }
  }

  return null;
});
