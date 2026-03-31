import 'dart:async';
import 'dart:convert';

import 'package:dda/service/api_base_url.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class LoginApiService {
  static String get _baseUrl => ApiBaseUrl.value;
  static const Duration _timeout = Duration(seconds: 30);
  static const String _timeoutMessage =
      '서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요.';

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      debugPrint('LOGIN_API url=$_baseUrl/v1/auth/login role=$role');
      final response = await http
          .post(
            Uri.parse('$_baseUrl/v1/auth/login'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'role': role,
            }),
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        throw Exception(body['detail']?.toString() ?? '로그인에 실패했습니다.');
      }

      return body;
    } on TimeoutException {
      throw Exception(_timeoutMessage);
    }
  }

  Future<Map<String, dynamic>> getMe({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/v1/auth/me'),
            headers: {'X-Session-Token': token},
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        throw Exception(body['detail']?.toString() ?? '세션 정보를 확인하지 못했습니다.');
      }

      return body;
    } on TimeoutException {
      throw Exception(_timeoutMessage);
    }
  }

  Future<void> logout({
    required String token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/v1/auth/logout'),
            headers: {'X-Session-Token': token},
          )
          .timeout(_timeout);

      if (response.statusCode >= 400) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(body['detail']?.toString() ?? '로그아웃에 실패했습니다.');
      }
    } on TimeoutException {
      throw Exception(_timeoutMessage);
    }
  }
}
