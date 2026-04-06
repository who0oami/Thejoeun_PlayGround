/*
Description : teacher 메인페이지구성 (Decorated UI + Drawer DB 연동 + Calendar Schedule)
Date : 2026-1-18
Author : 민재 (calendar + schedule connected)
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teacher/util/acolor.dart';
import 'package:teacher/view/dusik/teacher_login.dart';
import 'package:teacher/view/minwook/view_notice.dart';
import 'package:teacher/vm/minjae/teacher_riverpod.dart';
import 'package:teacher/vm/minjae/meal_riverpod.dart';
import 'package:teacher/vm/minjae/timetable_riverpod.dart';
import 'package:teacher/vm/minjae/schedule_riverpod.dart';
import 'package:teacher/model/timetable.dart';
import 'package:teacher/model/schedule.dart';
import 'package:teacher/model/lunch_menu.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

final selectedDayProvider = StateProvider<DateTime?>((ref) => DateTime.now());
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

final lastLunchCacheProvider =
    StateProvider<Map<String, List<LunchMenu>>?>((ref) => null);

class TeacherMainPage extends ConsumerStatefulWidget {
  const TeacherMainPage({super.key});

  @override
  ConsumerState<TeacherMainPage> createState() => _TeacherMainPageState();
}

class _TeacherMainPageState extends ConsumerState<TeacherMainPage> {
  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);

    final formattedDate =
        DateFormat('yyyy.MM.dd EEEE', 'ko_KR').format(selectedDay ?? DateTime.now());

    final teacherAsync = ref.watch(teacherNotifierProvider);
    final timetableAsync = ref.watch(timetableListProvider);

    final lunchDateKey =
        DateFormat('yyyy-MM-dd').format(selectedDay ?? DateTime.now());

    return Scaffold(
      backgroundColor: Acolor.baseBackgroundColor,

      /// ================= Drawer (그대로 유지) =================
      drawer: Drawer(
        child: Consumer(
          builder: (context, ref, _) {
            final drawerTeacherAsync = ref.watch(teacherNotifierProvider);

            return drawerTeacherAsync.when(
              data: (teachers) {
                if (teachers.isEmpty) {
                  return const Center(child: Text('선생님 정보 없음'));
                }

                final t = teachers.first;

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    UserAccountsDrawerHeader(
                      accountName: Text(t.teacher_name),
                      accountEmail: Text(t.teacher_email),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                          "http://10.0.2.2:8000/minjae/view/${t.teacher_id}",
                        ),
                      ),
                      decoration: const BoxDecoration(color: Colors.deepPurple),
                    ),
                    _drawerItems(context, ref),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(child: Text("오류: $e")),
            );
          },
        ),
      ),

      appBar: AppBar(
        title:Image.asset('images/atti_logo.png',width: 70,),
        centerTitle: true,
        backgroundColor: Acolor.primaryColor,
        foregroundColor: Acolor.onPrimaryColor,
        elevation: 0,
      ),

      /// ================= Body =================
      body: teacherAsync.when(
        data: (teachers) {
          if (teachers.isEmpty) {
            return const Center(child: Text('선생님 데이터 없음'));
          }

          return timetableAsync.when(
            data: (timetables) {
              if (timetables.isEmpty) {
                return const Center(child: Text('시간표 데이터 없음'));
              }

              final t = teachers.first;
              final timetable = timetables.first;

              return LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 900; // 태블릿/가로 넓은 화면

                  final leftColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _dashboardHeader(t, formattedDate),
                      const SizedBox(height: 14),

                      // 일정 카드
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _cardTitle(
                              icon: Icons.event_note,
                              title: "오늘 일정",
                              trailing: _pillText("캘린더"),
                            ),
                            const SizedBox(height: 12),
                            _buildCalendar(ref, selectedDay, focusedDay),
                            const SizedBox(height: 10),
                            _buildScheduleList(ref),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () {},
                                  icon: const Icon(Icons.location_on),
                                  label: const Text(
                                    "학생 위치 찾기",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  final rightColumn = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 시간표 카드
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _cardTitle(
                              icon: Icons.schedule,
                              title: "오늘의 시간표",
                              trailing: _pillText("${timetable.timetable_period}교시"),
                            ),
                            const SizedBox(height: 12),
                            _buildTimeTable(timetable),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 급식 카드
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _cardTitle(
                              icon: Icons.restaurant_menu,
                              title: "오늘의 급식",
                              trailing: _pillText(DateFormat('MM.dd').format(selectedDay ?? DateTime.now())),
                            ),
                            const SizedBox(height: 12),
                            _MealSection(dateKey: lunchDateKey),
                          ],
                        ),
                      ),
                    ],
                  );

                  if (!isWide) {
                    // 폰/좁은 화면: 1열
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        leftColumn,
                        const SizedBox(height: 14),
                        rightColumn,
                      ],
                    );
                  }

                  // 태블릿: 2열 카드 배치(드로어는 그대로)
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: leftColumn),
                            const SizedBox(width: 14),
                            Expanded(child: rightColumn),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("시간표 오류: $e")),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("오류: $e")),
      ),
    );
  }

  /// ================= Drawer Items =================
  /// ✅ ref를 받아 invalidate 가능하게
  Widget _drawerItems(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const ListTile(
          leading: Icon(Icons.lock_outline),
          title: Text("비밀번호 수정"),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.how_to_reg),
          title: Text("학생 출결 조회"),
        ),
        const ListTile(
          leading: Icon(Icons.edit_calendar),
          title: Text("학생 출결 수정"),
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.campaign),
          title: const Text("공지 작성/수정"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ViewNotice()),
            );
          },
        ),
        Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("로그아웃", style: TextStyle(color: Colors.red)),
          onTap: () async {
            final box = GetStorage();
            await box.remove('teacher_id');
            await box.save();

            ref.invalidate(teacherNotifierProvider);
            ref.invalidate(lastLunchCacheProvider);

            if (!context.mounted) return;

            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const TeacherLogin()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  /// ================= 깔끔한 상단 헤더 =================
  Widget _dashboardHeader(dynamic t, String formattedDate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              "http://10.0.2.2:8000/minjae/view/${t.teacher_id}",
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "두식초등학교 · 1학년 1반",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  "${t.teacher_name} 선생님",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Acolor.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.school, color: Acolor.primaryColor),
          ),
        ],
      ),
    );
  }

  /// ================= 카드 UI =================
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _cardTitle({required IconData icon, required String title, Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, color: Acolor.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _pillText(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  // ================= Calendar (with schedule) =================
  Widget _buildCalendar(
      WidgetRef ref, DateTime? selectedDay, DateTime focusedDay) {
    final scheduleMap = ref.watch(scheduleMapProvider);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: TableCalendar(
        locale: 'ko_KR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
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
          final key = DateTime(day.year, day.month, day.day);
          return scheduleMap[key] ?? [];
        },
      ),
    );
  }

  // ================= Schedule List =================
  Widget _buildScheduleList(WidgetRef ref) {
    final schedules = ref.watch(scheduleMapProvider);
    final selectedDate = ref.watch(selectedDayProvider);

    final key = DateTime(
      selectedDate!.year,
      selectedDate.month,
      selectedDate.day,
    );

    final todaySchedules = schedules[key] ?? [];

    if (todaySchedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          "오늘은 등록된 일정이 없습니다",
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: todaySchedules.map((Schedule s) {
        final timeStr = DateFormat('HH:mm').format(s.schedule_startdate);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.event, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.schedule_title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text("$timeStr · ${s.schedule_contents}",
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ================= Schedule List =================
 
  // ================= TimeTable =================
  Widget _buildTimeTable(Timetable timetable) {
    final table = timetable.timetable_table;
    final days = ['월', '화', '수', '목', '금'];

    return Table(
      border: TableBorder.all(color: Colors.black.withOpacity(0.18)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            _cell('', isHeader: true),
            ...days.map((d) => _cell(d, isHeader: true)).toList(),
          ],
        ),
        for (int i = 0; i < timetable.timetable_period; i++)
          TableRow(
            children: [
              _cell('${i + 1}교시', isHeader: true),
              ...days.map((day) {
                final list = table[day] ?? [];
                return _cell(i < list.length ? list[i] : '');
              }).toList(),
            ],
          ),
      ],
    );
  }

  Widget _cell(String text, {bool isHeader = false}) {
    return Container(
      height: 46,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      color: isHeader ? Colors.black.withOpacity(0.04) : null,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/// =======================================================
/// ✅ 급식 섹션만 분리 (캐시 유지 + 얇은 로딩바)
/// =======================================================
class _MealSection extends ConsumerWidget {
  const _MealSection({required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lunchAsync = ref.watch(lunchByDateProvider(dateKey));
    final cached = ref.watch(lastLunchCacheProvider);

    ref.listen<AsyncValue<Map<String, List<LunchMenu>>>>(
      lunchByDateProvider(dateKey),
      (prev, next) {
        next.whenData((data) {
          ref.read(lastLunchCacheProvider.notifier).state = data;
        });
      },
    );

    final display = lunchAsync.value ?? cached ?? <String, List<LunchMenu>>{};

    const order = ['밥', '국', '반찬', '기타', '디저트'];
    final menus = <LunchMenu>[];

    for (final k in order) {
      if (display.containsKey(k)) menus.addAll(display[k]!);
    }
    display.forEach((k, v) {
      if (!order.contains(k)) menus.addAll(v);
    });

    final showTopLoadingBar =
        lunchAsync.isLoading && cached != null && lunchAsync.value == null;

    return Stack(
      children: [
        _buildMealGrid(menus),
        if (showTopLoadingBar)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  Widget _buildMealGrid(List<LunchMenu> menus) {
    if (menus.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(child: Text('급식 정보 없음')),
      );
    }

    // 태블릿에서 자동으로 좀 더 많이 보이게
    // (드로어는 유지되니까 너무 과하게 늘리진 않음)
    final width = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;

    int crossAxisCount = 2;
    if (width >= 900) crossAxisCount = 3;
    if (width >= 1200) crossAxisCount = 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menus.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 140,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, index) {
        final menu = menus[index];
        return Container(
          decoration: BoxDecoration(
            color: Acolor.primaryColor,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(menu.lunch_menu_image, height: 60),
              const SizedBox(height: 8),
              Text(
                menu.lunch_menu_name,
                style: TextStyle(
                  color: Acolor.onPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
