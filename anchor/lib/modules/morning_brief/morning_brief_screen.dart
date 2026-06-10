import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/design/anchor_theme.dart';
import '../../core/utils/date_extensions.dart';
import '../../core/utils/task_extensions.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../data/local/database.dart';
import '../../models/progress_model.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/api_provider.dart';
import '../../data/remote/weather_api.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Weather state provider.
final weatherProvider = FutureProvider<WeatherData?>((ref) async {
  final settings = await ref.watch(settingsProvider.future);
  final lat = settings.weatherLat;
  final lon = settings.weatherLon;
  final api = ref.read(weatherApiProvider);

  // Use user location if set, otherwise default to Ludhiana: 30.9009, 75.8573
  final targetLat = lat ?? 30.9009;
  final targetLon = lon ?? 75.8573;

  return api.getCurrentWeather(lat: targetLat, lon: targetLon);
});

/// Morning Briefing generator provider.
final morningBriefingProvider = FutureProvider<String?>((ref) async {
  final settings = await ref.watch(settingsProvider.future);
  final daysRemaining = await ref.watch(daysRemainingProvider.future) ?? 0;
  final topTasks = await ref.watch(topTasksProvider.future);

  final overdueCount = topTasks.where((t) => t.isOverdue).length;

  // Get yesterday's screen time
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  final dateOnly = DateTime(yesterday.year, yesterday.month, yesterday.day);
  final db = ref.read(databaseProvider);
  final yesterdayEntry = await (db.select(db.journalEntries)
        ..where((e) => e.date.equals(dateOnly)))
      .getSingleOrNull();

  final screenTimeStr = yesterdayEntry?.screenTimeMinutes != null
      ? '${yesterdayEntry!.screenTimeMinutes} minutes'
      : null;

  // Get weekly progress study hours
  final progressList = await ref.watch(weeklyProgressProvider.future);
  final studyProgress = progressList.firstWhere(
    (p) => p.dimensionName.toLowerCase().contains('study') || p.dimensionName.toLowerCase().contains('academic'),
    orElse: () => WeeklyProgress(
      dimensionId: 'study',
      dimensionName: 'Study',
      currentWeekTotal: 0.0,
      lastWeekTotal: 0.0,
      weeklyTarget: 10.0,
      colorHex: '#C6F52C',
      unit: 'hrs',
    ),
  );
  final weeklyStudyStr = '${studyProgress.currentWeekTotal} / ${studyProgress.weeklyTarget} hours';

  final taskTitles = topTasks.take(3).map((t) => t.title).toList();

  final gemini = ref.read(geminiApiProvider);
  if (!gemini.isConfigured) {
    return "Welcome back! Start today with purpose. Make every hour count towards your long-term goals.";
  }

  try {
    final brief = await gemini.generateMorningBriefing(
      daysRemaining: daysRemaining,
      independenceLabel: settings.independenceLabel,
      topTasks: taskTitles,
      yesterdayScreenTime: screenTimeStr,
      weeklyStudyHours: weeklyStudyStr,
      overdueTaskCount: overdueCount,
    );
    return brief;
  } catch (e) {
    debugPrint('Error generating morning brief: $e');
    return "Welcome back! Prioritize your top focus tasks, minimize distractions, and stay disciplined today.";
  }
});

class MorningBriefScreen extends ConsumerWidget {
  const MorningBriefScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final daysRemainingAsync = ref.watch(daysRemainingProvider);
    final topTasksAsync = ref.watch(topTasksProvider);

    final settings = settingsAsync.valueOrNull;
    final name = settings?.userName ?? 'STUDENT';

