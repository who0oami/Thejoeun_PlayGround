/* 
Description : Notice 입력 페이지
Date : 2026-1-19
Author : 황민욱
*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/model/notice.dart';
import 'package:teacher/util/message.dart';
import 'package:teacher/vm/minwook/image_provider.dart';
import 'package:teacher/vm/minwook/notice_provider.dart';

class InsertNotice extends ConsumerStatefulWidget {
  const InsertNotice({super.key});

  @override
  ConsumerState<InsertNotice> createState() => _InsertNoticeState();
}

class _InsertNoticeState extends ConsumerState<InsertNotice> {

  late final TextEditingController titleController;
  late final TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    contentController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noticeAction = ref.read(noticeActionProvider.notifier);
    final imgState = ref.watch(imageNotifierProvider);
    final imgAction = ref.read(imageNotifierProvider.notifier); 
    
    return Scaffold(
      appBar: AppBar(title: Text('공지 입력'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField('제목을 입력하세요.', titleController),
            _buildTextField('내용을 입력하세요.', contentController),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await imgAction.pickImagesFromGallery();
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('이미지 추가'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text('선택: ${imgState.files.length}장'),
                  ),
                ],
              ),
            ),
            if (imgState.files.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: imgState.files.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final x = imgState.files[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(x.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: InkWell(
                            onTap: () => imgAction.removeAt(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
                  Message.snackBar(context, '내용을 입력하세요!', 1, Colors.red);
                  return;
                }
              
                try {
                  final teacherId = 1;
              
                  final files = imgState.files.map((x) => File(x.path)).toList();
                  final urls = files.isEmpty
                      ? <String>[]
                      : await noticeAction.uploadNoticeImages(files: files, teacherId: teacherId);
              
                  final notice = Notice(
                    teacher_id: teacherId,
                    notice_title: titleController.text,
                    notice_content: contentController.text,
                    notice_insertdate: DateTime.now(),
                    notice_images: urls,
                  );
              
                  await noticeAction.addNotice(notice);
              
                  if (!context.mounted) return;
                  imgAction.clear();
                  Message.snackBar(context, '공지가 등록되었습니다.', 1, Colors.blue);
                  Navigator.pop(context);
                } catch (e) {
                  if (!context.mounted) return;
                  Message.snackBar(context, '등록 실패: $e', 1, const Color.fromARGB(255, 39, 19, 17));
                }
              },
                child: const Text('입력'),
              ),
            ),
          ],
        ),
      ),
    );
  } // build

  // --- Widgets
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

} // class