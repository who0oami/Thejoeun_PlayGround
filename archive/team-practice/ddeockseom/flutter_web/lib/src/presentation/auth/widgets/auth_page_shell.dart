import 'package:flutter/material.dart';
import '../../../core/theme/dashboard_palette.dart';
import '../../../core/utils/breakpoints.dart';

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({
    super.key,
    required this.leftTitle,
    required this.leftSubtitle,
    required this.leftCaption,
    required this.formCard,
    this.leftImageAsset,
  });

  final String leftTitle;
  final String leftSubtitle;
  final String leftCaption;
  final Widget formCard;
  final String? leftImageAsset;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<DashboardPalette>()!;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final breakpoint = breakpointForWidth(width);
            final isMobile = breakpoint.name == 'MOBILE';
            final useSideBySide = width >= 1000;

            final leftPanel = Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                isMobile ? 24 : 48,
                isMobile ? 32 : 48,
                isMobile ? 24 : 40,
                isMobile ? 32 : 48,
              ),
              decoration: BoxDecoration(
                image: leftImageAsset != null
                    ? DecorationImage(
                        image: AssetImage(leftImageAsset!),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          const Color(0xFF103A96).withOpacity(0.7),
                          BlendMode.darken,
                        ),
                      )
                    : null,
                gradient: leftImageAsset == null
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1B4DD0), Color(0xFF103A96)],
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.water_drop, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'HanFlow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    leftTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 32 : 40,
                      fontWeight: FontWeight.bold,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    leftSubtitle,
                    style: TextStyle(
                      color: const Color(0xFFCDD8FF),
                      fontSize: isMobile ? 14 : 16,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            leftCaption,
                            style: TextStyle(color: Colors.white70, fontSize: isMobile ? 12 : 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

            final formPanel = Center(
              child: Container(
                width: useSideBySide ? 520 : double.infinity,
                padding: EdgeInsets.all(isMobile ? 24 : 32),
                decoration: BoxDecoration(
                  color: palette.cardBackground,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 36,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: formCard,
              ),
            );

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: useSideBySide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: leftPanel),
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
                                child: formPanel,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            leftPanel,
                            const SizedBox(height: 24),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 24),
                              child: formPanel,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
