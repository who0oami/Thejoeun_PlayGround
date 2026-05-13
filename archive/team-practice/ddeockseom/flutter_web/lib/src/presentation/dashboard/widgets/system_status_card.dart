import 'package:flutter/material.dart';

import '../../../core/theme/dashboard_palette.dart';
import '../../../domain/models/system_status.dart';

class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({
    super.key,
    required this.statuses,
  });

  final List<SystemStatus> statuses;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\uC2DC\uC2A4\uD15C \uC0C1\uD0DC',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '\uC13C\uC11C, CCTV, \uB124\uD2B8\uC6CC\uD06C \uC5F0\uACB0 \uC0C1\uD0DC\uB97C \uD55C\uB208\uC5D0 \uD655\uC778\uD558\uC138\uC694.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.mutedText,
                  ),
            ),
            const SizedBox(height: 20),
            ...statuses.map((status) => _SystemStatusTile(status: status)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('\uC2DC\uC2A4\uD15C \uC0C1\uD0DC \uC790\uC138\uD788 \uBCF4\uAE30'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemStatusTile extends StatelessWidget {
  const _SystemStatusTile({required this.status});

  final SystemStatus status;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.panelBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  status.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.mutedText,
                      ),
                ),
              ],
            ),
          ),
          Text(
            status.isHealthy ? '\uC815\uC0C1' : '\uC5D0\uB7EC',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: status.isHealthy ? palette.accentGreen : palette.accentRed,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
