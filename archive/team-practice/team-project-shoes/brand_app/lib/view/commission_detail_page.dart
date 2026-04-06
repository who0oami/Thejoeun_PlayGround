import 'dart:convert';
import 'package:brand_app/ip/ipaddress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CommissionDetailPage extends StatefulWidget {
  const CommissionDetailPage({super.key});

  @override
  State<CommissionDetailPage> createState() => _CommissionDetailPageState();
}

class _CommissionDetailPageState extends State<CommissionDetailPage> {
  late Map<String, dynamic> item;
  late int refId;
  String? serverProductName;

  late TextEditingController quantityController;

  @override
  void initState() {
    super.initState();
    item = Get.arguments as Map<String, dynamic>;
    refId = item['refId'] ?? item['pid'];
    serverProductName = item['serverProductName'] ?? item['product_name'] ?? item['ename'];

    quantityController = TextEditingController(text: item['quantity']?.toString() ?? "0");

    if (item['serverProductName'] == null) {
      _fetchRealProductName();
    }
  }

  Future<void> _fetchRealProductName() async {
    try {
      final url = Uri.parse("${IpAddress.baseUrl}/productname/select?pid=$refId");
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final decoded = json.decode(utf8.decode(res.bodyBytes));
        final List results = decoded['results'];
        if (results.isNotEmpty) {
          if (mounted) {
            setState(() {
              serverProductName = results[0]['name'].toString();
            });
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    quantityController.dispose();
    super.dispose();
  }

  Future<void> completeCommission() async {
    final request = http.MultipartRequest("POST", Uri.parse("${IpAddress.baseUrl}/commission/complete"));
    request.fields['commission_id'] = item['commission_id']?.toString() ?? item['id'].toString();
    request.fields['pid'] = item['pid'].toString();
    request.fields['quantity'] = quantityController.text;

    final response = await request.send();

    if (response.statusCode == 200) {
      Get.snackbar("성공", "입고 처리가 완료되었습니다.",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.green, colorText: Colors.white);
      Get.back();
    } else {
      Get.snackbar("오류", "입고 처리에 실패했습니다.",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void confirmComplete() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 50, color: Colors.blueAccent),
            const SizedBox(height: 15),
            const Text("입고 확정", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("${serverProductName}\n${quantityController.text}개를 입고하시겠습니까?", textAlign: TextAlign.center),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("취소"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () { Get.back(); completeCommission(); },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("확정", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text("입고 검수", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🏷 상단 상태 표시 바
            Container(
              width: double.infinity,
              color: Colors.blueAccent.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text("실물 수량과 시스템 수량을 대조해 주세요.", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🖼 Hero 이미지 섹션
                  Center(
                    child: Hero(
                      tag: "comm_${item['pid']}",
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            "${IpAddress.baseUrl}/productimage/view?pid=$refId&position=main",
                            width: 220, height: 220, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(width: 220, height: 220, color: Colors.white, child: const Icon(Icons.image_not_supported, size: 50)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),

                  // 📝 상품 상세 정보 카드
                  _buildSectionTitle("상품 정보"),
                  _buildInfoCard(
                    child: Column(
                      children: [
                        _buildInfoRow("상품명", serverProductName ?? "로딩 중..."),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(child: _buildInfoRow("사이즈", "${item['product_size']} mm")),
                            Container(width: 1, height: 20, color: Colors.grey[200]),
                            Expanded(child: _buildInfoRow("컬러", "${item['product_color']}", crossAxisAlignment: CrossAxisAlignment.end)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 🔢 수량 수정 섹션
                  _buildSectionTitle("최종 입고 수량 확인"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 2),
                    ),
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        suffixText: "개",
                        suffixStyle: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 🔘 처리 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: confirmComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text("검수 완료 및 입고 확정", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF6B7280))),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value, {CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start}) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}