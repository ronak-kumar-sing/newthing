import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/local/daos/journal_dao.dart';
import '../data/local/daos/progress_dao.dart';
import '../data/local/daos/screen_time_dao.dart';
import '../data/local/daos/settings_dao.dart';
import '../data/local/daos/task_dao.dart';
import '../data/local/daos/chat_dao.dart';
import '../data/local/daos/whatsapp_dao.dart';

/// Singleton database instance provider.
final databaseProvider = Provider<AnchorDatabase>((ref) {
  final db = AnchorDatabase();
  _seedDemoData(db);
  return db;
});

void _seedDemoData(AnchorDatabase db) async {
  try {
    // Check if dimensions are empty
    final existingDimensions = await db.select(db.progressDimensions).get();
    if (existingDimensions.isEmpty) {
      final studyId = 'dim_study_hours';
      final gymId = 'dim_gym_workouts';
      final leetcodeId = 'dim_leetcode';

      await db.into(db.progressDimensions).insert(ProgressDimension(
        id: studyId,
        name: 'Study Hours',
        weeklyTarget: 20.0,
        unit: 'hrs',
        isAutomatic: false,
        colorHex: '#C6F52C',
        sortOrder: 0,
        createdAt: DateTime.now(),
      ));

      await db.into(db.progressDimensions).insert(ProgressDimension(
        id: gymId,
        name: 'Gym Workouts',
        weeklyTarget: 4.0,
        unit: 'sessions',
        isAutomatic: false,
        colorHex: '#FFB4AB',
        sortOrder: 1,
        createdAt: DateTime.now(),
      ));

      await db.into(db.progressDimensions).insert(ProgressDimension(
        id: leetcodeId,
        name: 'LeetCode Problems',
        weeklyTarget: 10.0,
        unit: 'probs',
        isAutomatic: false,
        colorHex: '#BFE9FE',
        sortOrder: 2,
        createdAt: DateTime.now(),
      ));

      // Seed progress values for the last 14 days
      final now = DateTime.now();
      for (int i = 0; i < 14; i++) {
        final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        
        final studyVal = 1.5 + (i % 3) * 0.8;
        await db.into(db.progressValues).insert(ProgressValue(
          id: 'val_study_$i',
          dimensionId: studyId,
          date: date,
          value: studyVal,
        ));

        if (i % 2 == 0) {
          await db.into(db.progressValues).insert(ProgressValue(
            id: 'val_gym_$i',
            dimensionId: gymId,
            date: date,
            value: 1.0,
          ));
        }

        final leetVal = (i % 2 == 0) ? 2.0 : 1.0;
        await db.into(db.progressValues).insert(ProgressValue(
          id: 'val_leetcode_$i',
          dimensionId: leetcodeId,
          date: date,
          value: leetVal,
        ));
      }
    }

    // Check if Tasks are empty
    final existingTasks = await db.select(db.tasks).get();
    if (existingTasks.isEmpty) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      await db.into(db.tasks).insert(Task(
        id: 'task_overdue_1',
        title: 'Submit Placement Resume Draft',
        description: 'Draft section on internship and projects. Send to counselor.',
        priority: 1,
        label: 'Placement',
        dueDate: today.subtract(const Duration(days: 1)),
        isCompleted: false,
        createdAt: today.subtract(const Duration(days: 3)),
        source: 'local',
        isRecurring: false,
      ));

      await db.into(db.tasks).insert(Task(
        id: 'task_today_1',
        title: 'Finish Calculus Assignment 4',
        description: 'Problems 1-15 on page 42. Show all work.',
        priority: 1,
        label: 'Academic',
        dueDate: today.add(const Duration(hours: 23, minutes: 59)),
        isCompleted: false,
        createdAt: today.subtract(const Duration(days: 1)),
        source: 'local',
        isRecurring: false,
      ));

      await db.into(db.tasks).insert(Task(
        id: 'task_today_2',
        title: 'Read 10 pages of Atomic Habits',
        description: 'Build the habit loop.',
        priority: 3,
        label: 'Habit',
        dueDate: today.add(const Duration(hours: 22, minutes: 0)),
        isCompleted: false,
        createdAt: today.subtract(const Duration(days: 2)),
        source: 'local',
        isRecurring: false,
      ));

      await db.into(db.tasks).insert(Task(
        id: 'task_tomorrow_1',
        title: 'Review Physics Lab Notes',
        description: 'Prepare for tomorrow\'s lab session on thermodynamics.',
        priority: 2,
        label: 'Academic',
        dueDate: today.add(const Duration(days: 1)),
        isCompleted: false,
        createdAt: today,
        source: 'local',
        isRecurring: false,
      ));

      await db.into(db.tasks).insert(Task(
        id: 'task_upcoming_1',
        title: 'Buy Groceries',
        description: 'Milk, eggs, bread, coffee beans.',
        priority: 3,
        label: 'Personal',
        dueDate: today.add(const Duration(days: 2)),
        isCompleted: false,
        createdAt: today,
        source: 'local',
        isRecurring: false,
      ));

      await db.into(db.tasks).insert(Task(
        id: 'task_upcoming_2',
        title: 'React Course Video 12-15',
        description: 'Watch hooks section and practice code.',
        priority: 4,
        label: 'Project',
        dueDate: today.add(const Duration(days: 4)),
        isCompleted: false,
        createdAt: today,
        source: 'local',
        isRecurring: false,
      ));

      await db.into(db.tasks).insert(Task(
        id: 'task_comp_1',
        title: 'Submit Chemistry Lab Report 2',
        description: 'Printed and signed copy.',
        priority: 3,
        label: 'Academic',
        dueDate: today.subtract(const Duration(days: 2)),
        isCompleted: true,
        completedAt: today.subtract(const Duration(days: 2)),
        createdAt: today.subtract(const Duration(days: 5)),
        source: 'local',
        isRecurring: false,
      ));

      await db.into(db.tasks).insert(Task(
        id: 'task_comp_2',
        title: 'Setup Discord OS Bot',
        description: 'Heroku config and keys setup.',
        priority: 4,
        label: 'Project',
        dueDate: today.subtract(const Duration(days: 1)),
        isCompleted: true,
        completedAt: today.subtract(const Duration(days: 1)),
        createdAt: today.subtract(const Duration(days: 3)),
        source: 'local',
        isRecurring: false,
      ));
    }

    // Check if Journal Entries are empty
    final existingJournal = await db.select(db.journalEntries).get();
    if (existingJournal.isEmpty) {
      final now = DateTime.now();
      for (int i = 0; i < 20; i++) {
        final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        
        final isFocusChecked = i != 12; 
        final focusRating = isFocusChecked ? 4 : 2;
        final sleepRating = 3 + (i % 3);
        final energyRating = 3 + (i % 2);

        await db.into(db.journalEntries).insert(JournalEntry(
          id: 'journal_entry_$i',
          date: date,
          sleepRating: sleepRating,
          energyRating: energyRating,
          focusRating: focusRating,
          moodRating: 4,
          reflection: 'Today was day $i of high focus work.',
          dailyIntention: 'Maintain study and gym discipline.',
          createdAt: date,
          tasksCompleted: 0,
          weeklyReflectionGenerated: false,
        ));
      }
    }
  } catch (e) {
    // Fail silently
  }
}

/// Task DAO provider.
final taskDaoProvider = Provider<TaskDao>((ref) {
  final db = ref.watch(databaseProvider);
  return TaskDao(db);
});

/// Journal DAO provider.
final journalDaoProvider = Provider<JournalDao>((ref) {
  final db = ref.watch(databaseProvider);
  return JournalDao(db);
});

/// Settings DAO provider.
final settingsDaoProvider = Provider<SettingsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsDao(db);
});

/// Progress DAO provider.
final progressDaoProvider = Provider<ProgressDao>((ref) {
  final db = ref.watch(databaseProvider);
  return ProgressDao(db);
});

/// Screen time DAO provider.
final screenTimeDaoProvider = Provider<ScreenTimeDao>((ref) {
  final db = ref.watch(databaseProvider);
  return ScreenTimeDao(db);
});

/// Chat DAO provider — for AI Coach conversation history.
final chatDaoProvider = Provider<ChatDao>((ref) {
  final db = ref.watch(databaseProvider);
  return ChatDao(db);
});

/// WhatsApp DAO provider — for digests and group tracking.
final whatsappDaoProvider = Provider<WhatsappDao>((ref) {
  final db = ref.watch(databaseProvider);
  return WhatsappDao(db);
});
