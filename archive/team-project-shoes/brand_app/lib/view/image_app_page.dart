import 'dart:convert';
import 'dart:io';
import 'package:brand_app/ip/ipaddress.dart';
import 'package:brand_app/util/pcolor.dart';
import 'package:brand_app/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ImageAppPage extends StatefulWidget {
  const ImageAppPage({super.key});

  @override
  State<ImageAppPage> createState() => _ImageAppPageState();
}

class _ImageAppPageState extends State<ImageAppPage> {
  // --- 기존 로직 및 컨트롤러 유지 (수정 없음) ---
  final TextEditingController priceController = TextEditingController(text: '0');
  final TextEditingController productNameController = TextEditingController(); 
  final TextEditingController enameController = TextEditingController();       
  final List<int> sizeList = List.generate(21, (index) => 230 + index * 5);
  int? startSize;
  int? endSize;
  List<int> selectedSizes = [];
  final ImagePicker _picker = ImagePicker();
  File? mainImage, topImage, sideImage, backImage;
  List<String> manufacturers = [];
  List<String> colorlist = [];
  String? selectedManufacturer; 
  String? selectedColorlist; 

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  // --- 기존 기능 로직 (절대 건드리지 않음) ---
  Future<void> fetchDropdownData() async {
    try {
      final mRes = await http.get(Uri.parse('${IpAddress.baseUrl}/manufacturername/all'));
      final cRes = await http.get(Uri.parse('${IpAddress.baseUrl}/productcolor/all'));
      if (mRes.statusCode == 200 && cRes.statusCode == 200) {
        setState(() {
          manufacturers = List<String>.from(json.decode(utf8.decode(mRes.bodyBytes))['results']);
          colorlist = List<String>.from(json.decode(utf8.decode(cRes.bodyBytes))['results']);
        });
      }
    } catch (e) {
      setState(() {
        manufacturers = ['나이키', '퓨마', '아디다스', '스니커즈', '뉴발란스'];
        colorlist = ['화이트', '레드', '블랙', '브라운'];
      });
    }
  }

