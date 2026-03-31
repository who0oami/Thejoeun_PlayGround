//  Edit Model
/*
  Created in: 16/01/2026 10:58
  Author: Chansol, Park
  Description: Edit Model
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Edit {
  //  Property
  int? edit_id; //  PK
  int teacher_id; //  FK
  int student_id; //  FK
  DateTime edit_date;

  //  Constructor
  Edit({
    this.edit_id,
    required this.teacher_id,
    required this.student_id,
    required this.edit_date,
  });

  //  Decode from Json type
  factory Edit.fromJson(Map<String, dynamic> json) {
    return Edit(
      edit_id: json['edit_id'],
      teacher_id: json['teacher_id'],
      student_id: json['student_id'],
      edit_date: DateTime.parse((json['edit_date'])),
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson() {
    return {
      'edit_id': edit_id,
      'teacher_id': teacher_id,
      'student_id': student_id,
      'edit_date': edit_date.isUtc
          ? edit_date.toIso8601String()
          : edit_date.toUtc().toIso8601String(),
    };
  }

  //  copyWith for Riverpod state
  /*  
  ****NOTICE****
    All keys MUST NOT be changed. Therefore NO keys in copyWith requirement.
  */

  Edit copyWith({DateTime? edit_date}) {
    return Edit(
      edit_id: edit_id,
      teacher_id: teacher_id,
      student_id: student_id,
      edit_date: edit_date ?? this.edit_date,
    );
  }
}
