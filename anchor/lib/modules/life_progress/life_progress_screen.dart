import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../models/progress_model.dart';
import '../../providers/progress_provider.dart';

/// Life Progress Board — visual dashboard of progress across life dimensions.
class LifeProgressScreen extends ConsumerWidget {
  const LifeProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyProgressAsync = ref.watch(weeklyProgressProvider);
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Text(
                    isMobile ? 'Progress' : 'Life Progress',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDimensionDialog(context, ref),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(isMobile ? 'Add' : 'Add Dimension'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Track what matters. See the truth about your direction.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),

              // ── Responsive layout ──
              if (isMobile)
                _MobileLayout(weeklyProgressAsync: weeklyProgressAsync)
              else
                _DesktopLayout(weeklyProgressAsync: weeklyProgressAsync),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddDimensionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _AddDimensionDialog(),
    );
  }
}

// ── Mobile layout: single column ──
class _MobileLayout extends StatelessWidget {
  final AsyncValue<List<WeeklyProgress>> weeklyProgressAsync;

  const _MobileLayout({required this.weeklyProgressAsync});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        weeklyProgressAsync.when(
          data: (progresses) {
            if (progresses.isEmpty) return const _EmptyState();
            return Column(
              children: progresses
                  .map((p) => _ProgressDimensionCard(progress: p))
                  .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _s) =>
              const Center(child: Text('Error loading progress')),
        ),
        const SizedBox(height: 16),
        _WeeklyComparisonCard(),
        const SizedBox(height: 12),
        _StreakCard(),
        const SizedBox(height: 12),
        _ReflectionCard(),
      ],
    );
  }
}

// ── Desktop layout: two columns ──
class _DesktopLayout extends StatelessWidget {
  final AsyncValue<List<WeeklyProgress>> weeklyProgressAsync;

  const _DesktopLayout({required this.weeklyProgressAsync});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: progress bars
        Expanded(
          flex: 3,
          child: weeklyProgressAsync.when(
            data: (progresses) {
              if (progresses.isEmpty) return const _EmptyState();
              return Column(
                children: progresses
                    .map((p) => _ProgressDimensionCard(progress: p))
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) =>
                const Center(child: Text('Error loading progress')),
          ),
        ),
        const SizedBox(width: 20),
        // Right: side panel
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _WeeklyComparisonCard(),
              const SizedBox(height: 16),
              _StreakCard(),
              const SizedBox(height: 16),
              _ReflectionCard(),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────

class _ProgressDimensionCard extends StatelessWidget {
  final WeeklyProgress progress;

  const _ProgressDimensionCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final color = Color(
      int.parse(progress.colorHex.replaceFirst('#', '0xFF')),
    );
    final percent = progress.progressPercent.clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                progress.dimensionName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              _TrendIndicator(trend: progress.trend),
              const SizedBox(width: 10),
              Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.progressTrack,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progress.currentWeekTotal.toStringAsFixed(1)} / ${progress.weeklyTarget.toStringAsFixed(1)} ${progress.unit}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                'Last week: ${progress.lastWeekTotal.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  final ProgressTrend trend;

  const _TrendIndicator({required this.trend});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (trend) {
      case ProgressTrend.up:
        icon = Icons.trending_up;
        color = AppColors.productive;
      case ProgressTrend.down:
        icon = Icons.trending_down;
        color = AppColors.distracted;
      case ProgressTrend.neutral:
        icon = Icons.trending_flat;
        color = AppColors.textMuted;
    }
    return Icon(icon, size: 16, color: color);
  }
}

class _WeeklyComparisonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ProgressCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WEEKLY COMPARISON',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Text(
                          days[value.toInt() % 7],
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 6),
                  _makeBarGroup(1, 8),
                  _makeBarGroup(2, 4),
                  _makeBarGroup(3, 9),
                  _makeBarGroup(4, 5),
                  _makeBarGroup(5, 3),
                  _makeBarGroup(6, 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 14,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ProgressCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STREAKS',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          _StreakRow(label: 'Study Hours', streak: 5, target: 7),
          const SizedBox(height: 10),
          _StreakRow(label: 'Exercise', streak: 3, target: 5),
          const SizedBox(height: 10),
          _StreakRow(label: 'No Late Gaming', streak: 12, target: 14),
        ],
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  final String label;
  final int streak;
  final int target;

  const _StreakRow({
    required this.label,
    required this.streak,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (streak / target).clamp(0.0, 1.0);
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.progressTrack,
              valueColor: AlwaysStoppedAnimation(
                percent >= 1.0 ? AppColors.productive : AppColors.neutral,
              ),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$streak',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ProgressCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WEEKLY REFLECTION',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'This week you studied 8 hours — less than last week\'s 11. Your strongest pattern was consistency on weekdays. The slip happened on Saturday. Pay attention to weekend discipline.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.trending_up,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'No dimensions yet',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add dimensions to track what matters to you.\nStudy hours, exercise, coding practice — you decide.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final Widget child;

  const _ProgressCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AddDimensionDialog extends StatelessWidget {
  const _AddDimensionDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Add Progress Dimension',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(hintText: 'Name (e.g., Study Hours)'),
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(hintText: 'Weekly Target'),
            keyboardType: TextInputType.number,
            style: const TextStyle(fontFamily: 'Inter'),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration:
                const InputDecoration(hintText: 'Unit (hours, sessions, etc.)'),
            style: const TextStyle(fontFamily: 'Inter'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
