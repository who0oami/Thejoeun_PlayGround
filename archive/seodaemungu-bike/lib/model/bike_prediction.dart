class BikePrediction {
  const BikePrediction({
    required this.hoursAhead,
    required this.predictedBikeCount,
    required this.predictedDelta,
    required this.targetTime,
  });

  final int hoursAhead;
  final int predictedBikeCount;
  final int predictedDelta;
  final DateTime targetTime;

  factory BikePrediction.fromJson(Map<String, dynamic> json) {
    return BikePrediction(
      hoursAhead: json['hours_ahead'] as int? ?? 0,
      predictedBikeCount: json['predicted_bike_count'] as int? ?? 0,
      predictedDelta: json['predicted_delta'] as int? ?? 0,
      targetTime: DateTime.parse(json['target_time'].toString()),
    );
  }
}
