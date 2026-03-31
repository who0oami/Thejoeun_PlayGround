/* 
Description : Timetable Model for Firebase
Date : 2026-1-16
Author : 황민욱
*/

class Timetable {
  final String timetable_id;       // Firestore doc.id
  final Map<String, List<String>> timetable_table;
  final String timetable_semester;
  final int timetable_period;
  final int timetable_grade;
  final int timetable_class;

  Timetable({
    required this.timetable_id,
    required this.timetable_table,
    required this.timetable_semester,
    required this.timetable_period, 
    required this.timetable_class, 
    required this.timetable_grade,
  });

  factory Timetable.fromMap(Map<String, dynamic> map, String id){
    return Timetable(
      timetable_id: id,
      timetable_table: (map['timetable_table'] as Map<String, dynamic>)
                      .map((key, value) => MapEntry(key, List<String>.from(value as List))),
      timetable_semester: map['timetable_semester'] ?? "",
      timetable_period: map['timetable_period'] ?? 0,
      timetable_class: map['timetable_class'] ?? 0,
      timetable_grade: map['timetable_grade'] ?? 0,
    );
  }

}