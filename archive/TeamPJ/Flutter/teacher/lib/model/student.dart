/* 
Description : student 테이블 구성
Date : 2026-1-16
Author : 민재
*/

import 'dart:typed_data';

class Student {
  int? student_id;
  String student_name;
  String student_phone;
  String student_guardian_phone;
  String student_password;
  String student_address;
  String student_birthday;
  Uint8List student_image;


  Student(
    {
      this.student_id,
      required this.student_name,
      required this.student_phone,
      required this.student_guardian_phone,
      required this.student_password,
      required this.student_address,
      required this.student_birthday,
      required this.student_image
    }
  );


   factory Student.fromJson(Map<String, dynamic> json){
      return Student(
        student_id: json["student_id"],
        student_name: json['student_name'],
        student_phone: json['student_phone'],
        student_guardian_phone: json['student_guardian_phone'],
        student_password: json['student_password'],
        student_address: json['student_address'],
        student_birthday: json['student_birthday'],
         student_image: json['student_image']);


   }
  Map<String,dynamic> toJson(){
    return{
      "student_id":student_id,
      'student_name':student_name,
      'student_phone':student_phone,
      'student_guardian_phone':student_guardian_phone,
      'student_password':student_password,
      'student_address':student_address,
      'student_birthday':student_birthday,
      'student_image':student_image,
    };



  }

}