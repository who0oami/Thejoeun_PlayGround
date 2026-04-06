/* 
Description : 선생님 데이터베이스 리버팝
Date : 2026-1-22
Author : 정시온
*/


import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:student/model/teacher.dart';

class TeacherNotifier extends AsyncNotifier<List<Teacher>> {
  final String baseUrl = "http://10.0.2.2:8000"; // Android 에뮬레이터 기준

  @override
  FutureOr<List<Teacher>> build() async {
    return await fetchTeacher();
  }

  Future<List<Teacher>> fetchTeacher() async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/minjae/select/teacher?teacher_id=1"),
      );

      if (res.statusCode != 200) {
        throw Exception("불러오기 실패: ${res.statusCode}");
      }

      final data = json.decode(utf8.decode(res.bodyBytes));

      // null 또는 잘못된 타입 처리
      final results = data['results'];
      if (results == null || results is! List) {
        return [];
      }

      return results.map((e) => Teacher.fromJson(e)).toList();
    } catch (e) {
      print("에러 발생: $e");
      return [];
    }
  }

  Future<void> refreshTeacher() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await fetchTeacher());
  }
}

// Provider 등록
final teacherNotifierProvider =
    AsyncNotifierProvider<TeacherNotifier, List<Teacher>>(
  () => TeacherNotifier(),
);
