import 'package:dda/service/login_api_service.dart';
import 'package:dda/service/storage_service.dart';
import 'package:dda/view/admin_dashboard_page.dart';
import 'package:dda/view/login_page.dart';
import 'package:dda/view/user_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const DdaApp());
}

class DdaApp extends StatelessWidget {
  const DdaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ttareungyi Neo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF118847),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F5FB),
      ),
      home: const AppEntryPage(),
    );
  }
}

class AppEntryPage extends StatefulWidget {
  const AppEntryPage({super.key});

  @override
  State<AppEntryPage> createState() => _AppEntryPageState();
}

class _AppEntryPageState extends State<AppEntryPage> {
  final _storageService = StorageService();
  final _loginApiService = LoginApiService();
  bool _loading = true;
  Widget _page = const LoginPage();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final token = _storageService.sessionToken;
    final role = _storageService.loginRole;

    if (token == null || role == null) {
      setState(() {
        _loading = false;
        _page = const LoginPage();
      });
      return;
    }

    try {
      await _loginApiService.getMe(token: token);
      setState(() {
        _loading = false;
        _page = role == 'admin'
            ? const AdminDashboardPage()
            : const UserDashboardPage();
      });
    } catch (_) {
      await _storageService.clearSession();
      setState(() {
        _loading = false;
        _page = const LoginPage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _page;
  }
}
