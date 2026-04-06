/* 
Description : attendance 테이블 구성
Date : 2026-1-16
Author : 상현
*/

class Attendance {
  final int? attendance_id;
  final String attendance_start_time;
  final String? attendance_end_time;
  final String attendance_status;
  final int attendance_grade;
  final int attendance_class;
  final int student_id;
  final String? student_name;         // JOIN 결과
  final String? attendance_content;   // 🔥 NEW: 결석/지각 사유 등

  Attendance({
    this.attendance_id,
    required this.attendance_start_time,
    this.attendance_end_time,
    required this.attendance_status,
    required this.attendance_grade,
    required this.attendance_class,
    required this.student_id,
    this.student_name,
    this.attendance_content,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendance_id: json['attendance_id'],
      attendance_start_time: json['attendance_start_time'],
      attendance_end_time: json['attendance_end_time'],
      attendance_status: json['attendance_status'],
      attendance_grade: json['attendance_grade'] ?? 1,
      attendance_class: json['attendance_class'] ?? 1,
      student_id: json['student_id'],
      student_name: json['student_name'],
      attendance_content: json['attendance_content'], // ✅ 사유 파싱
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendance_id,
      'attendance_start_time': attendance_start_time,
      'attendance_end_time': attendance_end_time,
      'attendance_status': attendance_status,
      'attendance_grade': attendance_grade,
      'attendance_class': attendance_class,
      'student_id': student_id,
      'student_name': student_name,
      'attendance_content': attendance_content, // ✅ 사유 포함
    };
  }
}
