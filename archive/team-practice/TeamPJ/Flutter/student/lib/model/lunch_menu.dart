/* 
Description : LunchMenu Model for Firebase
Date : 2026-1-22
Author : 황민욱
*/

class LunchMenu {
  final String lunch_menu_id;          // Firestore doc.id
  final String lunch_menu_name;
  final String lunch_menu_category;
  final String lunch_menu_image;

  LunchMenu({
    required this.lunch_menu_id,
    required this.lunch_menu_name,
    required this.lunch_menu_category,
    required this.lunch_menu_image,
  });

  factory LunchMenu.fromMap(Map<String, dynamic> map, String id) {
    return LunchMenu(
      lunch_menu_id: id,
      lunch_menu_name: map['lunch_menu_name'] ?? "",
      lunch_menu_category: map['lunch_menu_category'] ?? "",
      lunch_menu_image: map['lunch_menu_image'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lunch_menu_name': lunch_menu_name,
      'lunch_menu_category': lunch_menu_category,
      'lunch_menu_image': lunch_menu_image,
    };
  }
}
