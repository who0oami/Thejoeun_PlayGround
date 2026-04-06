import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/model/student.dart';
import 'package:http/http.dart' as http;

class StudentNotifier extends AsyncNotifier<List<Student>>{
  final String baseUrl = "http://127.0.0.1:8000/dusik";

  @override // 함수 수정해서 쓰는게 override
  FutureOr<List<Student>> build() async{
    return await fetchStudents(); // 만들어지자마자 fetch함
  }

  List<Student> students = [];
  bool isLoading = false;
  String? error;


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


  Future<void> refreshStudents() async{
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await fetchStudents()); // null 데이터 체크
  }

} // StudentNotifier

final studentNotifierProvider = AsyncNotifierProvider<StudentNotifier, List<Student>>(
  StudentNotifier.new
);