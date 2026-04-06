/* 
Description : AppDrawer
Date : 2026-1-19
Author : 황민욱
*/

import 'package:flutter/material.dart';
import 'package:teacher/view/minwook/insert_lunch.dart';
import 'package:teacher/view/minwook/insert_timetable.dart';
import 'package:teacher/view/minwook/view_homework.dart';
import 'package:teacher/view/minwook/view_notice.dart';
import 'package:teacher/view/minwook/view_schedule.dart';

class AppDrawer extends StatelessWidget {
  final Widget currentPage; // Stateless는 this, Stateful은 widget으로 쓰면 됨.
  const AppDrawer({super.key, required this.currentPage});

  void _move(BuildContext context, Widget page) {
    Navigator.pop(context);
    if (currentPage.runtimeType == page.runtimeType) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            DrawerHeader(child: Center(child: Image.asset('images/atti_logo.png'))),
            _buildDrawerListTile('공지', context, ViewNotice()),
            _buildDrawerListTile('숙제', context, ViewHomework()),
            _buildDrawerListTile('시간표', context, InsertTimetable()),
            _buildDrawerListTile('급식표', context, InsertLunch()),
            _buildDrawerListTile('학사일정', context, ViewSchedule()),
          ],
        ),
      ),
    );
  } // build

  // Widget ===================================
  Widget _buildDrawerListTile(String title, BuildContext context, Widget page) {
    return ListTile(
      title: Text(title),
      onTap: () => _move(context, page),
    );
  }

} // class