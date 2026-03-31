//  Configuration
/*
  Created in: 16/01/2026 12:11
  Author: Chansol, Park
  Description: Config file for configurations
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
          18/01/2026 12:56, 'Point 1, IP change in different devices', Creator: Chansol, Park
          22/01/2026 10:04, 'Point 2, Actual IP added', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
*/

import 'package:flutter/foundation.dart';

bool _isAllowedLanIp(String host) {
  final match =
      RegExp(r'^192\.168\.10\.(\d{1,3})$').firstMatch(host.trim());

  if (match == null) return false;

  final last = int.parse(match.group(1)!);
  return last >= 0 && last <= 255;
}

String getSafeForwardIp() {
  final ip = getForwardIP();

  if (!_isAllowedLanIp(ip)) {
    throw Exception(
      '허용되지 않은 네트워크입니다.\n'
      '192.168.10.x 환경에서만 사용 가능합니다.',
    );
  }

  return ip;
}


// Point 1
String getForwardIP(){
  if (kIsWeb){
    return '127.0.0.1'; //  Web IP
  }
  switch(defaultTargetPlatform){
    case TargetPlatform.android: return '10.0.2.2'; //  Android emulator IP
    case TargetPlatform.iOS: return '127.0.0.1';  //  IOS emulator IP
    default: return '127.0.0.1';  //  All the others
  }
}
const String forwardport = '8000';

//  Point 2
String centerIP = '192.168.10.';