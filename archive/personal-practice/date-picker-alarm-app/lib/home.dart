import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Property
  late String currentDateTime; // 현재 시간
  DateTime? chosenDateTime;  // 선택 시간
  late bool _isRunning; // 작동 여부
  late Color _color; // 배경색
  late String _chosenTime; // 선택 시간_비교용

  @override
  void initState() {
    super.initState();
     currentDateTime = "";
    _isRunning = true;
    Timer.periodic(Duration(seconds: 1), (timer){
      if(!_isRunning){
        timer.cancel();
      }
      _addItem();
      setState(() {});
    },
    );
    _color = Colors.white;
  }
  _addItem(){
    DateTime now = DateTime.now();
    currentDateTime = ("${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${_weekdatToString(now.weekday)} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}:${now.second.toString().padLeft(2,'0')}");
  
  String _currentDateTime = ("${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${_weekdatToString(now.weekday)} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}");
  //  _currentDateTime => 현재 시간_비교용
  if(chosenDateTime != null && _chosenTime == _currentDateTime){
    _color = _color ==  Colors.red ? Colors.yellow : Colors.red;
  }else{
    _color = Colors.white;
  }
  
  }
  _weekdatToString(int weekday){
    String dateName = "";
    switch(weekday){
      case 1 : dateName  = "월";
      case 2 : dateName  = "화";
      case 3 : dateName  = "수";
      case 4 : dateName  = "목";
      case 5 : dateName  = "금";
      case 6 : dateName  = "토";
      case 7 : dateName  = "일";
    }
      return dateName;
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알람 정하기'),
      ),
      backgroundColor: _color,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "현재 시간 : $currentDateTime",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(
              width: 300,
              height: 200,
              child: CupertinoDatePicker(
                initialDateTime: DateTime.now(),
                use24hFormat: true,
                onDateTimeChanged: (value) {
                  chosenDateTime = value;
                  setState(() {});
                },
              ),
            ),
            Text(
              "선택시간 : ${chosenDateTime != null ? _chosenItem(chosenDateTime!): "시간을 선택하세요!"}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
      ),
    );
  } // build
  // ----- Functions -----
  String _chosenItem(DateTime now){
    String chosenDateTime = ("${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${_weekdatToString(now.weekday)} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}");
    _chosenTime =("${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${_weekdatToString(now.weekday)} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}");
    return chosenDateTime;
  }

}//class