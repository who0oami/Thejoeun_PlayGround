import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/theme/app_theme.dart';
import 'presentation/app/bindings/app_binding.dart';
import 'presentation/app/controllers/app_theme_controller.dart';
import 'presentation/auth/auth_routes.dart';
import 'presentation/auth/login/login_page.dart';
import 'presentation/dashboard/dashboard_page.dart';

void bootstrap() {
  Get.put(AppThemeController(), permanent: true);
  runApp(const ParkFlowApp());
}

class ParkFlowApp extends StatelessWidget {
  const ParkFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = Get.find<AppThemeController>();

      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ParkFlow Admin',
        initialBinding: AppBinding(),
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeController.themeMode.value,
        initialRoute: AuthRoutes.login,
        getPages: [
          GetPage(name: AuthRoutes.login, page: () => const LoginPage()),
          GetPage(name: AuthRoutes.dashboard, page: () => const DashboardPage()),
        ],
        unknownRoute: GetPage(name: AuthRoutes.login, page: () => const LoginPage()),
      );
    });
  }
}
