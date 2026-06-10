import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design/anchor_theme.dart';
import '../../core/theme/slice_spacing.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../providers/screen_time_provider.dart';
import '../../providers/settings_provider.dart';

/// Screen Mirror — matches Stitch design "Screen Mirror"
/// Tracks and displays screen time using Anchor High-Performance dark tonal design.
class ScreenMirrorScreen extends ConsumerStatefulWidget {
  const ScreenMirrorScreen({super.key});

  @override
  ConsumerState<ScreenMirrorScreen> createState() => _ScreenMirrorScreenState();
}

class _ScreenMirrorScreenState extends ConsumerState<ScreenMirrorScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      ref.invalidate(todayScreenTimeProvider);
      ref.invalidate(screenTimeByCategoryProvider);
      ref.invalidate(weeklyScreenTimeProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayMinutesAsync = ref.watch(todayScreenTimeProvider);
    final categoryMinutesAsync = ref.watch(screenTimeByCategoryProvider);
    final weeklyAsync = ref.watch(weeklyScreenTimeProvider);
    final settingsAsync = ref.watch(settingsProvider);

    final todayMinutes = todayMinutesAsync.valueOrNull ?? 0;
    final categoryMinutes = categoryMinutesAsync.valueOrNull ?? {};
    final weeklyMinutes = weeklyAsync.valueOrNull ?? {};
    final limitMinutes = settingsAsync.valueOrNull?.distractionLimitMinutes ?? 120;

    final productiveMinutes = categoryMinutes['productive'] ?? 0;
    final distractedMinutes = categoryMinutes['distracted'] ?? 0;
    final neutralMinutes = categoryMinutes['neutral'] ?? 0;

    final totalHours = todayMinutes ~/ 60;
    final totalMins = todayMinutes % 60;

    final health = _calculateHealth(productiveMinutes, todayMinutes);

    return Scaffold(
      backgroundColor: AnchorTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Text(
                'Screen Mirror',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AnchorTheme.textPrimary,
                ),
              ).animate().fade().slideY(begin: -0.2),
              const SizedBox(height: 6),
              Text(
                'Real-time awareness of where your time goes.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AnchorTheme.textSecondary,
                ),
              ).animate(delay: 100.ms).fade(),
              const SizedBox(height: 24),

              // ── Total time card ──
              _TotalTimeCard(
                hours: totalHours,
                minutes: totalMins,
                health: health,
              ).animate(delay: 200.ms).fade().slideY(begin: 0.1),
              const SizedBox(height: 16),

              // ── Health indicator ──
              _HealthIndicator(health: health).animate(delay: 300.ms).fade().slideY(begin: 0.1),
              const SizedBox(height: 16),

              // ── Limit card ──
              _LimitCard(
                distractedMinutes: distractedMinutes,
                limitMinutes: limitMinutes,
              ).animate(delay: 400.ms).fade().slideY(begin: 0.1),
              const SizedBox(height: 16),

              // ── Category breakdown ──
              _CategoryBreakdown(
                productive: productiveMinutes,
                neutral: neutralMinutes,
                distracted: distractedMinutes,
                limit: limitMinutes,
              ).animate(delay: 500.ms).fade().slideY(begin: 0.1),
              const SizedBox(height: 16),

              // ── Weekly trend ──
              _WeeklyTrendCard(weeklyData: weeklyMinutes).animate(delay: 600.ms).fade().slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }

  _HealthStatus _calculateHealth(int productive, int total) {
    if (total == 0) return _HealthStatus.noData;
    final ratio = productive / total;
    if (ratio >= 0.5) return _HealthStatus.good;
    if (ratio >= 0.3) return _HealthStatus.fair;
    return _HealthStatus.poor;
  }
}

// ──────────────────────────────────────────────────────────────
// Health Status Enum
// ──────────────────────────────────────────────────────────────

enum _HealthStatus { good, fair, poor, noData }

// ──────────────────────────────────────────────────────────────
// Total Time Card
// ──────────────────────────────────────────────────────────────

