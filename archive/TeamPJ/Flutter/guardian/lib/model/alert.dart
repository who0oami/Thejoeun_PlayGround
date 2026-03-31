/* 
Description : alert 테이블 구성
Date : 2026-1-16
Author : 상현
*/


class Alert {
  final int? alert_id;
  final int student_id;
  final int guardian_id;
  final int teacher_id;
  final double alert_lat;
  final double alert_lng;
  final String alert_start_date;
  final String alert_end_date;

  Alert(
    {
      this.alert_id,
      required this.student_id,
      required this.guardian_id,
      required this.teacher_id,
      required this.alert_lat,
      required this.alert_lng,
      required this.alert_start_date,
      required this.alert_end_date,
    }
  );

  factory Alert.fromJson(Map<String,dynamic> json){
    return Alert(
      alert_id : json['alert_id'],
      student_id: json['student_id'] ?? '', 
      guardian_id: json['guardian_id'] ?? '',
      teacher_id: json['teacher_id'] ?? '',
      alert_lat: json['alert_lat'] ?? '',
      alert_lng: json['alert_lng'] ??'',
      alert_start_date: json['alert_start_date'] ?? '',
      alert_end_date: json['alert_end_date'] ?? ''
      );
  }

  Map<String,dynamic> toJson(){
    return{
      'student_id' : student_id,
      'guardian_id' : guardian_id,
      'teacher_id' : teacher_id,
      'alert_lat' : alert_lat,
      'alert_lng' : alert_lat,
      'alert_start_date' : alert_start_date,
      'alert_end_date' : alert_end_date
    };
  }
}
