import 'package:dda/service/login_api_service.dart';
import 'package:dda/service/storage_service.dart';
import 'package:dda/view/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardHeader extends StatelessWidget {
  final String activeTab;

  const DashboardHeader({
    super.key,
    required this.activeTab,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['스테이션', '예측', '스케줄', '설정'];

    return Row(
      children: [
        const Text(
          'Ttareungyi Neo',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0D1B2A),
          ),
        ),
        const Spacer(),
        Wrap(
          spacing: 36,
          children: tabs
              .map(
                (tab) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tab,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: tab == activeTab
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: tab == activeTab
                            ? const Color(0xFF118847)
                            : const Color(0xFF0D1B2A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 78,
                      height: 3,
                      color: tab == activeTab
                          ? const Color(0xFF22C55E)
                          : Colors.transparent,
                    ),
                  ],
                ),
              )
              .toList(),
        ),
        const Spacer(),
        const Icon(Icons.notifications, color: Color(0xFF415641)),
        const SizedBox(width: 20),
        InkWell(
          onTap: () async {
            final storage = StorageService();
            final token = storage.sessionToken;
            if (token != null) {
              try {
                await LoginApiService().logout(token: token);
              } catch (_) {
                // Even if the backend session is already invalid, clear local state.
              }
            }
            await storage.clearSession();
            Get.offAll(() => const LoginPage());
          },
          borderRadius: BorderRadius.circular(999),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.account_circle, size: 30, color: Color(0xFF415641)),
          ),
        ),
      ],
    );
  }
}
