/* 
Description : Teacher Notifier
Date : 2026-1-20
Author : 황민욱
*/

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:teacher/model/teacher.dart';

final String baseUrl = "http://10.238.248.183:8000";

// teacher_id로 교사 1명 조회
final teacherByIdProvider = FutureProvider.family<Teacher?, int>((ref, teacherId) async {
  final res = await http.get(Uri.parse("$baseUrl/minwook/teacher/$teacherId"));

  if (res.statusCode != 200) {
    throw Exception('불러오기 실패: ${res.statusCode}\n${utf8.decode(res.bodyBytes)}');
  }

  final data = json.decode(utf8.decode(res.bodyBytes));

  final result = data['results'];
  if (result == null) return null;

  return Teacher.fromJson(result as Map<String, dynamic>);
});

// teacher_id -> teacher_name
final teacherNameByIdProvider = FutureProvider.family<String, int>(
  (ref, teacherId) async {
    final t = await ref.watch(teacherByIdProvider(teacherId).future);
    return t?.teacher_name ?? '알 수 없음';
  }
);