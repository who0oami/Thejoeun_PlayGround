import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:guardian/model/guardian.dart';
import 'package:http/http.dart' as http;

/// ✅ GetStorage Provider
final storageProvider = Provider<GetStorage>((ref) => GetStorage());

/// ✅ GetStorage의 student_id 변화를 Riverpod에 연결 (로그인/로그아웃 반영)
final studentIdStreamProvider = StreamProvider<String?>((ref) {
  final box = ref.watch(storageProvider);
  final controller = StreamController<String?>();

  // 1) 초기값 방출
  controller.add(box.read('student_id')?.toString());

  // 2) 변경 감지
  box.listenKey('student_id', (value) {
    controller.add(value?.toString());
  });

  ref.onDispose(() async {
    await controller.close();
  });

  return controller.stream.distinct();
});

class GuardianNotifier extends AsyncNotifier<List<Guardian>> {
  final String baseUrl = _resolveBaseUrl();

  @override
  FutureOr<List<Guardian>> build() async {
    // ✅ student_id가 바뀌면 자동 rebuild
    final idFromStream = ref.watch(studentIdStreamProvider).value;

    // stream 로딩 타이밍 보완용: storage에서 한 번 더 읽기
    final box = ref.watch(storageProvider);
    final studentId = (idFromStream ?? box.read('student_id')?.toString());

    if (studentId == null || studentId.isEmpty) {
      // 로그인 전/로그아웃 상태
      return [];
    }

    return await fetchGuardianByStudentId(studentId);
  }

  /// ✅ student_id로 보호자 정보 조회
  Future<List<Guardian>> fetchGuardianByStudentId(String studentId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/minjae/select?student_id=$studentId"),
    );

    if (res.statusCode != 200) {
      throw Exception("불러오기 실패: ${res.statusCode}");
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    final results = data['results'];

    // ✅ 서버가 results를 null/다른 타입으로 주는 경우 방어
    if (results == null || results is! List || results.isEmpty) {
      return [];
    }

    return results.map((d) => Guardian.fromJson(d)).toList();
  }

  Future<void> refreshGuardian() async {
    state = const AsyncLoading();

    final box = ref.read(storageProvider);
    final studentId = box.read('student_id')?.toString();

    if (studentId == null || studentId.isEmpty) {
      state = const AsyncData([]);
      return;
    }

    state = await AsyncValue.guard(
      () async => await fetchGuardianByStudentId(studentId),
    );
  }
}

final guardianNotifierProvider =
    AsyncNotifierProvider<GuardianNotifier, List<Guardian>>(
  GuardianNotifier.new,
);

String _resolveBaseUrl() {
  const String apiHost = String.fromEnvironment('API_HOST', defaultValue: '');
  if (apiHost.isNotEmpty) {
    return 'http://$apiHost:8000';
  }
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000';
  }
  return 'http://127.0.0.1:8000';
}
