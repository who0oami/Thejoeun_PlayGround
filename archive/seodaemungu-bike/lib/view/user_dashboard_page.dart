import 'package:dda/components/dashboard_header.dart';
import 'package:dda/model/cycle_station.dart';
import 'package:dda/model/weather_snapshot.dart';
import 'package:dda/service/cycle_station_api_service.dart';
import 'package:dda/service/weather_api_service.dart';
import 'package:dda/view/station_map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  static const _stationIds = ['ST-17', 'ST-33', 'ST-35', 'ST-232'];

  final _stationApiService = CycleStationApiService();
  final _weatherApiService = WeatherApiService();
  late final Future<List<CycleStation>> _stationsFuture;
  final Map<String, Future<WeatherSnapshot>> _weatherFutures = {};
  String _selectedStationId = _stationIds.first;

  @override
  void initState() {
    super.initState();
    _stationsFuture = _stationApiService.fetchStations(_stationIds);
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const DashboardHeader(activeTab: '스테이션'),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: [
                        _buildMapSection(),
                        const SizedBox(height: 18),
                        _buildTimelineSection(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        _buildForecastCard(context),
                        const SizedBox(height: 18),
                        _buildWeatherCards(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF16A34A),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMapSection() {
    return FutureBuilder<List<CycleStation>>(
      future: _stationsFuture,
      builder: (context, snapshot) {
        final hasStations = snapshot.hasData && snapshot.data!.isNotEmpty;

        return Container(
          height: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: const LinearGradient(
              colors: [Color(0xFF1B7A73), Color(0xFF167A78)],
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Stack(
              children: [
                Positioned.fill(
                  child: hasStations
                      ? _DashboardStationMap(
                          stations: snapshot.data!,
                          selectedStation:
                              _selectedStation(snapshot.data!) ?? snapshot.data!.first,
                          selectedStationId: _selectedStationId,
                          onSelectStation: _selectStation,
                        )
                      : Container(
                          color: Colors.white.withOpacity(0.06),
                          child: Center(
                            child: snapshot.hasError
                                ? const Icon(
                                    Icons.map_outlined,
                                    color: Colors.white70,
                                    size: 48,
                                  )
                                : const CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(hasStations ? 0.08 : 0.0),
                  ),
                ),
                Positioned(
                  left: 22,
                  top: 22,
                  child: _buildStationPanel(snapshot),
                ),
                if (snapshot.hasError)
                  Positioned(
                    right: 24,
                    bottom: 24,
                    child: _MapErrorBubble(
                      message: '일부 스테이션 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStationPanel(AsyncSnapshot<List<CycleStation>> snapshot) {
    final stations = snapshot.data ?? const <CycleStation>[];
    final selectedStation = _selectedStation(stations);

    return Container(
      width: 340,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xB7BFE3EC),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '서대문구 스테이션',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    '스테이션 검색...',
                    style: TextStyle(color: Color(0xFF677488), fontSize: 16),
                  ),
                ),
                Icon(Icons.search),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _stationIds.length; i++) ...[
            _StationListTile(
              title: _stationName(_stationIds[i], stations),
              count: _stationCountText(_stationIds[i], stations),
              isCurrent: _stationIds[i] == _selectedStationId,
              onTap: () => _selectStation(_stationIds[i]),
            ),
            if (i != _stationIds.length - 1) const SizedBox(height: 10),
          ],
          if (selectedStation != null) ...[
            const SizedBox(height: 14),
            Text(
              '현재 선택: ${selectedStation.name}',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _stationCountText(String stationId, List<CycleStation> stations) {
    for (final station in stations) {
      if (station.id == stationId) {
        return station.parkingCount.toString().padLeft(2, '0');
      }
    }
    return '--';
  }

  String _stationName(String stationId, List<CycleStation> stations) {
    for (final station in stations) {
      if (station.id == stationId) {
        return station.name;
      }
    }
    return stationId;
  }

  CycleStation? _selectedStation(List<CycleStation> stations) {
    for (final station in stations) {
      if (station.id == _selectedStationId) {
        return station;
      }
    }
    return stations.isNotEmpty ? stations.first : null;
  }

  Widget _buildTimelineSection() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '시간대별 대여 타이밍',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: _TimeChip(label: '오전', selected: true)),
              SizedBox(width: 12),
              Expanded(child: _TimeChip(label: '오후')),
              SizedBox(width: 12),
              Expanded(child: _TimeChip(label: '야간')),
              SizedBox(width: 12),
              Expanded(child: _TimeChip(label: '직접 설정')),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFCFE0FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF118847),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('06:00'),
              Text('09:00'),
              Text('12:00'),
              Text('15:00'),
              Text('18:00'),
              Text('21:00'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCards() {
    return FutureBuilder<List<CycleStation>>(
      future: _stationsFuture,
      builder: (context, snapshot) {
        final selectedStation = _selectedStation(snapshot.data ?? const []);
        if (selectedStation == null) {
          return const Row(
            children: [
              Expanded(child: _SmallMetricCard(title: '오늘 날씨', value: '--')),
              SizedBox(width: 16),
              Expanded(child: _SmallMetricCard(title: '강수/바람', value: '--')),
            ],
          );
        }

        return FutureBuilder<WeatherSnapshot>(
          future: _weatherFutureFor(selectedStation),
          builder: (context, weatherSnapshot) {
            if (weatherSnapshot.connectionState != ConnectionState.done) {
              return const Row(
                children: [
                  Expanded(child: _SmallMetricCard(title: '오늘 날씨', value: '불러오는 중')),
                  SizedBox(width: 16),
                  Expanded(child: _SmallMetricCard(title: '강수/바람', value: '불러오는 중')),
                ],
              );
            }

            if (weatherSnapshot.hasError || !weatherSnapshot.hasData) {
              return const Row(
                children: [
                  Expanded(child: _SmallMetricCard(title: '오늘 날씨', value: '오류')),
                  SizedBox(width: 16),
                  Expanded(child: _SmallMetricCard(title: '강수/바람', value: '오류')),
                ],
              );
            }

            final weather = weatherSnapshot.data!;
            return Row(
              children: [
                Expanded(
                  child: _SmallMetricCard(
                    title: '오늘 날씨',
                    value:
                        '${weather.summary}\n${weather.maxTemperature.toStringAsFixed(0)} / ${weather.minTemperature.toStringAsFixed(0)}도',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SmallMetricCard(
                    title: '강수/바람',
                    value:
                        '${weather.precipitationSum.toStringAsFixed(1)} mm\n${weather.maxWindSpeed.toStringAsFixed(1)} km/h',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<WeatherSnapshot> _weatherFutureFor(CycleStation station) {
    return _weatherFutures.putIfAbsent(
      station.id,
      () => _weatherApiService.fetchDailyWeather(
        latitude: station.location.latitude,
        longitude: station.location.longitude,
      ),
    );
  }

  Widget _buildForecastCard(BuildContext context) {
    return FutureBuilder<List<CycleStation>>(
      future: _stationsFuture,
      builder: (context, snapshot) {
        final selectedStation = _selectedStation(snapshot.data ?? const []);
        final parkingCount = selectedStation?.parkingCount ?? 0;
        final stationName = selectedStation?.name ?? '스테이션';

        return Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(34),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120F2342),
                blurRadius: 34,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '대여 예측',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.1),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F9EC),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'AI POWERED',
                      style: TextStyle(color: Color(0xFF118847), fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                stationName,
                style: const TextStyle(fontSize: 16, color: Color(0xFF51627B)),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$parkingCount',
                    style: const TextStyle(
                      fontSize: 72,
                      color: Color(0xFF118847),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 18),
                    child: Text('대', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '현재 이용 가능한 자전거 수를 보여줍니다.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 18),
              _forecastStatus(parkingCount),
              const SizedBox(height: 16),
              _batteryStatus(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => StationMapPage(stationId: _selectedStationId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('지금 대여하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _forecastStatus(int parkingCount) {
    final isAvailable = parkingCount > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF22C55E), width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '실시간 대여 결과',
                  style: TextStyle(color: Color(0xFF51627B), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  isAvailable ? '대여 가능' : '대여 어려움',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF118847),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF118847),
            child: Icon(isAvailable ? Icons.check : Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _batteryStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(child: Text('평균 배터리 잔량', style: TextStyle(fontWeight: FontWeight.w600))),
              Text('84%', style: TextStyle(color: Color(0xFF118847), fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(
              5,
              (index) => Expanded(
                child: Container(
                  height: 16,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: index < 4 ? const Color(0xFF118847) : const Color(0xFFD8E2F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStationMap extends StatefulWidget {
  const _DashboardStationMap({
    required this.stations,
    required this.selectedStation,
    required this.selectedStationId,
    required this.onSelectStation,
  });

  final List<CycleStation> stations;
  final CycleStation selectedStation;
  final String selectedStationId;
  final ValueChanged<String> onSelectStation;

  @override
  State<_DashboardStationMap> createState() => _DashboardStationMapState();
}

class _DashboardStationMapState extends State<_DashboardStationMap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant _DashboardStationMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedStationId != widget.selectedStationId) {
      _mapController.move(widget.selectedStation.location, 16.8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.selectedStation.location,
        initialZoom: 16.8,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dda',
        ),
        MarkerLayer(
          markers: widget.stations
              .map(
                (station) => Marker(
                  point: station.location,
                  width: 70,
                  height: 70,
                  child: _MapMarker(
                    count: station.parkingCount,
                    selected: station.id == widget.selectedStationId,
                    onTap: () => widget.onSelectStation(station.id),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _StationListTile extends StatelessWidget {
  const _StationListTile({
    required this.title,
    required this.count,
    required this.onTap,
    this.isCurrent = false,
  });

  final String title;
  final String count;
  final VoidCallback onTap;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isCurrent ? const Color(0xFF93C5BE) : const Color(0xFFCBE4F0),
            borderRadius: BorderRadius.circular(18),
            border: isCurrent
                ? const Border(left: BorderSide(color: Color(0xFF118847), width: 4))
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCurrent)
                      const Text(
                        'CURRENT',
                        style: TextStyle(color: Color(0xFF118847), fontWeight: FontWeight.w800),
                      ),
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Text(
                count,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF118847),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? const Color(0xFF16A34A) : const Color(0xFF22C55E),
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Center(
          child: Text(
            '$count',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _MapErrorBubble extends StatelessWidget {
  const _MapErrorBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF51627B),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    this.selected = false,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF16A34A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF0D1B2A),
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SmallMetricCard extends StatelessWidget {
  const _SmallMetricCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF51627B))),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
