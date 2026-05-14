import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/dashboard_palette.dart';
import '../../../domain/models/parking_lot.dart';

class ParkingLocationMapCard extends StatelessWidget {
  const ParkingLocationMapCard({
    super.key,
    required this.parkingLots,
    required this.selectedIndex,
    required this.onParkingLotSelected,
    required this.selectedLot,
    this.height = 420,
    this.isDetailView = false,
  });

  final List<ParkingLot> parkingLots;
  final int selectedIndex;
  final ValueChanged<int> onParkingLotSelected;
  final ParkingLot? selectedLot;
  final double height;
  final bool isDetailView;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\uC8FC\uCC28\uC7A5 \uC704\uCE58',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: palette.primaryText,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\uC8FC\uCC28\uC7A5\uC744 \uC120\uD0DD\uD558\uBA74 \uC9C0\uB3C4\uC758 \uC911\uC2EC\uC73C\uB85C \uC774\uB3D9\uD569\uB2C8\uB2E4.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: palette.secondaryText,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: palette.primaryText.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: palette.cardBorder),
                  ),
                  child: Text(
                    '\uC2E4\uC2DC\uAC04',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.primaryText,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final viewport = Size(constraints.maxWidth, constraints.maxHeight);
                  final worldSize = Size(
                    math.max(viewport.width * (isDetailView ? 1.82 : 1.56), isDetailView ? 1320 : 1120),
                    math.max(viewport.height * (isDetailView ? 1.62 : 1.42), isDetailView ? 860 : 740),
                  );
                  final placements = _buildPlacements(worldSize);
                  final selectedPlacement = placements.isEmpty
                      ? null
                      : placements[selectedIndex.clamp(0, placements.length - 1).toInt()];
                  final offset = _centerOffset(
                    viewport: viewport,
                    worldSize: worldSize,
                    selectedPlacement: selectedPlacement,
                  );

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          left: offset.dx,
                          top: offset.dy,
                          child: SizedBox(
                            width: worldSize.width,
                            height: worldSize.height,
                            child: InteractiveViewer(
                              constrained: false,
                              boundaryMargin: EdgeInsets.symmetric(
                                horizontal: worldSize.width * 0.25,
                                vertical: worldSize.height * 0.25,
                              ),
                              minScale: 0.72,
                              maxScale: 2.1,
                              child: SizedBox(
                                width: worldSize.width,
                                height: worldSize.height,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: _MapBackdrop(
                                        child: CustomPaint(
                                          painter: _MapCanvasPainter(
                                            palette: palette,
                                            isDetailView: isDetailView,
                                          ),
                                        ),
                                      ),
                                    ),
                                    for (final placement in placements)
                                      _MapMarker(
                                        lot: placement.lot,
                                        index: placement.index,
                                        isSelected: placement.index == selectedIndex,
                                        left: placement.left,
                                        top: placement.top,
                                        onTap: () => onParkingLotSelected(placement.index),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 18,
                          child: _SelectedLotInfo(
                            selectedIndex: selectedIndex,
                            selectedLot: selectedLot,
                            palette: palette,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_MarkerPlacement> _buildPlacements(Size worldSize) {
    if (parkingLots.isEmpty) {
      return const [];
    }

    final lats = parkingLots.map((lot) => lot.latitude).toList(growable: false);
    final lngs = parkingLots.map((lot) => lot.longitude).toList(growable: false);

    final minLat = lats.reduce(math.min);
    final maxLat = lats.reduce(math.max);
    final minLng = lngs.reduce(math.min);
    final maxLng = lngs.reduce(math.max);

    final latSpan = (maxLat - minLat).abs();
    final lngSpan = (maxLng - minLng).abs();

    final baseX = worldSize.width * 0.50;
    final baseY = worldSize.height * 0.47;
    final spreadX = worldSize.width * 0.34;
    final spreadY = worldSize.height * 0.25;

    return [
      for (var i = 0; i < parkingLots.length; i++)
        (() {
          final lot = parkingLots[i];
          final xRatio = lngSpan == 0
              ? 0.5
              : ((lot.longitude - minLng) / lngSpan).clamp(0.0, 1.0);
          final yRatio = latSpan == 0
              ? 0.5
              : ((maxLat - lot.latitude) / latSpan).clamp(0.0, 1.0);

          final wiggle = (i.isEven ? -1 : 1) * 12.0;
          return _MarkerPlacement(
            lot: lot,
            index: i,
            left: baseX + (xRatio - 0.5) * spreadX + wiggle,
            top: baseY + (yRatio - 0.5) * spreadY + (i * 6.0),
          );
        })(),
    ];
  }

  Offset _centerOffset({
    required Size viewport,
    required Size worldSize,
    required _MarkerPlacement? selectedPlacement,
  }) {
    if (selectedPlacement == null) {
      return Offset.zero;
    }

    final targetX = viewport.width / 2 - selectedPlacement.left - 22;
    final targetY = viewport.height / 2 - selectedPlacement.top - 34;

    final minX = viewport.width - worldSize.width;
    final minY = viewport.height - worldSize.height;

    final clampedX = targetX.clamp(minX, 0.0);
    final clampedY = targetY.clamp(minY, 0.0);

    return Offset(clampedX, clampedY);
  }
}

class _MarkerPlacement {
  const _MarkerPlacement({
    required this.lot,
    required this.index,
    required this.left,
    required this.top,
  });

  final ParkingLot lot;
  final int index;
  final double left;
  final double top;
}

class _MapBackdrop extends StatelessWidget {
  const _MapBackdrop({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FBFF),
            Color(0xFFEFF4FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -70,
            top: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2F6BFF).withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: -60,
            top: 120,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF19C2D1).withOpacity(0.06),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _MapCanvasPainter extends CustomPainter {
  _MapCanvasPainter({
    required this.palette,
    required this.isDetailView,
  });

  final DashboardPalette palette;
  final bool isDetailView;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.44)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    _drawDistrictBlocks(canvas, size);
    _drawRiver(canvas, size);
    _drawRoads(canvas, size);
    _drawParks(canvas, size);
    _drawLandmarks(canvas, size);
  }

  void _drawDistrictBlocks(Canvas canvas, Size size) {
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFF2F7FD).withOpacity(0.75);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFD7E3F3).withOpacity(0.95);

    final blocks = [
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.04, size.height * 0.10, size.width * 0.28, size.height * 0.28),
        const Radius.circular(26),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.34, size.height * 0.08, size.width * 0.23, size.height * 0.22),
        const Radius.circular(24),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.61, size.height * 0.10, size.width * 0.32, size.height * 0.24),
        const Radius.circular(28),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.10, size.height * 0.63, size.width * 0.22, size.height * 0.20),
        const Radius.circular(22),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.36, size.height * 0.62, size.width * 0.26, size.height * 0.18),
        const Radius.circular(22),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, size.height * 0.63, size.width * 0.22, size.height * 0.18),
        const Radius.circular(22),
      ),
    ];

    for (final block in blocks) {
      canvas.drawRRect(block, fill);
      canvas.drawRRect(block, stroke);
    }
  }

  void _drawRiver(Canvas canvas, Size size) {
    final riverPaint = Paint()
      ..color = const Color(0xFF74D8FF).withOpacity(0.98)
      ..strokeWidth = isDetailView ? 30 : 26
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverEdge = Paint()
      ..color = const Color(0xFFE6FAFF).withOpacity(0.98)
      ..strokeWidth = isDetailView ? 40 : 34
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.02, size.height * 0.58)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.44,
        size.width * 0.28,
        size.height * 0.65,
        size.width * 0.43,
        size.height * 0.52,
      )
      ..cubicTo(
        size.width * 0.54,
        size.height * 0.42,
        size.width * 0.66,
        size.height * 0.58,
        size.width * 0.78,
        size.height * 0.44,
      )
      ..cubicTo(
        size.width * 0.86,
        size.height * 0.34,
        size.width * 0.95,
        size.height * 0.39,
        size.width * 1.00,
        size.height * 0.31,
      );

    canvas.drawPath(path, riverEdge);
    canvas.drawPath(path, riverPaint);
  }

  void _drawRoads(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF8EA2C1).withOpacity(0.92)
      ..strokeWidth = isDetailView ? 15 : 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadHighlight = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final bridges = [
      (Offset(size.width * 0.12, size.height * 0.27), Offset(size.width * 0.48, size.height * 0.21)),
      (Offset(size.width * 0.50, size.height * 0.22), Offset(size.width * 0.77, size.height * 0.29)),
      (Offset(size.width * 0.76, size.height * 0.38), Offset(size.width * 0.96, size.height * 0.33)),
    ];

    for (final bridge in bridges) {
      canvas.drawLine(bridge.$1, bridge.$2, roadPaint);
      canvas.drawLine(bridge.$1, bridge.$2, roadHighlight);
    }

    final majorRoads = [
      Path()
        ..moveTo(size.width * 0.04, size.height * 0.74)
        ..lineTo(size.width * 0.96, size.height * 0.74),
      Path()
        ..moveTo(size.width * 0.39, size.height * 0.06)
        ..lineTo(size.width * 0.39, size.height * 0.94),
      Path()
        ..moveTo(size.width * 0.68, size.height * 0.14)
        ..lineTo(size.width * 0.68, size.height * 0.88),
    ];

    for (final road in majorRoads) {
      canvas.drawPath(road, roadPaint);
      canvas.drawPath(road, roadHighlight);
    }
  }

  void _drawParks(Canvas canvas, Size size) {
    final parkFill = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFDFF3D8).withOpacity(0.88);
    final parkStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = const Color(0xFFC7E4BC).withOpacity(0.95);

    final parks = [
      Path()
        ..moveTo(size.width * 0.02, size.height * 0.03)
        ..lineTo(size.width * 0.30, size.height * 0.03)
        ..lineTo(size.width * 0.34, size.height * 0.18)
        ..lineTo(size.width * 0.22, size.height * 0.23)
        ..lineTo(size.width * 0.05, size.height * 0.19)
        ..close(),
      Path()
        ..moveTo(size.width * 0.57, size.height * 0.05)
        ..lineTo(size.width * 0.95, size.height * 0.05)
        ..lineTo(size.width * 0.95, size.height * 0.22)
        ..lineTo(size.width * 0.79, size.height * 0.28)
        ..lineTo(size.width * 0.59, size.height * 0.20)
        ..close(),
    ];

    for (final park in parks) {
      canvas.drawPath(park, parkFill);
      canvas.drawPath(park, parkStroke);
    }
  }

  void _drawLandmarks(Canvas canvas, Size size) {
    const labelStyle = TextStyle(
      color: Color(0xFF3A4B6A),
      fontSize: 18,
      fontWeight: FontWeight.w800,
    );
    const smallStyle = TextStyle(
      color: Color(0xFF58708E),
      fontSize: 13,
      fontWeight: FontWeight.w700,
    );

    _paintLabel(canvas, '\uB69D\uC12C', size.width * 0.15, size.height * 0.54, labelStyle);
    _paintLabel(canvas, '\uB69D\uC12C\uD55C\uAC15\uACF5\uC6D0', size.width * 0.11, size.height * 0.61, smallStyle);
    _paintLabel(canvas, '\uC790\uC591\uB3D9', size.width * 0.69, size.height * 0.58, smallStyle);
    _paintLabel(canvas, '\uC131\uC218\uB300\uAD50', size.width * 0.28, size.height * 0.25, smallStyle, rotate: -0.12);
    _paintLabel(canvas, '\uC601\uB3D9\uB300\uAD50', size.width * 0.56, size.height * 0.26, smallStyle, rotate: 0.08);
    _paintLabel(canvas, '\uCCAD\uB2F4\uB300\uAD50', size.width * 0.80, size.height * 0.32, smallStyle, rotate: -0.06);
    _paintLabel(canvas, '\uD55C\uAC15', size.width * 0.49, size.height * 0.47, smallStyle, rotate: -0.08);
    _paintLabel(canvas, '\uC7A0\uC2E4\uB300\uAD50', size.width * 0.88, size.height * 0.47, smallStyle, rotate: 0.1);
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    double x,
    double y,
    TextStyle style, {
    double rotate = 0,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotate);
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) {
    return oldDelegate.palette != palette || oldDelegate.isDetailView != isDetailView;
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.lot,
    required this.index,
    required this.isSelected,
    required this.left,
    required this.top,
    required this.onTap,
  });

  final ParkingLot lot;
  final int index;
  final bool isSelected;
  final double left;
  final double top;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = isSelected ? '\uC120\uD0DD' : 'P${index + 1}';

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: isSelected ? 1.12 : 1.0,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.97),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? lot.progressColor : const Color(0xFFCBD7E8),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: lot.progressColor.withOpacity(isSelected ? 0.28 : 0.12),
                      blurRadius: 18,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF183153),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: lot.progressColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: lot.progressColor.withOpacity(0.38),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedLotInfo extends StatelessWidget {
  const _SelectedLotInfo({
    required this.selectedIndex,
    required this.selectedLot,
    required this.palette,
  });

  final int selectedIndex;
  final ParkingLot? selectedLot;
  final DashboardPalette palette;

  @override
  Widget build(BuildContext context) {
    final lot = selectedLot;
    final palette = this.palette;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      child: lot == null
          ? _InfoCard(
              key: const ValueKey('empty'),
              title: '\uC8FC\uCC28\uC7A5\uC744 \uC120\uD0DD\uD558\uC138\uC694',
              subtitle: '\uAC80\uC0C9\uC5B4\uB97C \uC9C0\uC6B0\uAC70\uB098 \uC67C\uCABD \uCE74\uB4DC\uC5D0\uC11C \uC8FC\uCC28\uC7A5\uC744 \uC120\uD0DD\uD558\uC138\uC694.',
              palette: palette,
            )
          : _InfoCard(
              key: ValueKey(lot.name),
              title: lot.name,
              subtitle:
                  '\uB0A8\uC740 ${lot.available}\uBA74 \u00B7 ${lot.latitude.toStringAsFixed(5)}, ${lot.longitude.toStringAsFixed(5)}',
              palette: palette,
              trailing: lot.statusLabel,
              color: lot.progressColor,
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.palette,
    this.trailing,
    this.color,
  });

  final String title;
  final String subtitle;
  final DashboardPalette palette;
  final String? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1D314F).withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.10),
            blurRadius: 14,
            spreadRadius: 0.2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color ?? palette.accentBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF1B2430),
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF7A8799),
                      ),
                ),
              ],
            ),
          ),
          if (trailing != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (color ?? palette.accentBlue).withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                trailing!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF1B2430),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
