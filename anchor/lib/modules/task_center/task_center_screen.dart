import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design/anchor_theme.dart';
import '../../core/utils/date_extensions.dart';
import '../../core/utils/task_extensions.dart';
import '../../data/local/database.dart';
import '../../providers/task_provider.dart';
import '../../providers/api_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/sync_provider.dart';
import '../../data/remote/sync_service.dart';
import '../../core/widgets/anchor_background.dart';
import '../../core/responsive/responsive_content_layout.dart';

// ─── Custom Bouncing Gesture Wrapper ───────────────────────────────────────
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const BouncingButton({super.key, required this.child, this.onTap});

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Task Center — matches Stitch screen "Task Center" exactly.
/// All tasks in one place with Todoist sync.
class TaskCenterScreen extends ConsumerStatefulWidget {
  const TaskCenterScreen({super.key});

  @override
  ConsumerState<TaskCenterScreen> createState() => _TaskCenterScreenState();
}

class _TaskCenterScreenState extends ConsumerState<TaskCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterLabel = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTasksAsync = ref.watch(activeTasksProvider);
    final overdueAsync = ref.watch(overdueTasksProvider);
    final todayAsync = ref.watch(tasksDueTodayProvider);
    final completedTasksAsync = ref.watch(completedTasksProvider);

    final overdueCount = overdueAsync.valueOrNull?.length ?? 0;
    final todayCount = todayAsync.valueOrNull?.length ?? 0;
    final activeCount = activeTasksAsync.valueOrNull?.length ?? 0;
    final upcomingCount = activeCount - todayCount;

    final mobileBody = Scaffold(
      backgroundColor: AnchorTheme.backgroundDeep,
      body: AnchorBackground(
        child: _buildContent(
          context,
          activeTasksAsync,
          overdueAsync,
          todayAsync,
          completedTasksAsync,
          overdueCount,
          todayCount,
          upcomingCount,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, curve: Curves.easeOut);

    return ResponsiveContentLayout(
      mobileBody: mobileBody,
      desktopBody: _buildContent(
        context,
        activeTasksAsync,
        overdueAsync,
        todayAsync,
        completedTasksAsync,
        overdueCount,
        todayCount,
        upcomingCount,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AsyncValue<List<Task>> activeTasksAsync,
    AsyncValue<List<Task>> overdueAsync,
    AsyncValue<List<Task>> todayAsync,
    AsyncValue<List<Task>> completedTasksAsync,
    int overdueCount,
    int todayCount,
    int upcomingCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main scrollable canvas containing bento statistics and list
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // ── Stats row ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatPill(
                        label: 'Overdue',
                        count: overdueCount,
                        bgColor: AnchorTheme.statusRed.withOpacity(0.15),
                        borderColor: AnchorTheme.statusRed.withOpacity(0.3),
                        textColor: AnchorTheme.statusRed,
                        hasDot: true,
                      ),
                      const SizedBox(width: 8),
                      _buildStatPill(
                        label: 'Due Today',
                        count: todayCount,
                        bgColor: AnchorTheme.accentContainer.withOpacity(0.15),
                        borderColor: AnchorTheme.accentContainer.withOpacity(0.3),
                        textColor: AnchorTheme.accent,
                        hasDot: true,
                      ),
                      const SizedBox(width: 8),
                      _buildStatPill(
                        label: 'Upcoming',
                        count: upcomingCount >= 0 ? upcomingCount : 0,
                        bgColor: AnchorTheme.surfaceContainerHigh,
                        borderColor: AnchorTheme.surfaceVariant,
                        textColor: AnchorTheme.textSecondary,
                        hasDot: false,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Filter + Add Row ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (val) => setState(() => _filterLabel = val),
                      color: AnchorTheme.cardBgHigh,
                      borderRadius: BorderRadius.circular(12),
                      itemBuilder: (context) => ['All', 'Academic', 'Personal', 'Project', 'Habit', 'Placement']
                          .map((l) => PopupMenuItem(
                                value: l,
                                child: Text(
                                  l,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AnchorTheme.textPrimary,
                                  ),
                                ),
                              ))
                          .toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AnchorTheme.surfaceContainerHigh,
                          border: Border.all(color: AnchorTheme.surfaceVariant, width: 1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _filterLabel,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AnchorTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 16,
                              color: AnchorTheme.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    BouncingButton(
                      onTap: () => _showAddTaskBottomSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AnchorTheme.accentContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 16,
                              color: AnchorTheme.onAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Add Task',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AnchorTheme.onAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Tab Bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AnchorTheme.surfaceVariant, width: 1),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(color: AnchorTheme.accent, width: 2),
                    ),
                    labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal),
                    labelColor: AnchorTheme.textPrimary,
                    unselectedLabelColor: AnchorTheme.textMuted,
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(text: 'Active'),
                      Tab(text: 'Today'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ),
              ),

              // ── Tab Content ──
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _TaskList(
                      tasksAsync: activeTasksAsync,
                      emptyMessage: 'No active tasks yet. Add your first task.',
                      filterLabel: _filterLabel,
                      onAction: (task) => _completeTask(task),
                    ),
                    _TaskList(
                      tasksAsync: todayAsync,
                      emptyMessage: 'Nothing due today. Enjoy the breathing room.',
                      filterLabel: _filterLabel,
                      onAction: (task) => _completeTask(task),
                    ),
                    _TaskList(
                      tasksAsync: completedTasksAsync,
                      emptyMessage: 'Completed tasks will appear here.',
                      filterLabel: _filterLabel,
                      onAction: (task) => _reopenTask(task),
                      isCompletedList: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatPill({
    required String label,
    required int count,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required bool hasDot,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            '$count $label'.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _completeTask(Task task) async {
    if (task.todoistId != null) {
      try {
        await ref.read(todoistApiProvider).closeTask(task.todoistId!);
      } catch (_) {}
    }
    await ref.read(taskDaoProvider).completeTask(task.id);

    ref.invalidate(activeTasksProvider);
    ref.invalidate(overdueTasksProvider);
    ref.invalidate(tasksDueTodayProvider);
    ref.invalidate(completedTasksProvider);
    ref.invalidate(topTasksProvider);

    ref.read(syncServiceProvider).syncTasks().then((_) {
      ref.invalidate(activeTasksProvider);
      ref.invalidate(overdueTasksProvider);
      ref.invalidate(tasksDueTodayProvider);
      ref.invalidate(completedTasksProvider);
      ref.invalidate(topTasksProvider);
    });

    _showSnackBar('Task completed');
  }

  void _reopenTask(Task task) async {
    if (task.todoistId != null) {
      try {
        await ref.read(todoistApiProvider).reopenTask(task.todoistId!);
      } catch (_) {}
    }
    await ref.read(taskDaoProvider).reopenTask(task.id);

    ref.invalidate(activeTasksProvider);
    ref.invalidate(overdueTasksProvider);
    ref.invalidate(tasksDueTodayProvider);
    ref.invalidate(completedTasksProvider);
    ref.invalidate(topTasksProvider);

    ref.read(syncServiceProvider).syncTasks().then((_) {
      ref.invalidate(activeTasksProvider);
      ref.invalidate(overdueTasksProvider);
      ref.invalidate(tasksDueTodayProvider);
      ref.invalidate(completedTasksProvider);
      ref.invalidate(topTasksProvider);
    });

    _showSnackBar('Task reopened');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AnchorTheme.cardBgHigh,
        duration: const Duration(seconds: 1),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AnchorTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskBottomSheet(),
    );
  }
}

// ─── Task List View ────────────────────────────────────────────────────────
class _TaskList extends ConsumerWidget {
  final AsyncValue<List<Task>> tasksAsync;
  final String emptyMessage;
  final String filterLabel;
  final void Function(Task) onAction;
  final bool isCompletedList;

  const _TaskList({
    required this.tasksAsync,
    required this.emptyMessage,
    required this.filterLabel,
    required this.onAction,
    this.isCompletedList = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onRefresh() async {
      ref.read(syncStatusProvider.notifier).state = SyncStatus.syncing;
      try {
        final result = await ref.read(syncServiceProvider).syncTasks();
        ref.read(lastSyncResultProvider.notifier).state = result;
        ref.read(syncStatusProvider.notifier).state = SyncStatus.success;
        ref.read(lastSyncTimeProvider.notifier).state = DateTime.now();

        ref.invalidate(activeTasksProvider);
        ref.invalidate(overdueTasksProvider);
        ref.invalidate(tasksDueTodayProvider);
        ref.invalidate(completedTasksProvider);
        ref.invalidate(topTasksProvider);

        if (context.mounted) {
          final msg = result.hasErrors
              ? 'Sync completed with errors: ${result.errors.first}'
              : 'Sync successful: ${result.tasksAdded} added, ${result.tasksPushed} pushed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AnchorTheme.cardBgHigh,
              duration: const Duration(seconds: 2),
              content: Text(
                msg,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AnchorTheme.textPrimary,
                ),
              ),
            ),
          );
        }
      } catch (e) {
        ref.read(syncStatusProvider.notifier).state = SyncStatus.error;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AnchorTheme.statusRed,
              content: Text(
                'Sync failed: $e',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
      }
    }

    return tasksAsync.when(
      data: (tasks) {
        final filteredTasks = filterLabel == 'All'
            ? tasks
            : tasks.where((t) => t.label?.toLowerCase() == filterLabel.toLowerCase()).toList();

        if (filteredTasks.isEmpty) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            color: AnchorTheme.accent,
            backgroundColor: AnchorTheme.cardBgHigh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inbox_outlined, size: 48, color: AnchorTheme.textMuted),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              emptyMessage,
                              style: GoogleFonts.inter(fontSize: 14, color: AnchorTheme.textMuted),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ).animate().fadeIn(duration: 200.ms);
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          color: AnchorTheme.accent,
          backgroundColor: AnchorTheme.cardBgHigh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20).copyWith(bottom: 100),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return Dismissible(
                key: ValueKey(task.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(
                    color: AnchorTheme.statusRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AnchorTheme.radiusCard),
                    border: Border.all(color: AnchorTheme.statusRed.withOpacity(0.5), width: 1),
                  ),
                  child: const Icon(Icons.delete_outline, color: AnchorTheme.statusRed),
                ),
                onDismissed: (_) async {
                  if (task.todoistId != null) {
                    try {
                      await ref.read(todoistApiProvider).deleteTask(task.todoistId!);
                    } catch (_) {}
                  }
                  await ref.read(taskDaoProvider).deleteTask(task.id);
                  ref.invalidate(activeTasksProvider);
                  ref.invalidate(overdueTasksProvider);
                  ref.invalidate(tasksDueTodayProvider);
                  ref.invalidate(completedTasksProvider);
                  ref.invalidate(topTasksProvider);

                  ref.read(syncServiceProvider).syncTasks().then((_) {
                    ref.invalidate(activeTasksProvider);
                    ref.invalidate(overdueTasksProvider);
                    ref.invalidate(tasksDueTodayProvider);
                    ref.invalidate(completedTasksProvider);
                    ref.invalidate(topTasksProvider);
                  });
                },
                child: BouncingButton(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AddTaskBottomSheet(taskToEdit: task),
                    );
                  },
                  child: _TaskItem(
                    task: task,
                    onAction: () => onAction(task),
                    isCompleted: isCompletedList,
                  ),
                ),
              ).animate(delay: (index * 80).ms)
               .fadeIn(duration: 300.ms)
               .slideY(begin: 0.08, end: 0, duration: 300.ms, curve: Curves.easeOut);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AnchorTheme.accent)),
      error: (_, __) => Center(
        child: Text(
          'Error loading tasks',
          style: GoogleFonts.inter(fontSize: 14, color: AnchorTheme.statusRed),
        ),
      ),
    );
  }
}

