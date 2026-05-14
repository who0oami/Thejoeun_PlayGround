import '../models/dashboard_snapshot.dart';

abstract class DashboardRepository {
  Future<DashboardSnapshot> fetchDashboardSnapshot();
}
