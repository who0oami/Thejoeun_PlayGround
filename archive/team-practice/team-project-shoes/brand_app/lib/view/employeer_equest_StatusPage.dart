import 'dart:convert';
import 'package:brand_app/ip/ipaddress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // 날짜 포맷팅용

class EmployeeRequestStatusPage extends StatefulWidget {
  const EmployeeRequestStatusPage({super.key});

  @override
  State<EmployeeRequestStatusPage> createState() =>
      _EmployeeRequestStatusPageState();
}

class _EmployeeRequestStatusPageState extends State<EmployeeRequestStatusPage> {
  List<Map<String, dynamic>> data = [];
  bool _isLoading = true;

  Future<void> getJSONData() async {
    setState(() => _isLoading = true);
    final url = Uri.parse("${IpAddress.baseUrl}/request/select/all");

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is Map && decoded['results'] is List) {
          setState(() {
            data = List<Map<String, dynamic>>.from(decoded['results']);
          });
        }
      }
    } catch (e) {
      debugPrint("데이터 로드 에러: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getJSONData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // 연한 그레이 배경
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text(
          "품의 내역 조회",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: getJSONData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : data.isEmpty
              ? _buildEmptyState()
              : _buildListView(),
    );
  }

  // 데이터가 없을 때 표시할 화면
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "작성된 품의 내역이 없습니다",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // 리스트 뷰 영역
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final bool isApproved = item['okdate'] != null;
        final String employeeName = item['employee_name'] ?? "알 수 없음";
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 헤더 섹션 (이름 & 상태)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: const Icon(Icons.person, size: 16, color: Colors.blue),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          employeeName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    _buildStatusBadge(isApproved),
                  ],
                ),
              ),
              
              // 내용 섹션
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item['contents'] ?? "내용 없음",
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              
              // 하단 푸터 섹션 (날짜)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      "신청일: ${item['date']}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (isApproved) ...[
                      const Spacer(),
                      const Icon(Icons.check_circle_outline, size: 12, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        "승인일: ${item['okdate']}",
                        style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 상태 배지 위젯
  Widget _buildStatusBadge(bool isApproved) {
    final color = isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isApproved ? "승인 완료" : "승인 대기",
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}