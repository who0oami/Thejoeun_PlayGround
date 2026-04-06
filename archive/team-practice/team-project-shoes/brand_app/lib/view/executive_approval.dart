import 'dart:convert';

import 'package:brand_app/ip/ipaddress.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExecutiveApproval extends StatefulWidget {
  const ExecutiveApproval({super.key});

  @override
  State<ExecutiveApproval> createState() => _ExecutiveApprovalState();
}

class _ExecutiveApprovalState extends State<ExecutiveApproval> {
  List<Map<String, dynamic>> data = [];

  //  품의서 목록 조회
  Future<void> getJSONData() async {
    final url = Uri.parse("${IpAddress.baseUrl}/request/select");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      print("HTTP ERROR ${response.statusCode}");
      print(response.body);
      return;
    }

    final decoded = json.decode(utf8.decode(response.bodyBytes));
    data.clear();

    if (decoded is Map && decoded['results'] is List) {
      data = List<Map<String, dynamic>>.from(decoded['results']);
    }

    setState(() {});
  }

  //  승인 (okdate = NOW())
  Future<void> approveRequest(int requestId) async {
    final url = Uri.parse("${IpAddress.baseUrl}/request/approve");
    final request = http.MultipartRequest("POST", url);
    request.fields['id'] = requestId.toString();

    final response = await request.send();
    if (response.statusCode == 200) {
      await getJSONData();
    } else {
      print("승인 실패");
    }
  }

  //  반려 (DELETE)
  Future<void> rejectRequest(int requestId) async {
    final url = Uri.parse("${IpAddress.baseUrl}/request/reject");
    final request = http.MultipartRequest("POST", url);
    request.fields['id'] = requestId.toString();

    final response = await request.send();
    if (response.statusCode == 200) {
      await getJSONData();
    } else {
      print("반려 실패");
    }
  }

  // 🔹 승인 확인 다이얼로그
  Future<void> confirmApprove(int requestId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("승인"),
        content: const Text("이 품의서를 승인하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("승인"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await approveRequest(requestId);
    }
  }

  //  반려 확인 다이얼로그 (삭제)
  Future<void> confirmReject(int requestId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("반려"),
        content: const Text(
          "이 품의서를 반려하면\n완전히 삭제됩니다.\n계속하시겠습니까?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("삭제"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await rejectRequest(requestId);
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
      appBar: AppBar(
        title: const Text("품의서 결재 목록"),
        centerTitle: true,
      ),
      body: data.isEmpty
          ? const Center(child: Text("작성된 품의서가 없습니다"))
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];

                final int requestId = item['id'];
                final String employeeName =
                    item['employee_name']?.toString() ?? "알 수 없음";
                final String eid = item['eid']?.toString() ?? "-";
                final bool isApproved = item['okdate'] != null;

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "요청 ID : $requestId",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("요청자 : $employeeName (eid: $eid)"),
                        Text("요청일 : ${item['date']}"),
                        Text("승인일 : ${item['okdate'] ?? '-'}"),
                        const Divider(),
                        Text(
                          "내용",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(item['contents'] ?? ""),
                        const SizedBox(height: 8),

                        //  상태에 따른 UI 분기
                        isApproved
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  Chip(
                                    backgroundColor: Colors.green,
                                    label: Text(
                                      "승인 완료",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        confirmApprove(requestId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black87,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(50, 32),
                                    ),
                                    child: const Text(
                                      "승인",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () =>
                                        confirmReject(requestId),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black87,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(50, 32),
                                    ),
                                    child: const Text(
                                      "반려",
                                      style: TextStyle(fontSize: 12),
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
}
