import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:student/util/config.dart' as config;

final weatherProvider = AsyncNotifierProvider<WeatherProvider, String>(
  WeatherProvider.new,
);

class WeatherProvider extends AsyncNotifier<String> {
  @override
  Future<String> build() {
    return fetchCurrentWeather();
  }

  Future<String> fetchCurrentWeather() async {
    final uri = Uri.parse(
      'http://${config.getForwardIP()}:${config.forwardport}/restitutor/currentweather',
    );
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('API Error ${res.statusCode}: ${res.body}');
    }

    final Map<String, dynamic> data =
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    switch (data['PTY']?.toString()) {
      case '0':
        return '맑음';
      case '1':
        return '비';
      case '2':
        return '눈';
      case '3':
        return '눈';
      case '5':
        return '비';
      case '6':
        return '눈';
      case '7':
        return '눈';
      default:
        return '에러';
    }
  }
}
