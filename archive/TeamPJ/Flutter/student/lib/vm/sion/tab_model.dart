/* 
Description : tab model
Date : 2026-1-19
Author : 정시온
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';

class Tabnotifier extends Notifier<int>{

  @override
  int build() => 0;


  void changeTab(int index){
    state = index;
  }
}// TabNotifier

final tabnotifierProvider = NotifierProvider<Tabnotifier, int>(
  Tabnotifier.new
);