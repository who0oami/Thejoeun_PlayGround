/* 
Description : Homework 상세 페이지
Date : 2026-1-20
Author : 황민욱
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/util/acolor.dart';
import 'package:teacher/util/message.dart';
import 'package:teacher/view/minwook/update_homework.dart';
import 'package:teacher/vm/minwook/homework_provider.dart';
import 'package:teacher/vm/minwook/teacher_provider.dart';

class DetailHomework extends ConsumerWidget {
  final String id;
  const DetailHomework({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final homeworkDetailAsync = ref.watch(homeworkDetailProvider(id));
    final homeworkDetailAction = ref.read(homeworkActionProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(''), centerTitle: true),
      body: homeworkDetailAsync.when(
        data: (homeworkDetail) {
            if (homeworkDetail == null) {return const Center(child: Text('삭제된 공지임'));}
          final teacherNameAsync = ref.watch(teacherNameByIdProvider(homeworkDetail.teacher_id));
          return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(homeworkDetail.homework_title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        teacherNameAsync.when(
                          data: (data) => Text('작성자: $data', style: TextStyle(fontSize: 15)),
                          error: (error, stackTrace) => Text('$error'),
                          loading: () => CircularProgressIndicator(),
                        ),
                        Column(
                          children: [
                            Text(homeworkDetail.homework_insertdate.toString().substring(0, 19), style: TextStyle(fontSize: 15)),
                            Visibility(
                              visible: homeworkDetail.homework_updatedate == null ? false : true,
                              child: Text(homeworkDetail.homework_updatedate == null ? '' : '(수정: ${homeworkDetail.homework_updatedate.toString()})', style: TextStyle(fontSize: 15))
                            ),
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(thickness: 10),
                    ),
                    Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Text(
                                homeworkDetail.homework_contents
                              ),
                            ),
                            homeworkDetail.homework_images.isEmpty
                            ? SizedBox.shrink()
                            : SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                              child: ListView.builder(
                                itemCount: homeworkDetail.homework_images.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    width: 250,
                                    height: 250,
                                    child: Image.network(homeworkDetail.homework_images[index]),
                                  );
                                },
                              ),
                            )
                          ],
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateHomework(
                                    homeworkId: id
                                  ),
                                )
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Acolor.successBackColor,
                              foregroundColor: Acolor.successTextColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(5)
                              )
                            ),
                            child: Text('수정')
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      title: const Text('삭제 확인'),
                                      content: const Text('정말 삭제하시겠습니까?'),
                                      actions: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: const Text('취소'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                Navigator.pop(ctx);
                                                try {
                                                  await homeworkDetailAction.deleteHomework(id: id);
                                                  if (!context.mounted) return;
                                                  Navigator.pop(context);
                                                  Message.snackBar(context, '삭제 완료', 1, Colors.blue);
                                                } catch (e) {
                                                  if (!context.mounted) return;
                                                  Message.snackBar(context, '삭제 실패: $e', 1, Colors.red);
                                                }
                                              },
                                              child: const Text('확인'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Acolor.errorBackgroundColor,
                                foregroundColor: Acolor.errorTextColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(5)
                                )
                              ),
                              child: Text('삭제')
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          loading: () => Center(child: CircularProgressIndicator()),
        )
      
    );
  }
}