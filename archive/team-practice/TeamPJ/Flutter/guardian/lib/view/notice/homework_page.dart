/* 
Description : homework page - insert 들어가게 함!
Date : 2026-1-19
Author : 정시온
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian/util/acolor.dart';
import 'package:guardian/view/notice/homework_insertpage.dart';
import 'package:guardian/vm/sion/homework_provider.dart';
import 'package:guardian/vm/sion/teacher_riverpod.dart';
import 'package:intl/intl.dart';


class HomeworkPage extends ConsumerStatefulWidget {
  const HomeworkPage({super.key});

   @override
  ConsumerState<HomeworkPage> createState() => _HomeworkState();
}

class _HomeworkState extends ConsumerState<HomeworkPage> {
  @override
  Widget build(BuildContext context) {
    final homeworkAsync = ref.watch(homeworkListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: homeworkAsync.when(
        data: (homeworkList) {
          if (homeworkList.isEmpty) return const Center(child: Text('숙제가 없습니다.'));

          return ListView.builder(
            itemCount: homeworkList.length + 1,
            itemBuilder: (context, index) {
              if (index == homeworkList.length) return _buildFooter();

              final homework = homeworkList[index];
              return _buildNoticeCard(homework, ref);
            },
          );
        },
        error: (error, stack) => Center(child: Text('Error: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildNoticeCard(homework, WidgetRef ref) {
    final teacherAsync = ref.watch(teacherNotifierProvider);

    return teacherAsync.when(
      data: (teachers) {
        final teacherMap = {
          for (var t in teachers) t.teacher_id.toString(): t
        };

        final selectedTeacher = teacherMap[homework.teacher_id.toString()] 
                               ?? (teachers.isNotEmpty ? teachers.first : null);

        if (selectedTeacher == null) {
          return const SizedBox(height: 100, child: Center(child: Text('선생님 정보없음')));
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => HomeworkInsertpage(homework: homework, teacher: selectedTeacher),));
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
                          DateFormat('yy.MM.dd E요일', 'ko_KR').format(homework.homework_insertdate),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildSubjectTag(homework.homework_subject),
                    const SizedBox(width: 12),
                    Text(
                      homework.homework_title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  homework.homework_contents,
                  style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                ),
                const SizedBox(height: 20),
                ImageSlider(images: homework.homework_images),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => const Text("선생님 정보를 불러올 수 없습니다."),
    );
  }

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

// 과목 버튼 위젯
Widget _buildSubjectTag(String subject) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 안쪽 여백
    decoration: BoxDecoration(
      color: Acolor.primaryColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      subject,
      style: const TextStyle(
        color: Colors.white, // 글자색 흰색
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
  );
}


class ImageSlider extends StatefulWidget {
  final List<String> images;

  const ImageSlider({super.key, required this.images});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _currentPage = 0; // 현재 보고 있는 페이지 번호

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. 이미지 슬라이더
          PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page; // 페이지 바뀔 때마다 상태 업데이트
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              );
            },
          ),
            
          // 2. 동적 인디케이터 (색상 변경 적용)
          Positioned(
            bottom: 15, // 위치를 살짝 위로 올림
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300), // 부드러운 전환 효과
                  width: _currentPage == index ? 12 : 8, // 선택된 점은 더 크게
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    // 선택된 점은 진한 색, 나머지는 반투명한 회색
                    color: _currentPage == index 
                        ? Acolor.successBackColor
                        : Colors.black26, 
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}


