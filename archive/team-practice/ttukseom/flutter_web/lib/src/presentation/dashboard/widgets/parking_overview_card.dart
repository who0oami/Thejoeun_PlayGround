import 'package:flutter/material.dart';

import '../../../core/theme/dashboard_palette.dart';
import '../../../domain/models/parking_lot.dart';

class ParkingOverviewCard extends StatelessWidget {
  const ParkingOverviewCard({
    super.key,
    required this.parkingLots,
    required this.selectedIndex,
    required this.onParkingLotSelected,
    required this.selectedLot,
    required this.onDetailPressed,
  });

  final List<ParkingLot> parkingLots;
  final int selectedIndex;
  final ValueChanged<int> onParkingLotSelected;
  final ParkingLot? selectedLot;
  final VoidCallback? onDetailPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(context),
            const SizedBox(height: 20),
            _buildParkingLotGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\uC2E4\uC2DC\uAC04 \uD1B5\uD569 \uD604\uD669',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '\uC8FC\uCC28\uC7A5\uBCC4 \uC810\uC720\uC728\uACFC \uC794\uC5EC \uACF5\uAC04\uC744 \uBE60\uB974\uAC8C \uD655\uC778\uD558\uC138\uC694.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.mutedText,
                    ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: selectedLot == null ? null : onDetailPressed,
          child: const Text('\uC0C1\uC138\uBCF4\uAE30'),
        ),
      ],
    );
  }

  Widget _buildParkingLotGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactWidth = constraints.maxWidth < 700;

        return GridView.builder(
          shrinkWrap: true,
          itemCount: parkingLots.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isCompactWidth ? 1 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isCompactWidth ? 2.35 : 1.65,
          ),
          itemBuilder: (context, index) {
            return _ParkingLotTile(
              lot: parkingLots[index],
              isSelected: index == selectedIndex,
              onTap: () => onParkingLotSelected(index),
            );
          },
        );
      },
    );
  }
}

class _ParkingLotTile extends StatelessWidget {
  const _ParkingLotTile({
    required this.lot,
    required this.isSelected,
    required this.onTap,
  });

  final ParkingLot lot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final occupancyPercent = '${(lot.occupancyRate * 100).round()}% \uC810\uC720';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? palette.panelBackground : palette.panelBackground.withOpacity(0.7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSelected ? lot.progressColor.withOpacity(0.8) : palette.cardBorder,
          width: isSelected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? lot.progressColor.withOpacity(0.12) : palette.glowColor,
            blurRadius: isSelected ? 22 : 18,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLotHeader(context),
                const Spacer(),
                Text(
                  '${lot.occupied} / ${lot.capacity}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\uC8FC\uCC28\uAC00\uB2A5 ${lot.available}\uBA74',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.mutedText,
                      ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: lot.occupancyRate,
                    backgroundColor: palette.progressTrack,
                    valueColor: AlwaysStoppedAnimation<Color>(lot.progressColor),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    occupancyPercent,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLotHeader(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Expanded(
          child: Text(
            lot.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.secondaryText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? lot.statusColor.withOpacity(0.22) : lot.statusColor.withOpacity(0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: lot.progressColor.withOpacity(0.45)),
          ),
          child: Text(
            lot.statusLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.primaryText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
