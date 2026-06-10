import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/chat_message_table.dart';

part 'chat_dao.g.dart';

/// Data Access Object for AI Coach chat message history.
@DriftAccessor(tables: [ChatMessages])
class ChatDao extends DatabaseAccessor<AnchorDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  /// Insert a new chat message.
  Future<void> insertMessage(ChatMessagesCompanion message) {
    return into(chatMessages).insert(message);
  }

  /// Get all messages for a given session, ordered oldest→newest.
  Future<List<ChatMessage>> getSessionMessages(String sessionId) {
    return (select(chatMessages)
      ..where((m) => m.sessionId.equals(sessionId))
      ..orderBy([(m) => OrderingTerm(expression: m.timestamp)]))
        .get();
  }

  /// Watch messages for a session (reactive stream).
  Stream<List<ChatMessage>> watchSessionMessages(String sessionId) {
    return (select(chatMessages)
      ..where((m) => m.sessionId.equals(sessionId))
      ..orderBy([(m) => OrderingTerm(expression: m.timestamp)]))
        .watch();
  }

  /// Get distinct sessions, most recent first.
  /// Returns a list of (sessionId, latestTimestamp) pairs.
  Future<List<ChatMessage>> getLatestMessagePerSession() async {
    // Get the latest message from each session
    final query = select(chatMessages)
      ..orderBy([(m) => OrderingTerm(expression: m.timestamp, mode: OrderingMode.desc)]);
    final all = await query.get();
    
    final seen = <String>{};
    final result = <ChatMessage>[];
    for (final msg in all) {
      if (!seen.contains(msg.sessionId)) {
        seen.add(msg.sessionId);
        result.add(msg);
      }
    }
    return result;
  }

  /// Get all messages not yet synced to Todoist.
  Future<List<ChatMessage>> getUnsyncedMessages() {
    return (select(chatMessages)
      ..where((m) => m.todoistTaskId.isNull()))
        .get();
  }

  /// Mark all messages in a session as synced with the given Todoist task ID.
  Future<void> markSessionSynced(String sessionId, String todoistTaskId) {
    return (update(chatMessages)
      ..where((m) => m.sessionId.equals(sessionId)))
        .write(ChatMessagesCompanion(
          todoistTaskId: Value(todoistTaskId),
        ));
  }

  /// Delete all messages in a session.
  Future<int> deleteSession(String sessionId) {
    return (delete(chatMessages)
      ..where((m) => m.sessionId.equals(sessionId)))
        .go();
  }

  /// Get message count for a session.
  Future<int> getSessionMessageCount(String sessionId) async {
    final msgs = await getSessionMessages(sessionId);
    return msgs.length;
  }
}
