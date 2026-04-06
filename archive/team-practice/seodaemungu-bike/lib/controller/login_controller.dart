import 'package:dda/service/login_api_service.dart';
import 'package:dda/service/storage_service.dart';
import 'package:dda/utils/input_validators.dart';
import 'package:dda/view/admin_dashboard_page.dart';
import 'package:dda/view/user_dashboard_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum LoginMode { user, admin }

class LoginController extends GetxController {
  LoginController({
    StorageService? storageService,
    LoginApiService? loginApiService,
  })  : _storageService = storageService ?? StorageService(),
        _loginApiService = loginApiService ?? LoginApiService();

  final StorageService _storageService;
  final LoginApiService _loginApiService;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final Rx<LoginMode> loginMode = LoginMode.user.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String get submitLabel =>
      loginMode.value == LoginMode.user ? '사용자 로그인' : '관리자 로그인';

  void changeMode(LoginMode mode) {
    if (loginMode.value == mode) return;
    loginMode.value = mode;
    errorMessage.value = '';
  }

  Future<void> login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    errorMessage.value = '';

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final role = loginMode.value == LoginMode.admin ? 'admin' : 'user';

    debugPrint(
      'LOGIN_CLICK email=$email role=$role password_len=${password.length}',
    );

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = '이메일과 비밀번호를 입력해주세요.';
      debugPrint('LOGIN_BLOCK empty_input');
      _showError('입력 오류', errorMessage.value);
      return;
    }

    if (!InputValidators.isValidEmail(email)) {
      errorMessage.value = '올바른 이메일 형식인지 확인해주세요.';
      debugPrint('LOGIN_BLOCK invalid_email');
      _showError('이메일 오류', errorMessage.value);
      return;
    }

    isLoading.value = true;
    debugPrint('LOGIN_REQUEST start');

    try {
      final result = await _loginApiService.login(
        email: email,
        password: password,
        role: role,
      );
      debugPrint('LOGIN_REQUEST success');

      final user = result['user'] as Map<String, dynamic>;
      await _storageService.saveSession(
        role: role,
        token: result['session_token'].toString(),
        expiresAt: result['expires_at'].toString(),
        userName: user['name'].toString(),
        userEmail: user['email'].toString(),
      );

      Get.snackbar(
        '로그인 완료',
        '${user['name']}님, 환영합니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE9F8EF),
        colorText: const Color(0xFF172638),
        margin: const EdgeInsets.all(18),
      );

      if (role == 'admin') {
        Get.offAll(() => const AdminDashboardPage());
      } else {
        Get.offAll(() => const UserDashboardPage());
      }
    } catch (error) {
      debugPrint('LOGIN_REQUEST error=$error');
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
      _showError('로그인 실패', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
