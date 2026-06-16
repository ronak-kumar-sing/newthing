import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design/anchor_theme.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../providers/database_provider.dart';
import '../../providers/journey_config_provider.dart';
import '../../providers/settings_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/streak/widgets/streak_clock_screen.dart';
import 'wallpaper_screen.dart';
import 'widgets_screen.dart';
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

class IndependenceClockScreen extends ConsumerStatefulWidget {
  const IndependenceClockScreen({super.key});

  @override
  ConsumerState<IndependenceClockScreen> createState() => _IndependenceClockScreenState();
}

class _IndependenceClockScreenState extends ConsumerState<IndependenceClockScreen> {
  Future<void> _pickDate(BuildContext context, DateTime? current, {bool isStartDate = false}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: isStartDate ? DateTime(2000) : DateTime.now(),
      lastDate: isStartDate ? DateTime.now() : DateTime.now().add(const Duration(days: 365 * 10)),
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
    if (picked == null) return;

    final dao = ref.read(settingsDaoProvider);
    if (isStartDate) {
      await dao.setIndependenceStartDate(picked);
    } else {
      await dao.updateTargetDate(picked);
    }

    // Sync dates/label to SharedPreferences for the background wallpaper task.
    await _syncWallpaperPrefs();

    ref.invalidate(settingsProvider);
    ref.invalidate(daysRemainingProvider);
    ref.invalidate(independenceDateProvider);
    ref.invalidate(journeyConfigProvider);
  }

  Future<void> _syncWallpaperPrefs() async {
    try {
      final settings = await ref.read(settingsDaoProvider).getSettings();
      final prefs = await SharedPreferences.getInstance();
      if (settings.independenceDate != null) {
        await prefs.setString('anchor_target_date', settings.independenceDate!.toIso8601String());
      }
      if (settings.independenceStartDate != null) {
        await prefs.setString('anchor_start_date', settings.independenceStartDate!.toIso8601String());
      }
      if (settings.independenceLabel != null) {
        await prefs.setString('anchor_goal_title', settings.independenceLabel!);
      }
    } catch (e) {
      debugPrint('Failed to sync wallpaper prefs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final journeyAsync = ref.watch(journeyConfigProvider);
    final journey = journeyAsync.valueOrNull ?? const JourneyConfig();
    final goalDate = journey.goalDate;
    final startDate = journey.startDate;
    final label = journey.label;

    final daysLeft = journey.daysRemaining;
    final totalDays = journey.totalDays;
    final progress = journey.progress;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: AnchorBackground(
        child: Column(
            children: [
              // Sticky Top Bar Header
              _buildHeader(context, goalDate, startDate),
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 24, 32, 100),
                  child: Column(
                    children: [
                      // Hero Countdown Card
                      FadeSlideIn(
                        delaySeconds: 0.05,
                        child: _buildHeroCard(daysLeft, goalDate, startDate, label, progress, totalDays),
                      ),
                      const SizedBox(height: 24.0),

                      if (!journey.hasStartDate) ...[
                        FadeSlideIn(
                          delaySeconds: 0.08,
                          child: _buildStartDatePrompt(),
                        ),
                        const SizedBox(height: 24.0),
                      ],

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
                        child: _buildStreakClockCard(label),
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

  Widget _buildHeader(BuildContext context, DateTime? goalDate, DateTime? startDate) {
    final dateStr = goalDate != null
        ? DateFormat('MMM d, yyyy').format(goalDate)
        : 'Select Target';
    final startStr = startDate != null
        ? DateFormat('MMM d, yyyy').format(startDate)
        : 'Set Start';

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
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WallpaperScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
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
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WidgetsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.widgets_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.settings_outlined, size: 20, color: Colors.white.withValues(alpha: 0.50)),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(int daysLeft, DateTime? goalDate, DateTime? startDate, String label, double progress, int totalDays) {
    final startedStr = startDate != null
        ? DateFormat('MMM d').format(startDate)
        : DateFormat('MMM d').format(DateTime.now());
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
            animate: false,
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

  Widget _buildStartDatePrompt() {
    return CleanCard(
      onTap: () => context.push('/settings'),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AnchorTheme.accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AnchorTheme.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set your journey start date in Settings',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Make your streak and countdown responsive to your actual timeline.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AnchorTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AnchorTheme.textMuted,
            size: 20,
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

  Widget _buildStreakClockCard(String label) {
    final streakDaysAsync = ref.watch(streakDaysProvider);

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
            targetDays: streakData.length,
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
