/*
Description : 화면 마다 컬러 값을 동일하게 부여하기 위해
Date : 2026-01-15
Author : 유지현
*/

import 'package:flutter/material.dart';

class Acolor {
  static Color baseBackgroundColor = Color.fromARGB(255, 226, 226, 224);        // 바탕 배경 컬러
  static Color secondaryBackgroundColor = Color.fromARGB(255, 208, 208, 208);   // 바탕 배경 컬러
  static Color appBarBackgroundColor = Colors.black;                            // AppBar 배경 컬러
  static Color appBarForegroundColor = Colors.white;                            // AppBar 글자 컬러

  static Color errorBackgroundColor = Colors.red;                              // Error 배경 컬러
  static Color errorTextColor = Colors.white;                                  // Error 글자 컬러
  static Color successBackColor = const Color.fromARGB(255, 109, 215, 250);    // Success 배경 컬러
  static Color successTextColor = Colors.white;                                // Success 글자 컬러
  static Color primaryColor = const Color.fromARGB(255, 255, 210, 98);         // 메인 컬러
  static Color onPrimaryColor = Colors.white;                                  // primary 위의 텍스트/아이콘

}