/* 
Description : notice tabbar page - 공지사항, 숙제, 시간표, 급식표 나오게 함!
Date : 2026-1-19
Author : 정시온
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian/util/acolor.dart';
import 'package:guardian/view/notice/homework_page.dart';
import 'package:guardian/view/notice/lunch_page.dart';
import 'package:guardian/view/notice/notice_page.dart';
import 'package:guardian/view/notice/timetable_page.dart';
import 'package:guardian/vm/sion/notice_provider.dart';
import 'package:guardian/vm/sion/tab_model.dart';


class NoticeTabbar extends ConsumerStatefulWidget { // Provider의 TabBar는 Stateful로 제어한다. 
  const NoticeTabbar({super.key});

  @override
  ConsumerState<NoticeTabbar> createState() => _NoticeState(); // <<<<<<<<<
}

class _NoticeState extends ConsumerState<NoticeTabbar> with SingleTickerProviderStateMixin{ //<<<<
  late TabController _tabController; 
  final List<Widget> _pages = [NoticePage(), HomeworkPage(),TimetablePage(),LunchPage()];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
     _tabController.addListener(() {
      if(!_tabController.indexIsChanging){
       ref.read(tabnotifierProvider.notifier).changeTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final noticeAsync = ref.watch(noticeListProvider);
    return Scaffold(
      appBar: AppBar(
             
        title: 
        SizedBox(
        child: Image.asset('images/atti_logo.png'),
        height:80 ,),
        centerTitle: true,
        backgroundColor: Acolor.primaryColor,
        foregroundColor: Acolor.onPrimaryColor,
      elevation: 0,
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.black,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
        tabs: [
                    Tab(text: "공지사항"),
                    Tab(text: "숙제"),
                    Tab(text: "시간표"),
                    Tab(text: "급식표"),
        ],

      ),
      ),
        body:          
      TabBarView(
        controller: _tabController,
        children: _pages, 
      ),
    );
  }
}