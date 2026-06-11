import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;
import 'package:go_router/go_router.dart';
import '../../core/design/anchor_theme.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../data/local/database.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/streak/models/streak_day.dart';
import '../../features/streak/models/streak_day.dart';
import '../../features/streak/widgets/streak_clock_screen.dart';
import '../../features/streak/widgets/wallpaper_preview.dart';
import '../../features/streak/models/streak_widget_data.dart';
import '../../core/widgets/anchor_background.dart';
import 'widgets/clock_widgets.dart';

/// Focus streak count provider.
final journalStreakProvider = FutureProvider<int>((ref) async {
  final dao = ref.watch(journalDaoProvider);
  return dao.getStreak((entry) => entry.focusRating != null && entry.focusRating! >= 3);
});

/// Checked-in dates for the current week (Monday to Sunday).
final currentWeekCheckInsProvider = FutureProvider<List<DateTime>>((ref) async {
  final dao = ref.watch(journalDaoProvider);
  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  final sunday = monday.add(const Duration(days: 7));

  final entries = await dao.getEntriesForRange(monday, sunday);
  return entries.map((e) => e.date).toList();
});

/// Checked-in dates for a specific month.
final monthlyCheckInsProvider = FutureProvider.family<List<DateTime>, DateTime>((ref, monthDate) async {
  final dao = ref.watch(journalDaoProvider);
  final startOfMonth = DateTime(monthDate.year, monthDate.month, 1);
  final endOfMonth = DateTime(monthDate.year, monthDate.month + 1, 1).subtract(const Duration(seconds: 1));

  final entries = await dao.getEntriesForRange(startOfMonth, endOfMonth);
  return entries.map((e) => e.date).toList();
});

/// Checked-in dates for the last 365 days mapped to StreakDay.
final streakDaysProvider = FutureProvider<List<StreakDay>>((ref) async {
  final dao = ref.watch(journalDaoProvider);
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 365));
  final endDate = DateTime(now.year, now.month, now.day);

  final entries = await dao.getEntriesForRange(startDate, endDate);
  
  final entryMap = {
    for (var e in entries)
      DateTime(e.date.year, e.date.month, e.date.day): e
  };

  final List<StreakDay> list = [];
  for (int i = 0; i <= 365; i++) {
    final date = startDate.add(Duration(days: i));
    final dateKey = DateTime(date.year, date.month, date.day);
    final entry = entryMap[dateKey];
    final isCompleted = entry != null && entry.focusRating != null && entry.focusRating! >= 3;
    final double? intensity = entry?.focusRating != null 
        ? (entry!.focusRating! / 5.0).clamp(0.0, 1.0) 
        : null;
    list.add(StreakDay(
      date: date,
      isCompleted: isCompleted,
      intensity: intensity,
    ));
  }
  return list;
});

class IndependenceClockScreen extends ConsumerStatefulWidget {
  const IndependenceClockScreen({super.key});

  @override
  ConsumerState<IndependenceClockScreen> createState() => _IndependenceClockScreenState();
}

