import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/util/acolor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:student/vm/dusik/student%20_%20provider.dart';

/* 
Description : 학생 긴급 호출 화면
  - 1) 긴급 호출 이미지
  - 2) 길게 누르면 이미지 변경, 하단 텍스트 변경
      - 기본 이미지 , 기본 텍스트 설정
      - 변경하면서 현재 위치 전달
  - 3) Firestore에 긴급 알림 저장
      - guardian 앱에서 ACTIVE 상태만 조회
Date : 2026-01-17
Author : 지현
*/

class Emergency extends ConsumerStatefulWidget {
  const Emergency({super.key});

  @override
  ConsumerState<Emergency> createState() => _EmergencyState();
}

class _EmergencyState extends ConsumerState<Emergency> {


  late String emergencyText; // 버튼 하단 텍스트
  late String buttonImage;   // 버튼 이미지
  late Color appBarColor;    // 앱바 컬러
  late Color bodyColor;      // 바디 컬러

  final box = GetStorage();  //로그인 정보 저장소

  @override
  void initState() {
    super.initState();
    emergencyText = "위급한 상황에 꾸욱- 눌러주세요";
    buttonImage = "images/emergency.png";
    appBarColor = Acolor.baseBackgroundColor;
    bodyColor = Acolor.baseBackgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    final gid = ref.watch(guardianIdProvider(box.read('student_id')));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
      ),
      body: Container(
        color: bodyColor,
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "긴급 호출",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onLongPress: () async {
                  gid.when(
                    data: (data) => buttonChange(data),
                    error: (error, stackTrace) => Center(child: Text('Error:$error'),),
                    loading: () => Center(child: CircularProgressIndicator(),),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(buttonImage),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                emergencyText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "위급한 상황에만 눌러주세요",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      )
    );
  } // build 끝

  //
  /*
  void buttonChange(){
    if(emergencyText == "위급한 상황에 꾸욱- 눌러주세요"){
      emergencyText = "현재 위치가 전달 되었습니다";
      appBarColor = Colors.green;
      bodyColor = Colors.yellow;
      buttonImage = "images/emergency_push.png";
    }else{
      emergencyText = "위급한 상황에 꾸욱- 눌러주세요";
      appBarColor = Colors.red;
      bodyColor = Colors.blue;
      buttonImage = "images/emergency.png";
    }
    setState(() {});
  }
  */

  Future<void> buttonChange(int gid) async {
    // 이미 호출된 상태면 다시 실행 안 함
    if (emergencyText != "위급한 상황에 꾸욱- 눌러주세요") return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final studentId = box.read('student_id');
    final guardianId = gid;
    if (studentId == null || guardianId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인 정보가 없습니다")),
      );
      return;
    }

    await FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'atti',
  ).collection("emergency_calls")
        .add({
      "student_id": studentId,              // 학생 ID
      "guardian_id": guardianId,             // 보호자 ID
      "teacher_id": 1,
      "alert_lat": position.latitude,        // 위도
      "alert_lng": position.longitude,       // 경도
      "status": "ACTIVE",                    // 
      "alert_start_date": FieldValue.serverTimestamp(),
    });
    setState(() {
      emergencyText = "현재 위치가 전달 되었습니다";
      appBarColor = Colors.green;
      bodyColor = Colors.yellow;
      buttonImage = "images/emergency_push.png";
    });
  }
} // class