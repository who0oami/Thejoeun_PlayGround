import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:teacher/util/config.dart' as config;
import 'package:teacher/vm/restitutor/weather_provider.dart';

//  Forecast Provider
/*
  Created in: 18/01/2026 14:35
  Author: Chansol, Park
  Description: Forecast Provider for next 6 hrs
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
*/

final forecastProvider = AsyncNotifierProvider<ForecastProvider, List<String>>(
  ForecastProvider.new,
);

class ForecastProvider extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async{
    await ref.watch(weatherProvider.future);
    return fetchForecast();
  }

  Future<List<String>> fetchForecast() async {
    final uri = Uri.parse(
      'http://${config.getForwardIP()}:${config.forwardport}/restitutor/forecast',
    );
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('API Error ${res.statusCode}: ${res.body}');
    }

    final Map<String, dynamic> forecasts =
        jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

    final List<String> result = List.generate(forecasts.length, (index) {
      final pty = forecasts['$index']?['PTY']?.toString() ?? '에러';
      return calculateForecast(pty);
    });

    return result;
  }

  String calculateForecast(String input) {
    switch (input) {
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
