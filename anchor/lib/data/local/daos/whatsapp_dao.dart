import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/whatsapp_digest_table.dart';
import '../tables/whatsapp_group_table.dart';

part 'whatsapp_dao.g.dart';

/// Data Access Object for WhatsApp digests and group management.
@DriftAccessor(tables: [WhatsappDigests, WhatsappGroups])
class WhatsappDao extends DatabaseAccessor<AnchorDatabase>
    with _$WhatsappDaoMixin {
  WhatsappDao(super.db);

  // ─── Digests ───────────────────────────────────────────────

  /// Insert a new WhatsApp digest.
  Future<void> insertDigest(WhatsappDigestsCompanion digest) {
    return into(whatsappDigests).insert(digest);
  }

  /// Get all digests for a specific date (matching digestDate day).
  Future<List<WhatsappDigest>> getDigestsByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(whatsappDigests)
      ..where((d) => d.digestDate.isBetweenValues(start, end))
      ..orderBy([
        (d) => OrderingTerm(expression: d.createdAt, mode: OrderingMode.desc)
      ]))
        .get();
  }

  /// Get the most recent N digests.
  Future<List<WhatsappDigest>> getRecentDigests(int limit) {
    return (select(whatsappDigests)
      ..orderBy([
        (d) => OrderingTerm(expression: d.digestDate, mode: OrderingMode.desc)
      ])
      ..limit(limit))
        .get();
  }

  /// Watch today's digests as a reactive stream.
  Stream<List<WhatsappDigest>> watchTodayDigests() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(whatsappDigests)
      ..where((d) => d.digestDate.isBetweenValues(start, end))
      ..orderBy([
        (d) => OrderingTerm(expression: d.createdAt, mode: OrderingMode.desc)
      ]))
        .watch();
  }

  /// Get digests that haven't been synced to Todoist yet.
  Future<List<WhatsappDigest>> getUnsyncedDigests() {
    return (select(whatsappDigests)
      ..where((d) => d.todoistTaskId.isNull()))
        .get();
  }

  /// Mark a digest as synced with the given Todoist task ID.
  Future<void> markDigestSynced(String digestId, String todoistTaskId) {
    return (update(whatsappDigests)
      ..where((d) => d.id.equals(digestId)))
        .write(WhatsappDigestsCompanion(
          todoistTaskId: Value(todoistTaskId),
        ));
  }

  /// Delete a digest by ID.
  Future<int> deleteDigest(String digestId) {
    return (delete(whatsappDigests)
      ..where((d) => d.id.equals(digestId)))
        .go();
  }

  // ─── Groups ────────────────────────────────────────────────

  /// Insert or update a WhatsApp group.
  Future<void> upsertGroup(WhatsappGroupsCompanion group) {
    return into(whatsappGroups).insertOnConflictUpdate(group);
  }

  /// Get all known WhatsApp groups.
  Future<List<WhatsappGroup>> getAllGroups() {
    return (select(whatsappGroups)
      ..orderBy([
        (g) => OrderingTerm(expression: g.name)
      ]))
        .get();
  }

  /// Get only tracked groups.
  Future<List<WhatsappGroup>> getTrackedGroups() {
    return (select(whatsappGroups)
      ..where((g) => g.isTracked.equals(true))
      ..orderBy([(g) => OrderingTerm(expression: g.name)]))
        .get();
  }

  /// Watch all groups as a reactive stream.
  Stream<List<WhatsappGroup>> watchAllGroups() {
    return (select(whatsappGroups)
      ..orderBy([(g) => OrderingTerm(expression: g.name)]))
        .watch();
  }

  /// Toggle tracking state of a group.
  Future<void> setGroupTracked(String jid, {required bool tracked}) {
    return (update(whatsappGroups)
      ..where((g) => g.jid.equals(jid)))
        .write(WhatsappGroupsCompanion(
          isTracked: Value(tracked),
        ));
  }

  /// Update the lastDigestAt timestamp for a group.
  Future<void> updateGroupLastDigest(String jid, DateTime timestamp) {
    return (update(whatsappGroups)
      ..where((g) => g.jid.equals(jid)))
        .write(WhatsappGroupsCompanion(
          lastDigestAt: Value(timestamp),
        ));
  }
}
