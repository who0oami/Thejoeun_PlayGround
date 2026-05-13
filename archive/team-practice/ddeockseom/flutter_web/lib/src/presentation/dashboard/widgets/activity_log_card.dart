import 'package:flutter/material.dart';

import '../../../core/theme/dashboard_palette.dart';
import '../../../domain/models/activity_log.dart';

class ActivityLogCard extends StatelessWidget {
  const ActivityLogCard({
    super.key,
    required this.logs,
    required this.lastUpdatedLabel,
  });

  final List<ActivityLog> logs;
  final String lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildLogTable(context),
            const SizedBox(height: 14),
            Text(
              lastUpdatedLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.mutedText,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final palette = context.palette;

    return Row(
      children: [
        Text(
          '\uC2E4\uC2DC\uAC04 \uD1B5\uD569 \uC774\uB825',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: palette.accentGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: palette.accentGreen.withOpacity(0.35),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Live Update',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: palette.accentGreen,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _buildLogTable(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: palette.panelBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        children: [
          const _ActivityLogHeader(),
          Divider(height: 20, color: palette.cardBorder),
          ...logs.map((activityLog) => _ActivityLogRow(log: activityLog)),
        ],
      ),
    );
  }
}

class _ActivityLogHeader extends StatelessWidget {
  const _ActivityLogHeader();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final headerStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: palette.mutedText,
          fontWeight: FontWeight.w700,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('\uBC88\uD638', style: headerStyle)),
          Expanded(child: Text('\uC720\uD615', style: headerStyle)),
          Expanded(child: Text('\uC2DC\uAC04', style: headerStyle)),
          Expanded(
            child: Text(
              '\uC0C1\uD0DC',
              style: headerStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityLogRow extends StatelessWidget {
  const _ActivityLogRow({required this.log});

  final ActivityLog log;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final statusColor =
        log.status == '\uC644\uB8CC' ? palette.accentBlue : const Color(0xFFF59E0B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              log.vehicleNumber,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Expanded(child: Text(log.type)),
          Expanded(child: Text(log.time)),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  log.status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
