import 'package:dda/model/bike_prediction.dart';
import 'package:dda/model/cycle_station.dart';
import 'package:dda/model/weather_snapshot.dart';
import 'package:dda/service/bike_prediction_api_service.dart';
import 'package:dda/service/cycle_station_api_service.dart';
import 'package:dda/service/weather_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StationMapPage extends StatefulWidget {
  const StationMapPage({
    super.key,
    this.stationId = 'ST-17',
  });

  final String stationId;

  @override
  State<StationMapPage> createState() => _StationMapPageState();
}

class _StationMapPageState extends State<StationMapPage> {
  static const _stationIds = ['ST-17', 'ST-33', 'ST-35', 'ST-232'];

  final _stationApiService = CycleStationApiService();
  final _weatherApiService = WeatherApiService();
  final _predictionApiService = BikePredictionApiService();
  final _mapController = MapController();

  late Future<List<CycleStation>> _stationsFuture;
  late String _selectedStationId;
  int _selectedHours = 1;
  final Map<String, Future<WeatherSnapshot>> _weatherFutures = {};
  final Map<String, Future<List<BikePrediction>>> _predictionFutures = {};

  @override
  void initState() {
    super.initState();
    _selectedStationId = widget.stationId;
    _stationsFuture = _stationApiService.fetchStations(_stationIds);
  }

  void _selectStation(CycleStation station) {
    setState(() {
      _selectedStationId = station.id;
    });
    _mapController.move(station.location, 16.8);
  }

  void _selectHours(int hours) {
    setState(() {
      _selectedHours = hours;
    });
  }

  Future<WeatherSnapshot> _weatherFor(CycleStation station) {
    return _weatherFutures.putIfAbsent(
      station.id,
      () => _weatherApiService.fetchDailyWeather(
        latitude: station.location.latitude,
        longitude: station.location.longitude,
      ),
    );
  }

  Future<List<BikePrediction>> _predictionsFor(
    CycleStation station,
    WeatherSnapshot weather,
  ) {
    final key = '${station.id}-$_selectedHours';
    return _predictionFutures.putIfAbsent(
      key,
      () => _predictionApiService.predict(
        station: station,
        weather: weather,
        horizonHours: _selectedHours,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대여소 지도'),
      ),
      body: FutureBuilder<List<CycleStation>>(
        future: _stationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error?.toString() ?? '스테이션 정보를 불러오지 못했습니다.',
                ),
              ),
            );
          }

          final stations = snapshot.data!;
          final selectedStation = stations.firstWhere(
            (station) => station.id == _selectedStationId,
            orElse: () => stations.first,
          );

          return FutureBuilder<WeatherSnapshot>(
            future: _weatherFor(selectedStation),
            builder: (context, weatherSnapshot) {
              return FutureBuilder<List<BikePrediction>>(
                future: weatherSnapshot.hasData
                    ? _predictionsFor(selectedStation, weatherSnapshot.data!)
                    : null,
                builder: (context, predictionSnapshot) {
                  final prediction = predictionSnapshot.data?.firstWhere(
                    (item) => item.hoursAhead == _selectedHours,
                    orElse: () => predictionSnapshot.data!.last,
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StationMapHero(
                          mapController: _mapController,
                          stations: stations,
                          selectedStationId: _selectedStationId,
                          onSelectStation: _selectStation,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: stations
                                    .map(
                                      (station) => ChoiceChip(
                                        label: Text(station.id),
                                        selected: station.id == selectedStation.id,
                                        onSelected: (_) => _selectStation(station),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                selectedStation.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '대여소 ID: ${selectedStation.id}',
                                style: const TextStyle(
                                  color: Color(0xFF51627B),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: _InfoCard(
                                      label: '현재 자전거',
                                      value: '${selectedStation.parkingCount}대',
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _InfoCard(
                                      label: '거치대 수',
                                      value: '${selectedStation.rackCount}대',
                                      color: const Color(0xFF0F766E),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                '예측 시간 선택',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(
                                  8,
                                  (index) => ChoiceChip(
                                    label: Text('${index + 1}시간'),
                                    selected: _selectedHours == index + 1,
                                    onSelected: (_) => _selectHours(index + 1),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (!weatherSnapshot.hasData)
                                const _PredictionCard(
                                  title: '예측 준비 중',
                                  body: '날씨 데이터를 불러오는 중입니다.',
                                )
                              else if (predictionSnapshot.connectionState != ConnectionState.done)
                                const _PredictionCard(
                                  title: '예측 준비 중',
                                  body: '선택한 시간대 예측을 계산하고 있습니다.',
                                )
                              else if (predictionSnapshot.hasError || prediction == null)
                                _PredictionCard(
                                  title: '${_selectedHours}시간 뒤 예측',
                                  body: '예측 데이터를 불러오지 못했습니다.',
                                )
                              else
                                _PredictionCard(
                                  title: '${_selectedHours}시간 뒤 예측',
                                  body:
                                      '예상 자전거 수 ${prediction.predictedBikeCount}대\n변화량 ${prediction.predictedDelta > 0 ? '+' : ''}${prediction.predictedDelta}대',
                                ),
                              const SizedBox(height: 16),
                              Text(
                                '위도 ${selectedStation.location.latitude.toStringAsFixed(6)}, 경도 ${selectedStation.location.longitude.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  color: Color(0xFF51627B),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _StationMapHero extends StatelessWidget {
  const _StationMapHero({
    required this.mapController,
    required this.stations,
    required this.selectedStationId,
    required this.onSelectStation,
  });

  final MapController mapController;
  final List<CycleStation> stations;
  final String selectedStationId;
  final ValueChanged<CycleStation> onSelectStation;

  @override
  Widget build(BuildContext context) {
    final selectedStation = stations.firstWhere(
      (station) => station.id == selectedStationId,
      orElse: () => stations.first,
    );

    return SizedBox(
      height: 360,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: selectedStation.location,
          initialZoom: 16.8,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dda',
          ),
          MarkerLayer(
            markers: stations
                .map(
                  (station) => Marker(
                    point: station.location,
                    width: 92,
                    height: 96,
                    child: _StationMarker(
                      station: station,
                      isSelected: station.id == selectedStationId,
                      onTap: () => onSelectStation(station),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _StationMarker extends StatelessWidget {
  const _StationMarker({
    required this.station,
    required this.isSelected,
    required this.onTap,
  });

  final CycleStation station;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF16A34A),
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
              '${station.parkingCount}대',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            station.id,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          Icon(
            Icons.location_on,
            color: isSelected ? const Color(0xFFB91C1C) : const Color(0xFFDC2626),
            size: 34,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF51627B))),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  const _PredictionCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFF51627B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
