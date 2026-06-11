import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/usage_stats_service.dart';
import '../data/local/database.dart';
import '../data/local/tables/screen_time_table.dart';
import 'database_provider.dart';

/// Syncs real Android usage stats into the local database.
///
/// This provider reads usage data from the Android UsageStatsManager
/// and populates the [ScreenTimeSessions] table. It should be called
/// before reading screen time data to ensure the DB is up to date.
///
/// Returns the number of sessions synced.
final syncUsageStatsProvider = FutureProvider<int>((ref) async {
  final dao = ref.watch(screenTimeDaoProvider);
  final usageStats = UsageStatsService();

  final hasPermission = await usageStats.hasPermission();
  if (!hasPermission) return 0;

  // Get today's usage stats from Android
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final stats = await usageStats.getUsageStats(todayStart, now);

  if (stats.isEmpty) return 0;

  // Get existing categories
  final categories = await dao.getAllCategories();

  int syncedCount = 0;
  final db = ref.read(databaseProvider);

  int gameTimeSeconds = 0;

  for (final stat in stats) {
    // Skip very short usage (< 1 minute)
    if (stat.totalMinutes < 1) continue;

    // Skip system apps
    if (_isSystemApp(stat.packageName)) continue;

    // Get or infer category
    String? category = categories[stat.packageName];
    if (category == null) {
      category = getDefaultCategory(stat.packageName);
      // Save inferred category for next time
      await dao.setAppCategory(stat.packageName, category);
    }

    if (category == 'Game') {
      gameTimeSeconds += stat.totalTimeInForegroundMs ~/ 1000;
    }

    // Create a session record
    final sessionId = 'st_${stat.packageName}_${todayStart.millisecondsSinceEpoch}';

    // Check if we already have a session for this app today
    final existing = await (db.select(db.screenTimeSessions)
          ..where((s) => s.id.equals(sessionId)))
        .getSingleOrNull();

    if (existing != null) {
      // Update existing session with new duration
      await (db.update(db.screenTimeSessions)
            ..where((s) => s.id.equals(sessionId)))
          .write(ScreenTimeSessionsCompanion(
        durationSeconds: Value(stat.totalTimeInForegroundMs ~/ 1000),
        endTime: Value(stat.lastTimeUsed ?? now),
      ));
    } else {
      // Insert new session
      await db.into(db.screenTimeSessions).insert(
        ScreenTimeSessionsCompanion(
          id: Value(sessionId),
          date: Value(todayStart),
          appName: Value(getAppDisplayName(stat.packageName)),
          category: Value(category),
          startTime: Value(todayStart),
          endTime: Value(stat.lastTimeUsed ?? now),
          durationSeconds: Value(stat.totalTimeInForegroundMs ~/ 1000),
        ),
        mode: InsertMode.insertOrReplace,
      );
      syncedCount++;
    }
  }

  if (gameTimeSeconds > 0) {
    final progressDao = ref.read(progressDaoProvider);
    await progressDao.recordValue('dim_game_sessions', todayStart, gameTimeSeconds / 3600.0);
  }

  return syncedCount;
});

/// Today's total screen time in minutes.
///
/// This provider first syncs usage stats from Android, then reads
/// the total from the local database.
final todayScreenTimeProvider = FutureProvider<int>((ref) async {
  // Sync first, then read
  await ref.watch(syncUsageStatsProvider.future);
  final dao = ref.watch(screenTimeDaoProvider);
  return dao.getTodayTotalMinutes();
});

/// Today's screen time by category.
///
/// This provider first syncs usage stats from Android, then reads
/// category breakdown from the local database.
final screenTimeByCategoryProvider = FutureProvider<Map<String, int>>((ref) async {
  // Sync first, then read
  await ref.watch(syncUsageStatsProvider.future);
  final dao = ref.watch(screenTimeDaoProvider);
  return dao.getTodayCategoryMinutes();
});

/// Weekly screen time totals by day.
final weeklyScreenTimeProvider = FutureProvider<Map<DateTime, int>>((ref) async {
  final dao = ref.watch(screenTimeDaoProvider);
  return dao.getWeeklyMinutes();
});

/// Raw usage stats from Android (for advanced use cases).
/// Returns a list of app usage stats without syncing to the database.
final rawUsageStatsProvider = FutureProvider<List<AppUsageStat>>((ref) async {
  final usageStats = UsageStatsService();
  final hasPermission = await usageStats.hasPermission();
  if (!hasPermission) return [];

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  return usageStats.getUsageStats(todayStart, now);
});

/// Whether usage stats permission is granted.
final usageStatsEnabledProvider = FutureProvider<bool>((ref) async {
  final usageStats = UsageStatsService();
  return usageStats.hasPermission();
});

/// Check if a package is a system app that should be excluded.
bool _isSystemApp(String packageName) {
  final systemPrefixes = [
    'android',
    'com.android.systemui',
    'com.android.launcher',
    'com.google.android.gms',
    'com.google.android.googlequicksearchbox',
    'com.google.android.inputmethod',
    'com.samsung.android',
    'com.miui',
    'com.huawei',
    'com.oneplus',
    'com.oppo',
    'com.vivo',
    'com.coloros',
    'com.funtouch',
    'com.realme',
    'com.asus',
    'com.sony',
    'com.lge',
    'com.motorola',
    'com.google.android.packageinstaller',
    'com.google.android.permissioncontroller',
    'com.google.android.ext.services',
    'com.google.android.cellbroadcastreceiver',
    'com.google.android.providers.settings',
    'com.android.providers',
    'com.android.printspooler',
    'com.android.captiveportallogin',
    'com.android.shell',
    'com.android.nfc',
    'com.android.bluetooth',
    'com.android.traceur',
    'com.android.wallpaper',
    'com.android.keychain',
    'com.android.defcontainer',
    'com.android.packageinstaller',
  ];

  for (final prefix in systemPrefixes) {
    if (packageName == prefix || packageName.startsWith('$prefix.')) {
      return true;
    }
  }
  return false;
}
