import 'dart:convert';
import 'package:brand_app/ip/ipaddress.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class Request extends StatefulWidget {
  const Request({super.key});

  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '1');

  String? _selectedMaker;
  String? _selectedProduct;
  String? _selectedSize;
  String? _selectedColor;

  List<String> manufacturers = [];
  List<String> _products = [];
  List<String> colorlist = ['화이트', '레드', '블랙', '브라운'];
  final List<String> _sizes = List.generate(13, (i) => (230 + (i * 5)).toString());

  bool _isLoadingProducts = false;
  bool _isLoadingMakers = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchMakers();
  }

  // --- API 호출 함수 ---
  Future<void> _fetchProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final response = await http.post(Uri.parse('${IpAddress.baseUrl}/product/select'), headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> data = decodedData['results'] ?? [];
        setState(() {
          _products = data.map((item) => item['ename'].toString()).toSet().toList();
          _products.sort();
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _fetchMakers() async {
    setState(() => _isLoadingMakers = true);
    try {
      final mRes = await http.get(Uri.parse('${IpAddress.baseUrl}/manufacturername/all'));
      final cRes = await http.get(Uri.parse('${IpAddress.baseUrl}/productcolor/all'));
      if (mRes.statusCode == 200 && cRes.statusCode == 200) {
        setState(() {
          manufacturers = List<String>.from(json.decode(utf8.decode(mRes.bodyBytes))['results']);
          colorlist = List<String>.from(json.decode(utf8.decode(cRes.bodyBytes))['results']);
          _isLoadingMakers = false;
        });
      }
    } catch (e) {
      setState(() {
        manufacturers = ['나이키', '퓨마', '아디다스', '스니커즈', '뉴발란스'];
        _isLoadingMakers = false;
      });
    }
  }

  Future<int?> insertAction() async {
    try {
      final url = Uri.parse("${IpAddress.baseUrl}/request/insert");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({
          "eid": 1,
          "contents": "작성자: ${_nameController.text} / 제조사: $_selectedMaker / 상품: $_selectedProduct / 사이즈: $_selectedSize / 컬러: $_selectedColor / 수량: ${_quantityController.text}",
        }),
      );
      if (response.statusCode == 200) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        if (res['results'] == 'OK') return 1;
      }
    } catch (e) { debugPrint("통신 에러: $e"); }
    return null;
  }

  void _updateQuantity(int amount) {
    int current = int.tryParse(_quantityController.text) ?? 0;
    int newValue = current + amount;
    if (newValue < 1) newValue = 1;
    setState(() => _quantityController.text = newValue.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('발주 품의서 작성', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            children: [
              _buildFormCard(
                title: "기본 정보",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('신청 직원'),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: '이름을 입력하세요',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        prefixIcon: const Icon(Icons.person_outline, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('품목 선택'),
                    _buildDropdownStyled('제조사', manufacturers, _selectedMaker, (v) => setState(() => _selectedMaker = v)),
                    const SizedBox(height: 12),
                    _buildDropdownStyled('상품명', _products, _selectedProduct, (v) => setState(() => _selectedProduct = v), isLoading: _isLoadingProducts),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildDropdownStyled('사이즈', _sizes, _selectedSize, (v) => setState(() => _selectedSize = v), suffix: 'mm')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDropdownStyled('컬러', colorlist, _selectedColor, (v) => setState(() => _selectedColor = v))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildFormCard(
                title: "발주 수량",
                child: Column(
                  children: [
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildQuantityControlRow('단위: 1', 1),
                    const SizedBox(height: 10),
                    _buildQuantityControlRow('단위: 10', 10),
                    const SizedBox(height: 10),
                    _buildQuantityControlRow('단위: 100', 100),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _showResultSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('품의서 작성 완료', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black87)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFEDF2F7))),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF718096))),
    );
  }

  Widget _buildDropdownStyled(String label, List<String> items, String? value, ValueChanged<String?> onChanged, {bool isLoading = false, String? suffix}) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(suffix != null ? "$e$suffix" : e, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      ),
      hint: isLoading ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)) : Text('$label 선택'),
    );
  }

  Widget _buildQuantityControlRow(String label, int unit) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13))),
        _stepButton(Icons.remove, Colors.redAccent, () => _updateQuantity(-unit)),
        const SizedBox(width: 12),
        _stepButton(Icons.add, Colors.blueAccent, () => _updateQuantity(unit)),
      ],
    );
  }

  Widget _stepButton(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 55, height: 45,
          decoration: BoxDecoration(border: Border.all(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  void _showResultSheet() {
    if (_nameController.text.isEmpty || _selectedProduct == null || _selectedMaker == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모든 필수 항목을 입력해주세요.')));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text("품의서 최종 확인", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 25),
            _resultRow("신청자", _nameController.text),
            _resultRow("제조사/품목", "$_selectedMaker / $_selectedProduct"),
            _resultRow("옵션", "$_selectedColor / $_selectedSize mm"),
            _resultRow("발주 수량", "${_quantityController.text} 개", isBold: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                onPressed: () async {
                  await insertAction();
                  Navigator.pop(context);
                  _nameController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('품의서가 제출되었습니다.')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('제출하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.w900 : FontWeight.bold, fontSize: 15, color: isBold ? Colors.blueAccent : Colors.black)),
        ],
      ),
    );
  }
}