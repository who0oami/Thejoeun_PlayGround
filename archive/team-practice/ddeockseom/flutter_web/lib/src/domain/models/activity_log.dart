class ActivityLog {
  const ActivityLog({
    required this.vehicleNumber,
    required this.type,
    required this.location,
    required this.time,
    required this.status,
  });

  final String vehicleNumber;
  final String type;
  final String location;
  final String time;
  final String status;
}
