/* 
Description : student_history 테이블 구성
Date : 2026-1-16
Author : 민재
*/


class StudentHistory {
 int student_history_class_number;
 int student_id;
 String student_history__grade_number;




StudentHistory({
  required this.student_history_class_number,
  required this.student_id,
  required this.student_history__grade_number,
});

factory StudentHistory.fromJson(Map<String,dynamic>json){
  return StudentHistory(
    student_history_class_number: json['student_history_class_number'],
    student_id: json['student_id'],
    student_history__grade_number: json['student_history__grade_number']
    );


}

Map<String,dynamic>toJson(){
  return{
    'student_history_class_number':student_history_class_number,
    'student_id':student_id,
    'student_history__grade_number':student_history__grade_number,
  };
}

}