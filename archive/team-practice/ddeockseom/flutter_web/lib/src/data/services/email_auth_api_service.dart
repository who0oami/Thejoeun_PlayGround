import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_base_url.dart';

class EmailAuthApiService {
  EmailAuthApiService({http.Client? client}) : _client = client ?? http.Client();

  static String get _baseUrl => ApiBaseUrl.value;
  static const Duration _timeout = Duration(seconds: 30);
  static const String _timeoutMessage =
      'Server response is taking too long. Please try again later.';

  final http.Client _client;

  Future<DateTime> sendCode({
    required String email,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/v1/auth/send-code'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);

      final body = _decodeBody(response.body);
      if (response.statusCode >= 400) {
        throw Exception(
          body['detail']?.toString() ?? 'Failed to send verification code.',
        );
      }

      final rawExpiresAt = body['expires_at'] ?? body['expiresAt'];
      if (rawExpiresAt == null) {
        throw Exception('The server did not return an expiration time.');
      }

      return DateTime.parse(rawExpiresAt.toString());
    } on TimeoutException {
      throw Exception(_timeoutMessage);
    }
  }

  Future<void> verifyAndSignup({
    required String adminname,
    required String email,
    required String password,
    required String code,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/v1/auth/verify'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'adminname': adminname,
              'email': email,
              'password': password,
              'code': code,
            }),
          )
          .timeout(_timeout);

      final body = _decodeBody(response.body);
      if (response.statusCode >= 400) {
        throw Exception(body['detail']?.toString() ?? 'Signup failed.');
      }
    } on TimeoutException {
      throw Exception(_timeoutMessage);
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
