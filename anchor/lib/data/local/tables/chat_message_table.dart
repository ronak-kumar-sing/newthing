import 'package:drift/drift.dart';

/// AI Coach chat history — persisted across sessions.
class ChatMessages extends Table {
  /// Unique message ID (UUID v4).
  TextColumn get id => text()();

  /// Message content.
  TextColumn get content => text()();

  /// True = user message, false = AI response.
  BoolColumn get isUser => boolean()();

  /// When the message was created.
  DateTimeColumn get timestamp => dateTime()();

  /// Session ID — groups messages into one conversation.
  /// Format: 'session_<millisecondsSinceEpoch>'
  TextColumn get sessionId => text()();

  /// Todoist task ID after sync (null = not synced yet).
  TextColumn get todoistTaskId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
