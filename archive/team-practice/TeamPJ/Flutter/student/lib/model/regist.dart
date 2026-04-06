//  Regist Model
/*
  Created in: 16/01/2026 11:26
  Author: Chansol, Park
  Description: Regist Model
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 

  DateTime MUST converted using value.toIso8601String() consider .toUtc and .isUtc
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Regist {
  //  Property
  int? regist_id; //  PK
  int teacher_id; //  FK
  int student_id; //  FK
  DateTime regist_date;

  //  Constructor
  Regist({
    this.regist_id,
    required this.teacher_id,
    required this.student_id,
    required this.regist_date,
  });

  //  Decode from Json type
  factory Regist.fromJson(Map<String, dynamic> json) {
    return Regist(
      regist_id: json['regist_id'],
      teacher_id: json['teacher_id'],
      student_id: json['student_id'],
      regist_date: DateTime.parse(json['regist_date']),
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson() {
    return {
      'regist_id': regist_id,
      'teacher_id': teacher_id,
      'student_id': student_id,
      'regist_date': regist_date.isUtc
          ? regist_date.toIso8601String()
          : regist_date.toUtc().toIso8601String(),
    };
  }

  //  copyWith for Riverpod state
  /*  
  ****NOTICE****
    All keys MUST NOT be changed. Therefore NO keys in copyWith requirement.
  */

  Regist copyWith({DateTime? regist_date}) {
    return Regist(
      regist_id: regist_id,
      teacher_id: teacher_id,
      student_id: student_id,
      regist_date: regist_date ?? this.regist_date
    );
  }
}
