import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/design/anchor_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/anchor_background.dart';
import '../../core/router/app_router.dart';
import '../../data/local/database.dart';
import '../../models/progress_model.dart';
import '../../models/life_progress_point.dart';
import '../../providers/database_provider.dart';
import '../../providers/progress_provider.dart';
import '../../core/widgets/segmented_progress_bar.dart';
import 'widgets/life_trend_chart.dart';
import 'widgets/log_today_sheet.dart';
import 'widgets/workout_log_sheet.dart';

enum Period { week, month }

final selectedPeriodProvider = StateProvider<Period>((ref) => Period.week);

final progressDataProvider = FutureProvider<List<WeeklyProgress>>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  final dao = ref.watch(progressDaoProvider);
  final dimensions = await dao.getAllDimensions();
  final now = DateTime.now();

  if (period == Period.week) {
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));

    final results = <WeeklyProgress>[];
    for (final dim in dimensions) {
      final currentWeek = await dao.getWeeklyTotal(dim.id, weekStart);
      final lastWeek = await dao.getWeeklyTotal(dim.id, lastWeekStart);

      results.add(WeeklyProgress(
        dimensionId: dim.id,
        dimensionName: dim.name,
        currentWeekTotal: currentWeek,
        lastWeekTotal: lastWeek,
        weeklyTarget: dim.weeklyTarget,
        colorHex: dim.colorHex,
        unit: dim.unit,
      ));
    }
    return results;
  } else {
    final monthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
    final lastMonthEnd = monthStart.subtract(const Duration(seconds: 1));

    final results = <WeeklyProgress>[];
    for (final dim in dimensions) {
      final currentMonthValues = await dao.getValuesForRange(dim.id, monthStart, currentMonthEnd);
      final lastMonthValues = await dao.getValuesForRange(dim.id, lastMonthStart, lastMonthEnd);

      final currentTotal = currentMonthValues.fold<double>(0.0, (sum, v) => sum + v.value);
      final lastTotal = lastMonthValues.fold<double>(0.0, (sum, v) => sum + v.value);

      results.add(WeeklyProgress(
        dimensionId: dim.id,
        dimensionName: dim.name,
        currentWeekTotal: currentTotal,
        lastWeekTotal: lastTotal,
        weeklyTarget: dim.weeklyTarget * 4.0,
        colorHex: dim.colorHex,
        unit: dim.unit,
      ));
    }
    return results;
  }
});

final weeklyChartDataProvider = FutureProvider<Map<int, double>>((ref) async {
  final selectedId = ref.watch(selectedDimensionIdProvider);
  if (selectedId == null) return {};
  final dao = ref.watch(progressDaoProvider);
  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  final sunday = monday.add(const Duration(days: 7));

  final values = await dao.getValuesForRange(selectedId, monday, sunday);
  final result = <int, double>{};
  for (final v in values) {
    result[v.date.weekday] = v.value;
  }
  return result;
});

// AiInsightData and aiInsightProvider replaced by RealInsightData/realInsightProvider
// from progress_provider.dart

