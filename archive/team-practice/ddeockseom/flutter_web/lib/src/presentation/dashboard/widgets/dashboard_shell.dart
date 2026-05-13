import 'package:flutter/material.dart';

import '../../../core/theme/dashboard_palette.dart';
import 'sidebar_navigation.dart';
import 'top_header.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({
    super.key,
    required this.childBuilder,
  });

  final Widget Function(double scrollOffset) childBuilder;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  double _scrollOffset = 0;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.shellGradientStart,
            palette.shellGradientEnd,
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompactLayout = constraints.maxWidth < 1100;

          return Row(
            children: [
              if (!isCompactLayout) const SidebarNavigation(),
              Expanded(
                child: Column(
                  children: [
                    const TopHeader(),
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.axis == Axis.vertical &&
                              notification.metrics.pixels != _scrollOffset) {
                            setState(() {
                              _scrollOffset = notification.metrics.pixels;
                            });
                          }
                          return false;
                        },
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                          child: widget.childBuilder(_scrollOffset),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
