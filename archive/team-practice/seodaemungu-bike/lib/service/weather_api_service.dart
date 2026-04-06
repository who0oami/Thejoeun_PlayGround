import 'dart:convert';

import 'package:dda/model/weather_snapshot.dart';
import 'package:http/http.dart' as http;

class WeatherApiService {
  Future<WeatherSnapshot> fetchDailyWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max',
        'forecast_days': '1',
        'timezone': 'Asia/Seoul',
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load weather data');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final daily = decoded['daily'] as Map<String, dynamic>?;
    if (daily == null) {
      throw Exception('Missing weather payload');
    }

    double readDouble(String key) {
      final values = daily[key] as List<dynamic>?;
      final value = values?.isNotEmpty == true ? values!.first : null;
      return value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
    }

    int readInt(String key) {
      final values = daily[key] as List<dynamic>?;
      final value = values?.isNotEmpty == true ? values!.first : null;
      return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
    }

    return WeatherSnapshot(
      maxTemperature: readDouble('temperature_2m_max'),
      minTemperature: readDouble('temperature_2m_min'),
      precipitationSum: readDouble('precipitation_sum'),
      maxWindSpeed: readDouble('wind_speed_10m_max'),
      weatherCode: readInt('weather_code'),
    );
  }
}