class LifeProgressScreen extends ConsumerWidget {
  const LifeProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: AnchorBackground(
        child: _buildBody(context, ref),
      ),
    ).animate().fadeIn(duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedPeriodProvider);
    final progressAsync = ref.watch(progressDataProvider);
    final selectedId = ref.watch(selectedDimensionIdProvider);

    // Auto-select first dimension if none selected
    final progresses = progressAsync.valueOrNull ?? [];
    if (progresses.isNotEmpty && selectedId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedDimensionIdProvider.notifier).state = progresses.first.dimensionId;
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Bar Header
          _buildTopBar(context, ref, period),
          const SizedBox(height: 24),

          // 2. Dimensions Section
          _buildDimensionsHeader(context, ref),
          const SizedBox(height: 12),

          progressAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return const _EmptyState().animate().fadeIn(duration: 300.ms);
              }
              return Column(
                children: List.generate(list.length, (index) {
                  final item = list[index];
                  final isSelected = item.dimensionId == selectedId;
                  return ScaleOnPress(
                    onTap: () {
                      ref.read(selectedDimensionIdProvider.notifier).state = item.dimensionId;
                      // Open log today sheet on tap
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        useRootNavigator: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => LogTodaySheet(progress: item),
                      );
                    },
                    child: _buildDimensionCard(item, isSelected)
                        .animate(delay: (index * 80).ms)
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.08, end: 0, duration: 300.ms),
                  );
                }),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: CircularProgressIndicator(color: Color(0xFFC6F52C)),
              ),
            ),
            error: (e, s) => const SizedBox(),
          ),
          const SizedBox(height: 24),

          // 3. Multi-line Performance Trend Chart
          if (progresses.isNotEmpty) ...[
            ref.watch(lifeTrendDataProvider).when(
              data: (points) => ScaleOnPress(
                child: LifeTrendChart(data: points)
                    .animate(delay: ((progresses.length) * 80).ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.08, end: 0, duration: 300.ms),
              ),
              loading: () => const SizedBox(
                height: 240,
                child: Center(child: CircularProgressIndicator(color: AnchorTheme.accent)),
              ),
              error: (e, s) => const SizedBox(),
            ),
            const SizedBox(height: 24),
          ],

          // 4. Weekly Detail Chart Card
          if (progresses.isNotEmpty)
            ScaleOnPress(
              child: _buildWeeklyChartCard(context, ref, progresses)
                  .animate(delay: ((progresses.length + 0.5) * 80).ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.08, end: 0, duration: 300.ms),
            ),
          const SizedBox(height: 24),

          // 5. Streaks Card (from DB)
          ref.watch(streakDataProvider).when(
            data: (streaks) => ScaleOnPress(
              child: _buildStreaksCardFromDB(streaks)
                  .animate(delay: ((progresses.length + 1) * 80).ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.08, end: 0, duration: 300.ms),
            ),
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
          ),
          const SizedBox(height: 24),

          // 6. Insights Section (real data)
          _buildRealInsightsSection(context, ref, progresses.length),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref, Period period) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Life Progress',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  _buildTogglePill(ref, 'Week', period == Period.week, Period.week),
                  _buildTogglePill(ref, 'Month', period == Period.month, Period.month),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.settings_outlined, size: 20, color: Colors.white.withOpacity(0.50)),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTogglePill(WidgetRef ref, String label, bool isActive, Period targetPeriod) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedPeriodProvider.notifier).state = targetPeriod;
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isActive
            ? Container(
                key: ValueKey('active_$label'),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFC6F52C),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              )
            : Container(
                key: ValueKey('inactive_$label'),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: Colors.transparent,
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.50),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDimensionsHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dimensions',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () => _showAddDimensionBottomSheet(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            '+ Add',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFC6F52C),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDimensionCard(WeeklyProgress progress, bool isSelected) {
    int? delta;
    IconData? trendIcon;
    final lastWeek = progress.lastWeekTotal;
    final current = progress.currentWeekTotal;
    if (lastWeek > 0) {
      final pct = ((current - lastWeek) / lastWeek * 100).round();
      delta = pct.abs();
      if (pct > 0) {
        trendIcon = Icons.arrow_upward;
      } else if (pct < 0) {
        trendIcon = Icons.arrow_downward;
      }
    }

    final accentColor = const Color(0xFFC6F52C);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  progress.dimensionName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.80),
                  ),
                ),
                if (delta != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (trendIcon != null)
                        Icon(trendIcon, size: 12, color: accentColor),
                      const SizedBox(width: 2),
                      Text(
                        '$delta%',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'vs last week',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.35),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  )
                else
                  Text(
                    '--',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.30),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: progress.currentWeekTotal),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    final valStr = value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
                    return Text(
                      valStr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    '${progress.unit} avg',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SegmentedProgressBar(
              progress: progress.progressPercent,
              segments: 10,
              height: 5,
              spacing: 4,
              activeColor: const Color(0xFFC6F52C),
              backgroundColor: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChartCard(BuildContext context, WidgetRef ref, List<WeeklyProgress> progresses) {
    final selectedId = ref.watch(selectedDimensionIdProvider);
    final weekOffset = ref.watch(weekOffsetProvider);
    final selectedProgress = progresses.firstWhere(
      (p) => p.dimensionId == selectedId,
      orElse: () => progresses.first,
    );

    final accentColor = const Color(0xFFC6F52C);
    final chartDataAsync = ref.watch(weeklyChartDataForOffsetProvider);
    final chartValues = chartDataAsync.valueOrNull ?? {};
    final todayWeekday = DateTime.now().weekday;

    // Week label
    String weekLabel;
    if (weekOffset == 0) {
      weekLabel = 'This Week';
    } else if (weekOffset == 1) {
      weekLabel = 'Last Week';
    } else {
      weekLabel = '$weekOffset weeks ago';
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: progresses.map((p) {
                        final isSelected = p.dimensionId == selectedId;
                        return GestureDetector(
                          onTap: () => ref.read(selectedDimensionIdProvider.notifier).state = p.dimensionId,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFC6F52C) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              p.dimensionName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.black : Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => ref.read(weekOffsetProvider.notifier).state = weekOffset + 1,
                      child: Icon(Icons.chevron_left, size: 20, color: Colors.white.withOpacity(0.5)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      weekLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.50),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: weekOffset > 0 ? () => ref.read(weekOffsetProvider.notifier).state = weekOffset - 1 : null,
                      child: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: weekOffset > 0 ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 24,
                  barTouchData: BarTouchData(enabled: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) {
                      if (value == 0 || value == 10 || value == 20) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.06),
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        );
                      }
                      return const FlLine(color: Colors.transparent);
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          final idx = value.toInt();
                          if (idx >= 0 && idx < 7) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                days[idx],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.35),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == 10 || value == 20) {
                            return Text(
                              value.toInt().toString(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: Colors.white.withOpacity(0.25),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    final dayIndex = i + 1;
                    final isToday = weekOffset == 0 && dayIndex == todayWeekday;
                    final val = chartValues[dayIndex] ?? 0.0;

                    Color barColor;
                    if (isToday) {
                      barColor = const Color(0xFFC6F52C);
                    } else if (val > 0) {
                      barColor = Colors.white.withOpacity(0.12);
                    } else {
                      barColor = Colors.white.withOpacity(0.05);
                    }

                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: val == 0 ? 1.0 : val,
                          color: barColor,
                          width: 24,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                        ),
                      ],
                    );
                  }),
                ),
                swapAnimationDuration: const Duration(milliseconds: 800),
                swapAnimationCurve: Curves.easeOutCubic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreaksCardFromDB(List<StreakData> streaks) {
    if (streaks.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Streaks ',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '🔥',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              children: List.generate(streaks.length, (index) {
                final item = streaks[index];
                final ringColor = Color(int.parse(item.colorHex.replaceFirst('#', '0xFF')));
                final progress = item.targetStreak > 0 ? item.currentStreak / item.targetStreak : 0.0;
                return Column(
                  children: [
                    if (index > 0)
                      Divider(
                        height: 1,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      child: Row(
                        children: [
                          Text(
                            item.dimensionName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${item.currentStreak}/${item.targetStreak}d',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.40),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: progress.clamp(0.0, 1.0)),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (ctx, val, _) => CustomPaint(
                              painter: StreakRingPainter(
                                progress: val,
                                trackColor: Colors.white.withOpacity(0.10),
                                arcColor: ringColor,
                                strokeWidth: 2.5,
                              ),
                              child: SizedBox(
                                width: 44,
                                height: 44,
                                child: Center(
                                  child: TweenAnimationBuilder<int>(
                                    tween: IntTween(begin: 0, end: item.currentStreak),
                                    duration: const Duration(milliseconds: 600),
                                    builder: (ctx, val, _) => Text(
                                      val.toString(),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealInsightsSection(BuildContext context, WidgetRef ref, int progressesLength) {
    final insightAsync = ref.watch(realInsightProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        insightAsync.when(
          data: (data) => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ScaleOnPress(
                      child: _buildMiniInsightCard1Real(data)
                          .animate(delay: ((progressesLength + 2) * 80).ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.08, end: 0, duration: 300.ms),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ScaleOnPress(
                      onTap: () {
                        // Open workout log on gym focus tap
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          useRootNavigator: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const WorkoutLogSheet(),
                        );
                      },
                      child: _buildMiniInsightCard2Real(data)
                          .animate(delay: ((progressesLength + 3) * 80).ms)
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.08, end: 0, duration: 300.ms),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ScaleOnPress(
                onTap: () {
                  context.go(Routes.taskCenter);
                },
                child: _buildWideInsightCardReal(data)
                    .animate(delay: ((progressesLength + 4) * 80).ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.08, end: 0, duration: 300.ms),
              ),
            ],
          ),
          loading: () => _buildShimmerInsights(),
          error: (e, s) => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildMiniInsightCard1Real(RealInsightData data) {
    final accentColor = const Color(0xFFC6F52C);
    final trendIcon = data.studyTrendDirection == 'up' ? Icons.trending_up
        : data.studyTrendDirection == 'down' ? Icons.trending_down
        : Icons.trending_flat;
    final trendColor = data.studyTrendDirection == 'up' ? accentColor
        : data.studyTrendDirection == 'down' ? const Color(0xFFFF5252)
        : Colors.white.withOpacity(0.45);
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 20,
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            data.studyTrend,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    data.studyTrendPercent,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    data.studyTrendDirection,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(trendIcon, size: 12, color: trendColor),
                  const SizedBox(width: 4),
                  Text(
                    'vs last week',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: trendColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInsightCard2Real(RealInsightData data) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 20,
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gym Focus',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.45),
                ),
              ),
              Icon(
                Icons.arrow_outward,
                size: 14,
                color: Colors.white.withOpacity(0.30),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.gymFocusStatus,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                data.gymFocusSub,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.40),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWideInsightCardReal(RealInsightData data) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                data.aiSummary != null ? 'AI Coach Reflection' : 'Tasks',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.45),
                ),
              ),
              const Spacer(),
              if (data.aiSummary == null)
                Icon(
                  data.overdueTasksCount > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  size: 16,
                  color: data.overdueTasksCount > 0 ? const Color(0xFFFF9800) : const Color(0xFFC6F52C),
                )
              else
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: const Color(0xFFB088F9),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (data.aiSummary != null)
            Text(
              data.aiSummary!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                height: 1.5,
                color: Colors.white.withOpacity(0.85),
              ),
            )
          else ...[
            Text(
              data.overdueTasksCount > 0
                  ? '${data.overdueTasksCount} overdue'
                  : 'All clear',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              data.overdueTasksCount > 0
                  ? 'Prioritize these next'
                  : 'No overdue tasks — keep it up!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.white.withOpacity(0.45),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerInsights() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDimensionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddDimensionBottomSheet(),
    );
  }
}

class AddDimensionBottomSheet extends ConsumerStatefulWidget {
  const AddDimensionBottomSheet({super.key});

  @override
  ConsumerState<AddDimensionBottomSheet> createState() => _AddDimensionBottomSheetState();
}

class _AddDimensionBottomSheetState extends ConsumerState<AddDimensionBottomSheet> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _unitController = TextEditingController();
  String _selectedColorHex = '#C6F52C';

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161616),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF252525), width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(28, 20, 28, 28 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add Progress Dimension',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField('Name (e.g., Study Hours)', _nameController, false),
          const SizedBox(height: 16),
          _buildTextField('Weekly Target', _targetController, true),
          const SizedBox(height: 16),
          _buildTextField('Unit (hours, sessions, etc.)', _unitController, false),
          const SizedBox(height: 20),
          Text(
            'Color Theme',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.50),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: ['#C6F52C', '#5B8DEF', '#FF5252', '#FF9800', '#E040FB'].map((colorHex) {
              final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
              final isSelected = _selectedColorHex == colorHex;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorHex = colorHex),
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final name = _nameController.text.trim();
                    final targetVal = double.tryParse(_targetController.text) ?? 0.0;
                    final unit = _unitController.text.trim();
                    if (name.isNotEmpty) {
                      final dao = ref.read(progressDaoProvider);
                      await dao.upsertDimension(ProgressDimensionsCompanion(
                        id: Value('dim_${DateTime.now().millisecondsSinceEpoch}'),
                        name: Value(name),
                        weeklyTarget: Value(targetVal),
                        unit: Value(unit.isEmpty ? 'count' : unit),
                        colorHex: Value(_selectedColorHex),
                        sortOrder: Value(0),
                      ));
                      ref.invalidate(weeklyProgressProvider);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC6F52C),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Add',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF252525), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
        style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white.withOpacity(0.30)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class StreakItem {
  final String name;
  final int current;
  final int target;
  const StreakItem(this.name, this.current, this.target);
}

class StreakRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color arcColor;
  final double strokeWidth;

  StreakRingPainter({
    required this.progress,
    required this.trackColor,
    required this.arcColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * 3.1415926535 * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant StreakRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class ScaleOnPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const ScaleOnPress({super.key, required this.child, this.onTap});

  @override
  State<ScaleOnPress> createState() => _ScaleOnPressState();
}

class _ScaleOnPressState extends State<ScaleOnPress> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) setState(() => _scale = 0.97);
      },
      onTapUp: (_) {
        if (widget.onTap != null) setState(() => _scale = 1.0);
      },
      onTapCancel: () {
        if (widget.onTap != null) setState(() => _scale = 1.0);
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.child,
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
            const Icon(Icons.show_chart, size: 48, color: AnchorTheme.textMuted),
            const SizedBox(height: 16),
            Text(
              'No dimensions yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add dimensions to track what matters to you.\nStudy hours, exercise, coding practice — you decide.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AnchorTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
