import 'dart:convert';
import 'dart:ui';
import 'package:customer_app/database/selected_store_database.dart';
import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/util/pcolor.dart';
import 'package:customer_app/util/snackbar.dart';
import 'package:customer_app/view/home/tabbar.dart';
import 'package:customer_app/view/map/map_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlng;

class MapSelect extends StatefulWidget {
  const MapSelect({super.key});

  @override
  State<MapSelect> createState() => _MapSelectState();
}

class _MapSelectState extends State<MapSelect> {
  // Property
  MapController mapController = MapController();
  TextEditingController searchController = TextEditingController();
  int? selectedStoreId;
  String query = '';
  List storeList = [];

  bool canRun = false;
  double latData = 0.0;
  double longData = 0.0;

  final SelectedStoreDatabase selectedStoreDB = SelectedStoreDatabase();

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
    loadStoreData();
    loadSelectedStoreId();
  }

  void checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      getCurrentLocation();
    }
  }

  void getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    latData = position.latitude;
    longData = position.longitude;
    canRun = true;
    await loadStoreData();
    if (mounted) setState(() {});
  }

  Future<void> loadStoreData() async {
    var url = Uri.parse("${IpAddress.baseUrl}/store/select");
    var response = await http.get(url);
    var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
    List result = dataConvertedJSON['results'];
    
    setState(() {
      storeList = query.isEmpty 
          ? result 
          : result.where((store) => store['name'].toString().contains(query)).toList();
      
      if (canRun) {
        storeList.sort((a, b) {
          double distA = Geolocator.distanceBetween(latData, longData, a['lat'], a['long']);
          double distB = Geolocator.distanceBetween(latData, longData, b['lat'], b['long']);
          return distA.compareTo(distB);
        });
      }
    });
  }

  Future<void> loadSelectedStoreId() async {
    final sid = await selectedStoreDB.queryStoreId();
    if (sid != null) {
      setState(() => selectedStoreId = sid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text('매장 검색', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildMapSection(),
          const Padding(
            padding: EdgeInsets.fromLTRB(25, 20, 25, 10),
            child: Row(
              children: [
                Icon(Icons.near_me, size: 16, color: Colors.blue),
                SizedBox(width: 5),
                Text("가까운 매장 리스트", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          Expanded(child: _buildStoreList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextField(
          controller: searchController,
          onSubmitted: (v) {
            query = v.trim();
            loadStoreData();
          },
          decoration: InputDecoration(
            hintText: '찾으시는 지점명을 입력하세요',
            hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.black54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send_rounded),
              onPressed: () {
                query = searchController.text.trim();
                loadStoreData();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            canRun ? flutterMap() : const Center(child: CircularProgressIndicator(color: Colors.black)),
            Positioned(
              right: 12,
              bottom: 12,
              child: Column(
                children: [
                  _mapFloatingButton(Icons.my_location, () {
                    mapController.move(latlng.LatLng(latData, longData), 16.0);
                  }),
                  const SizedBox(height: 8),
                  _mapFloatingButton(Icons.zoom_out_map, () {
                    double? tLat; double? tLng;
                    if (selectedStoreId != null) {
                      final s = storeList.firstWhere((e) => e['id'] == selectedStoreId, orElse: () => null);
                      if (s != null) { tLat = s['lat']; tLng = s['long']; }
                    }
                    Get.to(MapDetail(), arguments: {'lat': tLat, 'lng': tLng});
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapFloatingButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(12), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)]
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }

  Widget _buildStoreList() {
    if (storeList.isEmpty) return const Center(child: Text("결과가 없습니다."));
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
      itemCount: storeList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final store = storeList[index];
        final int storeId = store['id'];
        final bool isSelected = (selectedStoreId == storeId);
        
        double distance = canRun ? Geolocator.distanceBetween(latData, longData, store['lat'], store['long']) : 0;
        String distanceText = distance >= 1000 ? '${(distance / 1000).toStringAsFixed(1)}km' : '${distance.toStringAsFixed(0)}m';

        return GestureDetector(
          onTap: () {
            setState(() => selectedStoreId = storeId);
            mapController.move(latlng.LatLng(store['lat'], store['long']), 16.0);
            selectStore(store); // 하단 바텀시트 호출
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? Colors.black : Colors.grey[200]!),
              boxShadow: isSelected 
                  ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))] 
                  : [],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            store['name'], 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 17, 
                              color: isSelected ? Colors.white : Colors.black
                            )
                          ),
                          const SizedBox(width: 8),
                          if (index == 0 && canRun) 
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), 
                              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)), 
                              child: const Text("가까운 매장", style: TextStyle(color: Colors.white, fontSize: 10))
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        store['address'], 
                        style: TextStyle(fontSize: 13, color: isSelected ? Colors.white70 : Colors.grey[600])
                      ),
                      const SizedBox(height: 10),
                      Text(
                        distanceText, 
                        style: TextStyle(fontWeight: FontWeight.w900, color: isSelected ? Colors.blue[200] : Colors.blue)
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_off, 
                  color: isSelected ? Colors.white : Colors.grey[300],
                  size: 26,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  FlutterMap flutterMap() {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: latlng.LatLng(latData, longData), 
        initialZoom: 15.0
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: "com.tj.gpsmapapp",
        ),
        MarkerLayer(
          markers: [
            // 현위치 마커
            Marker(
              point: latlng.LatLng(latData, longData), 
              child: const Icon(Icons.my_location, color: Colors.blue, size: 30)
            ),
            // 매장 마커들
            ...storeList.map((s) => Marker(
              point: latlng.LatLng(s['lat'], s['long']),
              child: Icon(
                Icons.location_on, 
                color: selectedStoreId == s['id'] ? Colors.red : Colors.black, 
                size: selectedStoreId == s['id'] ? 40 : 30
              ),
            )),
          ],
        ),
      ],
    );
  }

  void selectStore(Map<String, dynamic> store) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const Text("매장 선택 확인", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("${store['name']} 지점을 선택하시겠습니까?", style: const TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 35),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 55), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      side: BorderSide(color: Colors.grey[300]!)
                    ), 
                    onPressed: () => Get.back(), 
                    child: const Text("취소", style: TextStyle(color: Colors.black))
                  )
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, 
                      minimumSize: const Size(0, 55), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ), 
                    onPressed: () async {
                      final int storeId = store['id'];
                      final String storeName = store['name'];
                      await selectedStoreDB.insertStoreId(storeId);
                      if (Get.isRegistered<StoreController>()) {
                        Get.find<StoreController>().updateStoreName(storeName);
                      }
                      Get.back(); // 바텀시트 닫기
                      Get.back(result: {'branchName': storeName, 'sid': storeId}); // 이전 화면으로 데이터 전송
                      Snackbar().okSnackBar('성공', '매장이 선택 되었습니다.');
                    }, 
                    child: const Text("매장 선택", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                  )
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}