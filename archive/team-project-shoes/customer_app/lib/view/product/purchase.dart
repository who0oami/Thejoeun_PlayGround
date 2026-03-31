import 'dart:convert';

import 'package:customer_app/ip/ipaddress.dart';
import 'package:customer_app/util/pcolor.dart';
import 'package:customer_app/view/map/map_select.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

/* 
Description : 사용자 결제 화면
  - 1) 상세페이지에서 넘어온 상품 정보, 수량, 구매 금액등을 획득.
  - 2) 획득된 정보를 memory에 존재 함으로 snapshot으로 Data를 가져온다.
  - 3) TextEditingController에 입력한 게 있는 경우 검색으로 넘겨준다.
  - 4) 검색으로 이동후에 돌아왔을 경우 매장 정보를 가지고 와서 새로 텍스트필드에 넣어준다.
  - 5) 픽업장소 미 지정 시
      - 지점 하단 지점명 대신 "미지정"으로 입력, 텍스트 컬러 -> 회색
      - 결제하기 하단 버튼 컬러 회색 & 눌리지 않게
  - 5) 픽업 장소 정해진 상태에서 결제하기 누르면 결제 완료 페이지 띄워준다. 
Date : 2025-12-30
Author : 지현
*/

class Purchase extends StatefulWidget {
  const Purchase({super.key});

  @override
  State<Purchase> createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase> {
  // Property
  late TextEditingController branchName; //  매장명
  late bool isBranchSelected; // 픽업 장소 선택 여부
  late int _radioValue; // Radio 버튼
  late Color okColor = Pcolor.appBarBackgroundColor; // 선택 시 바뀌는 컬러값
  late int totalPrice;
  late int fee = 6000;

  Map<String, dynamic> selectedProduct = Get.arguments; // 넘어온 상품 정보 저장
  int? selectedSid;

  @override
  void initState() {
    super.initState();
    branchName = TextEditingController();
    isBranchSelected = false;
    _radioValue = 0;
    totalPrice=(selectedProduct['price'])*(selectedProduct['quantity'])+fee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pcolor.basebackgroundColor,
        title: Text("결제하기"),
      ),
      backgroundColor: Color.fromARGB(255, 243, 243, 243),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "수령매장 선택",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                  color: Pcolor.basebackgroundColor,
                  borderRadius: BorderRadius.circular(16), // ← 동그랗게
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '지점',
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                              ),
                            Text(
                            branchName.text.isEmpty ? '미지정' : branchName.text,
                            style: TextStyle(
                              color: branchName.text.isEmpty ? const Color.fromARGB(255, 194, 194, 194) : Colors.black,
                            ),
                          ),
                          ],
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            height: 40,
                            child: TextField(
                              controller: branchName,
                              readOnly: true,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                                filled: true,
                                fillColor: const Color.fromARGB(255, 194, 194, 194),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 12,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    final result = await Get.to(() => MapSelect(), arguments: {
                                      'branchName': branchName.text,
                                    });
                                    if (result != null) {
                                      setState(() {
                                        branchName.text = result['branchName'];
                                        selectedSid = result['id'];
                                        isBranchSelected = true; // 버튼 활성화
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.search,
                                    color: Pcolor.appBarForegroundColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                "주문 상품",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                  color: Pcolor.appBarForegroundColor,
                  borderRadius: BorderRadius.circular(16), 
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                selectedProduct['image'],
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                  selectedProduct['name'],
                                  style: TextStyle(
                                  fontWeight: FontWeight.bold),),
                                  Text(selectedProduct['manufacturername'],),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${selectedProduct['size']} Size",
                                      style: TextStyle(
                                      fontWeight: FontWeight.bold),),
                                      Text(
                                        " / ",
                                      style: TextStyle(
                                      fontWeight: FontWeight.bold),),
                                      Text(
                                        "${selectedProduct['quantity']} 개",
                                      style: TextStyle(
                                      fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                ],
                              ),
                              ),
                          ],
                        ),
                        Divider(),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("결제 금액"),
                            Text("${selectedProduct['price']} 원"),
                          ],
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                "최종 주문 정보",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                  color: Pcolor.basebackgroundColor,
                  borderRadius: BorderRadius.circular(16), 
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        RadioGroup(
                        groupValue: _radioValue,
                        onChanged: (value) {
                          _radioValue = value!;
                          setState(() {});
                        }, 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Radio(value: 0),Text('간편 결제'),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(value: 1),Text('신용카드'),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(value: 2),Text('매장에서 결제'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ]
                      )
                      ),
                )
              ),
              Text(
                "최종 주문 정보",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                  color: Pcolor.basebackgroundColor,
                  borderRadius: BorderRadius.circular(16), 
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('구매가 합계'),
                                Text("${selectedProduct['price']*(selectedProduct['quantity'])} 원"), 
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('수수료'),
                                Text('6,000 원'),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                        SizedBox(height: 12),
                        Divider(),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                         Text(
                          '총 결제금액',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                         Text(
                          '$totalPrice원',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 40,
          width: 50,
          child: ElevatedButton(
            onPressed: () {
              if(branchName.text.isEmpty){
               okColor = Pcolor.errorBackColor;
              }else {
                insertPurchase(); 
              }
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: okColor,
              foregroundColor: Pcolor.effectForeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
                )
            ),
            child: Text("결제하기")
            ),
        ),
      ),
        );
  } // build
    // --- Functions ---
   Future<void> insertPurchase() async {
    var url = Uri.parse("${IpAddress.baseUrl}/purchase/insert");

    var response = await http.post(
      url,
      body: {
        'quantity': selectedProduct['quantity'].toString(), // 구매 수량
        'finalprice': totalPrice,// 최종 결제 금액
        'code': "ORD${DateTime.now().millisecondsSinceEpoch}", // 주문 번호_유저 정보조합 등으로 수정예정
        'pid': selectedProduct['pid'].toString(),
        'eid': selectedSid.toString(), 
        'cid': "1",
      },
    );
    var dataConvertdJSON = json.decode(utf8.decode(response.bodyBytes));
    
    if (dataConvertdJSON['result'] == "OK") {
      Get.snackbar("알림", "결제가 완료되었습니다!");
    } else {
      Get.snackbar("오류", "결제에 실패했습니다.");
    }
  }

} // class