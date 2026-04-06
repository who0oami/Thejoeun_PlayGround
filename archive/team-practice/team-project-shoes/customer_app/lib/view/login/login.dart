import 'dart:convert';
import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/model/customer.dart';
import 'package:customer_app/model/usercontroller.dart';
import 'package:customer_app/view/home/tabbar.dart';
import 'package:customer_app/view/login/find_id_pw.dart';
import 'package:customer_app/view/login/regist.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController pwController = TextEditingController();

  final UserController userController = Get.put(UserController()); // 유저 정보 저장

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        print('로그인 성공: ${googleUser.email}');
      }
    } catch (error) {
      print('구글 로그인 실패: $error');
    }
  }

@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    behavior: HitTestBehavior.translucent,
    child: Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 60),
                        child: Image.asset(
                          'images/logo_non.png',
                          width: 250,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: '이메일',
                            hintText: 'EX)dsss@email.com',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: TextField(
                          obscureText: true,
                          controller: pwController,
                          decoration: InputDecoration(labelText: '비밀번호'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                          ),
                          onPressed: () => loginAction(),
                          child: Text('로그인'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.g_mobiledata, size: 45),
                          label: Text('Google로 계속하기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: Size(double.infinity, 50),
                            side: BorderSide(color: Colors.grey),
                          ),
                          onPressed: _handleGoogleSignIn,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(double.infinity, 50),
                                  ),
                                  onPressed: () => Get.to(() => const Regist()),
                                  child: Text('회원가입'),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(double.infinity, 50),
                                  ),
                                  onPressed: () {
                                    Get.to(FindIdPw());
                                  },
                                  child: Text('ID / Pw 찾기'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}


  Future<void> loginAction() async {
    if (emailController.text.trim().isEmpty || pwController.text.trim().isEmpty) {
      _errorSnackBar('아이디와 비밀번호를 입력해주세요.');
      return;
    }

    try {
      final url = Uri.parse('${IpAddress.baseUrl}/customer/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailController.text.trim(),
          'password': pwController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['results'] == 'OK') {
        Customer loggedInUser = Customer.fromJson(data['customer_data']); 
        userController.login(loggedInUser);
        Get.offAll(() => const Tabbar());
        
        } else {
          _errorSnackBar('이메일 또는 비밀번호가 일치하지 않습니다.');
        }
      } else {
        _errorSnackBar('서버 연결 실패');
      }
    } catch (e) {
      _errorSnackBar('네트워크 에러가 발생했습니다.');
    }
  }

  void _errorSnackBar(String message) {
    Get.snackbar(
      '경고',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}