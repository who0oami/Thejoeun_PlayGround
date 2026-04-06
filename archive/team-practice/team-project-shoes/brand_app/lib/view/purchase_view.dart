import 'dart:convert';
import 'package:brand_app/view/purchase_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:brand_app/ip/ipaddress.dart';
import 'package:brand_app/util/snackbar.dart';

// --- 데이터 모델 (기존 로직 유지) ---
class PurchaseSummary {
  final int pcid, pid, mid, cid, finalprice, size, quantity;
  final String cemail, cname, pname, color, sname;
  final int? rid;
  final DateTime? purchasedate, pickupdate, refunddate;

  PurchaseSummary({
    required this.pcid, required this.pid, required this.mid, required this.cid,
    required this.cemail, required this.cname, required this.pname,
    required this.finalprice, required this.size, required this.color,
    required this.quantity, required this.sname,
    this.rid, this.purchasedate, this.pickupdate, this.refunddate,
  });

  factory PurchaseSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null || v == "null" || v == "") return null;
      return DateTime.tryParse(v.toString());
    }
    return PurchaseSummary(
      pcid: json['pcid'] ?? 0,
      pid: json['pid'] ?? 0,
      mid: json['mid'] ?? 0,
      cid: json['cid'] ?? 0,
      cemail: json['cemail']?.toString() ?? "-",
      cname: json['cname']?.toString() ?? "-",
      pname: (json['pname'] ?? json['product_name'] ?? "상품명 없음").toString(),
      finalprice: json['finalprice'] ?? 0,
      size: int.tryParse(json['size']?.toString() ?? "0") ?? 0,
      color: json['color']?.toString() ?? "-",
      quantity: json['quantity'] ?? 0,
      sname: json['sname']?.toString() ?? "-",
      rid: json['rid'],
      purchasedate: parseDate(json['purchasedate']),
      pickupdate: parseDate(json['pickupdate']),
      refunddate: parseDate(json['refunddate']),
    );
  }
}

class PurchaseView extends StatefulWidget {
  const PurchaseView({super.key});
  @override
  State<PurchaseView> createState() => _PurchaseViewState();
}

class _PurchaseViewState extends State<PurchaseView> {
  final f = NumberFormat('###,###,###,###');
  TextEditingController searchController = TextEditingController();
  final CustomSnackbar _snackbar = CustomSnackbar();
  String selectedSearchField = '고객이메일';
  String selectedStatus = '전체';
  List<PurchaseSummary> data = [];
  List<PurchaseSummary> filteredData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPurchaseData();
  }

  Future<void> loadPurchaseData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    var url = Uri.parse("${IpAddress.baseUrl}/purchase/selectSummary");
    try {
      var response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final decodeData = json.decode(body);
        List results = decodeData['results'] ?? [];
        setState(() {
          data = results.map((e) => PurchaseSummary.fromJson(e)).toList();
          _applyFilters();
        });
      }
    } catch (e) {
      debugPrint("에러: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    final query = searchController.text.trim().toLowerCase();
    setState(() {
      filteredData = data.where((item) {
        bool statusMatch = (selectedStatus == '전체' || _getStatus(item) == selectedStatus);
        bool searchMatch = query.isEmpty ? true : 
          selectedSearchField == '고객이메일' ? item.cemail.toLowerCase().contains(query) :
          selectedSearchField == '주문번호' ? item.pcid.toString().contains(query) :
          selectedSearchField == '제품명' ? item.pname.toLowerCase().contains(query) : true;
        return statusMatch && searchMatch;
      }).toList();
    });
  }

  String _getStatus(PurchaseSummary item) =>
      item.rid != null ? (item.refunddate != null ? '반품완료' : '반품대기') :
      (item.pickupdate != null ? '수령완료' : '수령대기');

  Future<void> _completePickup(PurchaseSummary item) async {
    CustomSnackbar.showConfirmDialog(
      title: '수령 처리',
      message: '해당 주문을 수령완료로 처리하시겠습니까?',
      onConfirm: () => _requestCompletePickup(item),
    );
  }

  Future<void> _requestCompletePickup(PurchaseSummary item) async {
    try {
      final url = Uri.parse("${IpAddress.baseUrl}/purchase/completePickup");
      final response = await http.post(url, body: {'pcid': item.pcid.toString()});
      if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        if (body['success'] == true) {
          await loadPurchaseData();
          _snackbar.okSnackBar('완료', '수령완료로 처리되었습니다.');
        } else {
          _snackbar.errorSnackBar('실패', body['message'] ?? '처리 실패');
        }
      }
    } catch (e) { _snackbar.errorSnackBar('에러', e.toString()); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text("주문 내역 관리", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: _buildHeaderFilter(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : Column(
              children: [
                _buildSummaryBar(),
                Expanded(child: _buildListArea()),
              ],
            ),
    );
  }

  Widget _buildHeaderFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: selectedSearchField,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                  items: ['고객이메일', '주문번호', '제품명'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
                  onChanged: (v) => setState(() => selectedSearchField = v!),
                ),
                const VerticalDivider(indent: 12, endIndent: 12),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => _applyFilters(),
                    decoration: const InputDecoration(hintText: "통합 검색", border: InputBorder.none, isDense: true, hintStyle: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['전체', '수령대기', '수령완료', '반품대기', '반품완료'].map((status) {
                bool isSelected = selectedStatus == status;
                return GestureDetector(
                  onTap: () { setState(() => selectedStatus = status); _applyFilters(); },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
                    ),
                    child: Text(status, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("총 ${filteredData.length}건의 주문", style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
          const Icon(Icons.sort_rounded, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildListArea() {
    if (filteredData.isEmpty) return const Center(child: Text("내역이 없습니다."));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final item = filteredData[index];
        final status = _getStatus(item);

        return GestureDetector(
          onTap: () => Get.to(PurchaseDetailView(), arguments: {
            'pcid': item.pcid, 'pid': item.pid, 'mid': item.mid, 'cid': item.cid,
            'cemail': item.cemail, 'cname': item.cname, 'pname': item.pname,
            'finalprice': item.finalprice, 'size': item.size, 'color': item.color,
            'quantity': item.quantity, 'sname': item.sname, 'rid': item.rid,
            'purchasedate': item.purchasedate?.toIso8601String(),
            'pickupdate': item.pickupdate?.toIso8601String(),
            'refunddate': item.refunddate?.toIso8601String(),
          }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("ID: ${item.pcid}", style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                      _buildStatusBadge(status),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          "${IpAddress.baseUrl}/productimage/view?pid=${item.mid}&position=main",
                          width: 80, height: 80, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[100], child: const Icon(Icons.image)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.pname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text("${item.color} / ${item.size}mm", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text("${item.cname} (${item.cemail})", style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${f.format(item.finalprice)}원", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      if (status == '수령대기')
                        SizedBox(
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () => _completePickup(item),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                            child: const Text("수령 완료", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        )
                      else
                        Text(item.purchasedate != null ? DateFormat('yyyy-MM-dd').format(item.purchasedate!) : "-", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status.contains('완료') ? Colors.green : (status.contains('반품') ? Colors.red : Colors.blue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}