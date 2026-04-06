import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:student/util/acolor.dart';
import 'package:student/util/message.dart';
import 'package:student/view/main_page.dart';
import 'package:student/vm/dusik/student%20_%20provider.dart';

/* 
Description : 학생 로그인 페이지
  - 1) body 생성 전, get_storage 에 정보 저장 되어 있는 경우 , main 페이지로 이동
  - 2) 전화번호 , 비밀번호 입력.
      - 미 입력시 snackBar로 알림 띄워주기
  - 3) 입력 정보와 DB 학생 정보 동일 한지 확인
  - 4) 맞게 입력 된 경우, Dialog 로 환영 창 띄워주기
      - get_storage 로 정보 저장
      - 틀린 경우 snackBar로 알림 띄워주기
  - 5) 확인 누르면 메인 페이지로 이동
      - 학생 정보 넘겨주기
Date : 2026-01-17
Author : 지현
*/

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  // Property
  late TextEditingController phoneController; // Phone
  late TextEditingController pwController; // Password
  final box = GetStorage(); // GetStorage

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
    pwController = TextEditingController();
    initStorage();
  }

  initStorage(){ // key, value
    box.write('p_userid', '');
    box.write('p_password', '');
  }


  @override
  void dispose() {
    phoneController.dispose();
    pwController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final studentAsync = ref.watch(studentNotifierProvider);
    return Scaffold(
      backgroundColor: Acolor.appBarForegroundColor,
      appBar: AppBar(
        title: Text(""),
      backgroundColor: Acolor.appBarForegroundColor,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                "images/head_book.png",
                width: 150,
                ),
            ),
            Text("학생 정보 입력"),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        Text(
                          "전화번호",
                          style: TextStyle(
                            fontWeight: FontWeight.w600
                          ),
                          ),
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2), // 클릭하면 파란색 두껍게
                            ),
                            labelText: '전화번호를 입력하세요',
                            // labelStyle: TextStyle(color: Acolor.successBackColor), _ 컬러가 이상함, 나중에 색상 변경 후 수정 예정
                            labelStyle: TextStyle(color: Colors.blue),
                          ),
                        ),
                        SizedBox(height: 40,),
                        Text(
                          "비밀번호",
                          style: TextStyle(
                            fontWeight: FontWeight.w600
                          ),
                          ),
                        TextField(
                          controller: pwController,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2),
                            ),
                            labelText: '비밀번호를 입력하세요',
                            labelStyle: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => checkLogin(), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Acolor.primaryColor,
                    foregroundColor: Acolor.onPrimaryColor, 
                    fixedSize: Size(200, 50)
                    ),
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18
                    ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } // build
  // ---- Functions ----
void checkLogin() async {
    final phone = phoneController.text.trim();
    final pw = pwController.text.trim();
    final studentNotifier = ref.read(studentNotifierProvider.notifier);
    if (phone.isEmpty || pw.isEmpty) {
      Message.snackBar(
        context,
        '전화번호와 비밀번호를 입력하세요',
        2,
        Colors.red,
      );
      return;
    }
    //서버로 로그인 요청 (위의 if문에 걸리지 않았을 때
    final result = await studentNotifier.loginStudent(phone, pw);
    //결과값이 OK
    if (result != 'FAIL') {
    phoneController.clear();
    pwController.clear();
      // 성공 시 다이얼로그
      Message.dialog(
        context,
        '환영합니다!',
        '오늘도 즐겁게 공부해보아요',
        Colors.white,
      );
      // saveStorage(result);
      // 페이지 이동
      Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
    } else {
      // 실패 시 스낵바
      Message.snackBar(
        context,
        '전화번호와 비밀번호를 확인해주세요',
        2,
        Colors.red,
      );
    }
  }
  // void saveStorage(String studentId){
  //   box.write('p_userid', studentId);
  //   phoneController.clear();
  //   pwController.clear();
  // }
} // class
