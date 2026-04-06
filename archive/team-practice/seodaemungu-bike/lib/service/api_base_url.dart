import 'package:flutter/foundation.dart';

class ApiBaseUrl {
  static String get value {
    if (kIsWeb) {
      return 'http://127.0.0.1:8002';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8002';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://127.0.0.1:8002';
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:8002';
    }
  }
}
