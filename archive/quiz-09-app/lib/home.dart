import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late int selectedItem; // 고른 숫자
  late List dan; // 구구단 몇단 인지

  @override
  void initState() {
    super.initState();
    selectedItem = 0;
    dan = List.generate(8, (index) => index+2);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${dan[selectedItem]}단'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 250,
              child: CupertinoPicker(
                itemExtent: 50,
                scrollController: FixedExtentScrollController(initialItem: 0),
                onSelectedItemChanged: (value) {
                  selectedItem = value;
                  setState(() {});
                }, 
                children: List.generate(
                    8,
                   (index) => Center( 
                    child: Text("${dan[index]}단") 
                   ),
                   ),
                ),
            ),
            Text(
              gugudanPrint()
            ),
          ],
        ),
      ),
    );
  } // build

  // ----Functions ----- 
  String gugudanPrint(){
    String gugu = "";
      for(int i =1; i<10; i++){
      gugu += "${dan[selectedItem]} X $i = ${dan[selectedItem]*i}\n";
      }
      return gugu;
  }



} // class