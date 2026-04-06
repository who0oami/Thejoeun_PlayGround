/* 
Description : Lunch Model for Firebase
Date : 2026-1-22
Author : 황민욱
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class Lunch {
  final String lunch_id;                           // Firestore doc.id
  final DateTime lunch_date;                       // 급식 날짜
  final Map<String, List<String>> lunch_contents;  // 카테고리별 menuId 리스트

  Lunch({
    required this.lunch_id,
    required this.lunch_date,
    required this.lunch_contents,
  });

  factory Lunch.fromMap(Map<String, dynamic> map, String id) {
    return Lunch(
      lunch_id: id,
      lunch_date: (map['lunch_date'] as Timestamp).toDate(),
      lunch_contents: (map['lunch_contents'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, List<String>.from(value as List))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lunch_date': Timestamp.fromDate(lunch_date),
      'lunch_contents': lunch_contents,
    };
  }
}
