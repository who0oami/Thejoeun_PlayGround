import 'dart:convert';

import 'package:dda/model/bike_prediction.dart';
import 'package:dda/model/cycle_station.dart';
import 'package:dda/model/weather_snapshot.dart';
import 'package:dda/service/api_base_url.dart';
import 'package:http/http.dart' as http;

class BikePredictionApiService {
  static String get _baseUrl => ApiBaseUrl.value;

  Future<List<BikePrediction>> predict({
    required CycleStation station,
    required WeatherSnapshot weather,
    required int horizonHours,
  }) async {
    final uri = Uri.parse('$_baseUrl/v1/forecasts/predict');
    final payload = {
      'station_id': station.id,
      'current_bike_count': station.parkingCount,
      'horizon_hours': horizonHours,
      'features': {
        'hour_sin': 0.0,
        'hour_cos': 1.0,
        'month': DateTime.now().month,
        'dayofweek': DateTime.now().weekday - 1,
        'is_weekend': DateTime.now().weekday >= DateTime.saturday ? 1 : 0,
        'is_holiday': 0,
        'outflow_now': 0,
        'inflow_now': 0,
        'netflow_now': 0,
        'temperature_c': weather.maxTemperature,
        'humidity_percent': 60,
        'snow_cm': 0,
        'outflow_now_lag1': 0,
        'outflow_now_lag24': 0,
        'inflow_now_lag1': 0,
        'inflow_now_lag24': 0,
      },
    };

    final response = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode >= 400) {
      throw Exception('Prediction unavailable');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['predictions'] as List<dynamic>? ?? const [];
    return items
        .map((item) => BikePrediction.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
