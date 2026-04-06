/* 
Description : Notice 목록 페이지
Date : 2026-1-19
Author : 황민욱
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/model/notice.dart';
import 'package:teacher/view/minwook/detail_notice.dart';
import 'package:teacher/view/minwook/insert_notice.dart';
import 'package:teacher/vm/minwook/drawer.dart';
import 'package:teacher/vm/minwook/notice_provider.dart';
import 'package:teacher/vm/minwook/teacher_provider.dart';

class ViewNotice extends ConsumerStatefulWidget {
  const ViewNotice({super.key});

  @override
  ConsumerState<ViewNotice> createState() => _ViewNoticeState();
}

class _ViewNoticeState extends ConsumerState<ViewNotice> {

  late String query;
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    query = "";
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final noticeAsync = ref.watch(filteredNoticeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('공지 목록'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InsertNotice(),
                )
              );
            },
            icon: Icon(Icons.edit)
          )
        ],
      ),
      drawer: AppDrawer(currentPage: widget),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: TextField(
                onChanged: (v) => ref.read(noticeSearchProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: '공지 검색',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: noticeAsync.when(
                data: (noticeList) => noticeList.isEmpty
                  ? Center(child: Text('공지가 없습니다.'))
                  : ListView.builder(
                    itemCount: noticeList.length,
                    itemBuilder: (context, index) {
                      Notice notice = noticeList[index];
                      final teacherNameAsync = ref.watch(teacherNameByIdProvider(notice.teacher_id));
                        return Card(
                          elevation: 0.8,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DetailNotice(
                                  id: notice.notice_id!,
                                ))
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: SizedBox(
                                      width: 30,
                                      child: Text(
                                        (noticeList.length - index).toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      notice.notice_title,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 20),
                                        child: teacherNameAsync.when(
                                          data: (name) => Text(name, style: TextStyle(fontSize: 16)),
                                          loading: () => Text('...', style: TextStyle(fontSize: 16)),
                                          error: (error, stackTrace) => Text('$error', style: TextStyle(fontSize: 16)),
                                        ),
                                      ),
                                      Text(
                                        notice.notice_insertdate.toString().substring(0, 10),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Icon(Icons.chevron_right, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                    },
                  ),
                error: (error, stackTrace) => Center(child: Text('Error: $error')),
                loading: () => Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  } // build
} // class