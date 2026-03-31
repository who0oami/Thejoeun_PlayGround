/* 
Description : semester 테이블 구성
Date : 2026-1-16
Author : 민재
*/


class Semester {
 final int? semester_id;
 final String semester_name;
 final String semester_start;
 final String semester_end;
 final int teacher_id;




  Semester(
    {
      this.semester_id,
      required this.semester_name,
      required this.semester_start,
      required this.semester_end,
      required this.teacher_id,


    }
  );
  factory Semester.fromJson(Map<String,dynamic> json){
    return Semester(
      semester_id: json['semester_id'],
      semester_name: json['semester_name']??"",
      semester_start: json['semester_start']??"",
      semester_end: json['semester_end']??"",
      teacher_id: json['teacher_id']
         
         );
  }

  Map<String,dynamic> toJson(){
    return{
      'semester_id':semester_id,
      'semester_name':semester_name,
      'semester_start':semester_start,
      'semester_end':semester_end,
      'teacher_id':teacher_id
    };
  }


}