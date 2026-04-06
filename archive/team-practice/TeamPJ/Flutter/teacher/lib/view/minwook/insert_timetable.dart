/* 
Description : Timetable 입력 & 수정 페이지
Date : 2026-1-19
Author : 황민욱
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:teacher/model/timetable.dart';
import 'package:teacher/util/message.dart';
import 'package:teacher/vm/minwook/drawer.dart';
import 'package:teacher/vm/minwook/timetable_provider.dart';

// 임시 Provider
final semesterProvider = StateProvider<String>((ref) => '2026-1');
final gradeProvider = StateProvider<int>((ref) => 1);
final classProvider = StateProvider<int>((ref) => 1);

class InsertTimetable extends ConsumerWidget {
  const InsertTimetable({super.key});

  // 임시 데이터
  static const List<String> _subjects = ['국어','수학','영어','사회','과학','체육','미술','음악','창체','도덕','기타'];
  static const List<String> _days = ['월', '화', '수', '목', '금'];
  static const List<String> _semesters = ['2026-1', '2026-2'];
  static const List<int> _grades = [1, 2, 3, 4, 5, 6];
  static const List<int> _classes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semester = ref.watch(semesterProvider);
    final grade = ref.watch(gradeProvider);
    final classNum = ref.watch(classProvider);

    final ttAsync = ref.watch(
      timetableByFilterProvider((semester: semester, grade: grade, classNum: classNum)),
    );
    
    return Scaffold(
      appBar: AppBar(title: const Text('시간표'), centerTitle: true),
      drawer: AppDrawer(currentPage: this),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _buildFilterBar(ref),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ttAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (tt) {
                    if (tt == null) {
                      return _buildEmptyState(context, ref, semester, grade, classNum);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Table(
                        border: TableBorder.all(color: Colors.grey.shade200),
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: _buildEditableTableRows(context, ref, tt),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } // build

  // Widgets =========================================
  // Empty state
  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    String semester,
    int grade,
    int classNum,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('시간표 데이터가 없음'),
          ),
          SizedBox(
            width: 180,
            height: 44,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('시간표 추가'),
              onPressed: () async {
                try {
                  await ref.read(timetableActionProvider.notifier).createDefaultIfNotExists(
                        semester: semester,
                        grade: grade,
                        classNum: classNum,
                        period: 6,
                        days: _days,
                      );

                  if (context.mounted) {
                    Message.snackBar(context, '시간표가 생성됨', 2, Colors.black87);
                  }
                } catch (e) {
                  if (context.mounted) {
                    Message.snackBar(context, '생성 실패: $e', 2, Colors.redAccent);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Filter bar
  Widget _buildFilterBar(WidgetRef ref) {
    final semester = ref.watch(semesterProvider);
    final grade = ref.watch(gradeProvider);
    final classNum = ref.watch(classProvider);

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DropdownButtonFormField<String>(
              value: semester,
              decoration: const InputDecoration(
                labelText: '학기',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _semesters.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) {
                if (v == null) return;
                ref.read(semesterProvider.notifier).state = v;
              },
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DropdownButtonFormField<int>(
              value: grade,
              decoration: const InputDecoration(
                labelText: '학년',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _grades.map((g) => DropdownMenuItem(value: g, child: Text('$g'))).toList(),
              onChanged: (v) {
                if (v == null) return;
                ref.read(gradeProvider.notifier).state = v;
              },
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<int>(
            value: classNum,
            decoration: const InputDecoration(
              labelText: '반',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _classes.map((c) => DropdownMenuItem(value: c, child: Text('$c'))).toList(),
            onChanged: (v) {
              if (v == null) return;
              ref.read(classProvider.notifier).state = v;
            },
          ),
        ),
      ],
    );
  }

  // Table rows editable
  List<TableRow> _buildEditableTableRows(BuildContext context, WidgetRef ref, Timetable tt) {
    final periodCount = (tt.timetable_period > 0) ? tt.timetable_period : 6;

    final rows = <TableRow>[];

    // Header
    rows.add(
      TableRow(
        children: [
          _buildHeaderCell('교시'),
          ..._days.map((d) => _buildHeaderCell(d)),
        ],
      ),
    );

    // Body
    for (int p = 0; p < periodCount; p++) {
      rows.add(
        TableRow(
          children: [
            _buildPeriodCell('${p + 1}교시'),
            ..._days.map((day) {
              final list = tt.timetable_table[day] ?? const <String>[];
              final current = (p < list.length) ? list[p] : '';

              return _buildSubjectCell(
                context: context,
                ref: ref,
                tt: tt,
                day: day,
                periodIndex: p,
                current: current,
              );
            }),
          ],
        ),
      );
    }
    return rows;
  }

  // Header cell
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Period cell
  Widget _buildPeriodCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Subject cell
  Widget _buildSubjectCell({
    required BuildContext context,
    required WidgetRef ref,
    required Timetable tt,
    required String day,
    required int periodIndex,
    required String current,
  }) {
    return InkWell(
      onTap: () async {
        final selected = await _pickSubjectBottomSheet(context, current);
        if (selected == null) return;

        try {
          await ref.read(timetableActionProvider.notifier).updateCell(
                timetableId: tt.timetable_id,
                day: day,
                periodIndex: periodIndex,
                subject: selected,
              );

          if (context.mounted) {
            Message.snackBar(context, '저장됨: $day ${periodIndex + 1}교시 → $selected', 2, Colors.black87);
          }
        } catch (e) {
          if (context.mounted) {
            Message.snackBar(context, '저장 실패: $e', 2, Colors.redAccent);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Center(
          child: Text(
            current.isEmpty ? '선택' : current,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: current.isEmpty ? Colors.grey.shade400 : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _pickSubjectBottomSheet(BuildContext context, String current) async {
    String? selected = current.isEmpty ? null : current;

    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  '과목 선택',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              DropdownButtonFormField<String>(
                value: selected,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                hint: const Text('과목을 선택'),
                items: _subjects
                    .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => selected = v,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, null),
                        child: const Text('취소'),
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(left: 10)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, selected),
                        child: const Text('선택'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