  Future<void> _pickImage(Function(File) onSelected) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (picked != null) setState(() => onSelected(File(picked.path)));
  }

  Future<int?> getExistingMid(String ename) async {
    try {
      var response = await http.get(Uri.parse('${IpAddress.baseUrl}/product/get_mid?ename=$ename'));
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        if (data['mid'] != null && data['mid'].toString() != "0") return int.tryParse(data['mid'].toString());
      }
    } catch (e) { return null; }
    return null; 
  }

  Future<int?> insertAction() async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('${IpAddress.baseUrl}/product/insert'));
      request.fields['ename'] = enameController.text.trim();
      request.fields['price'] = priceController.text.replaceAll(',', '');
      request.fields['quantity'] = '100';
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      if (response.statusCode == 200) return int.tryParse(json.decode(respStr)['pid'].toString());
    } catch (e) { return null; }
    return null;
  }

  Future<void> updateMid(int pid, int mid) async => await http.post(Uri.parse('${IpAddress.baseUrl}/product/updateMid'), body: {'pid': pid.toString(), 'mid': mid.toString()});
  Future<void> uploadProductName(int pid) async => await http.post(Uri.parse('${IpAddress.baseUrl}/productname/upload'), body: {'pid': pid.toString(), 'name': productNameController.text});
  Future<void> uploadManufacturerName(int pid) async => await http.post(Uri.parse('${IpAddress.baseUrl}/manufacturername/upload'), body: {'pid': pid.toString(), 'name': selectedManufacturer ?? ''});
  Future<void> uploadColor(int pid) async => await http.post(Uri.parse('${IpAddress.baseUrl}/productcolor/uproad'), body: {'pid': pid.toString(), 'color': selectedColorlist ?? ''});
  Future<void> uploadSingleSize(int pid, int size) async => await http.post(Uri.parse('${IpAddress.baseUrl}/productsize/insert?pid=$pid'), headers: {"Content-Type": "application/json"}, body: jsonEncode({"inputsize": [size]}));

  Future<void> uploadImages(int pid) async {
    final url = '${IpAddress.baseUrl}/productimage/upload';
    if (mainImage != null) await _sendImg(url, pid, 'main', mainImage!);
    if (topImage != null) await _sendImg(url, pid, 'top', topImage!);
    if (sideImage != null) await _sendImg(url, pid, 'side', sideImage!);
    if (backImage != null) await _sendImg(url, pid, 'back', backImage!);
  }

  Future<void> _sendImg(String url, int pid, String pos, File file) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['pid'] = pid.toString();
    request.fields['position'] = pos;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    await request.send();
  }

  void _updateSelectedSizes() { if (startSize != null && endSize != null && startSize! <= endSize!) setState(() => selectedSizes = [for (int i = startSize!; i <= endSize!; i += 5) i]); }

  // --- UI 디자인 리뉴얼 ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        title: const Text('New Collection', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildSectionCard(
              title: '상품 이미지',
              isRequired: true,
              child: _buildImagePickers(),
            ),
            _buildSectionCard(
              title: '기본 정보',
              child: Column(
                children: [
                  _buildDropdownStyled('제조사명', manufacturers, selectedManufacturer, (v) => setState(() => selectedManufacturer = v)),
                  const SizedBox(height: 20),
                  _buildTextFieldStyled('한글 상품명', productNameController, hint: '상품명을 입력하세요.'),
                  const SizedBox(height: 20),
                  _buildTextFieldStyled('영문 모델명', enameController, hint: '예: AIR_MAX_01', isEnglish: true),
                ],
              ),
            ),
            _buildSectionCard(
              title: '상세 옵션',
              child: Column(
                children: [
                  _buildDropdownStyled('칼라', colorlist, selectedColorlist, (v) => setState(() => selectedColorlist = v)),
                  const SizedBox(height: 20),
                  _buildSizeSection(),
                ],
              ),
            ),
            _buildSectionCard(
              title: '가격 설정',
              child: _buildPriceInputStyled(),
            ),
            const SizedBox(height: 20),
            _buildSubmitButtonStyled(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, bool isRequired = false, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              if (isRequired) const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildImagePickers() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _imageBoxStyled(title: '대표', image: mainImage, onTap: () => _pickImage((f) => mainImage = f)),
          _imageBoxStyled(title: 'Top', image: topImage, onTap: () => _pickImage((f) => topImage = f)),
          _imageBoxStyled(title: 'Side', image: sideImage, onTap: () => _pickImage((f) => sideImage = f)),
          _imageBoxStyled(title: 'Back', image: backImage, onTap: () => _pickImage((f) => backImage = f)),
        ],
      ),
    );
  }

  Widget _imageBoxStyled({required String title, File? image, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 85, height: 85,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFE0E5ED), width: 1.5),
              ),
              child: image == null
                  ? const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFFB0B7C3), size: 28)
                  : ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(image, fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTextFieldStyled(String label, TextEditingController controller, {String? hint, bool isEnglish = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          inputFormatters: isEnglish ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s_]'))] : [],
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            hintStyle: const TextStyle(color: Color(0xFFB0B7C3), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownStyled(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('사이즈 범위', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildSizeDropdown(startSize, '시작', (v) { setState(() { startSize = v; _updateSelectedSizes(); }); })),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('to', style: TextStyle(color: Colors.grey))),
            Expanded(child: _buildSizeDropdown(endSize, '종료', (v) { setState(() { endSize = v; _updateSelectedSizes(); }); })),
          ],
        ),
        if (selectedSizes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text('총 ${selectedSizes.length}개 상품 등록 예정', style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }

  Widget _buildSizeDropdown(int? value, String hint, ValueChanged<int?> onChanged) {
    return DropdownButtonFormField<int>(
      value: value,
      hint: Text(hint, style: const TextStyle(fontSize: 14)),
      items: sizeList.map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPriceInputStyled() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Text('판매가', style: TextStyle(fontWeight: FontWeight.w700)),
          Expanded(
            child: TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              decoration: const InputDecoration(border: InputBorder.none, suffixText: ' 원', suffixStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButtonStyled() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A1A),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          onPressed: () {
            if (productNameController.text.isEmpty || enameController.text.isEmpty || selectedSizes.isEmpty) {
              Get.snackbar("알림", "정보를 모두 입력해주세요.", backgroundColor: Colors.white); return;
            }
            // 기존 기능 로직 실행
            _executeSubmit();
          },
          child: const Text('컬렉션 등록하기', style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  // 기존 onSubmit 로직 유지
  void _executeSubmit() {
    CustomSnackbar.showConfirmDialog(
      title: '상품등록', message: '${selectedSizes.length}개의 사이즈 상품을 등록하시겠습니까?',
      onConfirm: () async {
        Get.back();
        Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
        try {
          int? sharedMid = await getExistingMid(enameController.text.trim());
          bool isNewGroup = (sharedMid == null);
          for (int i = 0; i < selectedSizes.length; i++) {
            int? newPid = await insertAction();
            if (newPid == null) throw Exception("PID 생성 실패");
            if (isNewGroup && i == 0) {
              sharedMid = newPid;
              await uploadImages(newPid);
              await uploadProductName(newPid);
              await uploadManufacturerName(newPid);
            }
            await Future.wait([
              uploadColor(newPid),
              uploadSingleSize(newPid, selectedSizes[i]),
              updateMid(newPid, sharedMid!),
            ]);
          }
          Get.back();
          Get.snackbar("성공", "그룹 등록이 완료되었습니다.", backgroundColor: Colors.white);
        } catch (e) { Get.back(); Get.snackbar("에러", "실패: $e"); }
      },
    );
  }
}

// CurrencyInputFormatter는 기존과 동일하게 유지
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return const TextEditingValue(text: '0');
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '').replaceFirst(RegExp(r'^0+'), '');
    final formatted = digits.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}