//  Chatting Model
/*
  Created in: 16/01/2026 10:36
  Author: Chansol, Park
  Description: Chatting Model for firebase connection
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
          19/01/2026 18:01, 'Point 1, Added guardian_id', Creator: Chansol, Park
  Version: 1.0
  Dependency: 

  DateTime MUST converted using value.toIso8601String()
  Stored DateTime in String MUST converted using DateTime.parse(value);
*/

class Chatting {
  //  Property
  //  No auto-increment Primary key
  /*  
  ****NOTICE****
    firebase primary key is always created in random Strings such as fVbI7qwtFAEqXQhuL2CH
    chatting_id(PK in ERD), guardian_id(PK in ERD) MUST not exist in this model
  */
  //  Point 1
  int guardian_id;  //  FK
  int category_id;  //  FK
  int teacher_id;   //  FK
  DateTime chatting_date;
  String chatting_content;

  //  Constructor
  Chatting({
    //  Point 1
    required this.guardian_id,
    required this.category_id,
    required this.teacher_id,
    required this.chatting_date,
    required this.chatting_content,
  });

  //  copyWith for Riverpod state
  /*  
  ****NOTICE****
    All keys MUST NOT be changed. Therefore NO keys in copyWith requirement.
  */

  Chatting copyWith({String? chatting_content, DateTime? chatting_date}) {
    return Chatting(
      //  Point 1
      guardian_id: guardian_id,
      category_id: category_id,
      teacher_id: teacher_id,
      chatting_date: chatting_date ?? this.chatting_date,
      chatting_content: chatting_content ?? this.chatting_content,
    );
  }
}