class _IndependenceClockScreenState extends ConsumerState<IndependenceClockScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  Future<void> _pickDate(BuildContext context, DateTime? current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AnchorTheme.accent,
            onPrimary: AnchorTheme.onAccent,
            surface: AnchorTheme.cardBgHigh,
            onSurface: AnchorTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      await ref.read(settingsDaoProvider).updateTargetDate(picked);
      ref.invalidate(settingsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.valueOrNull;
    final goalDate = settings?.independenceDate;
    final label = settings?.independenceLabel ?? 'INDEPENDENCE CLOCK';

    Duration? remaining;
    if (goalDate != null) {
      remaining = goalDate.difference(DateTime.now());
    }
    final daysLeft = remaining?.inDays ?? 0;
    const totalDays = 365;
    final progress = daysLeft > 0
        ? (1.0 - (daysLeft / totalDays).clamp(0.0, 1.0))
        : (goalDate != null ? 1.0 : 0.0);

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: AnchorBackground(
        child: Column(
            children: [
              // Sticky Top Bar Header
              _buildHeader(context, goalDate),
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 100),
                  child: Column(
                    children: [
                      // Hero Countdown Card
                      FadeSlideIn(
                        delaySeconds: 0.05,
                        child: _buildHeroCard(daysLeft, goalDate, label, progress),
                      ),
                      const SizedBox(height: 24.0),

                      // Streak Tracker
                      FadeSlideIn(
                        delaySeconds: 0.1,
                        child: const _StreakTrackerCard(),
                      ),
                      const SizedBox(height: 24.0),

                      // Pace Check
                      FadeSlideIn(
                        delaySeconds: 0.15,
                        child: _buildPaceCheckCard(progress, daysLeft),
                      ),
                      const SizedBox(height: 24.0),

                      // Streak Dot Grid Matrix
                      FadeSlideIn(
                        delaySeconds: 0.2,
                        child: _buildStreakClockCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildHeader(BuildContext context, DateTime? goalDate) {
    final dateStr = goalDate != null
        ? DateFormat('MMM d, yyyy').format(goalDate)
        : 'Select Target';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Color(0xFF252525), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.grid_view_rounded,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                'Student OS',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _pickDate(context, goalDate),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        dateStr,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AnchorTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AnchorTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final streakDaysAsync = ref.read(streakDaysProvider);
                  final streakData = streakDaysAsync.valueOrNull ?? [];
                  final settings = ref.read(settingsProvider).valueOrNull;
                  final label = settings?.independenceLabel ?? 'Focus Goals';
                  
                  int currentStreak = 0;
                  final today = DateTime.now();
                  final todayKey = DateTime(today.year, today.month, today.day);
                  final dateMap = {
                    for (var d in streakData)
                      DateTime(d.date.year, d.date.month, d.date.day): d
                  };
                  for (int i = 0; i <= 365; i++) {
                    final checkDate = todayKey.subtract(Duration(days: i));
                    final day = dateMap[checkDate];
                    if (day != null && day.isCompleted) {
                      currentStreak++;
                    } else if (i == 0) {
                      continue;
                    } else {
                      break;
                    }
                  }
                  final completedDays = streakData.where((d) => d.isCompleted).length;
                  const targetDays = 365;
                  final daysLeft = math.max(0, targetDays - completedDays);
                  final percentage = ((completedDays / targetDays) * 100.0).clamp(0.0, 100.0);
                  final List<bool> last7 = [];
                  for (int i = 6; i >= 0; i--) {
                    final checkDate = todayKey.subtract(Duration(days: i));
                    final day = dateMap[checkDate];
                    last7.add(day?.isCompleted ?? false);
                  }

                  final data = StreakWidgetData(
                    habitName: label,
                    currentStreak: currentStreak,
                    targetDays: targetDays,
                    daysLeft: daysLeft,
                    percentage: percentage,
                    last7Days: last7,
                    accentColorHex: '#C6F52C',
                  );

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WallpaperPreviewScreen(streakData: data),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.wallpaper_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
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
      ),
    );
  }

  Widget _buildHeroCard(int daysLeft, DateTime? goalDate, String label, double progress) {
    final startDate = goalDate != null
        ? goalDate.subtract(const Duration(days: 365))
        : DateTime.now();

    final startedStr = DateFormat('MMM d').format(startDate);
    final targetStr = goalDate != null ? DateFormat('MMM d').format(goalDate) : '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AnchorTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AnchorTheme.cardBorder, width: 1),
      ),
      child: Column(
        children: [
          CountdownRing(
            progress: progress,
            child: SpinningNumber(
              number: goalDate != null ? daysLeft : 0,
              textStyle: GoogleFonts.sora(
                fontSize: 80,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'DAYS REMAINING',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: AnchorTheme.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'until $label',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AnchorTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Started: $startedStr',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AnchorTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  width: 1,
                  height: 12,
                  color: Colors.white.withOpacity(0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Text(
                  'Target: $targetStr',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AnchorTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaceCheckCard(double progress, int daysLeft) {
    final actualPercent = (progress * 100).clamp(0.0, 100.0);
    final expectedPercent = (actualPercent - 3).clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnchorTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AnchorTheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pace Check',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AnchorTheme.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AnchorTheme.accent.withOpacity(0.1),
                  border: Border.all(
                    color: AnchorTheme.accent.withOpacity(0.2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥 ', style: TextStyle(fontSize: 11)),
                    Text(
                      'ON TRACK',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AnchorTheme.accent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final dotPosition = progress * maxWidth;
              return Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Track Fill
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AnchorTheme.accent,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AnchorTheme.accent.withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 1.5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Glowing indicator at the end of progress
                    if (progress > 0)
                      Positioned(
                        left: (dotPosition - 8).clamp(0.0, maxWidth - 16),
                        top: -2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AnchorTheme.accent,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AnchorTheme.accent.withOpacity(0.85),
                                blurRadius: 10,
                                spreadRadius: 2.5,
                              ),
                            ],
                          ),
                        ).animate(
                          onPlay: (controller) => controller.repeat(reverse: true),
                        ).scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.15, 1.15),
                          duration: 1000.ms,
                          curve: Curves.easeInOut,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  text: '${actualPercent.toStringAsFixed(0)}% ',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: 'complete',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AnchorTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Expected: ${expectedPercent.toStringAsFixed(0)}%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AnchorTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakClockCard() {
    final streakDaysAsync = ref.watch(streakDaysProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.valueOrNull;
    final label = settings?.independenceLabel ?? 'Focus Goals';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnchorTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AnchorTheme.cardBorder, width: 1),
      ),
      child: streakDaysAsync.when(
        data: (streakData) {
          return StreakClockScreen(
            habitName: label,
            streakData: streakData,
            targetDays: 365,
            accentColor: AnchorTheme.accent,
          );
        },
        loading: () => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AnchorTheme.accent),
            ),
          ),
        ),
        error: (e, s) => const SizedBox(),
      ),
    );
  }
}

class _StreakTrackerCard extends ConsumerWidget {
  const _StreakTrackerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(journalStreakProvider);
    final weekCheckInsAsync = ref.watch(currentWeekCheckInsProvider);

    final now = DateTime.now();
    final todayWeekday = now.weekday;
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnchorTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AnchorTheme.cardBorder, width: 1),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: -20,
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 100,
              color: Colors.white.withOpacity(0.012),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      size: 20,
                      color: Color(0xFFFF5252),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STREAK',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AnchorTheme.textMuted,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          streakAsync.when(
                            data: (streak) => Text(
                              '$streak',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            loading: () => Text(
                              '—',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            error: (e, s) => Text(
                              '0',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'DAYS',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AnchorTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              weekCheckInsAsync.when(
                data: (checkIns) {
                  final checkInDays = checkIns.map((d) => d.weekday).toSet();

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final dayIndex = i + 1;
                      final isPast = dayIndex < todayWeekday;
                      final isToday = dayIndex == todayWeekday;

                      final hasCheckIn = checkInDays.contains(dayIndex);

                      Widget statusIndicator;

                      if (isToday) {
                        statusIndicator = Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: hasCheckIn ? AnchorTheme.accent : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AnchorTheme.accent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AnchorTheme.accent.withOpacity(0.85),
                                blurRadius: 10,
                                spreadRadius: 1.5,
                              ),
                            ],
                          ),
                          child: hasCheckIn
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Colors.black,
                                )
                              : null,
                        ).animate(
                          onPlay: (controller) => controller.repeat(reverse: true),
                        ).scale(
                          begin: const Offset(0.92, 0.92),
                          end: const Offset(1.06, 1.06),
                          duration: 1000.ms,
                          curve: Curves.easeInOut,
                        );
                      } else if (hasCheckIn || (isPast && dayIndex % 2 == 0)) {
                        statusIndicator = Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AnchorTheme.accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AnchorTheme.accent,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.black,
                          ),
                        );
                      } else {
                        statusIndicator = Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        );
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          statusIndicator,
                          const SizedBox(height: 8),
                          Text(
                            weekdays[i],
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                              color: isToday ? Colors.white : AnchorTheme.textSecondary,
                            ),
                          ),
                        ],
                      );
                    }),
                  );
                },
                loading: () => const SizedBox(
                  height: 50,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AnchorTheme.accent),
                    ),
                  ),
                ),
                error: (e, s) => const SizedBox(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AtmosphericBackground extends StatelessWidget {
  final Widget child;

  const _AtmosphericBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF050505),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFAA5500).withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AnchorTheme.accent.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: 50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF643296).withOpacity(0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
