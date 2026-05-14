import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/dashboard_palette.dart';
import '../../../domain/models/parking_lot.dart';
import '../widgets/parking_location_map_card.dart';

class ParkingLotDetailPage extends StatefulWidget {
  const ParkingLotDetailPage({
    super.key,
    required this.parkingLots,
    required this.selectedIndex,
  });

  final List<ParkingLot> parkingLots;
  final int selectedIndex;

  @override
  State<ParkingLotDetailPage> createState() => _ParkingLotDetailPageState();
}

class _ParkingLotDetailPageState extends State<ParkingLotDetailPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.parkingLots.isEmpty
        ? 0
        : widget.selectedIndex.clamp(0, widget.parkingLots.length - 1).toInt();
  }

  @override
  void didUpdateWidget(covariant ParkingLotDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.parkingLots != oldWidget.parkingLots) {
      _selectedIndex = widget.parkingLots.isEmpty
          ? 0
          : _selectedIndex.clamp(0, widget.parkingLots.length - 1).toInt();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selectedLot = _selectedLot;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, palette, selectedLot),
              const SizedBox(height: 20),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 1180;

                    final detailMap = ParkingLocationMapCard(
                      parkingLots: widget.parkingLots,
                      selectedIndex: _selectedIndex,
                      onParkingLotSelected: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      selectedLot: selectedLot,
                      height: isWide ? 640 : 520,
                      isDetailView: true,
                    );

                    final forecastPanel = _buildForecastPanel(context, palette, selectedLot);
                    final summaryPanel = _buildSummaryPanel(context, palette, selectedLot);

                    final content = isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    summaryPanel,
                                    const SizedBox(height: 20),
                                    detailMap,
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                width: 380,
                                child: forecastPanel,
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              summaryPanel,
                              const SizedBox(height: 20),
                              detailMap,
                              const SizedBox(height: 20),
                              forecastPanel,
                            ],
                          );

                    return SingleChildScrollView(
                      child: content,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ParkingLot? get _selectedLot {
    if (widget.parkingLots.isEmpty) {
      return null;
    }

    final index = _selectedIndex.clamp(0, widget.parkingLots.length - 1).toInt();
    return widget.parkingLots[index];
  }

  Widget _buildHeader(BuildContext context, DashboardPalette palette, ParkingLot? lot) {
    return Row(
      children: [
        Material(
          color: palette.panelBackground,
          borderRadius: BorderRadius.circular(14),
          child: IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: '\uB3CC\uC544\uAC00\uAE30',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\uC8FC\uCC28\uC7A5 \uC0C1\uC138\uBCF4\uAE30',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFFE8F2FF),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                lot == null
                    ? '\uC120\uD0DD\uB41C \uC8FC\uCC28\uC7A5\uC774 \uC5C6\uC2B5\uB2C8\uB2E4.'
                    : '${lot.name}\uC758 \uD604\uC7AC \uB300\uC218\uC640 1~8\uC2DC\uAC04 \uC608\uCE21\uAC12\uC744 \uD655\uC778\uD569\uB2C8\uB2E4.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFA7BCD8),
                    ),
              ),
            ],
          ),
        ),
        if (lot != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: lot.statusColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: lot.progressColor.withOpacity(0.35)),
            ),
            child: Text(
              lot.statusLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFE8F2FF),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryPanel(BuildContext context, DashboardPalette palette, ParkingLot? lot) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: lot == null
            ? const SizedBox.shrink()
            : Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _SummaryTile(
                    title: '\uD604\uC7AC \uC810\uC720',
                    value: '${lot.occupied}\uB300',
                    subtitle: '\uC804\uCCB4 ${lot.capacity}\uBA74 \uC911',
                    color: lot.progressColor,
                    palette: palette,
                  ),
                  _SummaryTile(
                    title: '\uB0A8\uC740 \uC790\uB9AC',
                    value: '${lot.remaining}\uB300',
                    subtitle: '\uC9C0\uAE08 \uBC14\uB85C \uC8FC\uCC28 \uAC00\uB2A5',
                    color: const Color(0xFF18B5D8),
                    palette: palette,
                  ),
                  _SummaryTile(
                    title: '\uC810\uC720\uC728',
                    value: '${(lot.occupancyRate * 100).round()}%',
                    subtitle: lot.statusLabel,
                    color: lot.statusColor,
                    palette: palette,
                  ),
                  _SummaryTile(
                    title: '\uC704\uACBD\uB3C4',
                    value: lot.latitude.toStringAsFixed(5),
                    subtitle: lot.longitude.toStringAsFixed(5),
                    color: palette.secondaryText,
                    palette: palette,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildForecastPanel(BuildContext context, DashboardPalette palette, ParkingLot? lot) {
    if (lot == null) {
      return const SizedBox.shrink();
    }

    final forecast = _buildForecast(lot);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1~8\uC2DC\uAC04 \uC794\uC5EC\uB300\uC218 \uC608\uCE21',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: palette.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '\uD604\uC7AC \uC0C1\uD0DC\uB97C \uAE30\uC900\uC73C\uB85C \uD55C \uB354\uBBF8 \uC608\uCE21\uAC12\uC785\uB2C8\uB2E4.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.secondaryText,
                  ),
            ),
            const SizedBox(height: 20),
            ...forecast.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ForecastRow(
                  hour: item.hour,
                  remaining: item.remaining,
                  delta: item.delta,
                  directionLabel: item.directionLabel,
                  palette: palette,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ForecastPoint> _buildForecast(ParkingLot lot) {
    const deltas = <int>[1, 3, 4, 6, 7, 9, 10, 12];
    const directions = <String>[
      '\uC548\uC815',
      '\uC18C\uD3ED \uAC10\uC18C',
      '\uAC10\uC18C',
      '\uAC10\uC18C',
      '\uAC10\uC18C',
      '\uAE09\uAC10',
      '\uAE09\uAC10',
      '\uAE09\uAC10',
    ];

    return List.generate(8, (index) {
      final remaining = (lot.remaining - deltas[index]).clamp(0, lot.capacity).toInt();
      return _ForecastPoint(
        hour: index + 1,
        remaining: remaining,
        delta: lot.remaining - remaining,
        directionLabel: directions[index],
      );
    });
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.palette,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final DashboardPalette palette;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFE8F2FF) : const Color(0xFF5B6475);
    final valueColor = isDark ? Colors.white : const Color(0xFF1B2430);
    final subtitleColor = isDark ? const Color(0xFFB7C8E0) : const Color(0xFF7A8799);

    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: subtitleColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _ForecastPoint {
  const _ForecastPoint({
    required this.hour,
    required this.remaining,
    required this.delta,
    required this.directionLabel,
  });

  final int hour;
  final int remaining;
  final int delta;
  final String directionLabel;
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({
    required this.hour,
    required this.remaining,
    required this.delta,
    required this.directionLabel,
    required this.palette,
  });

  final int hour;
  final int remaining;
  final int delta;
  final String directionLabel;
  final DashboardPalette palette;

  @override
  Widget build(BuildContext context) {
    final percentage = (remaining / (remaining + delta + 1)).clamp(0.05, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1EAF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$hour\uC2DC\uAC04 \uD6C4',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF1B2430),
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              Text(
                directionLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF0F92E9),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: percentage,
              backgroundColor: const Color(0xFFE8EEF7),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3F6BFF)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\uC608\uC0C1 \uC794\uC5EC ${remaining}\uBA74  \u00B7  ${delta}\uBA74 \uAC10\uC18C',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF7A8799),
                ),
          ),
        ],
      ),
    );
  }
}
