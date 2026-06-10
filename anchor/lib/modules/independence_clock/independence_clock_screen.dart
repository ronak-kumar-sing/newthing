import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/slice_spacing.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../providers/settings_provider.dart';

/// Independence Clock — Clean white professional timer + countdown screen.
/// Functional timer (HH:MM:SS), target date picker, milestones, and pace check.
class IndependenceClockScreen extends ConsumerStatefulWidget {
  const IndependenceClockScreen({super.key});

  @override
  ConsumerState<IndependenceClockScreen> createState() =>
      _IndependenceClockScreenState();
}

class _IndependenceClockScreenState
    extends ConsumerState<IndependenceClockScreen> {
  Timer? _timer;
  int _tick = 0;

  // Timer state
  int _elapsedSeconds = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _tick++;
          if (_isRunning) {
            _elapsedSeconds++;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() => setState(() => _isRunning = true);
  void _pauseTimer() => setState(() => _isRunning = false);
  void _resetTimer() => setState(() {
        _isRunning = false;
        _elapsedSeconds = 0;
      });

  String get _timerDisplay {
    final hours = (_elapsedSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_elapsedSeconds ~/ 60) % 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      // Save via settings provider — the UI will rebuild reactively
      // ignore: unused_result
      ref.refresh(settingsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.valueOrNull;

    final goalDate = settings?.independenceDate;
    final label = settings?.independenceLabel ?? 'TIMER';

    Duration? remaining;
    if (goalDate != null) {
      remaining = goalDate.difference(DateTime.now());
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: SliceSpacing.desktopPadding,
            vertical: SliceSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TIMER header
              FadeSlideIn(
                delaySeconds: 0.0,
                child: SectionHeader(
                  label: label.toUpperCase(),
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: SliceSpacing.xxl),

              // 2. Main timer display
              FadeSlideIn(
                delaySeconds: 0.1,
                child: CleanCard(
                  padding: const EdgeInsets.all(SliceSpacing.lg),
                  child: Column(
                    children: [
                      Text(
                        _timerDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                          color: AppColors.textPrimary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: SliceSpacing.lg),
                      // 3. Control buttons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ControlButton(
                            icon: Icons.play_arrow,
                            color: const Color(0xFF10B981),
                            onPressed: _startTimer,
                          ),
                          const SizedBox(width: SliceSpacing.md),
                          _ControlButton(
                            icon: Icons.pause,
                            color: const Color(0xFFF59E0B),
                            onPressed: _pauseTimer,
                          ),
                          const SizedBox(width: SliceSpacing.md),
                          _ControlButton(
                            icon: Icons.refresh,
                            color: const Color(0xFFEF4444),
                            onPressed: _resetTimer,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SliceSpacing.xxl),

              // 4. TARGET DATE section
              FadeSlideIn(
                delaySeconds: 0.2,
                child: CleanCard(
                  padding: const EdgeInsets.all(SliceSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(label: 'TARGET DATE'),
                      const SizedBox(height: SliceSpacing.lg),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  goalDate != null
                                      ? '${goalDate.year}-${goalDate.month.toString().padLeft(2, '0')}-${goalDate.day.toString().padLeft(2, '0')}'
                                      : 'Select a date',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: goalDate != null
                                        ? AppColors.textPrimary
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SliceSpacing.xl),

              // 5. Countdown
              if (remaining != null) ...[
                FadeSlideIn(
                  delaySeconds: 0.25,
                  child: CleanCard(
                    padding: const EdgeInsets.all(SliceSpacing.lg),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.hourglass_top,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${remaining.inDays} days until target',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: SliceSpacing.xl),

                // 6. Milestones
                FadeSlideIn(
                  delaySeconds: 0.35,
                  child: CleanCard(
                    padding: const EdgeInsets.all(SliceSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(label: 'MILESTONES'),
                        const SizedBox(height: SliceSpacing.xl),
                        _Milestones(
                          daysRemaining: remaining.inDays,
                          goalDate: goalDate!,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: SliceSpacing.xl),

                // 7. Pace check
                FadeSlideIn(
                  delaySeconds: 0.45,
                  child: _PaceCheck(daysRemaining: remaining.inDays),
                ),
              ],

              const SizedBox(height: SliceSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Control Button — solid color, white icon, r=12
// ─────────────────────────────────────────────
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Icon(icon, size: 28, color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Milestones — 4 dots (100, 50, 30, 7 days)
// ─────────────────────────────────────────────
class _Milestones extends StatelessWidget {
  final int daysRemaining;
  final DateTime goalDate;

  const _Milestones({required this.daysRemaining, required this.goalDate});

  @override
  Widget build(BuildContext context) {
    final milestones = [
      _Milestone(label: '100', isReached: daysRemaining <= 100),
      _Milestone(label: '50', isReached: daysRemaining <= 50),
      _Milestone(label: '30', isReached: daysRemaining <= 30),
      _Milestone(label: '7', isReached: daysRemaining <= 7),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: milestones.map((m) => _MilestoneDot(milestone: m)).toList(),
    );
  }
}

class _Milestone {
  final String label;
  final bool isReached;

  _Milestone({required this.label, required this.isReached});
}

class _MilestoneDot extends StatelessWidget {
  final _Milestone milestone;

  const _MilestoneDot({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: milestone.isReached ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: milestone.isReached
                  ? AppColors.primary
                  : AppColors.border,
              width: 2,
            ),
          ),
          child: milestone.isReached
              ? const Center(
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          milestone.label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight:
                milestone.isReached ? FontWeight.w700 : FontWeight.w500,
            color: milestone.isReached
                ? AppColors.textPrimary
                : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'DAYS',
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            color: AppColors.textDisabled,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Pace Check — progress bar from start to target
// ─────────────────────────────────────────────
class _PaceCheck extends StatelessWidget {
  final int daysRemaining;

  const _PaceCheck({required this.daysRemaining});

  @override
  Widget build(BuildContext context) {
    final progress = (365 - daysRemaining.clamp(0, 365)) / 365;

    return CleanCard(
      padding: const EdgeInsets.all(SliceSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(label: 'PACE CHECK'),
          const SizedBox(height: SliceSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$daysRemaining',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'DAYS REMAINING',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: SliceSpacing.md),
          // Progress track
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.trackBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.trackFill,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: SliceSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'START',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                  color: AppColors.textDisabled,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% COMPLETE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
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
