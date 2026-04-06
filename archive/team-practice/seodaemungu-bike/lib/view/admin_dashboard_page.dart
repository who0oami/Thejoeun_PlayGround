import 'dart:async';

import 'package:dda/components/dashboard_header.dart';
import 'package:dda/model/bike_prediction.dart';
import 'package:dda/model/cycle_station.dart';
import 'package:dda/model/weather_snapshot.dart';
import 'package:dda/service/bike_prediction_api_service.dart';
import 'package:dda/service/cycle_station_api_service.dart';
import 'package:dda/service/weather_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  static const _stationIds = ['ST-17', 'ST-33', 'ST-35', 'ST-232'];

  final _stationApiService = CycleStationApiService();
  final _weatherApiService = WeatherApiService();
  final _predictionApiService = BikePredictionApiService();

  late Future<List<_AdminStationSummary>> _dashboardFuture;
  String _selectedStationId = _stationIds.first;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<List<_AdminStationSummary>> _loadDashboard() async {
    final stations = await _stationApiService.fetchStations(_stationIds);
    final summaries = await Future.wait(stations.map(_buildSummary));
    summaries.sort((a, b) => b.adjustmentAmount.compareTo(a.adjustmentAmount));

    if (summaries.isNotEmpty) {
      _selectedStationId = summaries.first.station.id;
    }

    return summaries;
  }

  Future<_AdminStationSummary> _buildSummary(CycleStation station) async {
    final weather = await _weatherApiService.fetchDailyWeather(
      latitude: station.location.latitude,
      longitude: station.location.longitude,
    );

    final predictions = await _predictionApiService.predict(
      station: station,
      weather: weather,
      horizonHours: 4,
    );

    final prediction = predictions.firstWhere(
      (item) => item.hoursAhead == 4,
      orElse: () => predictions.isNotEmpty
          ? predictions.last
          : BikePrediction(
              hoursAhead: 4,
              predictedBikeCount: station.parkingCount,
              predictedDelta: 0,
              targetTime: DateTime.now().add(const Duration(hours: 4)),
            ),
    );

    final targetStock = (station.rackCount * 0.6).round();
    final stockGap = targetStock - prediction.predictedBikeCount;
    final adjustmentType = stockGap > 0
        ? _AdjustmentType.refill
        : stockGap < 0
            ? _AdjustmentType.collect
            : _AdjustmentType.stable;

    return _AdminStationSummary(
      station: station,
      weather: weather,
      prediction: prediction,
      targetStock: targetStock,
      adjustmentType: adjustmentType,
      adjustmentAmount: stockGap.abs(),
      stockGap: stockGap,
    );
  }

  void _selectStation(String stationId) {
    setState(() {
      _selectedStationId = stationId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<_AdminStationSummary>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardHeader(activeTab: '관리자 대시보드'),
                  const SizedBox(height: 24),
                  if (snapshot.connectionState != ConnectionState.done)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 120),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (snapshot.hasError)
                    _ErrorPanel(message: snapshot.error.toString())
                  else ...[
                    _OverviewSection(items: snapshot.data!),
                    const SizedBox(height: 24),
                    _MapSection(
                      items: snapshot.data!,
                      selectedStationId: _selectedStationId,
                      onSelectStation: _selectStation,
                    ),
                    const SizedBox(height: 24),
                    _PrioritySection(items: snapshot.data!),
                    const SizedBox(height: 24),
                    _StationTable(items: snapshot.data!),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.items});

  final List<_AdminStationSummary> items;

  @override
  Widget build(BuildContext context) {
    final refillTotal = items
        .where((item) => item.adjustmentType == _AdjustmentType.refill)
        .fold<int>(0, (sum, item) => sum + item.adjustmentAmount);
    final collectTotal = items
        .where((item) => item.adjustmentType == _AdjustmentType.collect)
        .fold<int>(0, (sum, item) => sum + item.adjustmentAmount);
    final actionCount =
        items.where((item) => item.adjustmentType != _AdjustmentType.stable).length;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _HeroCard(
            refillTotal: refillTotal,
            collectTotal: collectTotal,
            actionCount: actionCount,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              _MetricCard(
                title: '보충 필요 합계',
                value: '$refillTotal대',
                subtitle: '4시간 뒤 예측 재고가 목표 재고보다 부족한 정류장 합계',
                accent: const Color(0xFFDC2626),
              ),
              const SizedBox(height: 20),
              _MetricCard(
                title: '회수 필요 합계',
                value: '$collectTotal대',
                subtitle: '4시간 뒤 예측 재고가 목표 재고보다 많은 정류장 합계',
                accent: const Color(0xFF0F766E),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.refillTotal,
    required this.collectTotal,
    required this.actionCount,
  });

  final int refillTotal;
  final int collectTotal;
  final int actionCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F7A36), Color(0xFF22A652)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '관리자 재배치 현황',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '목표 재고 기준으로\n채우고 빼야 할 수량',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(label: '보충 필요', value: '$refillTotal대'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _HeroMetric(label: '회수 필요', value: '$collectTotal대'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _HeroMetric(label: '조치 정류장', value: '$actionCount곳'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF51627B))),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection({
    required this.items,
    required this.selectedStationId,
    required this.onSelectStation,
  });

  final List<_AdminStationSummary> items;
  final String selectedStationId;
  final ValueChanged<String> onSelectStation;

  @override
  Widget build(BuildContext context) {
    final selected = items.firstWhere(
      (item) => item.station.id == selectedStationId,
      orElse: () => items.first,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F2342),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '재배치 지도',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            '초록은 회수, 빨강은 보충 우선입니다. 마커를 누르면 상세 수치를 볼 수 있습니다.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 420,
            child: Row(
              children: [
                Expanded(
                  flex: 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _AdminMap(
                      items: items,
                      selectedStationId: selectedStationId,
                      onSelectStation: onSelectStation,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  flex: 4,
                  child: _AdminMapSidebar(
                    items: items,
                    selected: selected,
                    onSelectStation: onSelectStation,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMap extends StatelessWidget {
  const _AdminMap({
    required this.items,
    required this.selectedStationId,
    required this.onSelectStation,
  });

  final List<_AdminStationSummary> items;
  final String selectedStationId;
  final ValueChanged<String> onSelectStation;

  @override
  Widget build(BuildContext context) {
    final averageLat = items
            .map((item) => item.station.location.latitude)
            .reduce((a, b) => a + b) /
        items.length;
    final averageLng = items
            .map((item) => item.station.location.longitude)
            .reduce((a, b) => a + b) /
        items.length;

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(averageLat, averageLng),
        initialZoom: 14.4,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dda',
        ),
        MarkerLayer(
          markers: items
              .map(
                (item) => Marker(
                  point: item.station.location,
                  width: 92,
                  height: 96,
                  child: _AdminMarker(
                    item: item,
                    isSelected: item.station.id == selectedStationId,
                    onTap: () => onSelectStation(item.station.id),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _AdminMarker extends StatelessWidget {
  const _AdminMarker({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _AdminStationSummary item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (item.adjustmentType) {
      _AdjustmentType.refill => const Color(0xFFDC2626),
      _AdjustmentType.collect => const Color(0xFF118847),
      _AdjustmentType.stable => const Color(0xFF64748B),
    };

    final symbol = switch (item.adjustmentType) {
      _AdjustmentType.refill => '+',
      _AdjustmentType.collect => '-',
      _AdjustmentType.stable => '=',
    };

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '$symbol${item.adjustmentAmount}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.station.id,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          Icon(
            Icons.location_on,
            color: color,
            size: 34,
          ),
        ],
      ),
    );
  }
}

class _AdminMapSidebar extends StatelessWidget {
  const _AdminMapSidebar({
    required this.items,
    required this.selected,
    required this.onSelectStation,
  });

  final List<_AdminStationSummary> items;
  final _AdminStationSummary selected;
  final ValueChanged<String> onSelectStation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return _MapStationTile(
                item: item,
                isSelected: item.station.id == selected.station.id,
                onTap: () => onSelectStation(item.station.id),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _SelectedStationCard(item: selected),
      ],
    );
  }
}

class _MapStationTile extends StatelessWidget {
  const _MapStationTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _AdminStationSummary item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = switch (item.adjustmentType) {
      _AdjustmentType.refill => const Color(0xFFDC2626),
      _AdjustmentType.collect => const Color(0xFF118847),
      _AdjustmentType.stable => const Color(0xFF64748B),
    };

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF1FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? accent : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.station.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.station.id,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Text(
              item.actionLabel,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedStationCard extends StatelessWidget {
  const _SelectedStationCard({required this.item});

  final _AdminStationSummary item;

  @override
  Widget build(BuildContext context) {
    final accent = switch (item.adjustmentType) {
      _AdjustmentType.refill => const Color(0xFFDC2626),
      _AdjustmentType.collect => const Color(0xFF118847),
      _AdjustmentType.stable => const Color(0xFF64748B),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.station.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.station.id} · 날씨 ${item.weather.summary}',
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          _SidebarMetric(label: '현재 재고', value: '${item.station.parkingCount}대'),
          _SidebarMetric(label: '4시간 뒤 예측', value: '${item.prediction.predictedBikeCount}대'),
          _SidebarMetric(label: '목표 재고', value: '${item.targetStock}대'),
          const SizedBox(height: 10),
          Text(
            item.actionDescription,
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarMetric extends StatelessWidget {
  const _SidebarMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _PrioritySection extends StatelessWidget {
  const _PrioritySection({required this.items});

  final List<_AdminStationSummary> items;

  @override
  Widget build(BuildContext context) {
    final topItems = items.take(4).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '우선 조치 대상',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const Text(
            '4시간 뒤 예측 재고와 목표 재고를 비교해 많이 움직여야 하는 순서대로 정렬했습니다.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          for (final item in topItems) ...[
            _PriorityTile(item: item),
            if (item != topItems.last) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _PriorityTile extends StatelessWidget {
  const _PriorityTile({required this.item});

  final _AdminStationSummary item;

  @override
  Widget build(BuildContext context) {
    final accent = switch (item.adjustmentType) {
      _AdjustmentType.refill => const Color(0xFFDC2626),
      _AdjustmentType.collect => const Color(0xFF118847),
      _AdjustmentType.stable => const Color(0xFF64748B),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.station.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.station.id} · 현재 ${item.station.parkingCount}대 · 4시간 뒤 ${item.prediction.predictedBikeCount}대',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          Text(
            item.actionLabel,
            style: TextStyle(
              color: accent,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StationTable extends StatelessWidget {
  const _StationTable({required this.items});

  final List<_AdminStationSummary> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F2342),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '정류장별 재배치 필요 수치',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            '목표 재고는 각 정류장 거치대 수의 60%입니다. 목표보다 많으면 회수, 적으면 보충으로 계산합니다.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 22),
          ...items.map((item) => _StationRow(item: item)),
        ],
      ),
    );
  }
}

class _StationRow extends StatelessWidget {
  const _StationRow({required this.item});

  final _AdminStationSummary item;

  @override
  Widget build(BuildContext context) {
    final ratio = item.station.rackCount == 0
        ? 0.0
        : (item.prediction.predictedBikeCount / item.station.rackCount).clamp(0.0, 1.0);

    final accent = switch (item.adjustmentType) {
      _AdjustmentType.refill => const Color(0xFFDC2626),
      _AdjustmentType.collect => const Color(0xFF118847),
      _AdjustmentType.stable => const Color(0xFF64748B),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.station.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.station.id} · 정원 ${item.station.rackCount}대',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _Cell(label: '현재 재고', value: '${item.station.parkingCount}대'),
              ),
              Expanded(
                child: _Cell(label: '4시간 뒤 예측', value: '${item.prediction.predictedBikeCount}대'),
              ),
              Expanded(
                child: _Cell(label: '목표 재고', value: '${item.targetStock}대'),
              ),
              Expanded(
                child: _Cell(
                  label: item.adjustmentType == _AdjustmentType.collect ? '회수 필요' : '보충 필요',
                  value: '${item.adjustmentAmount}대',
                  valueColor: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: const Color(0xFFDCE7FA),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${item.actionDescription} · 날씨 ${item.weather.summary}, 최고 ${item.weather.maxTemperature.toStringAsFixed(0)}°C',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF0F172A),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        '관리자 데이터를 불러오지 못했습니다.\n$message',
        style: const TextStyle(
          color: Color(0xFF9F1239),
          height: 1.5,
        ),
      ),
    );
  }
}

class _AdminStationSummary {
  const _AdminStationSummary({
    required this.station,
    required this.weather,
    required this.prediction,
    required this.targetStock,
    required this.adjustmentType,
    required this.adjustmentAmount,
    required this.stockGap,
  });

  final CycleStation station;
  final WeatherSnapshot weather;
  final BikePrediction prediction;
  final int targetStock;
  final _AdjustmentType adjustmentType;
  final int adjustmentAmount;
  final int stockGap;

  String get actionLabel {
    return switch (adjustmentType) {
      _AdjustmentType.refill => '+$adjustmentAmount대',
      _AdjustmentType.collect => '-$adjustmentAmount대',
      _AdjustmentType.stable => '0대',
    };
  }

  String get actionDescription {
    return switch (adjustmentType) {
      _AdjustmentType.refill => '목표보다 ${stockGap.abs()}대 부족해서 보충이 필요합니다',
      _AdjustmentType.collect => '목표보다 ${stockGap.abs()}대 많아서 회수가 필요합니다',
      _AdjustmentType.stable => '목표 재고와 같아 이동이 필요하지 않습니다',
    };
  }
}

enum _AdjustmentType {
  refill,
  collect,
  stable,
}
