import 'dart:convert';
import 'package:brand_app/ip/ipaddress.dart';
import 'package:brand_app/view/commission_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CommissionListPage extends StatefulWidget {
  const CommissionListPage({super.key});

  @override
  State<CommissionListPage> createState() => _CommissionListPageState();
}

class _CommissionListPageState extends State<CommissionListPage> {
  List<Map<String, dynamic>> data = [];
  bool isLoading = true;

  final Map<int, int> groupIdCache = {};
  final Map<int, String> productNameCache = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    
    await fetchData();
    await _resolveAllGroupIds();
    await _resolveAllProductNames();

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchData() async {
    try {
      final res = await http.get(Uri.parse("${IpAddress.baseUrl}/commission/select"));
      if (res.statusCode == 200) {
        final decoded = json.decode(utf8.decode(res.bodyBytes));
        data = List<Map<String, dynamic>>.from(decoded['results']);
      }
    } catch (e) {
      debugPrint("fetchData error: $e");
    }
  }

  Future<int> _getGroupIdFromServer(int pid) async {
    if (groupIdCache.containsKey(pid)) return groupIdCache[pid]!;
    try {
      final url = Uri.parse("${IpAddress.baseUrl}/product/selectdetail2?pid=$pid");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final decoded = json.decode(utf8.decode(res.bodyBytes));
        if (decoded != null && decoded['group_id'] != null) {
          final int gid = int.parse(decoded['group_id'].toString());
          groupIdCache[pid] = gid;
          return gid;
        }
      }
    } catch (_) {}
    return pid;
  }

  Future<String> _getProductNameFromServer(int refId) async {
    if (productNameCache.containsKey(refId)) return productNameCache[refId]!;
    try {
      final url = Uri.parse("${IpAddress.baseUrl}/productname/select?pid=$refId");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final decoded = json.decode(utf8.decode(res.bodyBytes));
        final List results = decoded['results'];
        if (results.isNotEmpty) {
          final String name = results[0]['name'].toString();
          productNameCache[refId] = name;
          return name;
        }
      }
    } catch (_) {}
    return "상품명 없음";
  }

  Future<void> _resolveAllGroupIds() async {
    await Future.wait(data.map((item) => _getGroupIdFromServer(item['pid'] ?? 0)));
  }

  Future<void> _resolveAllProductNames() async {
    final refIds = groupIdCache.values.toSet();
    await Future.wait(refIds.map((id) => _getProductNameFromServer(id)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        title: const Text("입고 대기 현황", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(onPressed: _init, icon: const Icon(Icons.sync, color: Colors.black)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : RefreshIndicator(
              onRefresh: _init,
              color: Colors.black,
              child: data.isEmpty
                  ? _buildEmptyState()
                  : _buildListView(),
            ),
    );
  }

  Widget _buildEmptyState() {
    return ListView( // RefreshIndicator 작동을 위해 ListView 사용
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text("현재 대기 중인 입고 내역이 없습니다.", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final int pid = item['pid'] ?? 0;
        final int refId = groupIdCache[pid] ?? pid;
        final String displayTitle = productNameCache[refId] ?? (item['ename'] ?? "상품명 확인 중...");

        return GestureDetector(
          onTap: () async {
            await Get.to(
              () => const CommissionDetailPage(),
              arguments: { ...item, 'refId': refId, 'serverProductName': displayTitle },
            );
            _init();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 🖼 상품 이미지 영역
                  Hero(
                    tag: "comm_$pid",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        "${IpAddress.baseUrl}/productimage/view?pid=$refId&position=main",
                        width: 85, height: 85, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 85, height: 85, color: const Color(0xFFF1F3F5),
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 📝 상품 정보 영역
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayTitle,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildOptionTag(item['product_color'] ?? '-'),
                            const SizedBox(width: 6),
                            _buildOptionTag("${item['product_size']}mm"),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("입고 예정 수량", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                            Text(
                              "${item['quantity']}개",
                              style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900, fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFCED4DA)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFF495057), fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}