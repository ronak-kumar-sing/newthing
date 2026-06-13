import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/local/daos/whatsapp_dao.dart';
import '../../data/remote/whatsapp_bridge_api.dart';
import 'whatsapp_notification_service.dart';

/// A normalized WhatsApp message used by the digest pipeline.
class WhatsappMessage {
  final String id;
  final String groupName;
  final String? groupJid;
  final String senderName;
  final String text;
  final DateTime timestamp;

  const WhatsappMessage({
    required this.id,
    required this.groupName,
    this.groupJid,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });
}

/// Abstraction over the different ways Anchor ingests WhatsApp messages.
abstract class WhatsappMessageSource {
  /// Whether this source is available on the current platform.
  Future<bool> get isAvailable;

  /// Fetch unprocessed messages for a group received on or after [since].
  Future<List<WhatsappMessage>> fetchMessages({
    required String groupName,
    String? groupJid,
    DateTime? since,
  });

  /// Mark the supplied messages as processed so they are not summarized again.
  Future<void> markProcessed(List<WhatsappMessage> messages);
}

/// Android-only source backed by the notification listener service and Drift.
class NotificationMessageSource implements WhatsappMessageSource {
  final WhatsappDao _dao;

  NotificationMessageSource(this._dao);

  @override
  Future<bool> get isAvailable async {
    if (kIsWeb || !Platform.isAndroid) return false;
    return WhatsappNotificationService.isPermissionGranted();
  }

  @override
  Future<List<WhatsappMessage>> fetchMessages({
    required String groupName,
    String? groupJid,
    DateTime? since,
  }) async {
    final rows = await _dao.getUnprocessedMessagesForGroup(groupName, since: since);
    return rows.map((r) => WhatsappMessage(
      id: r.id,
      groupName: r.groupName,
      groupJid: r.groupJid,
      senderName: r.senderName,
      text: r.messageText,
      timestamp: r.timestamp,
    )).toList();
  }

  @override
  Future<void> markProcessed(List<WhatsappMessage> messages) async {
    final ids = messages.map((m) => m.id).toList();
    await _dao.markRawMessageIdsProcessed(ids);
  }
}

/// Desktop source backed by the local Node.js Baileys bridge.
class BridgeMessageSource implements WhatsappMessageSource {
  final WhatsappBridgeApi _api;

  BridgeMessageSource(this._api);

  @override
  Future<bool> get isAvailable async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) return false;
    return _api.startBridge();
  }

  @override
  Future<List<WhatsappMessage>> fetchMessages({
    required String groupName,
    String? groupJid,
    DateTime? since,
  }) async {
    final jid = groupJid ?? groupName;
    final messages = since == null
        ? await _api.getMessages(jid)
        : await _api.getMessagesSince(jid, since);

    return messages.map((m) => WhatsappMessage(
      id: m.id,
      groupName: groupName,
      groupJid: jid,
      senderName: m.senderName,
      text: m.text,
      timestamp: m.timestamp,
    )).toList();
  }

  @override
  Future<void> markProcessed(List<WhatsappMessage> messages) async {
    // The bridge keeps its own in-memory buffer; nothing to mark locally.
    return;
  }
}
