import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/streak_day.dart';
import 'streak_dot_grid.dart';
import 'streak_summary_bar.dart';

class StreakClockScreen extends StatefulWidget {
  const StreakClockScreen({
    super.key,
    required this.habitName,
    required this.streakData,
    required this.targetDays,
    this.accentColor,
    this.glowIntensity,
    this.semanticLabel,
  });

  final String habitName;
  final List<StreakDay> streakData;
  final int targetDays;
  final Color? accentColor;
  final double? glowIntensity;
  final String? semanticLabel;

  @override
  State<StreakClockScreen> createState() => _StreakClockScreenState();
}

class _StreakClockScreenState extends State<StreakClockScreen> {
  @override
  Widget build(BuildContext context) {
    final completedCount = widget.streakData.where((d) => d.isCompleted).length;
    final double percentage = widget.targetDays > 0 
        ? ((completedCount / widget.targetDays) * 100).clamp(0.0, 100.0)
        : 0.0;
    
    // Calculate days left relative to target
    final daysLeft = math.max(0, widget.targetDays - completedCount);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreakDotGrid(
          streakData: widget.streakData,
          targetDays: widget.targetDays,
          accentColor: widget.accentColor,
          glowIntensity: widget.glowIntensity,
          semanticLabel: widget.semanticLabel,
        ),
        const SizedBox(height: 16.0),
        StreakSummaryBar(
          habitName: widget.habitName,
          daysLeft: daysLeft,
          percentage: percentage,
        ),
      ],
    );
  }
}
