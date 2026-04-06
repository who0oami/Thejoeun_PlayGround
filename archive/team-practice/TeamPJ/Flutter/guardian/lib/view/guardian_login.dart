import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian/util/acolor.dart';
import 'package:guardian/util/message.dart';
import 'package:guardian/view/minjae/guardian_main_page.dart';
import 'package:guardian/vm/dusik/guardian_login_provider.dart';

/* 
Description : 학부모 로그인 페이지
  - 1) body 생성 전, get_storage 에 정보 저장 되어 있는 경우 , main_page 페이지로 이동 (이전 main 화면에서)
  - 2) 이메일주소 , 비밀번호 입력.
      - 미 입력시 snackBar로 알림 띄워주기
  - 3) 입력 정보와 DB 보호자 정보 동일 한지 확인
  - 4) 맞게 입력 된 경우, Dialog 로 환영 창 띄워주기
      - get_storage 로 정보 저장
      - 틀린 경우 snackBar로 알림 띄워주기
  - 5) 확인 누르면 메인 페이지로 이동
Date : 2026-01-17
Author : 지현
*/

class GuardianLogin extends ConsumerStatefulWidget {
  const GuardianLogin({super.key});

  @override
  ConsumerState<GuardianLogin> createState() => _GuardianLoginState();
}

class _GuardianLoginState extends ConsumerState<GuardianLogin> {
  // Property
  late TextEditingController emailController; // email
  late TextEditingController pwController; // Password

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    pwController = TextEditingController();
  }



  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final teacherAsync = ref.watch(guardianLoginNotifierProvider);
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
                "images/head.png",
                width: 150,
                ),
            ),
            Text("보호자 정보 입력"),
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
                          "이메일",
                          style: TextStyle(
                            fontWeight: FontWeight.w600
                          ),
                          ),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)
                            ),
                            focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2), // 클릭하면 파란색 두껍게
                            ),
                            labelText: '이메일을 입력하세요',
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
    final email = emailController.text.trim();
    final pw = pwController.text.trim();
    final guardianNotifier = ref.read(guardianLoginNotifierProvider.notifier);
    if (email.isEmpty || pw.isEmpty) {
      Message.snackBar(
        context,
        '이메일과 비밀번호를 입력하세요',
        2,
        Colors.red,
      );
      return;
    }
    //서버로 로그인 요청 (위의 if문에 걸리지 않았을 때
    final result = await guardianNotifier.loginGuardian(email,pw);
    //결과값이 OK
    if (result == 'OK') {
      emailController.clear();
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
      MaterialPageRoute(builder: (context) => GuardianMainPage()),
    );
    } else {
      // 실패 시 스낵바
      Message.snackBar(
        context,
        '이메일과 비밀번호를 확인해주세요',
        2,
        Colors.red,
      );
    }
  }
  // void saveStorage(String teacherId){
  //   box.write('p_userid', teacherId);
  //   emailController.clear();
  //   pwController.clear();
  // }

  
} // class

