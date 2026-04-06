/* 
Description : Notice 수정 페이지
Date : 2026-1-19
Author : 황민욱
*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/util/message.dart';
import 'package:teacher/vm/minwook/edit_state.dart';
import 'package:teacher/vm/minwook/image_provider.dart';
import 'package:teacher/vm/minwook/notice_provider.dart';

class UpdateNotice extends ConsumerStatefulWidget {
  final String noticeId;

  const UpdateNotice({super.key, required this.noticeId});

  @override
  ConsumerState<UpdateNotice> createState() => _UpdateNoticeState();
}

class _UpdateNoticeState extends ConsumerState<UpdateNotice> {
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
    final noticeAsync = ref.watch(noticeDetailProvider(widget.noticeId));
    final noticeAction = ref.read(noticeActionProvider.notifier);

    final imgState = ref.watch(imageNotifierProvider);
    final imgAction = ref.read(imageNotifierProvider.notifier);

    final editState = ref.watch(editProvider(widget.noticeId));
    final editAction = ref.read(editProvider(widget.noticeId).notifier);


    return Scaffold(
      appBar: AppBar(title: const Text('공지 수정'), centerTitle: true),
      body: noticeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notice) {
          if (notice == null) return const Center(child: Text('존재하지 않는 공지임'));

          if (!editState.initialized) {
            titleController.text = notice.notice_title;
            contentController.text = notice.notice_content;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              editAction.initOnce(notice.notice_images);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTextField('제목을 입력하세요.', titleController),
                _buildTextField('내용을 입력하세요.', contentController),

                if (editState.existingUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: editState.existingUrls.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        final url = editState.existingUrls[index];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.black12,
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: InkWell(
                                onTap: () => editAction.removeExistingAt(index),
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
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async => imgAction.pickImagesFromGallery(),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('이미지 추가'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text('새로 선택: ${imgState.files.length}장'),
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
                        final teacherId = notice.teacher_id;

                        final newFiles = imgState.files.map((x) => File(x.path)).toList();
                        final newUrls = newFiles.isEmpty
                            ? <String>[]
                            : await noticeAction.uploadNoticeImages(files: newFiles, teacherId: teacherId);

                        final mergedUrls = <String>[...editState.existingUrls, ...newUrls];

                        await noticeAction.updateNotice(
                          id: widget.noticeId,
                          data: {
                            'notice_title': titleController.text.trim(),
                            'notice_content': contentController.text.trim(),
                            'notice_images': mergedUrls,
                            'notice_updatedate': DateTime.now(),
                          },
                        );

                        if (editState.removedUrls.isNotEmpty) {
                          await noticeAction.deleteStorageFilesByUrls(editState.removedUrls);
                          editAction.clearRemoved();
                        }

                        if (!context.mounted) return;
                        imgAction.clear();
                        Message.snackBar(context, '공지가 수정되었습니다.', 1, Colors.blue);
                        Navigator.pop(context);
                      } catch (e) {
                        if (!context.mounted) return;
                        Message.snackBar(context, '수정 실패: $e', 1, const Color.fromARGB(255, 39, 19, 17));
                      }
                    },
                    child: const Text('수정'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  } // build

  // Widgets ===============================
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }
} // class