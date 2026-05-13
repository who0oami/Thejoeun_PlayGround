import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_base_url.dart';

class AuthApiResult {
  AuthApiResult({required this.success, required this.message, this.data});

  final bool success;
  final String message;
  final Map<String, dynamic>? data;
}

class AuthApiService {
  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  static String get _baseUrl => ApiBaseUrl.value;
  static const Duration _timeout = Duration(seconds: 30);
  static const String _timeoutMessage =
      'Server response is taking too long. Please try again later.';

  final http.Client _client;

  Future<AuthApiResult> login({
    required String email,
    required String password,
  }) async {
    return _post('/v1/auth/login', {
      'id': email,
      'password': password,
    });
  }

  Future<AuthApiResult> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      final bodyMap = _decodeBody(response.body);
      final message = bodyMap['message'] as String? ?? bodyMap['detail'] as String?;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthApiResult(
          success: true,
          message: message ?? 'Request completed successfully.',
          data: bodyMap['data'] as Map<String, dynamic>?,
        );
      }

      return AuthApiResult(
        success: false,
        message: message ?? response.reasonPhrase ?? 'Request failed.',
        data: bodyMap['errors'] as Map<String, dynamic>?,
      );
    } on TimeoutException {
      return AuthApiResult(success: false, message: _timeoutMessage);
    }
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{'message': body};
    }
  }
}
