import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'view_models/dashboard_view_model.dart';
import 'widgets/dashboard_content.dart';
import 'widgets/dashboard_shell.dart';
import 'notices/notices_page.dart';

class DashboardPage extends GetView<DashboardViewModel> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value || controller.dashboardSnapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return DashboardShell(
            childBuilder: (scrollOffset) {
              return Obx(() {
                final section = controller.currentSection.value;
                final index = switch (section) {
                  DashboardSection.dashboard => 0,
                  DashboardSection.notices => 1,
                  DashboardSection.settings => 2,
                };

                return IndexedStack(
                  index: index,
                  children: [
                    DashboardContent(
                      controller: controller,
                      scrollOffset: scrollOffset,
                    ),
                    const NoticesPage(),
                    const _SettingsPlaceholder(),
                  ],
                );
              });
            },
          );
        }),
      ),
    );
  }
}

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
