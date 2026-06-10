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
  return AnchorDatabase();
});

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
