import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teacher/model/student.dart';
import 'package:teacher/vm/dusik/student%20_%20provider.dart';

import 'package:http/http.dart' as http;

/* 
Description : 학생 신규 등록 화면
  - 1) 이미지 선택, 사진 촬영
  - 2) 이름 입력
  - 3) 학년, 반 선택
      - drop down 으로 반, 학년 선택
      - 최종 입력 시 _ student_history 테이블-> 반과 번호 들어가게
  - 4) 전화번호 입력 (중복 확인)
      - 미 확인 시 _ ElevatedButton 에 "전화번호 중복을 확인 해주세요."
      - 중복 확인 완료 시 _ ElevatedButton 에 "전화번호 중복 확인 완료."
  - 5) 주소 조회 (주소 검색)
      - Google map API 활용
        - 미 확인 시 _ TextEditingController 에 "Ex) 서울시 강남구 테헤란로 111 주소 를 입력하세요."
        - 중복 확인 완료 시 _ 선택한 주소 띄워주기
  - 6) 생년 월일 입력
        - 캘린더로 선택 가능하게
  - 7) 부모님 연락처 입력
        - 숫자만 입력 가능하게
  - 8) 비밀번호 등록
  - 9) "학생등록" ElevatedButton 클릭시
      - 모든 정보 기입 된 경우
        - 학생 정보 DB에 넣어주기
Date : 2026-01-18
Author : 지현
*/

class InsertStudent extends ConsumerStatefulWidget {
  const InsertStudent({super.key});

  @override
  ConsumerState<InsertStudent> createState() => _InsertStudentState();
}

class _InsertStudentState extends ConsumerState<InsertStudent> {
   // Property
  late final TextEditingController nameController;          // 학생 이름
  late final TextEditingController phoneController;         // 학생 전화번호
  late final TextEditingController guardianPhoneController; // 보호자 연락처
  late final TextEditingController passwordController;      // 학생 비밀번호
  late final TextEditingController addressController;       // 학생 주소
  late final TextEditingController birthdayConttroller;     // 학생 생년월일

  XFile? imageFile;
  final ImagePicker picker = ImagePicker();

  String filename = ""; // ImagePicker 에서 선택된 filename

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    guardianPhoneController = TextEditingController();
    passwordController = TextEditingController();
    addressController = TextEditingController();
    birthdayConttroller = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();    
    guardianPhoneController.dispose();
    passwordController.dispose();
    addressController.dispose();
    birthdayConttroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentNotifier = ref.read(studentNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Insert Student")),
      body: 
        SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () => getImageFromGallery(ImageSource.gallery), 
                child: Text('이미지 가져오기')
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                color: Colors.grey,
                child: Center(
                  child: imageFile == null
                  ? Text("이미지가 선택되지 않았습니다.")
                  :Image.file(File(imageFile!.path))
                  ,
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () => insertAction(), 
            //   child: Text("입력")
            //   ),
            _buildTextField("이름", nameController),
            _buildTextField("전화번호", phoneController),
            _buildTextField("보호자 연락처", guardianPhoneController),
            _buildTextField("비밀번호", passwordController),
            _buildTextField("주소", addressController),
            _buildTextField("생년월일", birthdayConttroller),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final student = Student(
                  student_name: nameController.text, 
                  student_phone: phoneController.text, 
                  student_guardian_phone: guardianPhoneController.text, 
                  student_password: passwordController.text, 
                  student_address: addressController.text, 
                  student_birthday: birthdayConttroller.text, 
                  student_image: await imageFile!.readAsBytes()
                  );
                final result = await studentNotifier.insertStudent(student);
                if (result == 'OK') {
                  if (!context.mounted)
                    return; // await 이후에는 context가 여전히 유효한지 확인
                  Navigator.of(context).pop();
                  _snackBar(context, '학생 정보가 등록 되었습니다.', Colors.blue);
                } else {
                  if (!context.mounted) return;
                  _snackBar(context, '오류가 발생했습니다.', Colors.red);
                }
              },
              child: const Text('입력'),
            ),
          ],
        ),
      ),
    );
  } // build

  // --- Widgets
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // --- Functions
  Future<void> getImageFromGallery(ImageSource imageSource)async{
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if(pickedFile == null){
      // errorSnackBar("이미지를 선택해 주세요");
    }else{
      imageFile = XFile(pickedFile!.path);
    }
    setState(() {});
  }

  

  // Future<void> insertAction() async{
  //   var request = http.MultipartRequest(
  //         'POST', // 메소드 방식
  //         Uri.parse('http://127.0.0.1:8000/insert')
  //       );
  //   request.fields['student_name'] = nameController.text.trim();
  //   request.fields['student_phone'] = phoneController.text.trim();
  //   request.fields['student_guardian_phone'] = guardianPhoneController.text.trim();
  //   request.fields['student_password'] = passwordController.text.trim();
  //   request.fields['student_address'] = addressController.text.trim();
  //   request.fields['student_birthday'] = birthdayConttroller.text.trim();

  //   // 위에는 form 형태라서 저렇게고 아래는 이미지 파일 형식이라 다르게 해줄 거


  //   if(imageFile != null){
  //     request.files.add(await http.MultipartFile.fromPath('file', imageFile!.path));
  //   }
  //   var res = await request.send();
  //   if(res.statusCode == 200){
  //     //
  //   }else{
  //     // errorSnackBar("입력중 문제가 발생 하였습니다.");
  //   }
  // }

  void _snackBar(BuildContext context, String str, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(str),
        duration: Duration(seconds: 1),
        backgroundColor: color,
      ),
    );
  }

  
} // class

