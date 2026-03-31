import 'dart:async';
import 'dart:convert';

import 'package:dda/service/api_base_url.dart';
import 'package:http/http.dart' as http;

class EmailAuthApiService {
  static String get _baseUrl => ApiBaseUrl.value;
  static const Duration _timeout = Duration(seconds: 30);
  static const String _timeoutMessage =
      '서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요.';

  Future<DateTime> sendCode({
    required String email,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/v1/auth/send-code'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        throw Exception(
          body['detail']?.toString() ?? '인증번호 전송에 실패했습니다.',
        );
      }

      return DateTime.parse(body['expires_at'].toString());
    } on TimeoutException {
      throw Exception(_timeoutMessage);
    }
  }

  Future<void> verifyAndSignup({
    required String name,
    required String gender,
    required String email,
    required String password,
    required String role,
    required String code,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/v1/auth/verify'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'gender': gender,
              'email': email,
              'password': password,
              'role': role,
              'code': code,
            }),
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        throw Exception(body['detail']?.toString() ?? '회원가입에 실패했습니다.');
      }
    } on TimeoutException {
      throw Exception(_timeoutMessage);
    }
  }
}
