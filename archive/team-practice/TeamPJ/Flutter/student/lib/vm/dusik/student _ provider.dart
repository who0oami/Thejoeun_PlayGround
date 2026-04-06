import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:student/model/guardian.dart';
import 'package:student/model/student.dart';

  final guardianIdProvider = FutureProvider.family<int, String>((ref, guardianId) async {
    final String baseUrl = "http://10.0.2.2:8000/dusik";
    final int gid;
    final res = await http.get(Uri.parse("$baseUrl/select_guardian/$guardianId"));
    if (res.statusCode != 200) {
      throw Exception('불러오기 실패: ${res.statusCode}\n${utf8.decode(res.bodyBytes)}');
    }
    final data = json.decode(utf8.decode(res.bodyBytes));
    gid = data[0];
    return gid;
  });
  
class StudentNotifier extends AsyncNotifier<List<Student>>{
  final String baseUrl = "http://10.0.2.2:8000/dusik";

  @override // 함수 수정해서 쓰는게 override
  FutureOr<List<Student>> build() async{
    return await fetchStudents(); // 만들어지자마자 fetch함
  }

  List<Student> students = [];
  bool isLoading = false;
  String? error;
  final box = GetStorage(); // GetStorage 인스턴스 생성


  Future<List<Student>> fetchStudents() async{ 
  //   isLoading = true;
  //   error = null; try - catch 방법에서 수정
    final res = await http.get(Uri.parse("$baseUrl/select"));

    if(res.statusCode != 200){
      throw Exception('불러오기 실패: ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((d) => Student.fromJson(d)).toList();
  }

   Future<List<Student>> loginStudents() async{ 
  //   isLoading = true;
  //   error = null; try - catch 방법에서 수정
    final res = await http.get(Uri.parse("$baseUrl/student_login"));

    if(res.statusCode != 200){
      throw Exception('불러오기 실패: ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((d) => Student.fromJson(d)).toList(); // 차이점: list로 return
  }

  Future<String> insertStudent(Student s)async{
    final url = Uri.parse("$baseUrl/insert");
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(s.toJson()),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshStudents();
    return data['result'];
  }

  Future<String> loginStudent(String phone, String password) async {
    final url = Uri.parse("$baseUrl/student_login");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'student_phone': phone,
        'student_password': password,
      }),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    print("서버 응답 데이터: $data");
    if (data.toString().contains('Fail') || data.toString().contains('Error')) {
    return 'FAIL';
  } 
  if (data is List && data.isNotEmpty) {
    final studentId = data[0]['student_id'].toString();
    await box.write('student_id', studentId);
    print("저장된 ID: ${box.read('student_id')}"); // 확인용 지울 예정입니다
    return studentId;
    
  }
  return 'FAIL';
}

  Future<void> refreshStudents() async{
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await fetchStudents()); // null 데이터 체크
  }

} // StudentNotifier

final studentNotifierProvider = AsyncNotifierProvider<StudentNotifier, List<Student>>(
  StudentNotifier.new
);
