import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_storage/get_storage.dart';
import 'package:guardian/model/attendance.dart';
import 'package:guardian/util/acolor.dart';
import 'package:guardian/view/chatting/guardian_chatting.dart';
import 'package:guardian/view/guardian_login.dart';
import 'package:guardian/view/minjae/attendance_detail.dart';
import 'package:guardian/vm/minjae/guardian_riverpod.dart';
import 'package:guardian/vm/minjae/meal_riverpod%20copy.dart';
import 'package:guardian/vm/minjae/meal_riverpod.dart';
import 'package:guardian/vm/minjae/schedule_riverpod.dart';
import 'package:guardian/vm/timetable_riverpod.dart';
import 'package:guardian/model/schedule.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:guardian/model/timetable.dart';
import 'package:guardian/model/lunch_menu.dart';


import 'package:guardian/view/notice/notice_tabbar.dart';

final selectedDayProvider = StateProvider<DateTime?>((ref) => DateTime.now());
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// ✅ 급식 캐시(날짜 바꿀 때 끊김 완화용)
final lastLunchCacheProvider =
    StateProvider<Map<String, List<LunchMenu>>?>((ref) => null);

class GuardianMainPage extends ConsumerStatefulWidget {
  const GuardianMainPage({super.key});

  @override
  ConsumerState<GuardianMainPage> createState() => _GuardianMainPageState();
}

