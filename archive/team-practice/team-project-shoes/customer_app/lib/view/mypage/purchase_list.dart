import 'dart:convert';

import 'package:customer_app/config.dart' as config;
import 'package:customer_app/model/purchase.dart';
import 'package:customer_app/model/usercontroller.dart';
import 'package:customer_app/view/mypage/chatting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PurchaseList extends StatefulWidget {
  const PurchaseList({super.key});

  @override
  State<PurchaseList> createState() => _PurchaseListState();
}

class PurchaseRow {
  final Purchase purchase;
  final String productName;
  final String imageUrl;

  const PurchaseRow({
    required this.purchase,
    required this.productName,
    required this.imageUrl,
  });
}

class _PurchaseListState extends State<PurchaseList> {
  List<PurchaseRow> totalPurchases = [];
  bool isLoading = true;

  late final UserController userController;

  @override
  void initState() {
    super.initState();
    userController = Get.find<UserController>();
    _init();
  }

  Future<void> _init() async {
    final int? argCid = Get.arguments?['cid'] as int?;
    final int? loginCid = userController.user?.id;
    final int cid = argCid ?? loginCid ?? 1;

    debugPrint('PurchaseList init cid=$cid, hostip=${config.hostip}');

    try {
      final rows = await _loadPurchaseRows(cid);
      debugPrint('PurchaseList rows length=${rows.length}');
      if (!mounted) return;
      setState(() {
        totalPurchases = rows;
        isLoading = false;
      });
    } catch (e, st) {
      debugPrint('PurchaseList load error: $e\n$st');
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  /// (이미지용) pid -> group_id (없으면 pid 그대로)
  /// ⚠️ 네 selectdetail2 응답엔 group_id가 없어 보여서 그냥 pid로 떨어질 확률 높음
  Future<int> _resolveGroupId(int pid) async {
    try {
      final url = Uri.parse('http://${config.hostip}:8008/product/selectdetail2?pid=$pid');
      final res = await http.get(url);
      if (res.statusCode != 200) return pid;

      final decoded = json.decode(utf8.decode(res.bodyBytes));
      // group_id가 루트에 있으면 사용
      if (decoded is Map && decoded['group_id'] != null) {
        return int.tryParse(decoded['group_id'].toString()) ?? pid;
      }
      return pid;
    } catch (_) {
      return pid;
    }
  }

  /// ✅ 핵심: product/selectdetail2 결과 안에 product_name이 있음
  Future<String> _fetchProductNameFromDetail(int pid) async {
    try {
      final url = Uri.parse('http://${config.hostip}:8008/product/selectdetail2?pid=$pid');
      final res = await http.get(url);
      if (res.statusCode != 200) return '상품';

      final decoded = json.decode(utf8.decode(res.bodyBytes));

      if (decoded is! Map) return '상품';
      final results = decoded['results'];
      if (results is! List || results.isEmpty) return '상품';

      // 1) results 중에서 id == pid인 row를 찾는다 (구매한 그 상품)
      Map<String, dynamic>? hit;
      for (final e in results) {
        if (e is Map) {
          final id = e['id'];
          final idInt = int.tryParse(id?.toString() ?? '');
          if (idInt == pid) {
            hit = Map<String, dynamic>.from(e);
            break;
          }
        }
      }

      // 2) 못 찾으면 첫 번째 row 사용
      final row = hit ?? Map<String, dynamic>.from(results.first as Map);

      // 3) product_name 우선, 없으면 ename 등 대체
      final pn = (row['product_name']?.toString() ?? '').trim();
      if (pn.isNotEmpty && pn.toLowerCase() != 'null') return pn;

      final en = (row['ename']?.toString() ?? '').trim();
      if (en.isNotEmpty && en.toLowerCase() != 'null') return en;

      final name = (row['name']?.toString() ?? '').trim();
      if (name.isNotEmpty && name.toLowerCase() != 'null') return name;

      return '상품';
    } catch (e, st) {
      debugPrint('fetchProductNameFromDetail error pid=$pid: $e\n$st');
      return '상품';
    }
  }

  Future<List<PurchaseRow>> _loadPurchaseRows(int cid) async {
    final raw = await config.getJSONData('purchase/selectcustomer?cid=$cid');

    // purchase 응답이 Purchase 객체 or Map일 수 있어서 둘 다 처리
    List<Purchase> purchases = raw.whereType<Purchase>().toList();
    if (purchases.isEmpty) {
      purchases = raw
          .whereType<Map>()
          .map((e) => Purchase.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (purchases.isEmpty) return const <PurchaseRow>[];

    // ✅ pid -> groupId (이미지용)
    final Map<int, int> groupIdByPid = {};
    // ✅ pid -> productName 캐시 (중복 호출 방지)
    final Map<int, String> nameByPid = {};

    final uniquePids = purchases.map((p) => p.pid).toSet().toList();

    // 병렬로: groupId + productName 둘 다 채움
    await Future.wait(
      uniquePids.map((pid) async {
        groupIdByPid[pid] = await _resolveGroupId(pid);
        nameByPid[pid] = await _fetchProductNameFromDetail(pid);
        debugPrint('pid=$pid => name=${nameByPid[pid]}, groupId=${groupIdByPid[pid]}');
      }),
    );

    // rows 생성
    return purchases.map((p) {
      final pid = p.pid;
      final gid = groupIdByPid[pid] ?? pid;
      final productName = (nameByPid[pid] ?? '상품').trim().isEmpty ? '상품' : nameByPid[pid]!;
      final imageUrl = 'http://${config.hostip}:8008/productimage/view?pid=$gid&position=main';

      return PurchaseRow(
        purchase: p,
        productName: productName,
        imageUrl: imageUrl,
      );
    }).toList();
  }

  String _fmtMoney(dynamic value) {
    final n = num.tryParse(value?.toString() ?? '');
    if (n == null) return value?.toString() ?? '';
    return NumberFormat('#,###').format(n);
  }

  String _fmtDate(dynamic value) {
    if (value == null) return '-';
    if (value is DateTime) return DateFormat('yyyy-MM-dd').format(value);
    final s = value.toString();
    final dt = DateTime.tryParse(s);
    if (dt != null) return DateFormat('yyyy-MM-dd').format(dt);
    return s;
  }

  int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "구매 목록",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : totalPurchases.isEmpty
              ? const Center(child: Text('구매 내역이 없습니다.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: totalPurchases.length,
                  itemBuilder: (context, index) {
                    final row = totalPurchases[index];
                    final bool isPickedUp = row.purchase.pickupdate != null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    row.imageUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) => Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              row.productName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            isPickedUp ? "구매확정" : "수령대기",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isPickedUp ? Colors.blue : Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "주문금액: ${_fmtMoney(row.purchase.finalprice)}원 / ${row.purchase.quantity}개",
                                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "구매일: ${_fmtDate(row.purchase.purchasedate)}",
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                      if (isPickedUp)
                                        Text(
                                          "픽업일: ${_fmtDate(row.purchase.pickupdate)}",
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Get.to(
                                        const Chatting(),
                                        arguments: {
                                          'pcid': _asInt(row.purchase.id),
                                          'productName': row.productName,
                                        },
                                      )?.then((_) => setState(() {}));
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    child: const Text(
                                      "문의하기",
                                      style: TextStyle(fontSize: 12, color: Colors.black),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // TODO: 리뷰 로직
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    child: const Text(
                                      "리뷰하기",
                                      style: TextStyle(fontSize: 12, color: Colors.black),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      _showCancelOrRefundDialog(
                                        context,
                                        _asInt(row.purchase.id),
                                        isPickedUp,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                    child: Text(
                                      isPickedUp ? "환불하기" : "주문취소",
                                      style: const TextStyle(fontSize: 12, color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showCancelOrRefundDialog(
    BuildContext context,
    int purchaseId,
    bool isPickedUp,
  ) {
    final String title = isPickedUp ? "환불 확인" : "주문취소 확인";
    final String content = isPickedUp ? "해당 주문을 환불하시겠습니까?" : "주문을 취소하시겠습니까?";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("아니오")),
          TextButton(
            onPressed: () {
              // TODO: 취소/환불 API 호출
              Get.back();
            },
            child: const Text("예", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
