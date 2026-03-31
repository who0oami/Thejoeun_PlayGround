class WeatherSnapshot {
  const WeatherSnapshot({
    required this.maxTemperature,
    required this.minTemperature,
    required this.precipitationSum,
    required this.maxWindSpeed,
    required this.weatherCode,
  });

  final double maxTemperature;
  final double minTemperature;
  final double precipitationSum;
  final double maxWindSpeed;
  final int weatherCode;

  String get summary {
    if (weatherCode == 0) return '맑음';
    if (weatherCode <= 3) return '구름';
    if (weatherCode <= 67) return '비';
    if (weatherCode <= 77) return '눈';
    if (weatherCode <= 82) return '소나기';
    if (weatherCode <= 99) return '뇌우';
    return '날씨';
  }
}
