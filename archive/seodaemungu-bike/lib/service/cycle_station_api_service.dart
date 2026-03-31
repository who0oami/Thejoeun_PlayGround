import 'dart:convert';

import 'package:dda/model/cycle_station.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class CycleStationApiService {
  static const String _apiKey = '595975485377617236307a746f5179';

  Future<List<CycleStation>> fetchStations(List<String> stationIds) async {
    final stations = <CycleStation>[];

    for (final stationId in stationIds) {
      try {
        stations.add(await fetchStation(stationId));
      } catch (_) {
        continue;
      }
    }

    if (stations.isEmpty) {
      throw Exception('스테이션 정보를 불러오지 못했습니다.');
    }

    return stations;
  }

  Future<CycleStation> fetchStation(String stationId) async {
    final uri = Uri.parse(
      'http://openapi.seoul.go.kr:8088/$_apiKey/json/bikeList/1/1/$stationId',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to load station: $stationId');
    }

    final body = utf8.decode(response.bodyBytes, allowMalformed: true);
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final bikeStatus = decoded['rentBikeStatus'] as Map<String, dynamic>?;
    final rows = bikeStatus?['row'] as List<dynamic>?;

    if (rows == null || rows.isEmpty) {
      throw Exception('Empty station data: $stationId');
    }

    final row = rows.first as Map<String, dynamic>;
    final latitude = double.tryParse(row['stationLatitude']?.toString() ?? '');
    final longitude = double.tryParse(row['stationLongitude']?.toString() ?? '');

    if (latitude == null || longitude == null) {
      throw Exception('Invalid coordinates: $stationId');
    }

    return CycleStation(
      id: stationId,
      name: row['stationName']?.toString() ?? stationId,
      parkingCount: int.tryParse(row['parkingBikeTotCnt']?.toString() ?? '') ?? 0,
      rackCount: int.tryParse(row['rackTotCnt']?.toString() ?? '') ?? 0,
      location: LatLng(latitude, longitude),
    );
  }
}
