import 'package:drift/drift.dart';

/// WhatsApp group digest — AI-summarized group chat highlights.
class WhatsappDigests extends Table {
  /// Unique digest ID (UUID v4).
  TextColumn get id => text()();

  /// Group display name (e.g., "CSE Department").
  TextColumn get groupName => text()();

  /// WhatsApp group JID (e.g., "1234567890-123456@g.us"). Nullable for manual pastes.
  TextColumn get groupJid => text().nullable()();

  /// Raw concatenated messages that were summarized.
  TextColumn get rawMessages => text()();

  /// Gemini-generated summary (markdown bullets).
  TextColumn get summary => text()();

  /// Date of the digest.
  DateTimeColumn get digestDate => dateTime()();

  /// Todoist task ID after sync (null = not synced).
  TextColumn get todoistTaskId => text().nullable()();

  /// When the digest was created.
  DateTimeColumn get createdAt => dateTime().withDefault(Constant(DateTime.now()))();

  @override
  Set<Column> get primaryKey => {id};
}
