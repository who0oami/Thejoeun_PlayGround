import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian/firebase_options.dart';
import 'package:guardian/view/chatting/guardian_chatting.dart';
import 'package:intl/date_symbol_data_local.dart'; 

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    debugPrint("Firebase initialization warning: $e");
  }
  
  await initializeDateFormatting('ko_KR');
  runApp(
    ProviderScope(child: const MyApp())
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: GuardianChatting(),
    );
  }
}
