/* 
Description : Notice Model for Firebase / 수정
Date : 2026-1-19
Author : 정시온
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String? notice_id;       // Firestore doc.id
  final int teacher_id;    // FK
  final String notice_title; 
  final String notice_content;   
  final DateTime? notice_updatedate;
  final DateTime notice_insertdate;
  final List<String> notice_images;   

  Notice({
    this.notice_id,
    required this.teacher_id,
    required this.notice_title,
    required this.notice_content,
    this.notice_updatedate,
    required this.notice_insertdate,
    required this.notice_images,
  });

  factory Notice.fromMap(Map<String, dynamic> map, String id){
    return Notice(
      notice_id: id,
      teacher_id: map['teacher_id'] ?? 0,
      notice_title: map['notice_title'] ?? "",
      notice_content: map['notice_content'] ?? "",
      notice_updatedate: map['notice_updatedate'] != null ? (map['notice_updatedate'] as Timestamp).toDate() : null,
      notice_insertdate: (map['notice_insertdate'] as Timestamp).toDate(),
      notice_images: List<String>.from(map['notice_images'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teacher_id': teacher_id,
      'notice_title': notice_title,
      'notice_content': notice_content,
      'notice_insertdate': Timestamp.fromDate(notice_insertdate),
      'notice_updatedate': notice_updatedate != null ? Timestamp.fromDate(notice_updatedate!) : null,
      'notice_images': notice_images,
    };
  }
}
