//  Guardian Model
/*
  Created in: 16/01/2026 11:19
  Author: Chansol, Park
  Description: Guardian Model
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Guardian {
  //  Property
  int? guardian_id; //  PK
  String guardian_name;
  String guardian_email;
  String guardian_password;
  String sub_guardian_name;
  String sub_guardian_phone;

  //  Constructor
  Guardian({
    this.guardian_id,
    required this.guardian_name,
    required this.guardian_email,
    required this.guardian_password,
    required this.sub_guardian_name,
    required this.sub_guardian_phone,
  });

  //  Decode from Json type
  factory Guardian.fromJson(Map<String, dynamic> json) {
    return Guardian(
      guardian_id: json['guardian_id'],
      guardian_name: json['guardian_name'],
      guardian_email: json['guardian_email'],
      guardian_password: json['guardian_password'],
      sub_guardian_name: json['sub_guardian_name'],
      sub_guardian_phone: json['sub_guardian_phone'],
    );
  }

  //  Encode to Json type
  Map<String, dynamic> toJson() {
    return {
      'guardian_id': guardian_id,
      'guardian_name': guardian_name,
      'guardian_email': guardian_email,
      'guardian_password': guardian_password,
      'sub_guardian_name': sub_guardian_name,
      'sub_guardian_phone': sub_guardian_phone,
    };
  }

  //  copyWith for Riverpod state
  /*  
  ****NOTICE****
    All keys MUST NOT be changed. Therefore NO keys in copyWith requirement.
  */

  Guardian copyWith({
    String? guardian_name,
    String? guardian_email,
    String? guardian_password,
    String? sub_guardian_name,
    String? sub_guardian_phone,
  }) {
    return Guardian(
      guardian_id: guardian_id,
      guardian_name: guardian_name ?? this.guardian_name,
      guardian_email: guardian_email ?? this.guardian_email,
      guardian_password: guardian_password ?? this.guardian_password,
      sub_guardian_name: sub_guardian_name ?? this.sub_guardian_name,
      sub_guardian_phone: sub_guardian_phone ?? this.sub_guardian_phone,
    );
  }
}
