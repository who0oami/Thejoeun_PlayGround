import 'package:flutter/material.dart';

import '../../domain/models/activity_log.dart';
import '../../domain/models/dashboard_snapshot.dart';
import '../../domain/models/parking_lot.dart';
import '../../domain/models/system_status.dart';
import '../../domain/models/weekday_stat.dart';
import '../../domain/repositories/dashboard_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSnapshot> fetchDashboardSnapshot() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return DashboardSnapshot(
      lastUpdatedLabel: '\uB9C8\uC9C0\uB9C9 \uAC31\uC2E0: 2026-04-09 17:40',
      parkingLots: const [
        ParkingLot(
          name: '\uB69D\uC12C \uC81C1 \uC8FC\uCC28\uC7A5',
          occupied: 44,
          available: 20,
          capacity: 64,
          latitude: 37.5276908,
          longitude: 127.0781632,
          statusLabel: '\uBCF4\uD1B5',
          statusColor: Color(0xFFFFF1D6),
          progressColor: Color(0xFFFFA726),
        ),
        ParkingLot(
          name: '\uB69D\uC12C \uC81C2 \uC8FC\uCC28\uC7A5',
          occupied: 302,
          available: 54,
          capacity: 356,
          latitude: 37.5290757,
          longitude: 127.0735242,
          statusLabel: '\uD63C\uC7A1',
          statusColor: Color(0xFFFFE4E1),
          progressColor: Color(0xFFFF5A52),
        ),
        ParkingLot(
          name: '\uB69D\uC12C \uC81C3 \uC8FC\uCC28\uC7A5',
          occupied: 88,
          available: 35,
          capacity: 123,
          latitude: 37.5306712,
          longitude: 127.0673524,
          statusLabel: '\uBCF4\uD1B5',
          statusColor: Color(0xFFFFF1D6),
          progressColor: Color(0xFFFFA726),
        ),
        ParkingLot(
          name: '\uB69D\uC12C \uC81C4 \uC8FC\uCC28\uC7A5',
          occupied: 87,
          available: 44,
          capacity: 131,
          latitude: 37.5314716,
          longitude: 127.0644017,
          statusLabel: '\uBCF4\uD1B5',
          statusColor: Color(0xFFFFF1D6),
          progressColor: Color(0xFFFFA726),
        ),
      ],
      activityLogs: const [
        ActivityLog(
          vehicleNumber: '12\uAC00 3456',
          type: '\uC785\uCC28',
          location: '\uB69D\uC12C \uC8FC\uCC28\uC7A5 A \uAD6C\uC5ED',
          time: '14:22:15',
          status: '\uC644\uB8CC',
        ),
        ActivityLog(
          vehicleNumber: '98\uB098 7654',
          type: '\uCD9C\uCC28',
          location: '\uB69D\uC12C \uC8FC\uCC28\uC7A5 B \uAD6C\uC5ED',
          time: '14:20:02',
          status: '\uC644\uB8CC',
        ),
        ActivityLog(
          vehicleNumber: '55\uB2E4 1212',
          type: '\uC785\uCC28',
          location: '\uB69D\uC12C \uC8FC\uCC28\uC7A5 C \uAD6C\uC5ED',
          time: '14:18:45',
          status: '\uC644\uB8CC',
        ),
        ActivityLog(
          vehicleNumber: '77\uB77C 9021',
          type: '\uC785\uCC28',
          location: '\uB69D\uC12C \uC8FC\uCC28\uC7A5 \uC9C4\uC785\uB85C',
          time: '14:15:09',
          status: '\uC644\uB8CC',
        ),
      ],
      systemStatuses: const [
        SystemStatus(
          name: 'IoT \uC13C\uC11C',
          description: '\uC2E4\uC2DC\uAC04 \uC5F0\uACB0 \uC0C1\uD0DC \uC591\uD638',
          icon: Icons.sensors_rounded,
          isHealthy: true,
        ),
        SystemStatus(
          name: 'CCTV',
          description: '\uC601\uC0C1 \uC218\uC9D1 \uC815\uC0C1',
          icon: Icons.videocam_rounded,
          isHealthy: true,
        ),
        SystemStatus(
          name: '\uB124\uD2B8\uC6CC\uD06C',
          description: '\uC9C0\uC5F0 \uC5C6\uC74C',
          icon: Icons.wifi_rounded,
          isHealthy: true,
        ),
      ],
      weekdayStats: const [
        WeekdayStat(label: '\uC6D4', value: 42),
        WeekdayStat(label: '\uD654', value: 56),
        WeekdayStat(label: '\uC218', value: 61),
        WeekdayStat(label: '\uBAA9', value: 48),
        WeekdayStat(label: '\uAE08', value: 71),
        WeekdayStat(label: '\uD1A0', value: 92),
        WeekdayStat(label: '\uC77C', value: 84),
      ],
    );
  }
}
