import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import '../local/daos/chat_dao.dart';
import '../local/daos/task_dao.dart';
import '../local/daos/whatsapp_dao.dart';
import '../local/database.dart';
import './todoist_api.dart';


/// Result of a sync operation.
class SyncResult {
  final int tasksAdded;
  final int tasksUpdated;
  final int tasksPushed;
  final List<String> errors;
  final DateTime syncedAt;

  const SyncResult({
    this.tasksAdded = 0,
    this.tasksUpdated = 0,
    this.tasksPushed = 0,
    this.errors = const [],
    required this.syncedAt,
  });

  bool get hasErrors => errors.isNotEmpty;
  int get totalChanges => tasksAdded + tasksUpdated + tasksPushed;
}

/// Status of an ongoing sync.
enum SyncStatus { idle, syncing, success, error }

/// Central sync service — bidirectional Todoist sync + chat/digest backup.
class SyncService {
  final TodoistApi todoist;
  final TaskDao taskDao;
  final ChatDao chatDao;
  final WhatsappDao whatsappDao;

  static const _syncProjectName = 'Anchor Sync';

  SyncService({
    required this.todoist,
    required this.taskDao,
    required this.chatDao,
    required this.whatsappDao,
  });

  /// Bidirectional task sync: pull Todoist → local, push local → Todoist.
  Future<SyncResult> syncTasks() async {
    if (!todoist.isAuthenticated) {
      return SyncResult(
        syncedAt: DateTime.now(),
        errors: ['Todoist not authenticated'],
      );
    }

    int added = 0, updated = 0, pushed = 0;
    final errors = <String>[];

    try {
      // ── Pull Todoist → Local ──────────────────────────────
      final remoteTasks = await todoist.getTasks();
      for (final remote in remoteTasks) {
        try {
          await taskDao.upsertTask(TasksCompanion(
            id: Value('todoist_${remote.todoistId}'),
            title: Value(remote.title),
            description: Value(remote.description),
            dueDate: Value(remote.dueDate),
            priority: Value(remote.priority),
            label: Value(remote.label),
            projectName: Value(remote.projectName),
            isCompleted: const Value(false),
            source: const Value('todoist'),
            todoistId: Value(remote.todoistId),
          ));
          added++;
        } catch (e) {
          errors.add('Failed to upsert task "${remote.title}": $e');
        }
      }

      // ── Push Local → Todoist ──────────────────────────────
      final localTasks = await taskDao.getActiveTasks();
      for (final local in localTasks) {
        if (local.source == 'local' && local.todoistId == null) {
          try {
            final created = await todoist.createTask(
              title: local.title,
              description: local.description,
              dueDate: local.dueDate,
              priority: local.priority,
              labels: local.label != null ? [local.label!] : [],
            );
            if (created?.todoistId != null) {
              await taskDao.upsertTask(TasksCompanion(
                id: Value(local.id),
                title: Value(local.title),
                todoistId: Value(created!.todoistId),
                source: const Value('todoist'),
              ));
              pushed++;
            }
          } catch (e) {
            errors.add('Failed to push task "${local.title}": $e');
          }
        }
      }
    } catch (e) {
      errors.add('Sync failed: $e');
    }

    return SyncResult(
      tasksAdded: added,
      tasksPushed: pushed,
      tasksUpdated: updated,
      errors: errors,
      syncedAt: DateTime.now(),
    );
  }

  /// Backup an AI Coach session to Todoist as a task with message comments.
  Future<bool> backupChatSession(String sessionId) async {
    if (!todoist.isAuthenticated) return false;

    try {
      final messages = await chatDao.getSessionMessages(sessionId);
      if (messages.isEmpty) return false;

      // Check if already synced
      if (messages.first.todoistTaskId != null) return true;

      final projectId = await todoist.getOrCreateProject(_syncProjectName);

      // First user message as title
      final firstMsg = messages.firstWhere(
        (m) => m.isUser,
        orElse: () => messages.first,
      );
      final title = 'AI Coach — ${_formatDateShort(messages.first.timestamp)} — '
          '${firstMsg.content.substring(0, firstMsg.content.length.clamp(0, 40))}...';

      final created = await todoist.createTask(
        title: title,
        description: 'AI Coach conversation — ${messages.length} messages',
        projectId: projectId,
        labels: ['anchor-ai'],
      );

      if (created?.todoistId == null) return false;

      // Add each message as a comment
      for (final msg in messages) {
        final prefix = msg.isUser ? '👤 You' : '🤖 Anchor AI';
        final time = _formatTime(msg.timestamp);
        await todoist.addComment(
          taskId: created!.todoistId!,
          content: '**$prefix** [$time]\n\n${msg.content}',
        );
        // Small delay to avoid rate limits
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Mark all messages in session as synced
      await chatDao.markSessionSynced(sessionId, created!.todoistId!);
      return true;
    } catch (e) {
      debugPrint('backupChatSession error: $e');
      return false;
    }
  }

  /// Backup a WhatsApp digest to Todoist as a task.
  Future<bool> backupDigest(String digestId) async {
    if (!todoist.isAuthenticated) return false;

    try {
      final digests = await whatsappDao.getRecentDigests(100);
      final digest = digests.firstWhere(
        (d) => d.id == digestId,
        orElse: () => throw Exception('Digest not found'),
      );

      // Already synced
      if (digest.todoistTaskId != null) return true;

      final projectId = await todoist.getOrCreateProject(_syncProjectName);

      final title = 'WhatsApp — ${digest.groupName} — ${_formatDateShort(digest.digestDate)}';
      final created = await todoist.createTask(
        title: title,
        description: digest.summary,
        projectId: projectId,
        labels: ['anchor-whatsapp'],
      );

      if (created?.todoistId == null) return false;

      await whatsappDao.markDigestSynced(digestId, created!.todoistId!);
      return true;
    } catch (e) {
      debugPrint('backupDigest error: $e');
      return false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────

  String _formatDateShort(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