// ─── Task Item Card ───────────────────────────────────────────────────────
class _TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onAction;
  final bool isCompleted;

  const _TaskItem({
    required this.task,
    required this.onAction,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(task.priority);

    String? dueText;
    if (task.dueDate != null) {
      if (task.isOverdue) {
        dueText = 'Overdue';
      } else if (task.isDueToday) {
        dueText = 'Today';
      } else {
        final days = task.dueDate!.difference(DateTime.now()).inDays + 1;
        if (days == 1) {
          dueText = 'Tomorrow';
        } else {
          dueText = task.dueDate!.toIsoDate;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnchorTheme.cardBg,
        border: Border.all(color: AnchorTheme.cardBorder, width: 1),
        borderRadius: BorderRadius.circular(AnchorTheme.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom checkbox (border circle)
          GestureDetector(
            onTap: onAction,
            child: Container(
              margin: const EdgeInsets.only(top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? priorityColor.withOpacity(0.2) : Colors.transparent,
                border: Border.all(color: priorityColor, width: 2),
              ),
              child: isCompleted
                  ? Center(
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: priorityColor,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          // Task content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AnchorTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (task.label != null) _buildCategoryChip(task.label!),
                    if (dueText != null) _buildDueDateChip(task, dueText),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(int priority) {
    switch (priority) {
      case 1: return const Color(0xFFFFB4AB);
      case 2: return const Color(0xFFFFD2AB);
      case 3: return const Color(0xFFBFE9FE);
      default: return const Color(0xFFC8C6C5);
    }
  }

  Widget _buildCategoryChip(String category) {
    IconData icon;
    Color textColor;
    Color bgColor;
    Color borderColor;

    switch (category.toLowerCase()) {
      case 'academic':
        icon = Icons.school_outlined;
        textColor = const Color(0xFFB088F9);
        bgColor = const Color(0xFF2A1B3D);
        borderColor = const Color(0xFF402A5C);
        break;
      case 'personal':
        icon = Icons.person_outline;
        textColor = const Color(0xFF5EEAD4);
        bgColor = const Color(0xFF1A3A3A);
        borderColor = const Color(0xFF2A5A5A);
        break;
      case 'project':
        icon = Icons.work_outline;
        textColor = const Color(0xFF60A5FA);
        bgColor = const Color(0xFF1A263A);
        borderColor = const Color(0xFF2A3D5A);
        break;
      case 'habit':
        icon = Icons.star_outline;
        textColor = const Color(0xFF34D399);
        bgColor = const Color(0xFF1E352F);
        borderColor = const Color(0xFF2E4F44);
        break;
      case 'placement':
        icon = Icons.trending_up;
        textColor = const Color(0xFFFB923C);
        bgColor = const Color(0xFF3B2C1E);
        borderColor = const Color(0xFF5B422E);
        break;
      default:
        icon = Icons.label_outline;
        textColor = AnchorTheme.textSecondary;
        bgColor = AnchorTheme.surfaceContainerHigh;
        borderColor = AnchorTheme.surfaceVariant;
    }

    return _TagChip(
      label: category,
      icon: icon,
      textColor: textColor,
      bgColor: bgColor,
      borderColor: borderColor,
    );
  }

  Widget _buildDueDateChip(Task task, String dueText) {
    final isAlert = task.isOverdue || task.isDueToday;
    final textColor = isAlert ? const Color(0xFFFFB4AB) : AnchorTheme.textSecondary;
    final bgColor = isAlert ? const Color(0xFFFFB4AB).withOpacity(0.15) : AnchorTheme.surfaceContainerHigh;
    final borderColor = isAlert ? const Color(0xFFFFB4AB).withOpacity(0.3) : AnchorTheme.surfaceVariant;

    return _TagChip(
      label: dueText,
      icon: Icons.calendar_today_outlined,
      textColor: textColor,
      bgColor: bgColor,
      borderColor: borderColor,
    );
  }
}

// ─── Styled Tag Chip Component ─────────────────────────────────────────────
class _TagChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  const _TagChip({
    required this.label,
    this.icon,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AnchorTheme.radiusTag),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Task Bottom Sheet Modal ──────────────────────────────────────────
class AddTaskBottomSheet extends ConsumerStatefulWidget {
  final Task? taskToEdit;
  const AddTaskBottomSheet({this.taskToEdit});

  @override
  ConsumerState<AddTaskBottomSheet> createState() => AddTaskBottomSheetState();
}

class AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  int _priority = 4;
  String _label = 'Academic';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descriptionController.text = widget.taskToEdit!.description ?? '';
      _dueDate = widget.taskToEdit!.dueDate;
      _priority = widget.taskToEdit!.priority;
      _label = widget.taskToEdit!.label ?? 'Academic';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    // Extra padding so the floating nav bar doesn't cover the save button
    final navPadding = bottomInset > 0 ? 16.0 : (80.0 + safeBottom);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF252525), width: 1)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset + navPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: AnchorTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.taskToEdit == null ? 'New Task' : 'Edit Task',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AnchorTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // Title input
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                border: Border.all(color: const Color(0xFF252525), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Task Title',
                  hintStyle: GoogleFonts.inter(fontSize: 15, color: AnchorTheme.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Description input
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                border: Border.all(color: const Color(0xFF252525), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                controller: _descriptionController,
                style: GoogleFonts.inter(fontSize: 14, color: AnchorTheme.textSecondary),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: AnchorTheme.textMuted),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Priority Row
            Row(
              children: [
                Text(
                  'Priority:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AnchorTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [1, 2, 3, 4].map((p) {
                    final isSelected = _priority == p;
                    Color pColor;
                    switch (p) {
                      case 1: pColor = const Color(0xFFFFB4AB); break;
                      case 2: pColor = const Color(0xFFFFD2AB); break;
                      case 3: pColor = const Color(0xFFBFE9FE); break;
                      default: pColor = const Color(0xFFC8C6C5);
                    }
                    return GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AnchorTheme.accent : pColor.withOpacity(0.4),
                            width: isSelected ? 2.5 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: pColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Labels & Date selector row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Label Selector Button
                  PopupMenuButton<String>(
                    onSelected: (val) => setState(() => _label = val),
                    itemBuilder: (context) => ['Academic', 'Personal', 'Project', 'Habit', 'Placement']
                        .map((l) => PopupMenuItem(value: l, child: Text(l)))
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A1B3D),
                        border: Border.all(color: const Color(0xFF402A5C), width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.school_outlined, size: 14, color: Color(0xFFB088F9)),
                          const SizedBox(width: 4),
                          Text(
                            _label.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB088F9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Due Date selector
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
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
                      if (date != null) setState(() => _dueDate = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AnchorTheme.surfaceContainerHigh,
                        border: Border.all(color: AnchorTheme.surfaceVariant, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: AnchorTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            _dueDate != null ? _dueDate!.toIsoDate.toUpperCase() : 'DUE DATE',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AnchorTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Save button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: BouncingButton(
                onTap: _isSaving ? null : _saveTask,
                child: Container(
                  decoration: BoxDecoration(
                    color: AnchorTheme.accentContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isSaving
                        ? const CircularProgressIndicator(color: AnchorTheme.onAccent)
                        : Text(
                            widget.taskToEdit == null ? 'Add Task' : 'Save Task',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AnchorTheme.onAccent,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showError('Task title is required');
      return;
    }
    setState(() => _isSaving = true);
    final isEditing = widget.taskToEdit != null;
    final todoistId = widget.taskToEdit?.todoistId;

    if (isEditing && todoistId != null) {
      try {
        await ref.read(todoistApiProvider).updateTask(
          todoistId: todoistId,
          title: title,
          description: _descriptionController.text.trim(),
          dueDate: _dueDate,
          priority: _priority,
        );
      } catch (_) {}
    }

    final taskId = widget.taskToEdit?.id ?? 'local_${DateTime.now().millisecondsSinceEpoch}';
    final task = TasksCompanion(
      id: Value(taskId),
      title: Value(title),
      description: _descriptionController.text.trim().isNotEmpty
          ? Value(_descriptionController.text.trim())
          : const Value.absent(),
      priority: Value(_priority),
      label: Value(_label),
      dueDate: _dueDate != null ? Value(_dueDate!) : const Value.absent(),
      source: const Value('local'),
    );
    await ref.read(taskDaoProvider).upsertTask(task);
    ref.invalidate(activeTasksProvider);
    ref.invalidate(overdueTasksProvider);
    ref.invalidate(tasksDueTodayProvider);
    ref.invalidate(completedTasksProvider);
    ref.invalidate(topTasksProvider);

    ref.read(syncServiceProvider).syncTasks().then((_) {
      ref.invalidate(activeTasksProvider);
      ref.invalidate(overdueTasksProvider);
      ref.invalidate(tasksDueTodayProvider);
      ref.invalidate(completedTasksProvider);
      ref.invalidate(topTasksProvider);
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AnchorTheme.textPrimary,
          duration: const Duration(seconds: 1),
          content: Text(
            isEditing ? 'Task updated' : 'Task added',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AnchorTheme.statusRed,
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
