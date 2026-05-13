import 'activity_log.dart';
import 'parking_lot.dart';
import 'system_status.dart';
import 'weekday_stat.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.parkingLots,
    required this.activityLogs,
    required this.systemStatuses,
    required this.weekdayStats,
    required this.lastUpdatedLabel,
  });

  final List<ParkingLot> parkingLots;
  final List<ActivityLog> activityLogs;
  final List<SystemStatus> systemStatuses;
  final List<WeekdayStat> weekdayStats;
  final String lastUpdatedLabel;
}
