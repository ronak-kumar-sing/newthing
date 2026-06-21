import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design/anchor_theme.dart';
import '../../core/widgets/anchor_background.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../features/streak/models/streak_widget_data.dart';
import '../../features/streak/services/streak_calculator.dart';
import '../../features/streak/services/widget_sync_service.dart';
import '../../providers/journey_config_provider.dart';

/// Live streak data for the widget preview.
final _widgetStreakPreviewProvider = FutureProvider<StreakWidgetData>((ref) async {
  try {
    final journey = await ref.watch(journeyConfigProvider.future);
    final streakDays = await ref.watch(streakDaysProvider.future);

    final totalDays = journey.totalDays;
    final completedDays = streakDays.where((d) => d.isCompleted).length;
    final daysLeft = math.max(0, totalDays - completedDays);
    final percentage = totalDays > 0
        ? ((completedDays / totalDays) * 100.0).clamp(0.0, 100.0)
        : 0.0;

    final currentStreak = calculateCurrentStreak(streakDays);
    final last7 = last7Days(streakDays);

    return StreakWidgetData(
      habitName: journey.label,
      currentStreak: currentStreak,
      targetDays: totalDays,
      daysLeft: daysLeft,
      percentage: percentage,
      last7Days: last7,
      accentColorHex: AnchorTheme.accent.toHex(),
    );
  } catch (e, stack) {
    debugPrint('Widget streak preview error: $e\n$stack');
    return const StreakWidgetData(
      habitName: 'Focus Goal',
      currentStreak: 12,
      targetDays: 365,
      daysLeft: 353,
      percentage: 3.2,
      last7Days: [true, true, true, false, true, true, false],
      accentColorHex: '#C6F52C',
    );
  }
});

/// Home screen widgets gallery — preview and pin the streak widget.
class WidgetsScreen extends ConsumerStatefulWidget {
  const WidgetsScreen({super.key});

  @override
  ConsumerState<WidgetsScreen> createState() => _WidgetsScreenState();
}

class _WidgetsScreenState extends ConsumerState<WidgetsScreen> {
  bool _pinningStreak = false;

  Future<void> _pinStreakWidget() async {
    setState(() => _pinningStreak = true);
    final success = await WidgetSyncService.pinStreakWidget();
    setState(() => _pinningStreak = false);
    _showPinResult('Streak widget pin requested', success);
  }

  void _showPinResult(String message, bool success) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? '$message ✓' : 'Failed to request widget pin. You may need to add it manually.',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.black),
        ),
        backgroundColor: success ? AnchorTheme.accent : AnchorTheme.statusError,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final streakAsync = ref.watch(_widgetStreakPreviewProvider);

    return Scaffold(
      backgroundColor: AnchorTheme.backgroundDeep,
      body: AnchorBackground(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Widgets',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AnchorTheme.containerPadding).copyWith(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOME SCREEN WIDGET',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AnchorTheme.textMuted,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: AnchorTheme.stackGap),
                    _buildWidgetCard(
                      title: 'Streak Widget',
                      description: 'Keep your daily focus streak visible on your home screen.',
                      preview: streakAsync.when(
                        data: (data) => _StreakWidgetPreview(data: data),
                        loading: () => const _PreviewLoading(),
                        error: (_, __) => const _PreviewError(),
                      ),
                      buttonText: 'Pin Streak Widget',
                      buttonIcon: Icons.add_to_home_screen,
                      isLoading: _pinningStreak,
                      onPressed: _pinStreakWidget,
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

  Widget _buildWidgetCard({
    required String title,
    required String description,
    required Widget preview,
    required String buttonText,
    required IconData buttonIcon,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return CleanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.white.withOpacity(0.55),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: preview,
              ),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            buttonText,
            isLoading ? null : onPressed,
            icon: buttonIcon,
          ),
        ],
      ),
    );
  }
}

class _PreviewLoading extends StatelessWidget {
  const _PreviewLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      color: const Color(0xFF161616),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AnchorTheme.accent),
        ),
      ),
    );
  }
}

class _PreviewError extends StatelessWidget {
  const _PreviewError();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      color: const Color(0xFF161616),
      child: Center(
        child: Text(
          'Unable to load preview',
          style: GoogleFonts.inter(fontSize: 13, color: AnchorTheme.textMuted),
        ),
      ),
    );
  }
}

class _StreakWidgetPreview extends StatelessWidget {
  final StreakWidgetData data;

  const _StreakWidgetPreview({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF161616),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.habitName.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AnchorTheme.textMuted,
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${data.currentStreak}',
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'DAYS',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AnchorTheme.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                '${data.daysLeft}d left',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AnchorTheme.accent,
                ),
              ),
              Text(
                ' · ',
                style: GoogleFonts.inter(fontSize: 11, color: AnchorTheme.textMuted),
              ),
              Text(
                '${data.percentage.toInt()}%',
                style: GoogleFonts.inter(fontSize: 11, color: AnchorTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: data.last7Days.map((active) {
              return Expanded(
                child: Container(
                  height: 12,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: active ? AnchorTheme.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                    border: active
                        ? null
                        : Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
