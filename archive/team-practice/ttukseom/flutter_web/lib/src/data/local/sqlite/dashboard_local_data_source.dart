import '../../../domain/models/dashboard_snapshot.dart';

abstract class DashboardLocalDataSource {
  Future<DashboardSnapshot> fetchDashboardSnapshot();
}

class SqliteDashboardLocalDataSource implements DashboardLocalDataSource {
  @override
  Future<DashboardSnapshot> fetchDashboardSnapshot() {
    throw UnimplementedError(
      'SQLite 연결 전 단계입니다. sqflite 또는 drift 도입 후 구현하세요.',
    );
  }
}
