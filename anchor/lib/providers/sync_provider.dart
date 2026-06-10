import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/remote/sync_service.dart';
import 'api_provider.dart';
import 'database_provider.dart';

/// Sync service provider.
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    todoist: ref.watch(todoistApiProvider),
    taskDao: ref.watch(taskDaoProvider),
    chatDao: ref.watch(chatDaoProvider),
    whatsappDao: ref.watch(whatsappDaoProvider),
  );
});

/// Current sync status.
final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle);

/// Result of the last sync operation.
final lastSyncResultProvider = StateProvider<SyncResult?>((ref) => null);

/// Timestamp of the last successful sync.
final lastSyncTimeProvider = StateProvider<DateTime?>((ref) => null);
