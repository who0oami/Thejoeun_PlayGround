import 'dart:async';

import 'package:dda/controller/login_controller.dart';
import 'package:dda/service/email_auth_api_service.dart';
import 'package:dda/utils/input_validators.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  SignupController({EmailAuthApiService? emailAuthApiService})
      : _emailAuthApiService = emailAuthApiService ?? EmailAuthApiService();

  final EmailAuthApiService _emailAuthApiService;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final codeController = TextEditingController();

  final Rx<LoginMode> signupRole = LoginMode.user.obs;
  final RxString selectedGender = 'male'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSendingCode = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool codeSent = false.obs;
  final RxBool isCodeExpired = false.obs;
  final RxInt secondsRemaining = 0.obs;

  Timer? _timer;
  DateTime? _expiresAt;

  String get countdownLabel {
    final minutes = (secondsRemaining.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsRemaining.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void changeRole(LoginMode mode) {
    signupRole.value = mode;
    errorMessage.value = '';
  }

  void changeGender(String gender) {
    selectedGender.value = gender;
    errorMessage.value = '';
  }

  Future<void> sendCode() async {
    FocusManager.instance.primaryFocus?.unfocus();
    errorMessage.value = '';

    final email = emailController.text.trim();

    if (!InputValidators.isValidEmail(email)) {
      errorMessage.value = '올바른 이메일 주소를 입력해주세요.';
      _showError('이메일 오류', errorMessage.value);
      return;
    }

    isSendingCode.value = true;

    try {
      final expiresAt = await _emailAuthApiService.sendCode(email: email);
      _expiresAt = expiresAt.toLocal();
      codeSent.value = true;
      isCodeExpired.value = false;
      _startTimer();

      Get.snackbar(
        '인증번호 전송 완료',
        '입력한 이메일로 인증번호를 보냈습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE9F8EF),
        colorText: const Color(0xFF172638),
        margin: const EdgeInsets.all(18),
      );
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
      _showError('전송 실패', errorMessage.value);
    } finally {
      isSendingCode.value = false;
    }
  }

  Future<void> signup() async {
    FocusManager.instance.primaryFocus?.unfocus();
    errorMessage.value = '';

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final code = codeController.text.trim();
    final role = signupRole.value == LoginMode.admin ? 'admin' : 'user';

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        code.isEmpty) {
      errorMessage.value = '모든 항목을 입력해주세요.';
      _showError('입력 오류', errorMessage.value);
      return;
    }

    if (!InputValidators.isValidEmail(email)) {
      errorMessage.value = '올바른 이메일 주소를 입력해주세요.';
      _showError('이메일 오류', errorMessage.value);
      return;
    }

    if (!InputValidators.isValidPassword(password)) {
      errorMessage.value =
          '비밀번호는 영문 대소문자, 숫자, 특수문자를 포함한 10~16자리여야 합니다.';
      _showError('비밀번호 오류', errorMessage.value);
      return;
    }

    if (password != confirmPassword) {
      errorMessage.value = '비밀번호가 일치하지 않습니다.';
      _showError('비밀번호 오류', errorMessage.value);
      return;
    }

    if (!codeSent.value) {
      errorMessage.value = '먼저 이메일 인증번호를 요청해주세요.';
      _showError('인증 필요', errorMessage.value);
      return;
    }

    if (isCodeExpired.value) {
      errorMessage.value = '인증번호가 만료되었습니다. 다시 요청해주세요.';
      _showError('인증번호 만료', errorMessage.value);
      return;
    }

    isLoading.value = true;

    try {
      await _emailAuthApiService.verifyAndSignup(
        name: name,
        gender: selectedGender.value,
        email: email,
        password: password,
        role: role,
        code: code,
      );

      _timer?.cancel();
      isLoading.value = false;
      Get.back(result: role);
      Get.snackbar(
        '회원가입 완료',
        role == 'admin'
            ? '관리자 계정이 생성되었습니다.'
            : '사용자 계정이 생성되었습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE9F8EF),
        colorText: const Color(0xFF172638),
        margin: const EdgeInsets.all(18),
      );
    } catch (error) {
      isLoading.value = false;
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
      _showError('회원가입 실패', errorMessage.value);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_expiresAt == null) return;
    final diff = _expiresAt!.difference(DateTime.now());
    if (diff.isNegative || diff.inSeconds <= 0) {
      secondsRemaining.value = 0;
      isCodeExpired.value = true;
      _timer?.cancel();
      return;
    }
    secondsRemaining.value = diff.inSeconds;
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFCE9E9),
      colorText: const Color(0xFF8C1D1D),
      margin: const EdgeInsets.all(18),
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    codeController.dispose();
    super.onClose();
  }
}
