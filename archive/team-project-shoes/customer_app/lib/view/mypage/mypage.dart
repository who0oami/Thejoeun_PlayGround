import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_app/config.dart' as config;
import 'package:customer_app/model/customer.dart';
import 'package:customer_app/model/usercontroller.dart';
import 'package:customer_app/view/mypage/purchase_list.dart';
import 'package:customer_app/view/mypage/support_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class Mypage extends StatefulWidget {
  const Mypage({super.key});

  @override
  State<Mypage> createState() => _MypageState();
}

class _MypageState extends State<Mypage> {
  int purchases = 0;
  int reviews = 0;
  int asks = 0;
  late Customer customer;
  UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    customer = userController.user ??
        Customer(
          id: 1,
          email: '',
          password: '',
          name: '사용자',
          phone: '',
          date: DateTime.now(),
          address: '',
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCustomerAndReload();
    });
  }

  Future<void> _syncCustomerAndReload() async {
    final u = userController.user;
    if (u != null && u.id != null) {
      setState(() {
        customer = u;
      });
    }
    await _loadCounts();
  }

  Future<List<dynamic>> _getList(String path) async {
    final url = Uri.parse("http://${config.hostip}:8008/$path");
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Error');
    final decoded = json.decode(utf8.decode(res.bodyBytes));
    if (decoded is List) return decoded;
    return decoded['results'] ?? [];
  }

  Future<void> _loadCounts() async {
    try {
      final purchaseList = await _getList('purchase/selectcustomer?cid=${customer.id!}');
      final int reviewCount = await _countFirestoreByCid(collection: 'review', cid: customer.id!);
      final int askCount = await _countFirestoreByCid(collection: 'ask', cid: customer.id!);

      if (!mounted) return;
      setState(() {
        purchases = purchaseList.length;
        reviews = reviewCount;
        asks = askCount;
      });
    } catch (e) {
      debugPrint('mypage count error: $e');
    }
  }

  Future<int> _countFirestoreByCid({required String collection, required int cid}) async {
    final fs = FirebaseFirestore.instance;
    final q1 = await fs.collection(collection).where('cid', isEqualTo: cid).get();
    final q2 = await fs.collection(collection).where('cid', isEqualTo: cid.toString()).get();
    final ids = <String>{...q1.docs.map((d) => d.id), ...q2.docs.map((d) => d.id)};
    return ids.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // 밝은 회색톤 배경
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('마이 페이지', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined, color: Colors.black)),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildStatCard(),
            const SizedBox(height: 20),
            _buildMenuSection(),
            const SizedBox(height: 30),
            _buildFooterLogo(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.black),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${customer.name}님, 반가워요!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(customer.email, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('구매내역', purchases.toString(), () {
            Get.to(PurchaseList(), arguments: {'cid': customer.id!});
          }),
          _statItem('리뷰', reviews.toString(), () {}),
          _statItem('고객센터', asks.toString(), () {
            Get.to(SupportCenter());
          }),
        ],
      ),
    );
  }

  Widget _statItem(String title, String count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _menuTile(Icons.recycling_outlined, '취소/반품/교환 내역'),
          _divider(),
          _menuTile(Icons.assignment_outlined, '개인정보 처리방침'),
          _divider(),
          _menuTile(Icons.gavel_outlined, '서비스 이용 약관'),
          _divider(),
          _menuTile(Icons.info_outline, '버전 정보', trailing: '1.0.0'),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, {String? trailing}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      leading: Icon(icon, color: Colors.black, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: trailing != null 
          ? Text(trailing, style: const TextStyle(color: Colors.grey))
          : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _divider() => Divider(height: 1, indent: 20, endIndent: 20, color: Colors.grey[100]);

  Widget _buildFooterLogo() {
    return Opacity(
      opacity: 0.3,
      child: Image.asset(
        config.rlogoImage,
        width: 120,
        height: 80,
        fit: BoxFit.contain,
      ),
    );
  }
}