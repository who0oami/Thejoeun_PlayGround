import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:guardian/vm/dusik/emergency_alert_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyAlertPage extends ConsumerWidget {
  const EmergencyAlertPage({super.key});

  Future<void> openMap(double lat, double lng) async {
    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyAsync = ref.watch(emergencyAlertNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("긴급 알림")),
      body: Center(
        child: emergencyAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text("에러 발생: $e"),
          data: (alert) {
            print(alert);
            if (alert == null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "긴급 위치 데이터 없음",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(emergencyAlertNotifierProvider.notifier)
                          .refreshEmergency();
                    },
                    child: const Text("새로고침"),
                  ),
                ],
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "학생 위치가 도착했습니다",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => openMap(alert.lat, alert.lng),
                  child: const Text("위치 확인"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(emergencyAlertNotifierProvider.notifier)
                        .refreshEmergency();
                  },
                  child: const Text("새로고침"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
