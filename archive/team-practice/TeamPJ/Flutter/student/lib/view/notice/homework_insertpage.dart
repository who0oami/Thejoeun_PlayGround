/* 
Description : homework insertpage
Date : 2026-1-22
Author : 정시온
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:student/model/homework.dart';
import 'package:student/model/teacher.dart';
import 'package:student/util/acolor.dart';

class HomeworkInsertpage extends ConsumerStatefulWidget {
  final Homework homework;
  final Teacher teacher;
  

  const HomeworkInsertpage({
    super.key, 
    required this.homework, 
    required this.teacher 
  });

  @override
  ConsumerState<HomeworkInsertpage> createState() => _HomeworkInsertState();
}

class _HomeworkInsertState extends ConsumerState<HomeworkInsertpage>{

  @override
  Widget build(BuildContext context) {
    final homework = widget.homework;
    final teacher = widget.teacher;

    double screenHeight = MediaQuery.of(context).size.height;

  return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("숙제", style: TextStyle(fontWeight: FontWeight.bold)
        ),
        centerTitle:true,
        backgroundColor: Acolor.primaryColor,
        foregroundColor: Acolor.onPrimaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: screenHeight * 0.7,
              ),
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: NetworkImage(
                          "http://10.0.2.2:8000/minjae/view/${teacher.teacher_id}",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 💡 전달받은 teacher 객체의 이름을 사용합니다.
                            Text(
                              "${teacher.teacher_name} 선생님", 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                            ),
                            Text(
                              DateFormat('yyyy년 MM월 dd일 HH:mm').format(homework.homework_insertdate),
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  
                  // 공지 제목
                  Text(
                    homework.homework_title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

// 💡 3. 이미지 리스트 (아래로 계속 내려오는 방식)
                  if (homework.homework_images.isNotEmpty)
                    Column(
                      children: homework.homework_images.map((imageUrl) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0), // 이미지 사이 간격
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12), // 이미지 모서리 둥글게
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              // 이미지 로딩 중 에러 처리
                              errorBuilder: (context, error, stackTrace) => 
                                const SizedBox.shrink(), 
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  
                  const SizedBox(height: 20),

                  // 공지 내용
                  Text(
                    homework.homework_contents,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // SNS 아이콘 바
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        Icon(Icons.favorite_border, color: Acolor.primaryColor),
                        const SizedBox(width: 16),
                        const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                        const SizedBox(width: 16),
                        const Icon(Icons.send_outlined, color: Colors.grey),
                        const Spacer(),
                        const Icon(Icons.bookmark_border, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}