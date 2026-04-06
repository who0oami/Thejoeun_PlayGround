/* 
Description : 메인 페이지 구성 및 데이터 연동
  - 학생 프로필/드로워 UI 구성 및 로그아웃 동작 추가
  - 캘린더/일정/시간표/급식 위젯 구성
  - 출석 체크 팝업 및 긴급 호출 버튼 구성
  - GetStorage 기반 학생 ID 연동
Date : 2026-1-22
Author : 이상현
*/

/*
Description : 화면구성 작업
1. 학생 데이터만 연결해서 로그인 한 학생 데이터 임시로 1번으로 지정 해서 작업
2. 모든 파일 위젯으로 작업진행

Date : 2026-01-19
Author : 이상현

Description : 
  Weather, Calender widget implemented
  Attand system added
  Changed Consumer > CunsomerStateWidget

Date : 2026-01-20
Author : Chansol, Park
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:student/view/emergency.dart';
import 'package:student/view/restitutor/attend_student.dart';
import 'package:student/view/restitutor/weather/weather.dart';
import 'package:student/vm/restitutor/attendance_provider.dart';
import 'package:student/vm/sanghyun/meal_provider.dart';
import 'package:student/vm/sanghyun/student_provider.dart';
import 'package:student/view/login.dart';
import 'package:student/vm/sanghyun/lunch_by_date_provider.dart';
import 'package:student/view/minjae/attendance_detail.dart';
import 'package:student/view/notice/notice_tabbar.dart';
// [Codex] Use student Firebase providers for timetable/lunch/schedule data.
import 'package:student/vm/sion/schedule_provider.dart';
import 'package:student/vm/sion/timetable_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../util/acolor.dart';
// [Codex] Models used by Firebase-backed UI sections.
import '../model/lunch_menu.dart';
import '../model/schedule.dart';
import '../model/student.dart';
import '../model/timetable.dart';

// 캘린더 관리 위해서 필요한 프로바이더
final selectedDayProvider = StateProvider<DateTime?>((ref) => DateTime.now());
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

// [Codex] Normalize calendar dates for schedule lookup.
DateTime _onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

int _readStudentId() {
  final box = GetStorage();
  dynamic raw = box.read('p_userid');
  if (raw is String && raw.isEmpty) {
    raw = null;
  }
  raw ??= box.read('student_id');
  if (raw is String && raw.isEmpty) {
    raw = null;
  }
  debugPrint('GetStorage student id raw: $raw');
  if (raw is int) return raw;
  if (raw is String) return int.tryParse(raw) ?? 1;
  return 1;
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);
    final scheduleMap = ref.watch(scheduleMapProvider);
    final studentId = _readStudentId();
    final studentAsync = ref.watch(studentFutureProvider(studentId));
    final attendAsync = ref.watch(attendProvider);
    final timetableAsync = ref.watch(timetableListProvider);
    final lunchmenuAsync =
        ref.watch(lunchMenusByDateProvider(selectedDay ?? DateTime.now()));

    String formattedDate = DateFormat(
      'yyyy.MM.dd EEEE',
      'ko_KR',
    ).format(selectedDay ?? DateTime.now());
    final todayKey = _onlyDate(selectedDay ?? DateTime.now());
    final todaySchedules = scheduleMap[todayKey] ?? const <Schedule>[];
    final headerMessage = todaySchedules.isNotEmpty
        ? todaySchedules.first.schedule_title
        : "오늘 일정 없음";

    return Scaffold(
      appBar: AppBar(
        title: Image.asset('images/atti_logo.png',width: 70,),
        centerTitle: true,
        backgroundColor: Acolor.primaryColor,
        foregroundColor: Acolor.onPrimaryColor,
      ),
      drawer: _buildStudentDrawer(studentAsync),
      backgroundColor: Acolor.onPrimaryColor,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            AnimatedColorButton(
              height: 90,
              childWidget: Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 68),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildDateHeader(formattedDate, headerMessage),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildProfileCard(studentAsync),
            const SizedBox(height: 6),
            _buildSectionTitle("오늘 일정"),
            _buildCalendar(ref, selectedDay, focusedDay),
            const SizedBox(height: 8),
            _buildSectionTitle("시간표"),
            _buildTimetableSection(timetableAsync),
            const SizedBox(height: 8),
            _buildSectionTitle(
              '${DateFormat('M월 d일', 'ko_KR').format(selectedDay ?? DateTime.now())} 식단',
            ),
            _buildMealSection(lunchmenuAsync),
            const SizedBox(height: 100),
            AttendancePopupGate(attendAsync: attendAsync),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildEmergencyButton(),
    );
  }

  // --- UI 구성 위젯들 ---

  // 학생 정보 드로워 UI.
  Widget _buildStudentDrawer(AsyncValue<Student> studentAsync) {
    return Drawer(
      child: SafeArea(
        child: studentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('에러 발생: $err')),
          data: (student) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Acolor.successTextColor,
                      backgroundImage: MemoryImage(student.student_image),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.student_name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          student.student_phone,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('출결 내역'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendanceDetailPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.view_agenda),
                  title: const Text('통합 보기'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NoticeTabbar(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('설정'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('로그아웃'),
                  onTap: () async {
                    final box = GetStorage();
                    await box.erase();
                    ref.invalidate(studentFutureProvider);
                    ref.invalidate(attendProvider);
                    ref.invalidate(timetableListProvider);
                    ref.invalidate(lunchmenuListProvider);
                    ref.invalidate(scheduleMapProvider);
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 날짜/오늘 일정 텍스트 UI.
  Widget _buildDateHeader(String date, String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(date, style: const TextStyle(color: Colors.grey)),
        Text(
          message,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // 학생 프로필 카드 UI.
  Widget _buildProfileCard(AsyncValue<Student> studentAsync) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Acolor.appBarBackgroundColor, blurRadius: 1),
          ],
        ),
        child: studentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('에러 발생: $err')),
          data: (student) => Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Acolor.successTextColor,
                    backgroundImage: MemoryImage(student.student_image),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "학생 정보",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        student.student_name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AttendStudent()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Acolor.successBackColor,
                    shape: const StadiumBorder(),
                  ),
                  child: Text(
                    "학교왔어요 😊",
                    style: TextStyle(
                      color: Acolor.successTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 섹션 타이틀 공통 UI.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Acolor.appBarBackgroundColor,
          ),
        ),
      ),
    ); //뷁
  }

  // 일정 표시 캘린더 UI.
  Widget _buildCalendar(
    WidgetRef ref,
    DateTime? selectedDay,
    DateTime focusedDay,
  ) {
    // [Codex] Calendar with schedule markers.
    final scheduleMap = ref.watch(scheduleMapProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Acolor.appBarBackgroundColor, blurRadius: 2),
        ],
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
  }

  // 시간표 섹션 로딩/에러/데이터 분기 UI.
  Widget _buildTimetableSection(AsyncValue<List<Timetable>> timetableAsync) {
    return timetableAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text('시간표 로드 오류: $err'),
      ),
      data: (timetables) {
        if (timetables.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('등록된 시간표가 없습니다.'),
          );
        }
        final timetable = timetables.firstWhere(
          (t) => t.timetable_grade == 1 && t.timetable_class == 1,
          orElse: () => timetables.first,
        );
        return _buildTimetable(timetable);
      },
    );
  }

  // [Codex] Render Firestore timetable model.
  // 시간표 테이블 UI.
  Widget _buildTimetable(Timetable timetable) {
    final Map<String, List<String>> table = timetable.timetable_table;
    const days = ['월', '화', '수', '목', '금'];
    final int maxPeriod = timetable.timetable_period > 0
        ? timetable.timetable_period
        : 6;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Acolor.appBarBackgroundColor, blurRadius: 1),
        ],
      ),
      child: Table(
        border: TableBorder.all(color: Colors.grey),
        columnWidths: const {0: FixedColumnWidth(60)},
        children: [
          TableRow(
            children: [_cell(''), ...days.map((d) => _cell(d)).toList()],
          ),
          for (int i = 0; i < maxPeriod; i++)
            TableRow(
              children: [
                _cell('${i + 1}교시', isHeader: true),
                ...days.map((day) {
                  final subjects = table[day] ?? const <String>[];
                  return _cell(i < subjects.length ? subjects[i] : '');
                }).toList(),
              ],
            ),
        ],
      ),
    );
  }

  // 시간표 셀 UI.
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

  // 급식 섹션 로딩/에러/데이터 분기 UI.
  Widget _buildMealSection(AsyncValue<List<LunchMenu>> lunchAsync) {
    return lunchAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text('급식 데이터 오류: $err'),
      ),
      data: (menus) {
        if (menus.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('오늘 급식이 없습니다.'),
          );
        }
        return _buildMealGrid(menus);
      },
    );
  }

  // [Codex] Render lunch menu grid from Firestore data.
  // 급식 카드 그리드 UI.
  Widget _buildMealGrid(List<LunchMenu> menus) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Acolor.appBarBackgroundColor, blurRadius: 1),
        ],
      ),
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
                    errorBuilder: (context, error, stack) {
                      return const Icon(
                        Icons.restaurant,
                        size: 48,
                        color: Colors.white,
                      );
                    },
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

  // 긴급 호출 버튼 UI.
  Widget _buildEmergencyButton() {
    // 긴급호출 버튼 위젯
    return SizedBox(
      width: 100,
      height: 100,
      child: FloatingActionButton(
        elevation: 8,
        backgroundColor: Acolor.errorBackgroundColor,
        foregroundColor: Acolor.onPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white, width: 4),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Emergency()));
        },
        child: const Text(
          '긴급\n호출',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class AttendancePopupGate extends ConsumerStatefulWidget {
  final AsyncValue<bool> attendAsync;
  const AttendancePopupGate({super.key, required this.attendAsync});

  @override
  ConsumerState<AttendancePopupGate> createState() =>
      _AttendancePopupGateState();
}

class _AttendancePopupGateState extends ConsumerState<AttendancePopupGate> {
  bool _opened = false;

  @override
  Widget build(BuildContext context) {
    widget.attendAsync.whenData((checked) {
      if (!checked && !_opened) {
        _opened = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            isDismissible: false,
            enableDrag: false,
            builder: (context) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "출석 체크",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text("오늘 출석체크가 필요해요!"),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AttendStudent(),));
                          },
                          child: const Text("학교왔어요 😊"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        });
      }
    });

    return const SizedBox.shrink(); // 화면에 표시 X
  }
}
