/* 
Description : assignment 테이블 구성
Date : 2026-1-16
Author : 상현
*/

class Assignment {
  final int? assignment_id;
  final String assignment_year;
  final int teacher_id; // FK
  final int student_id; // FK

  Assignment(
    {
      this.assignment_id,
      required this.assignment_year,
      required this.teacher_id,
      required this.student_id
    }
  );

  factory Assignment.fromJson(Map<String,dynamic> json){
    return Assignment(
      assignment_id: json['assignment_id'],
      assignment_year: json['assignment_year'],
      teacher_id: json['teacher_id'],
      student_id: json['student_id']
      );
    }

    Map<String, dynamic> toJson(){
      return{
        'assignment_id' : assignment_id,
        'assignment_year' : assignment_year,
        'teacher_id' : teacher_id,
        'student_id' : student_id
      };
    }
}