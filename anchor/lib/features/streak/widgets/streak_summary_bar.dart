import 'package:flutter/material.dart';
import '../../../core/design/anchor_theme.dart';

class StreakSummaryBar extends StatelessWidget {
  final String habitName;
  final int daysLeft;
  final double percentage;

  const StreakSummaryBar({
    super.key,
    required this.habitName,
    required this.daysLeft,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            habitName,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4.0),
          Row(
            children: [
              Text(
                "${daysLeft}d left",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                " · ",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AnchorTheme.textMuted,
                ),
              ),
              Text(
                "${percentage.toInt()}%",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
