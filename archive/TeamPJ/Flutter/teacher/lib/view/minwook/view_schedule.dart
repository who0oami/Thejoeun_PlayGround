/* 
Description : Schedule 페이지 + BottomSheet (입력, 수정, 삭제)
Date : 2026-1-22
Author : 황민욱
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:teacher/model/schedule.dart';
import 'package:teacher/util/acolor.dart';
import 'package:teacher/vm/minwook/drawer.dart';
import 'package:teacher/vm/minwook/schedule_provider.dart';

// Provider
final selectedDayProvider = StateProvider<DateTime?>((ref) => DateTime.now());
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

class ViewSchedule extends ConsumerWidget {
  const ViewSchedule({super.key});

  DateTime _onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider) ?? DateTime.now();
    final focusedDay = ref.watch(focusedDayProvider);

    final scheduleMap = ref.watch(scheduleMapProvider);
    final key = _onlyDate(selectedDay);
    final daySchedules = scheduleMap[key] ?? const <Schedule>[];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('학사 일정'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _openAddSheet(context, ref, selectedDay),
            icon: const Icon(Icons.add, size: 30),
          )
        ],
      ),
      drawer: AppDrawer(currentPage: this),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: _buildCalendar(ref, selectedDay, focusedDay, scheduleMap),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildScheduleList(context, ref, daySchedules),
            ),
          ),
        ],
      ),
    );
  } //build

  // Widgets =================================
  Widget _buildCalendar(
    WidgetRef ref,
    DateTime selectedDay,
    DateTime focusedDay,
    Map<DateTime, List<Schedule>> scheduleMap,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Acolor.appBarBackgroundColor, blurRadius: 2),
        ],
      ),
      child: TableCalendar<Schedule>(
        locale: 'ko_KR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        daysOfWeekHeight: 30,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (newSelectedDay, newFocusedDay) {
          ref.read(selectedDayProvider.notifier).state = newSelectedDay;
          ref.read(focusedDayProvider.notifier).state = newFocusedDay;
        },
        eventLoader: (day) {
          final key = _onlyDate(day);
          return scheduleMap[key] ?? const <Schedule>[];
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Acolor.primaryColor,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Acolor.successBackColor,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  } // _buildCalendar

  Widget _buildScheduleList(BuildContext context, WidgetRef ref, List<Schedule> schedules) {
    if (schedules.isEmpty) {
      return const Center(child: Text('해당 날짜 일정 없음'));
    }

    final unique = {for (final s in schedules) s.schedule_id: s}.values.toList();

    return ListView.separated(
      itemCount: unique.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final s = unique[i];
        return ListTile(
          title: Text(s.schedule_title),
          subtitle: Text(
            '${s.schedule_contents}\n${_fmtDate(s.schedule_startdate)} ~ ${_fmtDate(s.schedule_enddate)}',
          ),
          isThreeLine: true,
          onTap: () => _openEditSheet(context, ref, s),
        );
      },
    );
  } // _buildScheduleList

  void _openAddSheet(BuildContext context, WidgetRef ref, DateTime day) {
    ref.read(scheduleFormProvider.notifier).initForAdd(day: day, teacherId: 1);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const ScheduleBottomSheet(),
    );
  } // _openAddSheet

  void _openEditSheet(BuildContext context, WidgetRef ref, Schedule s) {
    ref.read(scheduleFormProvider.notifier).initForEdit(s);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => const ScheduleBottomSheet(),
    );
  } // _openEditSheet

  String _fmtDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}.${two(d.month)}.${two(d.day)}';
  }
} // class

// BottomSheet
class ScheduleBottomSheet extends ConsumerStatefulWidget {
  const ScheduleBottomSheet({super.key});

  @override
  ConsumerState<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends ConsumerState<ScheduleBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentsController;

  String? _syncedScheduleId;
  ScheduleFormMode? _syncedMode;

  @override
  void initState() {
    super.initState();
    final form = ref.read(scheduleFormProvider);
    _titleController = TextEditingController(text: form.title);
    _contentsController = TextEditingController(text: form.contents);
    _syncedScheduleId = form.scheduleId;
    _syncedMode = form.mode;
    _titleController.addListener(() {ref.read(scheduleFormProvider.notifier).setTitle(_titleController.text);});
    _contentsController.addListener(() {ref.read(scheduleFormProvider.notifier).setContents(_contentsController.text);});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentsController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}.${two(d.month)}.${two(d.day)}';
  }

  void _syncControllers(ScheduleFormState form) {
    final changed = (form.mode != _syncedMode) || (form.scheduleId != _syncedScheduleId);
    if (!changed) return;
    _syncedMode = form.mode;
    _syncedScheduleId = form.scheduleId;
    _titleController.text = form.title;
    _contentsController.text = form.contents;
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(scheduleFormProvider);
    final notifier = ref.read(scheduleFormProvider.notifier);
    final action = ref.read(scheduleActionProvider.notifier);

    _syncControllers(form);

    final isEdit = form.mode == ScheduleFormMode.edit;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isEdit ? '일정 수정' : '일정 추가',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await _pickDate(form.start);
                        if (picked == null) return;
                        notifier.setStart(picked);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(Icons.calendar_month),
                          ),
                          Text('시작: ${_fmt(form.start)}'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await _pickDate(form.end);
                          if (picked == null) return;
                          notifier.setEnd(picked);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(Icons.calendar_month),
                            ),
                            Text('종료: ${_fmt(form.end)}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: _contentsController,
                decoration: const InputDecoration(
                  labelText: '내용',
                  border: OutlineInputBorder(),
                ),
                minLines: 2,
                maxLines: 4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: double.infinity),
                child: ElevatedButton(
                  onPressed: () async {
                    final title = form.title.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('제목은 필수임')),
                      );
                      return;
                    }
                    const teacherId = 1; // 임시
                    if (!isEdit) {
                      final schedule = Schedule(
                        schedule_id: '',
                        teacher_id: teacherId,
                        schedule_startdate: form.start,
                        schedule_enddate: form.end,
                        schedule_insertdate: DateTime.now(),
                        schedule_updatedate: null,
                        schedule_title: title,
                        schedule_contents: form.contents.trim(),
                      );
                      await action.addSchedule(schedule);
                    } else {
                      final id = form.scheduleId;
                      if (id == null) return;

                      await action.updateSchedule(id, {
                        'teacher_id': teacherId,
                        'schedule_startdate': form.start,
                        'schedule_enddate': form.end,
                        'schedule_title': title,
                        'schedule_contents': form.contents.trim(),
                        'schedule_updatedate': DateTime.now(),
                      });
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Acolor.successBackColor,
                    foregroundColor: Acolor.successTextColor
                  ),
                  child: Text(isEdit ? '수정 저장' : '등록'),
                ),
              ),
            ),

            if (isEdit)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: ConstrainedBox(
                  constraints: const BoxConstraints.tightFor(width: double.infinity),
                  child: OutlinedButton(
                    onPressed: () async {
                      final id = form.scheduleId;
                      if (id == null) return;

                      await action.deleteSchedule(id);
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white
                    ),
                    child: const Text('삭제'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  } // build
} // class