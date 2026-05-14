import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_web/src/app.dart';

void main() {
  testWidgets('dashboard renders after loading mock data', (tester) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ParkFlowApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('실시간 통합 현황'), findsNothing);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('실시간 통합 현황'), findsOneWidget);
    expect(find.text('중앙 주차타워 1'), findsOneWidget);
    expect(find.text('시스템 상태'), findsOneWidget);
  });
}
