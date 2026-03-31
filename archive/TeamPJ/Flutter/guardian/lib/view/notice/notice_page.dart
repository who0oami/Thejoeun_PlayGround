/* 
Description : notice page - insert 들어가게 함!
Date : 2026-1-22
Author : 정시온
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian/view/notice/homework_page.dart';
import 'package:guardian/view/notice/notice_insertpage.dart';
import 'package:guardian/vm/sion/notice_provider.dart';
import 'package:guardian/vm/sion/teacher_riverpod.dart';
import 'package:intl/intl.dart';


class NoticePage extends ConsumerStatefulWidget {
  const NoticePage({super.key});

  @override
  ConsumerState<NoticePage> createState() => _NoticeState();
}



class _NoticeState extends ConsumerState<NoticePage> {
  @override
  Widget build(BuildContext context) {
    final noticeAsync = ref.watch(noticeListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: noticeAsync.when(
        data: (noticeList) {
          if (noticeList.isEmpty) return const Center(child: Text('공지사항이 없습니다.'));
          return ListView.builder(
            itemCount: noticeList.length + 1,
            itemBuilder: (context, index) {
              if (index == noticeList.length) return _buildFooter();
              return _buildNoticeCard(noticeList[index], ref);
            },
          );
        },
        error: (error, stack) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildNoticeCard(notices, WidgetRef ref) {
    final teacherAsync = ref.watch(teacherNotifierProvider);

    return teacherAsync.when(
  data: (teachers) {
    final teacherMap = {
      for (var t in teachers) t.teacher_id.toString(): t
    };

    final selectedTeacher = teacherMap[notices.teacher_id.toString()] 
                            ?? (teachers.isNotEmpty ? teachers.first : null);

    if (selectedTeacher == null) {
      return const SizedBox(height: 100, child: Center(child: Text("선생님 정보 없음")));
    }

    return InkWell(
      onTap: () {
        Navigator.push(context, 
        MaterialPageRoute(
                builder: (context) => NoticeInsertpage(notice: notices, teacher: selectedTeacher, 
              ),));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    "http://192.168.10.107:8000/minjae/view/${selectedTeacher.teacher_id}",
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${selectedTeacher.teacher_name} 선생님",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      DateFormat('yy.MM.dd E요일', 'ko_KR').format(notices.notice_insertdate),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              notices.notice_title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              notices.notice_content,
              style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 12),
            ImageSlider(images: notices.notice_images),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  },
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (error, stack) => const Text("데이터를 불러올 수 없습니다."),
);
  }

  // 하단 안내 문구 위젯
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: const [
          Icon(Icons.check_circle_outline, color: Colors.grey, size: 30),
          SizedBox(height: 8),
          Text(
            "최근 공지사항을 모두 조회했습니다.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}