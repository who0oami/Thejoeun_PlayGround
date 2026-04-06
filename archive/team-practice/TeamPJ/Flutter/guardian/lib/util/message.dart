import 'package:flutter/material.dart';

/*
  Desciption : 모든 화면에서 Snack Bar나 Alert를 사용할 경우 공통 사용
  Date : 2026-01-15
  Author : 유지현
*/
/*
  Desciption : 컨펌 다이아로그 생성
  Date : 2026-01-23
  Author : 이상현
*/

class Message {
  // Snack Bar
  static void snackBar(BuildContext context,String message,int sec,Color color){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: sec),
      ),
    );
  } // snackBar

  // Dialog
  static void dialog(BuildContext context,String title,String content,Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          backgroundColor: color,
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('확인'),
              ),
            ),
          ],
        );
      },
    );
} // Dialog

  // Confirm dialog
  static Future<bool?> confirm(
    BuildContext context,
    String title,
    String content,
    Color color,
  ) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          backgroundColor: color,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('아니요'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('예'),
            ),
          ],
        );
      },
    );
  }

} 
