import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view_models/dashboard_view_model.dart';
import '../detail/parking_lot_detail_page.dart';
import 'parking_location_map_card.dart';
import 'widgets.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({
    super.key,
    required this.controller,
    required this.scrollOffset,
  });

  final DashboardViewModel controller;
  final double scrollOffset;

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final snapshot = widget.controller.snapshot;
      if (snapshot == null) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopSection(),
        ],
      );
    });
  }

  Widget _buildTopSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          final isWideScreen = constraints.maxWidth >= 1120;
          final parkingLots = widget.controller.filteredParkingLots;
          final selectedIndex = widget.controller.selectedIndex;
          final selectedLot = widget.controller.selectedParkingLot;

          final parkingCard = ParkingOverviewCard(
            parkingLots: parkingLots,
            selectedIndex: selectedIndex,
            onParkingLotSelected: widget.controller.selectParkingLot,
            selectedLot: selectedLot,
            onDetailPressed: selectedLot == null
                ? null
                : () => Get.to(
                      () => ParkingLotDetailPage(
                        parkingLots: parkingLots,
                        selectedIndex: selectedIndex,
                      ),
                    ),
          );

          final mapCard = ParkingLocationMapCard(
            parkingLots: parkingLots,
            selectedIndex: selectedIndex,
            onParkingLotSelected: widget.controller.selectParkingLot,
            selectedLot: selectedLot,
          );

          if (isWideScreen) {
            final mapWidth = constraints.maxWidth * 0.36;
            final stickyTop = widget.scrollOffset + 16;

            return Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: parkingCard,
                    ),
                    const SizedBox(width: 20),
                    SizedBox(width: mapWidth + 24),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: stickyTop,
                  child: SizedBox(
                    width: mapWidth,
                    child: mapCard,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              parkingCard,
              const SizedBox(height: 18),
              mapCard,
            ],
          );
        });
      },
    );
  }
}
