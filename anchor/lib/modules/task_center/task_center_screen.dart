import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/constants/app_colors.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../core/utils/date_extensions.dart';
import '../../core/utils/task_extensions.dart';
import '../../data/local/database.dart';
import '../../providers/task_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/api_provider.dart';

/// Task Center — clean white professional design.
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

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Text(
                    'Tasks',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  _FilterDropdown(
                    value: _filterLabel,
                    onChanged: (value) {
                      if (value != null) setState(() => _filterLabel = value);
                    },
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    'Add Task',
                    () => _showAddTaskDialog(context),
                    icon: Icons.add,
                    height: 44,
                  ),
                ],
              ),
            ),
            // ── Stats row ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: StatPill(
                      label: 'Overdue',
                      count: overdueAsync.valueOrNull?.length ?? 0,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatPill(
                      label: 'Due Today',
                      count: todayAsync.valueOrNull?.length ?? 0,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatPill(
                      label: 'Upcoming',
                      count: (activeTasksAsync.valueOrNull?.length ?? 0) -
                          (todayAsync.valueOrNull?.length ?? 0),
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Tab bar ──
            _TaskTabBar(controller: _tabController),
            // ── Tab content (Expanded so ListView inside can scroll) ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TaskList(
                    tasksAsync: activeTasksAsync,
                    emptyMessage: 'No active tasks yet. Add your first task.',
                    onComplete: (task) => _completeTask(task),
                  ),
                  _TaskList(
                    tasksAsync: todayAsync,
                    emptyMessage: 'Nothing due today. Enjoy the breathing room.',
                    onComplete: (task) => _completeTask(task),
                  ),
                  _CompletedTasksList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: AppColors.primary,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _completeTask(Task task) async {
    if (task.todoistId != null) {
      await ref.read(todoistApiProvider).closeTask(task.todoistId!);
    }

    await ref.read(taskDaoProvider).completeTask(task.id);

    ref.invalidate(activeTasksProvider);
    ref.invalidate(overdueTasksProvider);
    ref.invalidate(tasksDueTodayProvider);
    ref.invalidate(topTasksProvider);

    if (mounted) {
      _showSnackBar('Task completed');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.textPrimary,
        duration: const Duration(seconds: 1),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddTaskDialog(),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Filter Dropdown
// ──────────────────────────────────────────────────────────────

class _FilterDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textMuted, size: 18),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          items: ['All', 'Academic', 'Personal', 'Project', 'Habit', 'Placement']
              .map((label) => DropdownMenuItem(
                    value: label,
                    child: Text(label),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Tab Bar
// ──────────────────────────────────────────────────────────────

class _TaskTabBar extends StatelessWidget {
  final TabController controller;

  const _TaskTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Active'),
          Tab(text: 'Today'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Task List
// ──────────────────────────────────────────────────────────────

class _TaskList extends StatelessWidget {
  final AsyncValue<List<Task>> tasksAsync;
  final String emptyMessage;
  final void Function(Task) onComplete;

  const _TaskList({
    required this.tasksAsync,
    required this.emptyMessage,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _TaskItem(
              task: task,
              onComplete: () => onComplete(task),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
      error: (_, __) => Center(
        child: Text(
          'Error loading tasks',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Task Item (CleanCard)
// ──────────────────────────────────────────────────────────────

class _TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;

  const _TaskItem({
    required this.task,
    required this.onComplete,
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
        final days = task.dueDate!.difference(DateTime.now()).inDays;
        dueText = days == 1 ? 'Tomorrow' : 'In $days days';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CleanCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ── Completion checkbox ──
            InkWell(
              onTap: onComplete,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(
                    color: priorityColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: priorityColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // ── Task content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (task.description != null && task.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        task.description!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (task.label != null)
                        _TagChip(
                          label: task.label!,
                          color: AppColors.primary,
                        ),
                      if (dueText != null)
                        _TagChip(
                          label: dueText,
                          color: task.isOverdue ? AppColors.error : AppColors.textSecondary,
                        ),
                      _TagChip(
                        label: task.priorityLabel,
                        color: priorityColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Actions ──
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _IconButton(
                  icon: Icons.center_focus_strong,
                  color: AppColors.info,
                  tooltip: 'Focus Mode',
                  onPressed: () => context.push('/focus'),
                ),
                _IconButton(
                  icon: Icons.more_vert,
                  color: AppColors.textMuted,
                  tooltip: 'More',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.info;
      default:
        return AppColors.textMuted;
    }
  }
}

// ──────────────────────────────────────────────────────────────
// Tag Chip
// ──────────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Icon Button
// ──────────────────────────────────────────────────────────────

class _IconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _IconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Completed Tasks List
// ──────────────────────────────────────────────────────────────

class _CompletedTasksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Completed tasks will appear here.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Add Task Dialog
// ──────────────────────────────────────────────────────────────

class _AddTaskDialog extends ConsumerStatefulWidget {
  const _AddTaskDialog();

  @override
  ConsumerState<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<_AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueDate;
  int _priority = 4;
  String _label = 'Academic';
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dialog header ──
              SectionHeader(
                label: 'Add New Task',
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              // ── Title field ──
              _CleanTextField(
                controller: _titleController,
                hintText: 'Task title',
              ),
              const SizedBox(height: 16),
              // ── Description field ──
              _CleanTextField(
                controller: _descriptionController,
                hintText: 'Description (optional)',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // ── Priority & Label row ──
              Row(
                children: [
                  Expanded(
                    child: _CleanDropdown<int>(
                      value: _priority,
                      label: 'Priority',
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('High')),
                        DropdownMenuItem(value: 2, child: Text('Medium')),
                        DropdownMenuItem(value: 3, child: Text('Low')),
                        DropdownMenuItem(value: 4, child: Text('Normal')),
                      ],
                      onChanged: (v) => setState(() => _priority = v ?? 4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CleanDropdown<String>(
                      value: _label,
                      label: 'Label',
                      items: ['Academic', 'Personal', 'Project', 'Habit', 'Placement']
                          .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (v) => setState(() => _label = v ?? 'Academic'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ── Due date picker ──
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primary,
                          surface: AppColors.card,
                          onSurface: AppColors.textPrimary,
                        ),
                        dialogTheme: const DialogThemeData(
                          backgroundColor: AppColors.card,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (date != null) setState(() => _dueDate = date);
                },
                child: _CleanFieldContainer(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Due Date',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _dueDate?.toIsoDate ?? 'Select date',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _dueDate != null
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
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
              const SizedBox(height: 28),
              // ── Actions ──
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      'Cancel',
                      _isSaving ? null : () => Navigator.pop(context),
                      height: 48,
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      'Add',
                      _isSaving ? null : _saveTask,
                      height: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),
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

    final taskId = 'local_${DateTime.now().millisecondsSinceEpoch}';
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
    ref.invalidate(topTasksProvider);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.textPrimary,
          duration: const Duration(seconds: 1),
          content: Text(
            'Task added',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.error,
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// ──────────────────────────────────────────────────────────────
// Clean Text Field
// ──────────────────────────────────────────────────────────────

class _CleanTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? maxLines;

  const _CleanTextField({
    required this.controller,
    required this.hintText,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return _CleanFieldContainer(
      child: TextField(
        controller: controller,
        maxLines: maxLines ?? 1,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Clean Dropdown
// ──────────────────────────────────────────────────────────────

class _CleanDropdown<T> extends StatelessWidget {
  final T value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _CleanDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _CleanFieldContainer(
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<T>(
          value: value,
          dropdownColor: AppColors.card,
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textMuted, size: 18),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Clean Field Container (shared wrapper)
// ──────────────────────────────────────────────────────────────

class _CleanFieldContainer extends StatelessWidget {
  final Widget child;

  const _CleanFieldContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
