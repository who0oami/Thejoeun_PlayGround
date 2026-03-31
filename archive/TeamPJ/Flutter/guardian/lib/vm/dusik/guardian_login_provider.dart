import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:guardian/model/guardian.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class GuardianLoginNotifier extends AsyncNotifier<List<Guardian>>{
  final String baseUrl = "http://10.0.2.2:8000/dusik";

  @override // 함수 수정해서 쓰는게 override
  FutureOr<List<Guardian>> build() async{
    return await fetchGuardian(); // 만들어지자마자 fetch함
  }

  List<Guardian> guardian = []; // guardian 데이터
  bool isLoading = false; // 로딩중인지 임시 확인용
  String? error; // error 확인
  final box = GetStorage(); // GetStorage 인스턴스 생성



  Future<List<Guardian>> fetchGuardian() async{ 
  //   isLoading = true;
  //   error = null; try - catch 방법에서 수정
    final res = await http.get(Uri.parse("$baseUrl/select_guardian"));

    if(res.statusCode != 200){
      throw Exception('불러오기 실패: ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((d) => Guardian.fromJson(d)).toList();
  }

   Future<List<Guardian>> loginTeachers(String email) async{ 
  //   isLoading = true;
  //   error = null; try - catch 방법에서 수정
    final res = await http.get(Uri.parse("$baseUrl/student_login"));

    if(res.statusCode != 200){
      throw Exception('불러오기 실패: ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((d) => Guardian.fromJson(d)).toList(); // 차이점: list로 return
  }

  Future<String> insertGuardian(Guardian g)async{
    final url = Uri.parse("$baseUrl/insert_guardian");
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(g.toJson()),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshGuardian();
    return data['result'];
  }

//   Future<String> loginGuardian(String email, String password) async {
//     final url = Uri.parse("$baseUrl/guardian_login");
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'guardian_email': email,
//         'guardian_password': password,
//       }),
//     );
//     final data = json.decode(utf8.decode(response.bodyBytes));
//     if (data.toString().contains('Fail') || data.toString().contains('Error')) {
//     return 'FAIL';
//   } 
//   if (data is List && data.isNotEmpty) {
//     final guardianStudentId = data[0]['student_id'].toString();
//     await box.write('student_id', guardianStudentId);
//     print("저장된 ID: ${box.read('student_id')}"); // 확인용 지울 예정입니다
//     return guardianStudentId;
//   }
//   return 'FAIL';
// }

Future<String> loginGuardian(String email, String password) async {
  final url = Uri.parse("$baseUrl/guardian_login");

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'guardian_email': email,
      'guardian_password': password,
    }),
  );
  final data = json.decode(utf8.decode(response.bodyBytes));
  if (data.toString().contains('Fail') || data.toString().contains('Error')) {
    return 'FAIL';
  }
  // 로그인 성공
  if (data is List && data.isNotEmpty) {
    final guardianId = int.parse(data[0]['guardian_id'].toString());
    final studentId = int.parse(data[0]['student_id'].toString());
    await box.write('guardian_id', guardianId);
    await box.write('student_id', studentId);
    print("저장 guardian_id: ${box.read('guardian_id')}");
    print("저장 student_id: ${box.read('student_id')}"); // 확인 용 , 지울 예정
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      final tokenResult = await updateGuardianToken(guardianId, fcmToken);
      print("토큰 업데이트 결과: $tokenResult");
    } else {
      print("FCM 토큰 null");
    }
    return "OK";
  }
  return 'FAIL';
}


Future<String> updateGuardianToken(int guardianId, String fcmToken) async {
  final url = Uri.parse("$baseUrl/guardian/update_token");
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'guardian_id': guardianId,
      'fcm_token': fcmToken,
    }),
  );

  final data = json.decode(utf8.decode(response.bodyBytes));
  return data['result'].toString();
}
  Future<void> refreshGuardian() async{
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await fetchGuardian()); // null 데이터 체크
  }

} // GuardianLoginNotifier

final guardianLoginNotifierProvider = AsyncNotifierProvider<GuardianLoginNotifier, List<Guardian>>(
  GuardianLoginNotifier.new
);
