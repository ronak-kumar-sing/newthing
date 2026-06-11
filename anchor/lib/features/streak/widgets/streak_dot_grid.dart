import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/design/anchor_theme.dart';
import '../../../core/theme/slice_spacing.dart';
import '../models/streak_day.dart';

class StreakDotGrid extends StatelessWidget {
  final List<StreakDay> streakData;
  final int targetDays;
  final Color? accentColor;
  final double? glowIntensity;
  final String? semanticLabel;

  const StreakDotGrid({
    super.key,
    required this.streakData,
    required this.targetDays,
    this.accentColor,
    this.glowIntensity,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final activeAccent = accentColor ?? Theme.of(context).colorScheme.primary;
    final double intensity = glowIntensity ?? 1.0;

    if (streakData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Align data into week rows.
    final sortedData = List<StreakDay>.from(streakData)
      ..sort((a, b) => a.date.compareTo(b.date));

    final firstDay = sortedData.first.date;
    final firstMonday = firstDay.subtract(Duration(days: firstDay.weekday - 1));
    
    final lastDay = sortedData.last.date;
    final lastSunday = lastDay.add(Duration(days: 7 - lastDay.weekday));

    final totalDays = lastSunday.difference(firstMonday).inDays + 1;
    final List<StreakDay?> gridDays = List.filled(totalDays, null);

    final dataMap = {
      for (var day in sortedData)
        DateTime(day.date.year, day.date.month, day.date.day): day
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < totalDays; i++) {
      final currentQueryDate = firstMonday.add(Duration(days: i));
      final queryDateKey = DateTime(currentQueryDate.year, currentQueryDate.month, currentQueryDate.day);
      gridDays[i] = dataMap[queryDateKey] ?? StreakDay(date: currentQueryDate, isCompleted: false);
    }

    final int rows = (totalDays / 7).ceil();

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double spacing = SliceSpacing.xs; // 4.0
          final double maxWidth = constraints.maxWidth;
          final double dotSize = (maxWidth - (spacing * 6)) / 7;

          return Semantics(
            label: semanticLabel ?? "Streak Progress Grid",
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
                      return SizedBox(
                        width: dotSize,
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AnchorTheme.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                  ),
                  itemCount: totalDays,
                  itemBuilder: (context, index) {
                    final day = gridDays[index]!;
                    final isToday = DateTime(day.date.year, day.date.month, day.date.day) == today;
                    
                    final col = index % 7;
                    final row = index ~/ 7;
                    final centerCol = 3;
                    final centerRow = rows / 2;
                    final distance = math.sqrt(math.pow(col - centerCol, 2) + math.pow(row - centerRow, 2));
                    final delay = Duration(milliseconds: (distance * 30).toInt());

                    Widget dot = _buildDot(context, day, isToday, activeAccent, intensity, dotSize);

                    dot = dot.animate(delay: delay)
                        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
                        .scale(
                          begin: const Offset(0.3, 0.3),
                          end: const Offset(1.0, 1.0),
                          duration: 300.ms,
                          curve: Curves.easeOutBack,
                        );

                    if (isToday) {
                      dot = dot.animate(
                        onPlay: (controller) => controller.repeat(reverse: true),
                      ).scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.15, 1.15),
                        duration: 1000.ms,
                        curve: Curves.easeInOut,
                      );
                    }

                    final formattedDate = "${day.date.year}-${day.date.month}-${day.date.day}";
                    final statusText = day.isCompleted ? "completed" : "incomplete";
                    return Semantics(
                      label: "$formattedDate: $statusText",
                      focused: isToday,
                      child: Center(
                        child: dot,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDot(BuildContext context, StreakDay day, bool isToday, Color activeAccent, double intensity, double dotSize) {
    if (day.isCompleted) {
      final double fillOpacity = day.intensity ?? 1.0;
      return Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: activeAccent.withOpacity(fillOpacity),
          borderRadius: BorderRadius.circular(4.0),
          boxShadow: [
            BoxShadow(
              color: activeAccent.withOpacity(0.4 * intensity),
              blurRadius: 6.0 * intensity,
              spreadRadius: 1.0 * intensity,
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
            width: 1.0,
          ),
        ),
      );
    }
  }
}
