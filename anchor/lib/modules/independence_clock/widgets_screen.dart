import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design/anchor_theme.dart';
import '../../core/widgets/anchor_background.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../data/local/database.dart';
import '../../features/streak/models/streak_widget_data.dart';
import '../../features/streak/services/widget_sync_service.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';

/// Live streak data for the widget preview.
final _widgetStreakPreviewProvider = FutureProvider<StreakWidgetData>((ref) async {
  final dao = ref.watch(journalDaoProvider);
  final settings = await ref.watch(settingsProvider.future);
  final now = DateTime.now();
  final todayKey = DateTime(now.year, now.month, now.day);
  const targetDays = 365;
  final startDate = todayKey.subtract(const Duration(days: targetDays - 1));

  final entries = await dao.getEntriesForRange(startDate, todayKey);
  final dateMap = {
    for (final e in entries)
      DateTime(e.date.year, e.date.month, e.date.day): e,
  };

  final completedDays = entries.where((e) => e.focusRating != null && e.focusRating! >= 3).length;
  final daysLeft = math.max(0, targetDays - completedDays);
  final percentage = ((completedDays / targetDays) * 100.0).clamp(0.0, 100.0);

  // Current streak counting backwards from today/yesterday.
  int currentStreak = 0;
  for (int i = 0; i <= targetDays; i++) {
    final checkDate = todayKey.subtract(Duration(days: i));
    final entry = dateMap[checkDate];
    if (entry != null && entry.focusRating != null && entry.focusRating! >= 3) {
      currentStreak++;
    } else if (i == 0) {
      continue;
    } else {
      break;
    }
  }

  final last7Days = <bool>[
    for (int i = 6; i >= 0; i--)
      dateMap[todayKey.subtract(Duration(days: i))]?.focusRating != null &&
          dateMap[todayKey.subtract(Duration(days: i))]!.focusRating! >= 3,
  ];

  return StreakWidgetData(
    habitName: settings.independenceLabel ?? 'Focus Goal',
    currentStreak: currentStreak,
    targetDays: targetDays,
    daysLeft: daysLeft,
    percentage: percentage,
    last7Days: last7Days,
    accentColorHex: AnchorTheme.accent.toHex(),
  );
});

/// Home screen widgets gallery — preview and pin streak/tasks widgets.
class WidgetsScreen extends ConsumerStatefulWidget {
  const WidgetsScreen({super.key});

  @override
  ConsumerState<WidgetsScreen> createState() => _WidgetsScreenState();
}

class _WidgetsScreenState extends ConsumerState<WidgetsScreen> {
  bool _pinningStreak = false;
  bool _pinningTasks = false;

  Future<void> _pinStreakWidget() async {
    setState(() => _pinningStreak = true);
    final success = await WidgetSyncService.pinStreakWidget();
    setState(() => _pinningStreak = false);
    _showPinResult('Streak widget pin requested', success);
  }

  Future<void> _pinTasksWidget() async {
    setState(() => _pinningTasks = true);
    final success = await WidgetSyncService.pinTasksWidget();
    setState(() => _pinningTasks = false);
    _showPinResult('Tasks widget pin requested', success);
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
    final tasksAsync = ref.watch(activeTasksProvider);

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
            Container(height: 1, color: Colors.white.withOpacity(0.08)),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AnchorTheme.containerPadding).copyWith(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOME SCREEN WIDGETS',
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
                        error: (_, _) => const _PreviewError(),
                      ),
                      buttonText: 'Pin Streak Widget',
                      buttonIcon: Icons.add_to_home_screen,
                      isLoading: _pinningStreak,
                      onPressed: _pinStreakWidget,
                    ),
                    const SizedBox(height: AnchorTheme.stackGap),
                    _buildWidgetCard(
                      title: 'Tasks Widget',
                      description: "See today's active tasks at a glance without opening the app.",
                      preview: tasksAsync.when(
                        data: (tasks) {
                          final taskList = tasks
                              .take(3)
                              .map((t) => TaskWidgetData(
                                    id: t.id,
                                    title: t.title,
                                    isCompleted: t.isCompleted,
                                    category: t.label ?? 'General',
                                  ))
                              .toList();
                          return _TasksWidgetPreview(tasks: taskList);
                        },
                        loading: () => const _PreviewLoading(),
                        error: (_, _) => const _PreviewError(),
                      ),
                      buttonText: 'Pin Tasks Widget',
                      buttonIcon: Icons.add_to_home_screen,
                      isLoading: _pinningTasks,
                      onPressed: _pinTasksWidget,
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

class _TasksWidgetPreview extends StatelessWidget {
  final List<TaskWidgetData> tasks;

  const _TasksWidgetPreview({required this.tasks});

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TODAY'S TASKS",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.1,
                ),
              ),
              Text(
                'ANCHOR',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AnchorTheme.accent,
                  letterSpacing: 0.15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFF252525)),
          const SizedBox(height: 8),
          if (tasks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'All tasks completed for today.',
                  style: GoogleFonts.inter(fontSize: 12, color: AnchorTheme.textMuted),
                ),
              ),
            )
          else
            ...tasks.map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                        size: 16,
                        color: task.isCompleted
                            ? AnchorTheme.accent
                            : Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              (task.category ?? 'General').toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: AnchorTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
