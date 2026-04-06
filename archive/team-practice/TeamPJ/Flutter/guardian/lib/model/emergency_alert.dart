class EmergencyAlert {
  final String id;
  final double lat;
  final double lng;

  EmergencyAlert({
    required this.id,
    required this.lat,
    required this.lng,
  });

  factory EmergencyAlert.fromMap(String id, Map<String, dynamic> data) {
    return EmergencyAlert(
      id: id,
      lat: (data["alert_lat"] as int).toDouble(),
      lng: (data["alert_lng"] as int).toDouble(),
    );
  }
}
