import 'dart:convert';
import 'package:customer_app/database/selected_store_database.dart';
import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/view/home/home.dart';
import 'package:customer_app/view/map/map_select.dart';
import 'package:customer_app/view/mypage/mypage.dart';
import 'package:customer_app/view/shoppingcart/shoppingcart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// 🔹 상태 관리를 위한 GetX 컨트롤러
class StoreController extends GetxController {
  var selectedStoreName = "지점을 선택해주세요".obs;
  void updateStoreName(String name) => selectedStoreName.value = name;
}

class Tabbar extends StatefulWidget {
  const Tabbar({super.key});

  @override
  State<Tabbar> createState() => _TabbarState();
}

class _TabbarState extends State<Tabbar> {
  // 컨트롤러 주입
  final StoreController storeController = Get.put(StoreController());
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Home(),
    const MapSelect(),
    const Shoppingcart(),
    const Mypage()
  ];

  @override
  void initState() {
    super.initState();
    // ✅ 앱 시작 시 SQLite에서 저장된 지점 정보를 불러옴
    _initialLoad();
  }

  /// 🔹 SQLite에서 저장된 sid를 읽어와서 서버에서 지점명을 가져오는 핵심 함수
  Future<void> _initialLoad() async {
    final db = SelectedStoreDatabase();
    int? sid = await db.queryStoreId();

    if (sid != null) {
      try {
        // Purchase2와 동일하게 전체 지점 목록에서 매칭되는 sid를 찾음
        var url = Uri.parse('${IpAddress.baseUrl}/store/select');
        var response = await http.get(url);

        if (response.statusCode == 200) {
          var data = json.decode(utf8.decode(response.bodyBytes));
          List results = data['results'];

          var matched = results.firstWhere(
            (s) => s['id'] == sid, 
            orElse: () => null
          );

          if (matched != null) {
            // ✅ 찾은 지점명을 컨트롤러에 업데이트 (Obx가 감시 중이므로 즉시 반영)
            storeController.updateStoreName(matched['name']);
          }
        }
      } catch (e) {
        debugPrint("Tabbar 지점 정보 로드 에러: $e");
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- 🔹 지점 정보 표시줄 (Obx로 감싸서 실시간 반영) ---
          Obx(() => GestureDetector(
            onTap: () async {
              // ✅ 지도 페이지로 이동 후 돌아올 때까지 기다림
              await Get.to(() => const MapSelect());
              // ✅ 지도에서 지점을 바꾸고 돌아오면 다시 정보를 읽어서 갱신
              await _initialLoad();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              color: const Color(0xFF1E1E1E), 
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    storeController.selectedStoreName.value,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 13, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.refresh, color: Colors.grey, size: 14),
                ],
              ),
            ),
          )),
          // --- 하단 탭바 ---
          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF121212),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), activeIcon: Icon(Icons.location_on), label: 'Location'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Shop'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ],
      ),
    );
  }
}