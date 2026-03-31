import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:teacher/model/teacher.dart';

/// ✅ GetStorage Provider
final storageProvider = Provider<GetStorage>((ref) => GetStorage());

/// ✅ teacher_id 변화를 Stream으로 흘려보내는 Provider
final teacherIdStreamProvider = StreamProvider<String?>((ref) {
  final box = ref.watch(storageProvider);
  final controller = StreamController<String?>();

  // 1) 초기값 한번 방출
  controller.add(box.read('teacher_id')?.toString());

  // 2) teacher_id 변경될 때마다 방출
  box.listenKey('teacher_id', (value) {
    controller.add(value?.toString());
  });

  ref.onDispose(() async {
    await controller.close();
  });

  // 중복 방출 줄이기
  return controller.stream.distinct();
});

class TeacherNotifier extends AsyncNotifier<List<Teacher>> {
  final String baseUrl = "http://10.0.2.2:8000";

  @override
  FutureOr<List<Teacher>> build() async {
    // ✅ 핵심: teacher_id 변화를 구독해서, 값 바뀌면 build가 다시 돔
    final teacherId = ref.watch(teacherIdStreamProvider).value;

    // stream이 아직 로딩이면 storage에서 한번 읽어서 보강(초기 진입 안정화)
    final box = ref.watch(storageProvider);
    final id = (teacherId ?? box.read('teacher_id')?.toString());

    if (id == null) {
      // 로그인 안 된 상태
      return [];
    }

    return await fetchTeacher(id, box);
  }

  Future<List<Teacher>> fetchTeacher(String teacherId, GetStorage input) async {
    try {
      final teacherId = input.read('teacher_id');

      if (teacherId == null) {
        print('⚠️ 저장된 teacher_id 없음');
        return [];
      }

      final res = await http.get(
        Uri.parse("$baseUrl/minjae/select/teacher?teacher_id=$teacherId"),
      );

      if (res.statusCode != 200) {
        throw Exception("불러오기 실패: ${res.statusCode}");
      }

      final data = json.decode(utf8.decode(res.bodyBytes));
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

  Future<void> refreshTeacher(GetStorage input) async {
    state = const AsyncLoading();
    // ✅ 현재 teacher_id로 다시 가져오기
    final id = ref.read(storageProvider).read('teacher_id')?.toString();
    if (id == null) {
      state = const AsyncData([]);
      return;
    }
    state = await AsyncValue.guard(() async => await fetchTeacher(id, input));
  }
}

final teacherNotifierProvider =
    AsyncNotifierProvider<TeacherNotifier, List<Teacher>>(
  TeacherNotifier.new,
);
