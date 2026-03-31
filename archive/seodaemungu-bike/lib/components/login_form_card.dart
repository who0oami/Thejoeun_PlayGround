import 'package:dda/components/login_mode_switch.dart';
import 'package:dda/components/login_social_buttons.dart';
import 'package:dda/components/login_text_field.dart';
import 'package:dda/controller/login_controller.dart';
import 'package:dda/view/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    final emailOnly =
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9@._%+-]'));
    final asciiOnly = FilteringTextInputFormatter.allow(RegExp(r'[ -~]'));

    return Obx(
      () => Container(
        constraints: const BoxConstraints(maxWidth: 620),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FBFF),
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F2342),
              blurRadius: 50,
              offset: Offset(0, 24),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.topRight,
              child: Text(
                '따릉이 네오',
                style: TextStyle(
                  color: Color(0xFF131A28),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const LoginModeSwitch(),
            const SizedBox(height: 36),
            Text(
              controller.loginMode.value == LoginMode.user
                  ? '안녕하세요'
                  : '관리자 로그인',
              style: const TextStyle(
                color: Color(0xFF11233F),
                fontSize: 44,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              controller.loginMode.value == LoginMode.user
                  ? '회원가입한 계정으로 로그인하여 서비스를 시작하세요.'
                  : '관리자 계정으로 시스템에 접속하세요.',
              style: const TextStyle(
                color: Color(0xFF57657B),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 34),
            const Text(
              '이메일 주소',
              style: TextStyle(
                color: Color(0xFF223125),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            LoginTextField(
              controller: controller.emailController,
              hintText: 'name@example.com',
              prefixIcon: Icons.alternate_email_rounded,
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [emailOnly],
              enableSuggestions: false,
              autocorrect: false,
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    '비밀번호',
                    style: TextStyle(
                      color: Color(0xFF223125),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '비밀번호 찾기',
                  style: TextStyle(
                    color: Color(0xFF2B9B61),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '영문 대문자, 소문자, 숫자, 특수문자 포함 10~16자',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            LoginTextField(
              controller: controller.passwordController,
              hintText: 'Abcdef!123',
              prefixIcon: Icons.lock_rounded,
              obscureText: true,
              inputFormatters: [asciiOnly, LengthLimitingTextInputFormatter(16)],
              enableSuggestions: false,
              autocorrect: false,
            ),
            if (controller.errorMessage.value.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                controller.errorMessage.value,
                style: const TextStyle(
                  color: Color(0xFFC24141),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF118847),
                      Color(0xFF2CC96A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33118847),
                      blurRadius: 28,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.login,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              controller.submitLabel,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 26,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              height: 1,
              color: const Color(0xFFD8E2F0),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                '또는 다음으로 계속하기',
                style: TextStyle(
                  color: Color(0xFF344861),
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Center(
              child: LoginSocialButtons(),
            ),
            const SizedBox(height: 26),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  const Text(
                    '아직 회원이 아니신가요? ',
                    style: TextStyle(
                      color: Color(0xFF344861),
                      fontSize: 16,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final result = await Get.to<String>(
                        () => const SignupPage(),
                      );
                      if (result == 'admin') {
                        controller.changeMode(LoginMode.admin);
                      } else if (result == 'user') {
                        controller.changeMode(LoginMode.user);
                      }
                      controller.emailController.clear();
                      controller.passwordController.clear();
                    },
                    child: const Text(
                      '지금 가입하세요',
                      style: TextStyle(
                        color: Color(0xFF118847),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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
  }
}