class _GuardianMainPageState extends ConsumerState<GuardianMainPage> {
  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);

    final formattedDate = DateFormat('yyyy.MM.dd EEEE', 'ko_KR')
        .format(selectedDay ?? DateTime.now());

    // ✅ 급식 날짜키
    final lunchDateKey =
        DateFormat('yyyy-MM-dd').format(selectedDay ?? DateTime.now());

    final guardianAsync = ref.watch(guardianNotifierProvider);
    final timetableAsync = ref.watch(timetableListProvider);

    return guardianAsync.when(
      data: (guardians) {
        // ✅ 빈 리스트 방어(안 하면 Bad state: No element 터짐)
        if (guardians.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('보호자 정보 없음')),
          );
        }

        final g = guardians.first;

        return Scaffold(
          backgroundColor: Acolor.baseBackgroundColor,
          appBar: AppBar(
            title:Image.asset('images/atti_logo.png',width: 70,),
            centerTitle: true,
            backgroundColor: Acolor.primaryColor,
            foregroundColor: Acolor.onPrimaryColor,
          ),

          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(g.guardian_name),
                  accountEmail: Text(g.guardian_email ?? ""),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40),
                  ),
                  decoration: BoxDecoration(color: Acolor.primaryColor),
                ),

                _drawerItem(Icons.person, "비밀번호 수정"),
                _drawerItem(Icons.notifications, "학생 출결조회",
                  onTap: () {
                     Navigator.pop(context); // drawer 닫기
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) =>  AttendanceDetailPage()),
                    );
                  },
                
                ),
                _drawerItem(
                        Icons.question_answer,
                                  "선생님한테 문의하기",
                                      onTap: () {
                                    Navigator.pop(context); // drawer 닫기
                                    Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => GuardianChatting()),
                                    );
                               },
                                    ),


                // ✅ 공지조회 -> NoticeTabbar로 이동
                _drawerItem(
                  Icons.announcement,
                  "공지조회",
                  onTap: () {
                    Navigator.pop(context); // drawer 닫기
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NoticeTabbar()),
                    );
                  },
                ),

                const Divider(),
                _drawerItem(
  Icons.logout,
  "로그아웃",
  color: Colors.red,
  onTap: () async {
    final box = GetStorage();

    await box.remove('student_id');
    await box.remove('guardian_id'); // 저장 안하면 없어도 됨
    await box.save();

    ref.invalidate(guardianNotifierProvider);
    ref.invalidate(timetableListProvider);
    ref.invalidate(scheduleMapProvider);
    ref.invalidate(lastLunchCacheProvider);

    if (!context.mounted) return;

    Navigator.pop(context); // drawer 닫기

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const GuardianLogin()),
      (route) => false,
    );
  },
),

              ],
            ),
          ),

          body: timetableAsync.when(
            data: (timetables) {
              // 기존 로직 유지: 1-1반 시간표 찾기(없으면 기본값)
              final timetable = timetables.firstWhere(
                (t) => t.timetable_grade == 1 && t.timetable_class == 1,
                orElse: () => Timetable(
                  timetable_id: '',
                  timetable_table: {},
                  timetable_semester: '2026-1',
                  timetable_period: 6,
                  timetable_grade: 1,
                  timetable_class: 1,
                ),
              );

              return ListView(
                children: [
                  _guardianCard(g.guardian_name),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "오늘일정 $formattedDate",
                      textAlign: TextAlign.center,
                    ),
                  ),

                  _buildCalendar(ref, selectedDay, focusedDay),
                  _buildScheduleList(ref),
                  _buildLocationButton(),

                  _buildTimeTable(timetable),

                  /// ✅ 급식(선생님 메인과 동일 방식으로 연결)
                  _MealSection(dateKey: lunchDateKey),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("시간표 로드 오류: $e")),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("오류: $e")),
    );
  }

  /// ✅ onTap 추가 버전 (기본은 drawer 닫기)
  Widget _drawerItem(
    IconData icon,
    String title, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(title, style: TextStyle(color: color ?? Colors.black87)),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }

  Widget _guardianCard(String name) {
    return Center(
      child: Container(
        width: 320,
        height: 200,
        margin: const EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Acolor.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 50),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("두식초등학교"),
                      const Text("1학년 1반 OOO학생 보호자"),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(
      WidgetRef ref, DateTime? selectedDay, DateTime focusedDay) {
    final scheduleMap = ref.watch(scheduleMapProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Acolor.appBarBackgroundColor, blurRadius: 1)
        ],
      ),
      child: TableCalendar(
        locale: 'ko_KR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (newSelectedDay, newFocusedDay) {
          ref.read(selectedDayProvider.notifier).state = newSelectedDay;
          ref.read(focusedDayProvider.notifier).state = newFocusedDay;
        },
        eventLoader: (day) {
          final key = DateTime(day.year, day.month, day.day);
          return scheduleMap[key] ?? [];
        },
        headerStyle:
            const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        calendarStyle: CalendarStyle(
          todayDecoration:
              BoxDecoration(color: Acolor.primaryColor, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(
              color: Acolor.successBackColor, shape: BoxShape.circle),
          markerDecoration: const BoxDecoration(
              color: Colors.redAccent, shape: BoxShape.circle),
        ),
      ),
    );
  }

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
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "오늘은 등록된 일정이 없습니다",
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: todaySchedules.map((Schedule s) {
        final timeStr = DateFormat('HH:mm').format(s.schedule_startdate);
        return ListTile(
          leading: const Icon(Icons.event),
          title: Text(s.schedule_title),
          subtitle: Text("$timeStr - ${s.schedule_contents}"),
        );
      }).toList(),
    );
  }

  Widget _buildLocationButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Acolor.errorBackgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.emergency_share_rounded),
            SizedBox(width: 8),
            Text("학생 위치 찾기"),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTable(Timetable timetable) {
    final Map<String, List<String>> table = timetable.timetable_table;
    const days = ['월', '화', '수', '목', '금'];
    final maxPeriod = timetable.timetable_period;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        border: TableBorder.all(color: Colors.grey),
        columnWidths: const {0: FixedColumnWidth(60)},
        children: [
          TableRow(
            children: [
              _cell(''),
              ...days.map((d) => _cell(d, isHeader: true)).toList(),
            ],
          ),
          for (int i = 0; i < maxPeriod; i++)
            TableRow(
              children: [
                _cell('${i + 1}교시', isHeader: true),
                ...days.map((day) {
                  final subjects = table[day] ?? [];
                  return _cell(i < subjects.length ? subjects[i] : '');
                }).toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cell(String text, {bool isHeader = false}) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      color: isHeader ? Colors.blue.shade50 : null,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

/// =======================================================
/// ✅ 급식 섹션: dateKey로 조회 + 캐시 유지 + 얇은 로딩바
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
        _buildMealGrid(context, menus),
        if (showTopLoadingBar)
          const Positioned(
            left: 20,
            right: 20,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  Widget _buildMealGrid(BuildContext context, List<LunchMenu> menus) {
    if (menus.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('급식 정보 없음')),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menus.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 130,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final menu = menus[index];
          return Container(
            decoration: BoxDecoration(
              color: Acolor.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    menu.lunch_menu_image,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  menu.lunch_menu_name,
                  style: TextStyle(
                    color: Acolor.onPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
