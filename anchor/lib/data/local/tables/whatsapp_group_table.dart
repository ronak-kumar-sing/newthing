import 'package:drift/drift.dart';

/// WhatsApp groups that Anchor can track and summarize.
class WhatsappGroups extends Table {
  /// WhatsApp group JID — the unique group identifier (e.g., "1234567890-123456@g.us").
  TextColumn get jid => text()();

  /// Human-readable group name.
  TextColumn get name => text()();

  /// Whether Anchor is actively tracking this group for digests.
  BoolColumn get isTracked => boolean().withDefault(const Constant(false))();

  /// Participant count (updated from Baileys).
  IntColumn get participantCount => integer().withDefault(const Constant(0))();

  /// When the last digest was generated for this group.
  DateTimeColumn get lastDigestAt => dateTime().nullable()();

  /// When this group record was created/updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(Constant(DateTime.now()))();

  @override
  Set<Column> get primaryKey => {jid};
}
