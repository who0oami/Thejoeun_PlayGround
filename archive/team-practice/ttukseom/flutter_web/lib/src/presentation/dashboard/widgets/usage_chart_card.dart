import 'package:flutter/material.dart';

import '../../../core/theme/dashboard_palette.dart';
import '../../../domain/models/weekday_stat.dart';

class UsageChartCard extends StatelessWidget {
  const UsageChartCard({super.key, required this.weekdayStats});

  final List<WeekdayStat> weekdayStats;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final highestUsage = weekdayStats
        .map((weekdayStat) => weekdayStat.value)
        .fold<double>(
          0,
          (previous, value) => value > previous ? value : previous,
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\uC8FC\uAC04 \uC774\uC6A9 \uD604\uD669',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '\uD68C\uC6D4\uBCC4 \uC0AC\uC6A9 \uD328\uD134\uC744 \uD55C\uB208\uC5D0 \uD655\uC778\uD558\uC138\uC694.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.mutedText,
                  ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              height: 230,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weekdayStats
                    .map(
                      (weekdayStat) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _UsageBar(
                            weekdayStat: weekdayStat,
                            highestUsage: highestUsage,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  const TextSpan(text: '\uC8FC\uAC04 7\uC77C \uD3C9\uADE0 \uC774\uC6A9\uB7C9 '),
                  TextSpan(
                    text: '12.4% \uC99D\uAC00',
                    style: TextStyle(
                      color: palette.accentCyan,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  const _UsageBar({required this.weekdayStat, required this.highestUsage});

  final WeekdayStat weekdayStat;
  final double highestUsage;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final usageRatio =
        highestUsage == 0 ? 0.0 : weekdayStat.value / highestUsage;
    final isPeakDay = weekdayStat.value == highestUsage;
    final barColors = isPeakDay
        ? [palette.accentCyan, palette.accentBlue]
        : [palette.progressTrack, palette.accentBlue.withOpacity(0.65)];

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isPeakDay)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'MAX',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: palette.accentCyan,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          )
        else
          const SizedBox(height: 22),
        AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          height: 150 * usageRatio.clamp(0.0, 1.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: barColors,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: isPeakDay ? palette.glowColor : Colors.transparent,
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          weekdayStat.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isPeakDay ? palette.accentCyan : palette.secondaryText,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
