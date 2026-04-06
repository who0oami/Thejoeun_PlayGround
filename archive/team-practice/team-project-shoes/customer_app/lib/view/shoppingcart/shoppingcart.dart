import 'dart:convert';
import 'package:customer_app/model/usercontroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:customer_app/database/cartdatabasehandler.dart';
import 'package:customer_app/model/cart.dart';
import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/for test/purchase2.dart';
import 'package:intl/intl.dart';

class Shoppingcart extends StatefulWidget {
  const Shoppingcart({super.key});

  @override
  State<Shoppingcart> createState() => _ShoppingcartState();
}

class _ShoppingcartState extends State<Shoppingcart> {
  final UserController userController = Get.find<UserController>();
  final Cartdatabasehandler handler = Cartdatabasehandler();
  final f = NumberFormat('###,###,###,###');

  late Future<List<Cart>> cartFuture;
  final Map<int, int> quantityMap = {};
  final Map<int, Map<String, dynamic>> productCache = {};

  @override
  void initState() {
    super.initState();
    cartFuture = handler.queryCart();
  }

  // 기존 기능 유지 (기능 수정 없음)
  Future<Map<String, dynamic>?> getProductDetail(int pid) async {
    if (productCache.containsKey(pid)) return productCache[pid];
    try {
      final detailUrl = Uri.parse("${IpAddress.baseUrl}/product/selectdetail2?pid=$pid");
      final detailRes = await http.get(detailUrl);
      if (detailRes.statusCode == 200) {
        final detailData = json.decode(utf8.decode(detailRes.bodyBytes));
        final List results = detailData['results'];
        if (results.isEmpty) return null;
        final Map<String, dynamic> detail = Map<String, dynamic>.from(
          results.firstWhere((e) => e['id'] == pid, orElse: () => results.first)
        );
        final int mid = detail['mid'] ?? pid;
        final nameUrl = Uri.parse("${IpAddress.baseUrl}/productname/select?pid=$mid");
        final nameRes = await http.get(nameUrl);
        String realName = detail['product_name']?.toString() ?? "상품명 없음";
        if (nameRes.statusCode == 200) {
          final nameData = json.decode(utf8.decode(nameRes.bodyBytes));
          final List nameResults = nameData['results'];
          if (nameResults.isNotEmpty) {
            realName = nameResults[0]['name'].toString();
          }
        }
        final Map<String, dynamic> combinedData = {...detail, 'real_name': realName};
        productCache[pid] = combinedData;
        return combinedData;
      }
    } catch (e) {
      debugPrint("에러: $e");
    }
    return null;
  }

  Future<void> deleteCartItem(int cartRowId) async {
    await handler.deleteCart(cartRowId);
    quantityMap.remove(cartRowId);
    setState(() { cartFuture = handler.queryCart(); });
  }

  Future<void> goToPayment(List<Cart> carts) async {
    if (carts.isEmpty) return;
    final List<Map<String, dynamic>> orderItems = [];
    for (final cart in carts) {
      final int pid = cart.cartid;
      final int qty = quantityMap[cart.id] ?? 1;
      final item = productCache[pid] ?? await getProductDetail(pid);
      if (item == null) continue;
      orderItems.add({
        "pid": pid,
        "cid": userController.user!.id,
        "price": item['price'],
        "quantity": qty,
        "name": item['real_name'],
        "manufacturername": item['manufacturer_name'] ?? "",
        "size": item['size'] ?? "-",
        "color": item['color'] ?? "-",
        "image": '${IpAddress.baseUrl}/productimage/view?pid=${item['mid']}&position=main',
      });
    }
    Get.to(() => const Purchase2(), arguments: {"items": orderItems});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text("SHOPPING BAG", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Cart>>(
        future: cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }
          final carts = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: carts.length,
                  itemBuilder: (context, index) {
                    final cart = carts[index];
                    final int cartRowId = cart.id!;
                    final int pid = cart.cartid;
                    quantityMap.putIfAbsent(cartRowId, () => 1);

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: getProductDetail(pid),
                      builder: (context, productSnapshot) {
                        if (!productSnapshot.hasData) return const SizedBox(height: 120);
                        final item = productSnapshot.data!;
                        final int qty = quantityMap[cartRowId] ?? 1;
                        final int mid = item['mid'] ?? pid;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 상품 이미지
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  '${IpAddress.baseUrl}/productimage/view?pid=$mid&position=main',
                                  width: 100, height: 125, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(width: 100, height: 125, color: Colors.grey[100]),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // 상품 정보
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['manufacturer_name']?.toString().toUpperCase() ?? "BRAND",
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => deleteCartItem(cartRowId),
                                          child: const Icon(Icons.close, size: 20, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['real_name'] ?? "상품명 없음",
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.3),
                                      maxLines: 2, overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "옵션: ${item['size']} / ${item['color']}",
                                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 수량 조절
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              _qtyBtn(Icons.remove, () {
                                                if (qty > 1) setState(() => quantityMap[cartRowId] = qty - 1);
                                              }),
                                              SizedBox(width: 30, child: Center(child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)))),
                                              _qtyBtn(Icons.add, () {
                                                setState(() => quantityMap[cartRowId] = qty + 1);
                                              }),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "${f.format((item['price'] ?? 0) * qty)}원",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                        ),
                                      ],
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
                ),
              ),
              _buildBottomSummary(carts),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("장바구니가 비어있습니다.", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBottomSummary(List<Cart> carts) {
    // 합계 계산
    int totalPrice = 0;
    for (var cart in carts) {
      final item = productCache[cart.cartid];
      if (item != null) {
        totalPrice += ((item['price'] as int) * (quantityMap[cart.id] ?? 1));
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("총 결제 금액", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              Text("${f.format(totalPrice)}원", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => goToPayment(carts),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text("주문하기", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }
}