import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_extensions.dart';
import '../../core/utils/task_extensions.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../data/local/database.dart';
import '../../providers/database_provider.dart';

import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';

/// The Morning Brief — clean white professional design.
/// White backgrounds, solid colors, no glassmorphism, no neon.
class MorningBriefScreen extends ConsumerWidget {
  const MorningBriefScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final settingsAsync = ref.watch(settingsProvider);
    final daysRemainingAsync = ref.watch(daysRemainingProvider);
    final topTasksAsync = ref.watch(topTasksProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Status bar
              Container(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 32,
                  12,
                  isMobile ? 16 : 32,
                  8,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _StatusIndicator(
                      label: 'SYS',
                      status: 'ONLINE',
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    _StatusIndicator(
                      label: 'TODOIST',
                      status: 'SYNCED',
                      color: AppColors.textMuted,
                    ),
                    const Spacer(),
                    Text(
                      now.friendlyDate.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 9 : 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 24),
                child: isMobile
                    ? Column(
                        children: [
                          FadeSlideIn(
                            delaySeconds: 0.05,
                            child: _CountdownCard(
                              daysRemaining: daysRemainingAsync.valueOrNull,
                              settings: settingsAsync.valueOrNull,
                              isMobile: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FadeSlideIn(
                            delaySeconds: 0.1,
                            child: _WeatherCard(isMobile: true),
                          ),
                          const SizedBox(height: 12),
                          FadeSlideIn(
                            delaySeconds: 0.15,
                            child: _TasksCard(
                              tasks: topTasksAsync.valueOrNull ?? [],
                              isMobile: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FadeSlideIn(
                            delaySeconds: 0.2,
                            child: _CoachCard(isMobile: true),
                          ),
                          const SizedBox(height: 12),
                          FadeSlideIn(
                            delaySeconds: 0.25,
                            child: _CheckInCard(isMobile: true),
                          ),
                          const SizedBox(height: 12),
                          FadeSlideIn(
                            delaySeconds: 0.3,
                            child: _IntentionCard(isMobile: true),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                FadeSlideIn(
                                  delaySeconds: 0.05,
                                  child: _CountdownCard(
                                    daysRemaining: daysRemainingAsync.valueOrNull,
                                    settings: settingsAsync.valueOrNull,
                                    isMobile: false,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FadeSlideIn(
                                  delaySeconds: 0.1,
                                  child: _TasksCard(
                                    tasks: topTasksAsync.valueOrNull ?? [],
                                    isMobile: false,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FadeSlideIn(
                                  delaySeconds: 0.15,
                                  child: _CoachCard(isMobile: false),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                FadeSlideIn(
                                  delaySeconds: 0.1,
                                  child: _WeatherCard(isMobile: false),
                                ),
                                const SizedBox(height: 16),
                                FadeSlideIn(
                                  delaySeconds: 0.15,
                                  child: _CheckInCard(isMobile: false),
                                ),
                                const SizedBox(height: 16),
                                FadeSlideIn(
                                  delaySeconds: 0.2,
                                  child: _IntentionCard(isMobile: false),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label, status;
  final Color color;
  const _StatusIndicator({
    required this.label,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          status,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final int? daysRemaining;
  final dynamic settings;
  final bool isMobile;
  const _CountdownCard({
    this.daysRemaining,
    this.settings,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final label = settings?.independenceLabel ?? 'TARGET DATE';
    return CleanCard(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            label: label,
            isMobile: isMobile,
          ),
          const SizedBox(height: 20),
          if (daysRemaining != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                AnimatedCounter(
                  value: daysRemaining!,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 52 : 80,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 0.9,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'DAYS',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 12 : 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 3,
                  ),
                ),
              ],
            )
          else
            Text(
              'NO TARGET SET',
              style: GoogleFonts.inter(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 2,
              ),
            ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.35,
              backgroundColor: AppColors.trackBg,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.trackFill),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TasksCard extends StatelessWidget {
  final List<Task> tasks;
  final bool isMobile;
  const _TasksCard({required this.tasks, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return CleanCard(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            label: 'PRIORITY TASKS',
            isMobile: isMobile,
          ),
          const SizedBox(height: 16),
          if (tasks.isEmpty)
            _EmptyState(message: 'No Active Tasks')
          else
            Column(
              children: tasks.asMap().entries.map((entry) {
                return _TaskRow(
                  index: entry.key + 1,
                  task: entry.value,
                  isMobile: isMobile,
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              '+',
              () {},
              icon: Icons.add,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final int index;
  final Task task;
  final bool isMobile;
  const _TaskRow({
    required this.index,
    required this.task,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    Color priorityColor = AppColors.textMuted;
    if (task.priority == 1) priorityColor = AppColors.error;
    if (task.priority == 2) priorityColor = AppColors.warning;
    if (task.priority == 3) priorityColor = AppColors.info;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            index.toString().padLeft(2, '0'),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 4,
            height: isMobile ? 24 : 28,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.isOverdue)
                  Text(
                    'OVERDUE',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                      letterSpacing: 1.5,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final bool isMobile;
  const _CoachCard({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return CleanCard(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      borderColor: AppColors.border,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  label: 'AI COACH',
                  isMobile: isMobile,
                ),
                const SizedBox(height: 12),
                Text(
                  '"Today is a blank page. Start with the smallest task and let momentum carry you. Your only competition is yesterday."',
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  final bool isMobile;
  const _WeatherCard({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return CleanCard(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            label: 'WEATHER',
            isMobile: isMobile,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.wb_sunny,
                size: isMobile ? 36 : 48,
                color: AppColors.warning,
              ),
              const SizedBox(width: 12),
              Text(
                '34°',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 40 : 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLEAR',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'JALANDHAR',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
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
}

class _CheckInCard extends ConsumerStatefulWidget {
  final bool isMobile;
  const _CheckInCard({required this.isMobile});

  @override
  ConsumerState<_CheckInCard> createState() => _CheckInCardState();
}

class _CheckInCardState extends ConsumerState<_CheckInCard> {
  int? _sleepRating;
  int? _energyRating;
  int? _focusRating;

  @override
  void initState() {
    super.initState();
    _loadExistingRatings();
  }

  Future<void> _loadExistingRatings() async {
    final entry = await ref.read(journalDaoProvider).getTodayEntry();
    if (entry != null && mounted) {
      setState(() {
        _sleepRating = entry.sleepRating;
        _energyRating = entry.energyRating;
        _focusRating = entry.focusRating;
      });
    }
  }

  Future<void> _saveRating(String type, int rating) async {
    switch (type) {
      case 'SLEEP':
        await ref.read(journalDaoProvider).updateCheckIn(sleepRating: rating);
        setState(() => _sleepRating = rating);
      case 'ENERGY':
        await ref.read(journalDaoProvider).updateCheckIn(energyRating: rating);
        setState(() => _energyRating = rating);
      case 'FOCUS':
        await ref.read(journalDaoProvider).updateCheckIn(focusRating: rating);
        setState(() => _focusRating = rating);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CleanCard(
      padding: EdgeInsets.all(
        widget.isMobile ? 16 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            label: 'DAILY METRICS',
            isMobile: widget.isMobile,
          ),
          const SizedBox(height: 20),
          RatingRow(
            label: 'Sleep',
            max: 5,
            isMobile: widget.isMobile,
            selectedValue: _sleepRating,
            onSelected: (v) => _saveRating('SLEEP', v),
          ),
          const SizedBox(height: 12),
          RatingRow(
            label: 'Energy',
            max: 5,
            isMobile: widget.isMobile,
            selectedValue: _energyRating,
            onSelected: (v) => _saveRating('ENERGY', v),
          ),
          const SizedBox(height: 12),
          RatingRow(
            label: 'Focus',
            max: 5,
            isMobile: widget.isMobile,
            selectedValue: _focusRating,
            onSelected: (v) => _saveRating('FOCUS', v),
          ),
        ],
      ),
    );
  }
}

class _IntentionCard extends ConsumerStatefulWidget {
  final bool isMobile;
  const _IntentionCard({required this.isMobile});

  @override
  ConsumerState<_IntentionCard> createState() => _IntentionCardState();
}

class _IntentionCardState extends ConsumerState<_IntentionCard> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingIntention();
  }

  Future<void> _loadExistingIntention() async {
    final entry = await ref.read(journalDaoProvider).getTodayEntry();
    if (entry?.dailyIntention != null && mounted) {
      _controller.text = entry!.dailyIntention!;
    }
  }

  Future<void> _saveIntention() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSaving = true);

    final today = DateTime.now();
    final existing = await ref.read(journalDaoProvider).getTodayEntry();

    if (existing != null) {
      await ref.read(journalDaoProvider).upsertEntry(
            JournalEntriesCompanion(
              id: Value(existing.id),
              date: Value(DateTime(today.year, today.month, today.day)),
              dailyIntention: Value(text),
            ),
          );
    } else {
      await ref.read(journalDaoProvider).upsertEntry(
            JournalEntriesCompanion(
              id: Value('journal_${today.millisecondsSinceEpoch}'),
              date: Value(DateTime(today.year, today.month, today.day)),
              dailyIntention: Value(text),
            ),
          );
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return CleanCard(
      padding: EdgeInsets.all(
        widget.isMobile ? 16 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            label: 'INTENTION',
            isMobile: widget.isMobile,
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Define today...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                ),
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
                suffixIcon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              maxLines: 2,
              onSubmitted: (_) => _saveIntention(),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: PrimaryButton(
              'Save Intention',
              _isSaving ? null : _saveIntention,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(
        message,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