class _TotalTimeCard extends StatelessWidget {
  final int hours;
  final int minutes;
  final _HealthStatus health;

  const _TotalTimeCard({
    required this.hours,
    required this.minutes,
    required this.health,
  });

  @override
  Widget build(BuildContext context) {
    final Color healthColor = _healthColor(health);

    return CleanCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeader(label: "Today's Total"),
              _HealthDot(color: healthColor),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$hours',
                style: GoogleFonts.inter(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                  color: AnchorTheme.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'h',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AnchorTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$minutes',
                style: GoogleFonts.inter(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                  color: AnchorTheme.textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'm',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AnchorTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: healthColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: healthColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              _healthMessage(health),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: healthColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _healthColor(_HealthStatus health) {
    switch (health) {
      case _HealthStatus.good:
        return AnchorTheme.statusGreen;
      case _HealthStatus.fair:
        return AnchorTheme.statusOrange;
      case _HealthStatus.poor:
        return AnchorTheme.statusRed;
      case _HealthStatus.noData:
        return AnchorTheme.textMuted;
    }
  }

  String _healthMessage(_HealthStatus health) {
    switch (health) {
      case _HealthStatus.noData:
        return 'Start tracking to see your screen time';
      case _HealthStatus.good:
        return 'Productive ratio is healthy';
      case _HealthStatus.fair:
        return 'Borderline — watch your focus';
      case _HealthStatus.poor:
        return 'Significantly distracted today';
    }
  }
}

// ──────────────────────────────────────────────────────────────
// Health Dot (status indicator — no glow)
// ──────────────────────────────────────────────────────────────

class _HealthDot extends StatelessWidget {
  final Color color;

  const _HealthDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Category Breakdown
// ──────────────────────────────────────────────────────────────

class _CategoryBreakdown extends StatelessWidget {
  final int productive;
  final int neutral;
  final int distracted;
  final int limit;

  const _CategoryBreakdown({
    required this.productive,
    required this.neutral,
    required this.distracted,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final total = productive + neutral + distracted;
    if (total == 0) {
      return CleanCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monitor_outlined,
                  size: 40,
                  color: AnchorTheme.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  'No activity tracked yet today.\nApp categorization will appear here.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AnchorTheme.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CleanCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(label: 'Category Breakdown'),
          const SizedBox(height: 24),
          _CategoryBar(
            label: 'Productive',
            minutes: productive,
            total: total,
            barColor: AnchorTheme.statusGreen,
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(height: 20),
          _CategoryBar(
            label: 'Neutral',
            minutes: neutral,
            total: total,
            barColor: AnchorTheme.statusOrange,
            icon: Icons.remove_rounded,
          ),
          const SizedBox(height: 20),
          _CategoryBar(
            label: 'Distracted',
            minutes: distracted,
            total: total,
            barColor: AnchorTheme.statusRed,
            icon: Icons.warning_amber_rounded,
            limit: limit,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Category Bar (solid color, no gradient/glow)
// ──────────────────────────────────────────────────────────────

class _CategoryBar extends StatelessWidget {
  final String label;
  final int minutes;
  final int total;
  final Color barColor;
  final IconData icon;
  final int? limit;

  const _CategoryBar({
    required this.label,
    required this.minutes,
    required this.total,
    required this.barColor,
    required this.icon,
    this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? minutes / total : 0.0;
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';
    final overLimit = limit != null && minutes > limit!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: barColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: barColor),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AnchorTheme.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              timeStr,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: overLimit ? AnchorTheme.statusRed : AnchorTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 8,
            color: AnchorTheme.cardInset,
            child: Row(
              children: [
                Expanded(
                  flex: (fraction * 1000).toInt().clamp(0, 1000),
                  child: Container(color: barColor),
                ),
                Expanded(
                  flex: ((1 - fraction) * 1000).toInt().clamp(0, 1000),
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        if (limit != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Limit: ${limit! ~/ 60}h ${limit! % 60}m',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AnchorTheme.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Health Indicator (solid color circle, no glow)
// ──────────────────────────────────────────────────────────────

class _HealthIndicator extends StatelessWidget {
  final _HealthStatus health;

  const _HealthIndicator({required this.health});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    IconData icon;

    switch (health) {
      case _HealthStatus.good:
        label = 'On Track';
        color = AnchorTheme.statusGreen;
        icon = Icons.check_circle_rounded;
      case _HealthStatus.fair:
        label = 'Borderline';
        color = AnchorTheme.statusOrange;
        icon = Icons.warning_rounded;
      case _HealthStatus.poor:
        label = 'Needs Attention';
        color = AnchorTheme.statusRed;
        icon = Icons.error_rounded;
      case _HealthStatus.noData:
        label = 'No Data';
        color = AnchorTheme.textMuted;
        icon = Icons.help_outline_rounded;
    }

    return CleanCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Health Status',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AnchorTheme.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Limit Card (solid color progress bar)
// ──────────────────────────────────────────────────────────────

class _LimitCard extends StatelessWidget {
  final int distractedMinutes;
  final int limitMinutes;

  const _LimitCard({
    required this.distractedMinutes,
    required this.limitMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = limitMinutes - distractedMinutes;
    final overLimit = remaining < 0;
    final progress = (distractedMinutes / limitMinutes).clamp(0.0, 1.0);
    final barColor = overLimit ? AnchorTheme.statusRed : AnchorTheme.accent;

    return CleanCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            label: 'Distraction Limit',
            color: overLimit ? AnchorTheme.statusRed : AnchorTheme.accent,
          ),
          const SizedBox(height: 20),
          Text(
            overLimit
                ? 'Over limit'
                : '${remaining ~/ 60}h ${remaining % 60}m remaining',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: overLimit ? AnchorTheme.statusRed : AnchorTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              color: AnchorTheme.cardInset,
              child: Row(
                children: [
                  Expanded(
                    flex: (progress * 1000).toInt().clamp(0, 1000),
                    child: Container(color: barColor),
                  ),
                  Expanded(
                    flex: ((1 - progress) * 1000).toInt().clamp(0, 1000),
                    child: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Daily limit: ${limitMinutes ~/ 60}h ${limitMinutes % 60}m',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AnchorTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Weekly Trend Card (solid color bars, no gradient/glow)
// ──────────────────────────────────────────────────────────────

class _WeeklyTrendCard extends StatelessWidget {
  final Map<DateTime, int> weeklyData;

  const _WeeklyTrendCard({required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final days = <Map<String, dynamic>>[];
    int maxMinutes = 1;

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayKey = DateTime(day.year, day.month, day.day);
      final minutes = weeklyData[dayKey] ?? 0;
      if (minutes > maxMinutes) maxMinutes = minutes;

      final isToday = day.year == now.year &&
          day.month == now.month &&
          day.day == now.day;

      const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      days.add({
        'label': dayLabels[i],
        'minutes': minutes,
        'isToday': isToday,
      });
    }

    return CleanCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(label: 'Weekly Trend'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.map((d) {
              final height = (d['minutes'] as int) / maxMinutes;
              return _DayBar(
                day: d['label'] as String,
                height: height.clamp(0.05, 1.0),
                minutes: d['minutes'] as int,
                isToday: d['isToday'] as bool,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            weeklyData.isEmpty
                ? 'No weekly data yet. Use the app to track screen time.'
                : 'Data synced from device usage stats',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AnchorTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Day Bar (weekly chart bar — solid color, no glow)
// ──────────────────────────────────────────────────────────────

class _DayBar extends StatelessWidget {
  final String day;
  final double height;
  final int minutes;
  final bool isToday;

  const _DayBar({
    required this.day,
    required this.height,
    required this.minutes,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final timeStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Tooltip(
      message: timeStr,
      child: Column(
        children: [
          Container(
            width: 24,
            height: 80 * height,
            decoration: BoxDecoration(
              color: isToday ? AnchorTheme.accent : AnchorTheme.cardBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday ? AnchorTheme.accent : AnchorTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
