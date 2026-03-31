import 'dart:convert';

import 'package:brand_app/ip/ipaddress.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/* 
Description : 상품 재고 조회 화면
  - 1) 상단에 검색 TextEditingController 넣기
      - 상품 테이블에서 검색 할 수 있게
  - 2) 상품 테이블에 저장된 값으로 이미지, 제조사, 상품명, 재고수량 띄워주기.
      - GridViewBbuilder로
Date : 2025-12-31
Author : 지현
*/

class ProductInventory extends StatefulWidget {
  const ProductInventory({super.key});

  @override
  State<ProductInventory> createState() => _ProductInventoryState();
}

class _ProductInventoryState extends State<ProductInventory> {
  // Property 
  TextEditingController searchController = TextEditingController(); // 검색 controller
  ScrollController scrollController = ScrollController(); // GridViewBbuilder용
  List inventoryList = []; // 재고 (상품) 데이터 받아올 곳
  int orderAmount =  0; // 발주 수량

  @override
  void initState() {
    super.initState();
   getJSONData();

  }

  Future<void> getJSONData() async {
    String search = searchController.text.trim(); // 검색어
    var url;
    if (search.isEmpty) {
      url = Uri.parse("${IpAddress.baseUrl}/product/selectInventoryAll");
    } else {
      url = Uri.parse("${IpAddress.baseUrl}/product/searchInventory?query=$search");
    }
    var response = await http.get(url);
    var dataConvertdJSON = json.decode(utf8.decode(response.bodyBytes));
    List results = dataConvertdJSON['results'];
    if (results.isNotEmpty) {
      setState(() {
        inventoryList = results;
      });
    } else {
      setState(() {
        inventoryList = [];
      });
    }
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            SizedBox(height: 7),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요',
                  suffixIcon: IconButton(
                    onPressed: () {
                      getJSONData();
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
                keyboardType: TextInputType.text,
                maxLength: 20,
                maxLines: 1,
              ),
            )
          ],
        ),
        toolbarHeight: 120,
      ),
      body: Center(
        child: Column(
          children: [
            Expanded( 
              child: GridView.builder(
                controller: scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                ),
                itemCount: inventoryList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      children: [
                        Image.network(
                          '${IpAddress.baseUrl}/productimage/view?pid=${inventoryList[index]['mid']}&position=main',
                          width: 100,
                          height: 100,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(inventoryList[index]['mname'].toString()),  // 제조사
                                Text(inventoryList[index]['name'].toString(),
                                    style: TextStyle(fontWeight: FontWeight.bold)), // 상품명
                              ],
                            ),
                            Text(inventoryList[index]['color'].toString()), // 색상
                            Text(inventoryList[index]['quantity'].toString()), // 재고수량
                            inventoryList[index]['quantity'] <= 60
                            ? ElevatedButton(
                              onPressed: () {
                                _showOrderDialog(index, inventoryList[index]['quantity']);
                              }, 
                              child: Text("발주넣기"))
                            : SizedBox(height: 30),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  } // buid
  // ---- Functions ----
  void _showOrderDialog(int index, int currentStock) {
  orderAmount = 100 - currentStock;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("발주 확인"),
      content: Text("${inventoryList[index]['name']}\n\n$orderAmount개를 발주 넣으시겠습니까?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("아니요")),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // 발주 api 넣을 예정
          }, 
          child: const Text("예")
        ),
      ],
    ),
  );
}

} // class