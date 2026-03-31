import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:student/util/config.dart' as config;
import 'package:student/vm/restitutor/attendance_provider.dart';

class AttendStudent extends ConsumerStatefulWidget {
  const AttendStudent({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AttendStudentState();
  }
}

class _AttendStudentState extends ConsumerState {
  final Map<int, String> _nameCache = {};
  @override
  Widget build(BuildContext context) {
    final attendAsync = ref.watch(attendQueryProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('출결 현황'), centerTitle: true),
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
                    Text(
                      '날짜: ${dt.year}년 ${dt.month}월 ${dt.day}일',
                    ),
                    Text('상태: ${data[index]['attendance_status'] ?? '미체크'}'),
                    data[index]['attendance_status'] == null
                        ? ElevatedButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              final isBeforeOrAtNine =
                                  now.hour < 9 ||
                                  (now.hour == 9 && now.minute == 0);

                              final status = isBeforeOrAtNine ? '출석' : '지각';

                              final sid = int.parse(
                                data[index]['student_id'].toString(),
                              );

                              await ref
                                  .read(attendProvider.notifier)
                                  .attendCheck(
                                    studentId: sid,
                                    attendanceStatus: status,
                                  );

                              ref.invalidate(attendQueryProvider);
                            },
                            child: Text(
                              (DateTime.now().hour < 9 ||
                                      (DateTime.now().hour == 9 &&
                                          DateTime.now().minute == 0))
                                  ? '출석'
                                  : '지각',
                            ),
                          )
                        : Text('출석 완료'),
                    Divider(),
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
