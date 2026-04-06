/* 
Description : Homework 수정 페이지
Date : 2026-1-21
Author : 황민욱
*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:teacher/util/message.dart';
import 'package:teacher/vm/minwook/homework_provider.dart';
import 'package:teacher/vm/minwook/image_provider.dart';
import 'package:teacher/vm/minwook/edit_state.dart';

final homeworkSubjectProvider = StateProvider.autoDispose.family<String, String>((ref, homeworkId) => '국어');

class UpdateHomework extends ConsumerStatefulWidget {
  final String homeworkId;
  const UpdateHomework({super.key, required this.homeworkId});

  @override
  ConsumerState<UpdateHomework> createState() => _UpdateHomeworkState();
}

class _UpdateHomeworkState extends ConsumerState<UpdateHomework> {
  static const List<String> _subjects = [
    '국어','수학','영어','사회','과학','체육','미술','음악','창체','도덕','기타'
  ];

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
    final homeworkAsync = ref.watch(homeworkDetailProvider(widget.homeworkId));
    final homeworkAction = ref.read(homeworkActionProvider.notifier);

    final imgState = ref.watch(imageNotifierProvider);
    final imgAction = ref.read(imageNotifierProvider.notifier);

    final editState = ref.watch(editProvider(widget.homeworkId));
    final editAction = ref.read(editProvider(widget.homeworkId).notifier);

    final selectedSubject = ref.watch(homeworkSubjectProvider(widget.homeworkId));

    return Scaffold(
      appBar: AppBar(title: const Text('숙제 수정'), centerTitle: true),
      body: homeworkAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (homework) {
          if (homework == null) return const Center(child: Text('존재하지 않는 숙제임'));

          if (!editState.initialized) {
            titleController.text = homework.homework_title;
            contentController.text = homework.homework_contents;

            final initialSubject = _subjects.contains(homework.homework_subject)
                ? homework.homework_subject
                : '기타';

            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(homeworkSubjectProvider(widget.homeworkId).notifier).state = initialSubject;
              editAction.initOnce(homework.homework_images);
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: DropdownButtonFormField<String>(
                    value: selectedSubject,
                    decoration: const InputDecoration(
                      labelText: '과목',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _subjects
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      ref.read(homeworkSubjectProvider(widget.homeworkId).notifier).state = v;
                    },
                  ),
                ),
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
                      if (titleController.text.trim().isEmpty ||
                          contentController.text.trim().isEmpty) {
                        Message.snackBar(context, '내용을 입력하세요!', 1, Colors.red);
                        return;
                      }

                      try {
                        final teacherId = homework.teacher_id;

                        final newFiles = imgState.files.map((x) => File(x.path)).toList();
                        final newUrls = newFiles.isEmpty
                            ? <String>[]
                            : await homeworkAction.uploadHomeworkImages(
                                files: newFiles,
                                teacherId: teacherId,
                              );

                        final mergedUrls = <String>[...editState.existingUrls, ...newUrls];

                        await homeworkAction.updateHomework(
                          id: widget.homeworkId,
                          data: {
                            'homework_title': titleController.text.trim(),
                            'homework_contents': contentController.text.trim(),
                            'homework_subject': ref.read(homeworkSubjectProvider(widget.homeworkId)),
                            'homework_images': mergedUrls,
                            'homework_updatedate': DateTime.now(),
                          },
                        );

                        if (editState.removedUrls.isNotEmpty) {
                          await homeworkAction.deleteStorageFilesByUrls(editState.removedUrls);
                          editAction.clearRemoved();
                        }

                        if (!context.mounted) return;
                        imgAction.clear();
                        Message.snackBar(context, '숙제가 수정되었습니다.', 1, Colors.blue);
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

  // Widgets ===========================
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