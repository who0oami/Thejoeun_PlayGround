/* 
Description : Homework Model for Firebase
Date : 2026-1-16
Author : 황민욱 / 정시온이랑 수정
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class Homework {
  final String? homework_id;        // Firestore doc.id
  final String homework_title;
  final String homework_contents;
  final String homework_subject;
  final DateTime? homework_duedate;
  final DateTime homework_insertdate;
  final DateTime? homework_updatedate;
  final List<String> homework_images;
  final int teacher_id;

  Homework({
    this.homework_id,
    required this.homework_title,
    required this.homework_contents,
    required this.homework_subject,
    this.homework_duedate,
    required this.homework_insertdate,
    this.homework_updatedate,
    required this.homework_images,
    required this.teacher_id,
  });

  factory Homework.fromMap(Map<String, dynamic> map, String id){
    return Homework(
      homework_id: id,
      homework_title: map['homework_title'] ?? "",
      homework_contents: map['homework_contents'] ?? "",
      homework_subject: map['homework_subject'] ?? "",
      homework_duedate: map['homework_duedate'] != null ? (map['homework_duedate'] as Timestamp).toDate() : null,
      homework_insertdate: (map['homework_insertdate'] as Timestamp).toDate(),
      homework_updatedate: map['homework_updatedate'] != null ? (map['homework_updatedate'] as Timestamp).toDate() : null,
      homework_images: List<String>.from(map['homework_images'] ?? []),
      teacher_id: map['teacher_id'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'homework_title': homework_title,
      'homework_contents': homework_contents,
      'homework_subject': homework_subject,
      'homework_duedate': homework_duedate != null ? Timestamp.fromDate(homework_duedate!) : null,
      'homework_insertdate': Timestamp.fromDate(homework_insertdate),
      'homework_updatedate': homework_updatedate != null ? Timestamp.fromDate(homework_updatedate!) : null,
      'homework_images': homework_images,
      'teacher_id': teacher_id,
    };
  }
}