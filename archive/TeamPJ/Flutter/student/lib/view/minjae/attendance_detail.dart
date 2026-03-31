import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:student/model/attendance.dart';
import 'package:student/vm/minjae/attendance_riverpod.dart';

final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

class AttendanceDetailPage extends ConsumerWidget {
  const AttendanceDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceListProvider(1));
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('출결현황')),
      body: attendanceAsync.when(
        data: (attendances) {
          if (attendances.isEmpty) {
            return const Center(child: Text('출결 기록이 없습니다.'));
          }

          final studentName = attendances.first.student_name ?? '학생';

          final filtered = attendances.where((att) {
            final d = DateTime.parse(att.attendance_start_time);
            return d.year == selectedMonth.year && d.month == selectedMonth.month;
          }).toList();

          final stats = _calcStats(filtered);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1학년 1반', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Text('$studentName 학생 출결을 확인하세요',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statBox('출석', stats['출석']!, Colors.green),
                      _statBox('지각', stats['지각']!, Colors.purple),
                      _statBox('결석', stats['결석']!, Colors.red),
                      _statBox('조퇴', 0, Colors.grey),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        ref.read(selectedMonthProvider.notifier).state =
                            DateTime(selectedMonth.year, selectedMonth.month - 1);
                      },
                    ),
                    Text('${selectedMonth.month}월', style: const TextStyle(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        ref.read(selectedMonthProvider.notifier).state =
                            DateTime(selectedMonth.year, selectedMonth.month + 1);
                      },
                    ),
                  ],
                ),

                const Divider(thickness: 1),

                Row(
                  children: const [
                    Expanded(child: Text('날짜', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('출석현황', style: TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(child: Text('메모', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('해당 월 출결 없음'))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final att = filtered[index];
                            final date = DateFormat('M/d').format(DateTime.parse(att.attendance_start_time));
                            Color statusColor;
                            switch (att.attendance_status) {
                              case '출석':
                                statusColor = Colors.green;
                                break;
                              case '지각':
                                statusColor = Colors.purple;
                                break;
                              case '결석':
                                statusColor = Colors.red;
                                break;
                              default:
                                statusColor = Colors.black;
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(child: Text(date)),
                                  Expanded(
                                    child: Text(
                                      att.attendance_status,
                                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(att.attendance_content ?? '',
                                        style: const TextStyle(color: Colors.grey)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('에러: $e')),
      ),
    );
  }
Map<String, int> _calcStats(List<Attendance> list) {
  final map = {'출석': 0, '지각': 0, '결석': 0, '조퇴': 0}; 
  for (var a in list) {
    if (map.containsKey(a.attendance_status)) {
      map[a.attendance_status] = map[a.attendance_status]! + 1;
    }
  }
  return map;
}

  Widget _statBox(String title, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text('$count', style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}