/* 
Description : notice_insertpage
Date : 2026-1-22
Author : 정시온
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian/model/notice.dart';
import 'package:guardian/model/teacher.dart';
import 'package:guardian/util/acolor.dart';
import 'package:intl/intl.dart';
 // 선생님 모델 임포트

class NoticeInsertpage extends ConsumerStatefulWidget {
  final Notice notice;
  final Teacher teacher;

  const NoticeInsertpage({
    super.key, 
    required this.notice, 
    required this.teacher 
  });

  @override
  ConsumerState<NoticeInsertpage> createState() => _NoticeInsertState();
}

class _NoticeInsertState extends ConsumerState<NoticeInsertpage> {
  @override
  Widget build(BuildContext context) {
    final notice = widget.notice;
    final teacher = widget.teacher; 

    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("공지사항", style: TextStyle(fontWeight: FontWeight.bold)
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
                        radius: 22, // 조금 더 키웠어요
                        backgroundImage: NetworkImage(
                          "http://192.168.10.107:8000/minjae/view/${teacher.teacher_id}",
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
                              DateFormat('yyyy년 MM월 dd일 HH:mm').format(notice.notice_insertdate),
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
                    notice.notice_title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

// 💡 3. 이미지 리스트 (아래로 계속 내려오는 방식)
                  if (notice.notice_images.isNotEmpty)
                    Column(
                      children: notice.notice_images.map((imageUrl) {
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
                    notice.notice_content,
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