    return Scaffold(
      backgroundColor: AnchorTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, name),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  children: [
                    // Countdown Card
                    FadeSlideIn(
                      delaySeconds: 0.05,
                      child: _CountdownCard(
                        daysRemaining: daysRemainingAsync.valueOrNull,
                        label: settings?.independenceLabel ?? 'Target Date',
                      ),
                    ),
                    const SizedBox(height: AnchorTheme.stackGap),

                    // Tasks Card
                    FadeSlideIn(
                      delaySeconds: 0.1,
                      child: _TasksCard(
                        tasks: topTasksAsync.valueOrNull ?? [],
                      ),
                    ),
                    const SizedBox(height: AnchorTheme.stackGap),

                    // AI Coach Card
                    FadeSlideIn(
                      delaySeconds: 0.15,
                      child: const _AICoachCard(),
                    ),
                    const SizedBox(height: AnchorTheme.stackGap),

                    // Weather & Check-In Row
                    FadeSlideIn(
                      delaySeconds: 0.2,
                      child: Row(
                        children: [
                          Expanded(child: const _WeatherCard()),
                          const SizedBox(width: 16),
                          Expanded(child: const _CheckInCard()),
                        ],
                      ),
                    ),
                    const SizedBox(height: AnchorTheme.stackGap),

                    // Daily Intention Block
                    FadeSlideIn(
                      delaySeconds: 0.25,
                      child: const _IntentionCard(),
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

  Widget _buildHeader(BuildContext context, String name) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMM').format(now);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        color: AnchorTheme.background,
        border: Border(
          bottom: BorderSide(color: Color(0xFF252525), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateStr.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AnchorTheme.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Good morning, $name 👋',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              _buildHeaderIndicator('ONLINE'),
              const SizedBox(height: 6),
              _buildHeaderIndicator('TODOIST'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIndicator(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AnchorTheme.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: AnchorTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final int? daysRemaining;
  final String label;

  const _CountdownCard({this.daysRemaining, required this.label});

  @override
  Widget build(BuildContext context) {
    final days = daysRemaining ?? 0;
    final progress = days > 0 ? (1.0 - (days / 365.0).clamp(0.0, 1.0)) : 0.0;
    final currentDay = (365 - days).clamp(1, 365);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AnchorTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AnchorTheme.cardBorder, width: 1),
        gradient: LinearGradient(
          colors: [
            AnchorTheme.accent.withOpacity(0.04),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  daysRemaining != null ? '$days' : '—',
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2.0,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'DAYS REMAINING',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AnchorTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AnchorTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 96,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 96 * progress,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AnchorTheme.accent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Day $currentDay of 365',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AnchorTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 3,
                        backgroundColor: const Color(0xFF2A2A2A),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AnchorTheme.accent,
                        ),
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TasksCard extends StatelessWidget {
  final List<Task> tasks;

  const _TasksCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
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
            children: [
              Text(
                "Today's Focus",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${tasks.length}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AnchorTheme.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No active tasks — enjoy the breathing room.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AnchorTheme.textMuted,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (context, index) => Container(
                height: 1,
                color: const Color(0xFF252525),
                margin: const EdgeInsets.symmetric(vertical: 16),
              ),
              itemBuilder: (context, index) {
                return _MiniTask(task: tasks[index]);
              },
            ),
        ],
      ),
    );
  }
}

class _MiniTask extends StatelessWidget {
  final Task task;

  const _MiniTask({required this.task});

  @override
  Widget build(BuildContext context) {
    Color dotColor = AnchorTheme.textMuted;
    List<BoxShadow>? dotShadow;

    if (task.isOverdue) {
      dotColor = AnchorTheme.statusRed;
      dotShadow = [
        BoxShadow(
          color: AnchorTheme.statusRed.withOpacity(0.4),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else if (task.priority == 1) {
      dotColor = AnchorTheme.statusRed;
    } else if (task.priority == 2) {
      dotColor = AnchorTheme.statusOrange;
    } else if (task.priority == 3) {
      dotColor = AnchorTheme.statusBlue;
    } else {
      dotColor = AnchorTheme.accent;
    }

    final hasDescription = task.description != null && task.description!.trim().isNotEmpty;
    final hasDueDate = task.dueDate != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 6, right: 12),
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: dotShadow,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (task.isOverdue) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AnchorTheme.statusRed.withOpacity(0.1),
                        border: Border.all(
                          color: AnchorTheme.statusRed.withOpacity(0.2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'OVERDUE',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AnchorTheme.statusRed,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (hasDescription) ...[
                const SizedBox(height: 4),
                Text(
                  task.description!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AnchorTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (hasDueDate) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AnchorTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AnchorTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        task.isDueToday
                            ? 'Today'
                            : DateFormat('MMM d').format(task.dueDate!),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AnchorTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AICoachCard extends ConsumerWidget {
  const _AICoachCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final briefingAsync = ref.watch(morningBriefingProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AnchorTheme.cardBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 20,
            color: AnchorTheme.accent,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                briefingAsync.when(
                  data: (text) => Text(
                    text != null ? '"$text"' : '"No briefing generated. Stay focused today."',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AnchorTheme.accent),
                    ),
                  ),
                  error: (e, s) => Text(
                    '"Focus on your top focus tasks and maintain your streak today."',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '— ANCHOR AI',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AnchorTheme.textSecondary,
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

class _WeatherCard extends ConsumerWidget {
  const _WeatherCard();

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code <= 3) return Icons.cloud_queue_rounded;
    if (code <= 48) return Icons.filter_drama_rounded;
    if (code <= 67) return Icons.umbrella_rounded;
    if (code <= 77) return Icons.ac_unit_rounded;
    if (code <= 82) return Icons.thunderstorm_rounded;
    if (code <= 86) return Icons.ac_unit_rounded;
    if (code <= 99) return Icons.thunderstorm_rounded;
    return Icons.wb_cloudy_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final city = settingsAsync.valueOrNull?.weatherCity ?? 'Ludhiana';

    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AnchorTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AnchorTheme.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            weatherAsync.when(
              data: (data) => Icon(
                data != null ? _getWeatherIcon(data.weatherCode) : Icons.wb_sunny_rounded,
                size: 28,
                color: AnchorTheme.accent,
              ),
              loading: () => const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AnchorTheme.accent),
                ),
              ),
              error: (e, s) => const Icon(
                Icons.wb_sunny_rounded,
                size: 28,
                color: AnchorTheme.accent,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                weatherAsync.when(
                  data: (data) => Text(
                    data != null ? '${data.temperature.toStringAsFixed(0)}°' : '33°',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  loading: () => Text(
                    '33°',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  error: (e, s) => Text(
                    '33°',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  city.isNotEmpty ? city : 'Ludhiana',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AnchorTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                weatherAsync.when(
                  data: (data) => Text(
                    data != null ? data.description.toUpperCase() : 'PARTLY CLOUDY',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AnchorTheme.textMuted,
                    ),
                  ),
                  loading: () => Text(
                    'PARTLY CLOUDY',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AnchorTheme.textMuted,
                    ),
                  ),
                  error: (e, s) => Text(
                    'PARTLY CLOUDY',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AnchorTheme.textMuted,
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
}

class _CheckInCard extends ConsumerStatefulWidget {
  const _CheckInCard();

  @override
  ConsumerState<_CheckInCard> createState() => _CheckInCardState();
}

class _CheckInCardState extends ConsumerState<_CheckInCard> {
  int? _sleep;
  int? _energy;
  int? _focus;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final e = await ref.read(journalDaoProvider).getTodayEntry();
    if (e != null && mounted) {
      setState(() {
        _sleep = e.sleepRating;
        _energy = e.energyRating;
        _focus = e.focusRating;
      });
    }
  }

  Future<void> _save(String type, int val) async {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    final existing = await ref.read(journalDaoProvider).getTodayEntry();

    int? s = _sleep;
    int? en = _energy;
    int? f = _focus;

    switch (type) {
      case 'SLEEP':
        s = val;
      case 'ENERGY':
        en = val;
      case 'FOCUS':
        f = val;
    }

    await ref.read(journalDaoProvider).upsertEntry(
          JournalEntriesCompanion(
            id: Value(existing?.id ?? 'journal_${today.millisecondsSinceEpoch}'),
            date: Value(dateOnly),
            sleepRating: Value(s),
            energyRating: Value(en),
            focusRating: Value(f),
          ),
        );

    if (mounted) {
      setState(() {
        _sleep = s;
        _energy = en;
        _focus = f;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AnchorTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AnchorTheme.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CHECK-IN',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AnchorTheme.textMuted,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DotCheckInRow(
                  label: 'Sleep',
                  max: 5,
                  selectedValue: _sleep,
                  onSelected: (v) => _save('SLEEP', v),
                ),
                const SizedBox(height: 10),
                _DotCheckInRow(
                  label: 'Energy',
                  max: 5,
                  selectedValue: _energy,
                  onSelected: (v) => _save('ENERGY', v),
                ),
                const SizedBox(height: 10),
                _DotCheckInRow(
                  label: 'Focus',
                  max: 5,
                  selectedValue: _focus,
                  onSelected: (v) => _save('FOCUS', v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DotCheckInRow extends StatelessWidget {
  final String label;
  final int max;
  final int? selectedValue;
  final ValueChanged<int>? onSelected;

  const _DotCheckInRow({
    required this.label,
    required this.max,
    this.selectedValue,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AnchorTheme.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(max, (i) {
            final v = i + 1;
            final active = (selectedValue ?? 0) >= v;
            return GestureDetector(
              onTap: onSelected != null ? () => onSelected!(v) : null,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AnchorTheme.accent : Colors.transparent,
                  border: Border.all(
                    color: active ? AnchorTheme.accent : const Color(0xFF444444),
                    width: 1,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _IntentionCard extends ConsumerStatefulWidget {
  const _IntentionCard();

  @override
  ConsumerState<_IntentionCard> createState() => _IntentionCardState();
}

class _IntentionCardState extends ConsumerState<_IntentionCard> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  String _lastSavedText = '';

  @override
  void initState() {
    super.initState();
    _load();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final e = await ref.read(journalDaoProvider).getTodayEntry();
    if (e?.dailyIntention != null && mounted) {
      _ctrl.text = e!.dailyIntention!;
      _lastSavedText = e.dailyIntention!;
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _save();
    }
  }

  Future<void> _save() async {
    final text = _ctrl.text.trim();
    if (text == _lastSavedText) return;

    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);
    final existing = await ref.read(journalDaoProvider).getTodayEntry();

    await ref.read(journalDaoProvider).upsertEntry(
          JournalEntriesCompanion(
            id: Value(existing?.id ?? 'journal_${today.millisecondsSinceEpoch}'),
            date: Value(dateOnly),
            dailyIntention: Value(text),
          ),
        );

    _lastSavedText = text;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text.isEmpty ? 'Intention cleared' : 'Intention saved',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AnchorTheme.onAccent,
            ),
          ),
          backgroundColor: AnchorTheme.accent,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: Border(
          top: BorderSide(color: Color(0xFF252525), width: 1),
          right: BorderSide(color: Color(0xFF252525), width: 1),
          bottom: BorderSide(color: Color(0xFF252525), width: 1),
          left: BorderSide(color: AnchorTheme.accent, width: 3),
        ),
      ),
      child: TextField(
        controller: _ctrl,
        focusNode: _focusNode,
        onSubmitted: (_) => _save(),
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: "Set today's intention...",
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF666666),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        maxLines: 1,
        textInputAction: TextInputAction.done,
      ),
    );
  }
}

