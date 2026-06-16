import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import '../data/local/daos/journal_dao.dart';
import '../data/local/daos/progress_dao.dart';
import '../data/local/daos/screen_time_dao.dart';
import '../data/local/daos/settings_dao.dart';
import '../data/local/daos/task_dao.dart';
import '../data/local/daos/chat_dao.dart';
import '../data/local/daos/whatsapp_dao.dart';
import '../data/local/daos/placement_dao.dart';

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

      final gameSessionId = 'dim_game_sessions';
      await db.into(db.progressDimensions).insert(ProgressDimension(
        id: gameSessionId,
        name: 'Game Sessions',
        weeklyTarget: 7.0,
        unit: 'hrs',
        isAutomatic: true,
        colorHex: '#FF5252',
        sortOrder: 3,
        createdAt: DateTime.now(),
      ));
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

/// Placement DAO provider.
final placementDaoProvider = Provider<PlacementDao>((ref) {
  final db = ref.watch(databaseProvider);
  return PlacementDao(db);
});

