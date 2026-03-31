import 'dart:convert';
import 'dart:ui';
import 'package:customer_app/database/cartdatabasehandler.dart';
import 'package:customer_app/for%20test/purchase2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/model/product.dart';
import 'package:customer_app/model/cart.dart';
import 'package:customer_app/model/usercontroller.dart';
import 'package:intl/intl.dart';

class Detail2 extends StatefulWidget {
  const Detail2({super.key});

  @override
  State<Detail2> createState() => _Detail2State();
}

class _Detail2State extends State<Detail2> {
  late Product product;
  String? koreanName;
  final Cartdatabasehandler handler = Cartdatabasehandler();
  final UserController userController = Get.find<UserController>();

  List allOptions = [];
  List sizeList = [];
  List colorList = [];

  int? selectedSizeIndex;
  int? selectedColorIndex;
  String selectedSize = "";
  String selectedColor = "";
  int count = 1;

  @override
  void initState() {
    super.initState();
    product = Get.arguments['product'];
    koreanName = Get.arguments['koreanName'];
    getGroupData();
  }

  Future<void> getGroupData() async {
    var url = Uri.parse("${IpAddress.baseUrl}/product/selectdetail2?pid=${product.id}");
    try {
      var response = await http.get(url);
      var data = json.decode(utf8.decode(response.bodyBytes));
      if (data['results'] != null) {
        setState(() {
          allOptions = data['results'];
          sizeList = allOptions.map((e) => e['size']).where((e) => e != null).toSet().toList();
          colorList = allOptions.map((e) => e['color']).where((e) => e != null).toSet().toList();
          sizeList.sort();
          colorList.sort();
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _handleAction({required bool isCart}) async {
    if (selectedSize.isEmpty || selectedColor.isEmpty) {
      Get.snackbar("알림", "옵션을 모두 선택해주세요.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.black87, colorText: Colors.white);
      return;
    }
    if (userController.user == null) {
      Get.snackbar("알림", "로그인이 필요한 서비스입니다.");
      return;
    }

    int userCid = int.parse(userController.user!.id.toString());
    var matchedItem = allOptions.firstWhere(
      (item) => item['size'].toString() == selectedSize && item['color'].toString() == selectedColor,
      orElse: () => null,
    );

    if (matchedItem == null) return;
    int finalPid = matchedItem['id'];

    if (isCart) {
      try {
        await handler.insertCart(Cart(cid: userCid, cartid: finalPid));
        Get.back();
        Get.snackbar("Cart", "장바구니에 추가되었습니다.",
            backgroundColor: Colors.black, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        debugPrint("SQLite Error: $e");
      }
    } else {
      Get.back();
      Get.to(() => const Purchase2(), arguments: {
        "items": [
          {
            "pid": finalPid,
            "cid": userCid,
            "price": matchedItem['price'] ?? product.price,
            "quantity": count,
            "name": matchedItem['product_name'] ?? koreanName ?? product.ename,
            "productname": matchedItem['product_name'] ?? koreanName ?? product.ename,
            "manufacturername": matchedItem['manufacturer_name'] ?? "Premium Brand",
            "size": selectedSize,
            "color": selectedColor,
            "image": '${IpAddress.baseUrl}/productimage/view?pid=${product.mid ?? product.id}&position=main',
          }
        ]
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int imgId = (product.mid != null && product.mid != 0) ? product.mid! : (product.id ?? 0);
    final f = NumberFormat('###,###,###');

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.3),
          child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 이미지 (Hero 적용)
            Hero(
              tag: 'product_${product.id}',
              child: AspectRatio(
                aspectRatio: 0.8,
                child: imgId != 0
                    ? Image.network('${IpAddress.baseUrl}/productimage/view?pid=$imgId&position=main', fit: BoxFit.cover)
                    : const Center(child: Icon(Icons.image_not_supported, size: 100)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.ename.toUpperCase(), style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const Icon(Icons.share_outlined, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(koreanName ?? product.ename, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -1)),
                  const SizedBox(height: 12),
                  Text("${f.format(product.price)}원", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const Divider(height: 50, thickness: 1),
                  
                  const Text("PRODUCT DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 20),
                  if (imgId != 0) ...[
                    _img(imgId, 'top'),
                    const SizedBox(height: 10),
                    _img(imgId, 'side'),
                    const SizedBox(height: 10),
                    _img(imgId, 'back'),
                  ],
                  const SizedBox(height: 40),
                  const Text("SIZE GUIDE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('images/size.png', fit: BoxFit.fill),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          onPressed: () => showPurchaseSheet(),
          child: const Text("구매 옵션 선택", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _img(int pid, String pos) => ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          '${IpAddress.baseUrl}/productimage/view?pid=$pid&position=$pos',
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => const SizedBox.shrink(),
        ),
      );

  void showPurchaseSheet() {
    Get.bottomSheet(
      StatefulBuilder(builder: (context, setBS) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 25),
              const Text("Size", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _grid(sizeList, selectedSizeIndex, (i) => setBS(() { selectedSizeIndex = i; selectedSize = sizeList[i].toString(); }), 4),
              const SizedBox(height: 25),
              const Text("Color", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _grid(colorList, selectedColorIndex, (i) => setBS(() { selectedColorIndex = i; selectedColor = colorList[i].toString(); }), 4),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Quantity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      children: [
                        IconButton(onPressed: () => setBS(() => count > 1 ? count-- : null), icon: const Icon(Icons.remove, size: 18)),
                        Text("$count", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(onPressed: () => setBS(() => count++), icon: const Icon(Icons.add, size: 18)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), side: BorderSide(color: Colors.black)),
                      onPressed: () => _handleAction(isCart: true),
                      child: const Text("장바구니", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(0, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () => _handleAction(isCart: false),
                      child: const Text("바로 구매하기", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  Widget _grid(List list, int? sIdx, Function(int) onTap, int count) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(list.length, (i) {
          bool isSelected = sIdx == i;
          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
              ),
              child: Text(
                list[i].toString(),
                style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          );
        }),
      );
}