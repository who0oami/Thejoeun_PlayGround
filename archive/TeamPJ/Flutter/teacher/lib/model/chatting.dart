//  Chatting Model
/*
  Created in: 16/01/2026 10:36
  Author: Chansol, Park
  Description: Chatting Model for firebase connection
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
    'Point 1, fromMap created', Creator: Chansol, Park
  Version: 1.0
  Dependency: 

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Chatting {
  //  Property
  //  No auto-increment Primary key
  String? chatting_id;
  int category_id; //  FK
  int teacher_id; //  FK
  int guardian_id;
  DateTime chatting_date;
  String chatting_content;

  //  Constructor
  Chatting({
    this.chatting_id,
    required this.category_id,
    required this.teacher_id,
    required this.guardian_id,
    required this.chatting_date,
    required this.chatting_content,
  });

  //  Point 1
  factory Chatting.fromMap(Map<String, dynamic> map, String id) {
    return Chatting(
      chatting_id: id,
      category_id: map['category_id'] ?? "",
      teacher_id: map['teacher_id'] ?? "",
      guardian_id: map['gurdian_id'] ?? "",
      chatting_date: DateTime.parse(map['chatting_date']),
      chatting_content: map['chatting_content'] ?? "",
    );
  }

  //  copyWith for Riverpod state
  /*  
  ****NOTICE****
    All keys MUST NOT be changed. Therefore NO keys in copyWith requirement.
  */

  Chatting copyWith({String? chatting_content, DateTime? chatting_date}) {
    return Chatting(
      chatting_id: chatting_id,
      category_id: category_id,
      teacher_id: teacher_id,
      guardian_id: guardian_id,
      chatting_date: chatting_date ?? this.chatting_date,
      chatting_content: chatting_content ?? this.chatting_content,
    );
  }
}
