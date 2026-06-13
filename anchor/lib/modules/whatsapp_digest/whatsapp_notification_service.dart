import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import '../../data/local/database.dart';
import '../../data/local/daos/whatsapp_dao.dart';

/// Android-only listener that ingests WhatsApp notifications and stores
/// structured messages in the local Drift database.
class WhatsappNotificationService {
  static const int _maxSenderLength = 40;
  static bool _isListening = false;

  /// Check whether notification listener permission is granted.
  static Future<bool> isPermissionGranted() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    return NotificationListenerService.isPermissionGranted();
  }

  /// Request notification listener permission.
  static Future<bool> requestPermission() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    return NotificationListenerService.requestPermission();
  }

  /// Start listening to WhatsApp notifications and persisting them.
  static Future<void> init(WhatsappDao whatsappDao) async {
    if (_isListening) return;
    if (kIsWeb || !Platform.isAndroid) return;

    final granted = await NotificationListenerService.isPermissionGranted();
    if (!granted) {
      debugPrint('[WA Notification] Permission not granted');
      return;
    }

    debugPrint('[WA Notification] Starting notification stream listener...');
    _isListening = true;

    NotificationListenerService.notificationsStream.listen((event) async {
      final pkg = event.packageName ?? '';
      if (pkg != 'com.whatsapp' && pkg != 'com.whatsapp.w4b') return;

      final title = event.title ?? '';
      final content = event.content ?? '';

      if (title.isEmpty || content.isEmpty) return;
      if (_isSystemNotification(content)) return;
      if (_isMediaOnlyNotification(content)) return;

      final (sender, text) = _extractSenderAndText(title, content);
      if (text.isEmpty) return;

      final now = DateTime.now();
      final messageId = _deriveMessageId(title, sender, text, now);

      debugPrint('[WA Notification] Received: $title -> $sender: $text');

      // Ensure the group is known locally.
      await whatsappDao.upsertGroup(WhatsappGroupsCompanion(
        jid: Value(title),
        name: Value(title),
        updatedAt: Value(now),
      ));

      await whatsappDao.upsertRawMessage(WhatsappRawMessagesCompanion(
        id: Value(messageId),
        groupJid: Value(title),
        groupName: Value(title),
        senderName: Value(sender),
        messageText: Value(text),
        timestamp: Value(now),
        isProcessed: const Value(false),
        createdAt: Value(now),
      ));
    }, onError: (Object e) {
      debugPrint('[WA Notification] Stream error: $e');
    });
  }

  /// Heuristic to detect and skip WhatsApp system toasts.
  static bool _isSystemNotification(String content) {
    final lower = content.toLowerCase();
    return lower.contains('checking for new messages') ||
        lower.contains('whatsapp web is currently active') ||
        lower.contains('new chat') ||
        lower.contains('downloading messages');
  }

  /// Detect media-only notifications that have no meaningful text.
  static bool _isMediaOnlyNotification(String content) {
    final lower = content.toLowerCase().trim();
    const mediaHints = [
      'image',
      'photo',
      'video',
      'voice message',
      'audio',
      'sticker',
      'document',
      'gif',
      'poll',
      'location',
      'contact card',
    ];
    return mediaHints.any((hint) => lower == hint || lower.endsWith(' $hint'));
  }

  /// Extract sender and text from a notification.
  ///
  /// WhatsApp group notifications are usually formatted as:
  ///   title: "Group Name"
  ///   content: "Sender Name: message text"
  ///
  /// Falls back to the title as sender when the colon split is unreliable.
  static (String sender, String text) _extractSenderAndText(
    String title,
    String content,
  ) {
    final colonIndex = content.indexOf(': ');

    if (colonIndex > 0) {
      final candidate = content.substring(0, colonIndex).trim();
      final body = content.substring(colonIndex + 2).trim();

      // Reasonable sender names do not start with "Forwarded" and are not too long.
      if (candidate.length <= _maxSenderLength &&
          !_looksLikeForwardedHeader(candidate)) {
        return (candidate, body);
      }
    }

    // Fallback: the title is the chat/group name; treat the whole content as text.
    return (title, content.trim());
  }

  static bool _looksLikeForwardedHeader(String candidate) {
    final lower = candidate.toLowerCase();
    return lower.startsWith('forwarded') || lower.startsWith('forwarded from');
  }

  /// Derive a stable message id for deduplication.
  ///
  /// Because Android notifications do not expose WhatsApp message keys, we hash
  /// the group, sender, text, and minute of arrival. Collisions across the same
  /// minute are acceptable for notification dedup; exact duplicate delivery
  /// within the same minute is the common case.
  static String _deriveMessageId(
    String groupName,
    String sender,
    String text,
    DateTime timestamp,
  ) {
    final input = '$groupName\n$sender\n$text\n${timestamp.year}-${timestamp.month}-${timestamp.day}-${timestamp.hour}-${timestamp.minute}';
    return sha1.convert(utf8.encode(input)).toString();
  }
}
