//  Attendance view in teacher
/*
  Created in: 22/01/2026 10:11
  Author: Chansol, Park
  Description: Attendance view in teacher
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
*/

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:teacher/util/config.dart' as config;
import 'package:teacher/vm/restitutor/attendance_provider.dart';

class AttendanceTeacher extends ConsumerStatefulWidget {
  const AttendanceTeacher({super.key});

  @override
  ConsumerState<AttendanceTeacher> createState() {
    return _AttendanceTeacherState();
  }
}

class _AttendanceTeacherState extends ConsumerState<AttendanceTeacher> {
  final Map<int, String> _nameCache = {};
  @override
  Widget build(BuildContext context) {
    //  Property
    //  Provider watch
    final attendAsync = ref.watch(attendQueryProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('학생 출결현황')),
      body: attendAsync.when(
        data: (data) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final raw = data[index]['attendance_start_time'].toString();
              final dt = DateTime.parse(raw.replaceFirst(' ', 'T'));
              return ListTile(
                title: FutureBuilder<String>(
                  future: fetchStudentName(data[index]['student_id']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('이름 로딩중...');
                    }
                    if (snapshot.hasError) {
                      return const Text('이름 불러오기 실패');
                    }
                    return Text('학생 이름: ${snapshot.data}');
                  },
                ),
                subtitle: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('날짜: ${dt.year}년 ${dt.month}월 ${dt.day}일'),
                    Text('상태: ${data[index]['attendance_status'] ?? '미체크'}'),
                    ...(data[index]['attendance_status'] == null
                        ? [
                            ElevatedButton(
                              onPressed: () async {
                                await ref
                                    .read(attendProvider.notifier)
                                    .attendCheck(
                                      studentId: data[index]['student_id'],
                                      attendanceStatus: '조퇴',
                                    );
                                ref.invalidate(attendQueryProvider);
                              },
                              child: Text('조퇴'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await ref
                                    .read(attendProvider.notifier)
                                    .attendCheck(
                                      studentId: data[index]['student_id'],
                                      attendanceStatus: '외출',
                                    );
                                ref.invalidate(attendQueryProvider);
                              },
                              child: Text('외출'),
                            ),
                          ]
                        : [Text('미체크')]),
                  ],
                ),
              );
            },
          );
        },
        error: (error, stackTrace) {
          return Center(child: Text('에러 발생: $error'));
        },
        loading: () {
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<String> fetchStudentName(int studentId) async {
    if (_nameCache.containsKey(studentId)) {
      return _nameCache[studentId]!;
    }
    final url =
        'http://${config.getForwardIP()}:${config.forwardport}/sanghyun/student/$studentId';

    final res = await http.get(Uri.parse(url));

    if (res.statusCode != 200) {
      throw Exception('학생 조회 실패: ${res.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));

    if (data.containsKey('error')) {
      throw Exception(data['error']);
    }

    _nameCache[studentId] = data['student_name'];
    return data['student_name'];
  }
}
