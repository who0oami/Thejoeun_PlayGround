/* 
Description : schedule page - 색깔 바꿈!
Date : 2026-1-22
Author : 정시온
*/

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian/model/timetable.dart';
import 'package:guardian/vm/timetable_riverpod.dart';


class TimetablePage extends ConsumerStatefulWidget {
  const TimetablePage({super.key});

  @override
  ConsumerState<TimetablePage> createState() => _TimetableState();
}

class _TimetableState extends ConsumerState<TimetablePage> {
  @override
  Widget build(BuildContext context) {
    final timetableAsync = ref.watch(timetableListProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // 밝은 회색 배경으로 카드 부각
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimetableSection(timetableAsync),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableSection(AsyncValue<List<Timetable>> timetableAsync) {
    return timetableAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('로드 오류: $err')),
      data: (timetables) {
        if (timetables.isEmpty) return const Center(child: Text('데이터가 없습니다.'));
        
        final timetable = timetables.firstWhere(
          (t) => t.timetable_grade == 1 && t.timetable_class == 1,
          orElse: () => timetables.first,
        );
        return Column(
          children: [
            _buildHeader(timetable),
            _buildTimetableCard(timetable),
          ],
        );
      },
    );
  }

  // 상단 제목 섹션
  Widget _buildHeader(Timetable t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
      child: Row(
        children: [
          const Text("나의 시간표", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("${t.timetable_grade}학년 ${t.timetable_class}반", 
              style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // 메인 시간표 카드
  Widget _buildTimetableCard(Timetable timetable) {
    const days = ['월', '화', '수', '목', '금'];
    final Map<String, List<String>> table = timetable.timetable_table;
    final int maxPeriod = timetable.timetable_period > 0 ? timetable.timetable_period : 6;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Table(
          columnWidths: const {0: FixedColumnWidth(50)},
          children: [
            // 요일 헤더
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade50),
              children: [
                _cell(''),
                ...days.map((d) => _cell(d, isHeader: true)),
              ],
            ),
            // 교시별 행
            for (int i = 0; i < maxPeriod; i++)
              TableRow(
                children: [
                  _cell('${i + 1}', isPeriod: true),
                  ...days.map((day) {
                    final subjects = table[day] ?? [];
                    final subject = (i < subjects.length) ? subjects[i] : '';
                    return _cell(subject);
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text, {bool isHeader = false, bool isPeriod = false}) {
    // 과목에 따른 배경색 지정 (예시)
    Color? bgColor;
    if (!isHeader && !isPeriod && text.isNotEmpty) {
      if (text.contains('국어')) bgColor = const Color(0xFFFFE0E0);
      else if (text.contains('수학')) bgColor = const Color(0xFFE0F0FF);
      else if(text.contains('사회')) bgColor =  const Color.fromARGB(255, 255, 255, 205);
      else if(text.contains('과학')) bgColor =  const Color.fromARGB(255, 211, 249, 255);
      else if(text.contains('체육')) bgColor =  const Color.fromARGB(255, 251, 238, 255);
      else if(text.contains('미술')) bgColor =  const Color.fromARGB(255, 211, 255, 248);
      else if(text.contains('영어')) bgColor =  const Color.fromARGB(255, 255, 242, 224);
      else if(text.contains('음악')) bgColor =  const Color.fromARGB(255, 227, 243, 255);
      else if(text.contains('도덕')) bgColor =  const Color.fromARGB(255, 211, 255, 248);

      else bgColor = const Color(0xFFF0F0F0);
    }

    return Container(
      height: 60, // 셀 높이를 조금 높여서 시원하게
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isHeader ? 14 : 13,
          fontWeight: isHeader || isPeriod ? FontWeight.bold : FontWeight.normal,
          color: isPeriod ? Colors.grey : Colors.black87,
        ),
      ),
    );
  }
}