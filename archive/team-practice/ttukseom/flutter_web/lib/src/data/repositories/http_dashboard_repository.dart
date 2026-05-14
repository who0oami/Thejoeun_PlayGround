import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/activity_log.dart';
import '../../domain/models/dashboard_snapshot.dart';
import '../../domain/models/parking_lot.dart';
import '../../domain/models/system_status.dart';
import '../../domain/models/weekday_stat.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../services/api_base_url.dart';

class HttpDashboardRepository implements DashboardRepository {
  HttpDashboardRepository({http.Client? client}) : _client = client ?? http.Client();

  static String get _baseUrl => ApiBaseUrl.value;

  final http.Client _client;

  @override
  Future<DashboardSnapshot> fetchDashboardSnapshot() async {
    try {
      final parkingLots = await _fetchLiveParkingLots();
      return DashboardSnapshot(
        lastUpdatedLabel: _formatNowLabel(),
        parkingLots: parkingLots,
        activityLogs: _fallbackActivityLogs,
        systemStatuses: _fallbackSystemStatuses,
        weekdayStats: _fallbackWeekdayStats,
      );
    } catch (_) {
      return DashboardSnapshot(
        lastUpdatedLabel:
            '\uC2E4\uC2DC\uAC04 \uC815\uBCF4\uAC00 \uC5C6\uC5B4\uC11C \uAE30\uBCF8 \uD654\uBA74\uC744 \uD45C\uC2DC\uD569\uB2C8\uB2E4.',
        parkingLots: _fallbackParkingLots,
        activityLogs: _fallbackActivityLogs,
        systemStatuses: _fallbackSystemStatuses,
        weekdayStats: _fallbackWeekdayStats,
      );
    }
  }

  Future<List<ParkingLot>> _fetchLiveParkingLots() async {
    final response = await _client.get(Uri.parse('$_baseUrl/parkinglot/live'));
    final body = _decodeBody(response.body);

    if (response.statusCode >= 400) {
      throw Exception(body['detail']?.toString() ?? 'Failed to load parking lot data.');
    }

    final data = body['data'];
    if (data is! List) {
      throw Exception('Parking lot data format is invalid.');
    }

    final lots = data
        .whereType<Map<String, dynamic>>()
        .map(_mapToParkingLot)
        .toList(growable: false);

    if (lots.isEmpty) {
      throw Exception('Parking lot data is empty.');
    }

    return lots;
  }

  ParkingLot _mapToParkingLot(Map<String, dynamic> item) {
    final capacity = _toInt(item['capacity']) ?? 0;
    final occupied = _toInt(item['occupied']) ?? 0;
    final available = _toInt(item['available']) ?? 0;
    final latitude = _toDouble(item['latitude']) ?? 0.0;
    final longitude = _toDouble(item['longitude']) ?? 0.0;
    final name = _nameForLot(capacity);
    final resolvedAvailable = available >= 0 ? available : 0;
    final resolvedOccupied = occupied > 0 || capacity == 0 ? occupied : capacity - resolvedAvailable;
    final ratio = capacity == 0 ? 0.0 : resolvedOccupied / capacity;

    return ParkingLot(
      name: name,
      occupied: resolvedOccupied,
      available: resolvedAvailable,
      capacity: capacity,
      latitude: latitude,
      longitude: longitude,
      statusLabel: _statusLabel(ratio),
      statusColor: _statusColor(ratio),
      progressColor: _progressColor(ratio),
    );
  }

  String _nameForLot(int capacity) {
    switch (capacity) {
      case 64:
        return '\uB69D\uC12C \uC81C1 \uC8FC\uCC28\uC7A5';
      case 356:
        return '\uB69D\uC12C \uC81C2 \uC8FC\uCC28\uC7A5';
      case 123:
        return '\uB69D\uC12C \uC81C3 \uC8FC\uCC28\uC7A5';
      case 131:
        return '\uB69D\uC12C \uC81C4 \uC8FC\uCC28\uC7A5';
      default:
        return '\uB69D\uC12C';
    }
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  String _statusLabel(double ratio) {
    if (ratio >= 0.8) return '\uD63C\uC7A1';
    if (ratio >= 0.5) return '\uBCF4\uD1B5';
    return '\uC6D0\uD65C';
  }

  Color _statusColor(double ratio) {
    if (ratio >= 0.8) return const Color(0xFFFFE4E1);
    if (ratio >= 0.5) return const Color(0xFFFFF1D6);
    return const Color(0xFFE4F0FF);
  }

  Color _progressColor(double ratio) {
    if (ratio >= 0.8) return const Color(0xFFFF5A52);
    if (ratio >= 0.5) return const Color(0xFFFFA726);
    return const Color(0xFF2F6BFF);
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{'message': body};
    }
  }

  String _formatNowLabel() {
    final now = DateTime.now().toLocal();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '\uB9C8\uC9C0\uB9C9 \uAC31\uC2E0: $y-$m-$d $hh:$mm';
  }

  static const List<ParkingLot> _fallbackParkingLots = [
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
  ];

  static const List<ActivityLog> _fallbackActivityLogs = [
    ActivityLog(
      vehicleNumber: '12\uAC00 3456',
      type: '\uC785\uCC28',
      location: '\uB69D\uC12C \uC8FC\uCC28\uC7A5',
      time: '14:22:15',
      status: '\uC644\uB8CC',
    ),
    ActivityLog(
      vehicleNumber: '98\uB098 7654',
      type: '\uCD9C\uCC28',
      location: '\uB69D\uC12C \uC8FC\uCC28\uC7A5',
      time: '14:20:02',
      status: '\uC644\uB8CC',
    ),
  ];

  static const List<SystemStatus> _fallbackSystemStatuses = [
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
  ];

  static const List<WeekdayStat> _fallbackWeekdayStats = [
    WeekdayStat(label: '\uC6D4', value: 42),
    WeekdayStat(label: '\uD654', value: 56),
    WeekdayStat(label: '\uC218', value: 61),
    WeekdayStat(label: '\uBAA9', value: 48),
    WeekdayStat(label: '\uAE08', value: 71),
    WeekdayStat(label: '\uD1A0', value: 92),
    WeekdayStat(label: '\uC77C', value: 84),
  ];
}
