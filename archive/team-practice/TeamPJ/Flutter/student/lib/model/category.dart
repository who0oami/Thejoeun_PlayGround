/* 
Description : category 테이블 구성
Date : 2026-1-16
Author : 상현
*/

class Category {
  final int? category_id;
  final String category_title;

  Category(
    {
      this.category_id,
      required this.category_title
    }
  );

  factory Category.fromJson(Map<String, dynamic> json){
    return Category(
      category_title: json['category_title'] ?? ''
      );
  }

  Map<String, dynamic> toJson(){
    return{
      'category_title' : category_title
    };
  }
}