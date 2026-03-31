import 'dart:typed_data';

class Teacher {
int? teacher_id;
String teacher_name;
String teacher_email;
String teacher_phone;
String teacher_password;
String teacher_when;
String teacher_subject;
String? teacher_image;



Teacher({
  this.teacher_id,
  required this.teacher_name,
  required this.teacher_email,
  required this.teacher_phone,
  required this.teacher_password,
  required this.teacher_when,
  required this.teacher_subject,
  this.teacher_image
});

factory Teacher.fromJson(Map<String,dynamic>json){

  return Teacher(
  teacher_id:json['teacher_id'] ,
  teacher_name: json['teacher_name'],
  teacher_email: json['teacher_email'],
  teacher_phone: json['teacher_phone'],
  teacher_password: json['teacher_password'],
  teacher_when: json['teacher_when'],
  teacher_subject: json['teacher_subject'],
  teacher_image: json['teacher_image'].toString());


}

Map<String,dynamic> toJson(){
  return{
    'teacher_id':teacher_id,
    'teacher_name':teacher_name,
    'teacher_email':teacher_email,
    'teacher_phone':teacher_phone,
    'teacher_password':teacher_password,
    'teacher_when':teacher_when,
    'teacher_subject':teacher_subject,
    'teacher_image':teacher_image
  };
}

}