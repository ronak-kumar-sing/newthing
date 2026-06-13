import 'package:drift/drift.dart';

/// Raw WhatsApp messages captured from the notification listener service.
class WhatsappRawMessages extends Table {
  /// Stable message id used for deduplication.
  TextColumn get id => text()();

  /// WhatsApp group JID, when available.
  TextColumn get groupJid => text().nullable()();

  /// Human-readable group or chat name (the notification title).
  TextColumn get groupName => text()();

  /// Display name of the message sender.
  TextColumn get senderName => text()();

  /// Message text after sender extraction and filtering.
  TextColumn get messageText => text()();

  /// Best-effort message timestamp (when the notification was received).
  DateTimeColumn get timestamp => dateTime()();

  /// Whether this message has already been included in a digest.
  BoolColumn get isProcessed => boolean()();

  /// When the row was created locally.
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
