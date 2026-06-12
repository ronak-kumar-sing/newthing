import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:drift/drift.dart' show Value;
import '../../data/local/database.dart';
import '../../data/local/daos/whatsapp_dao.dart';

class WhatsappNotificationService {
  static const String _messagesPrefsKey = 'whatsapp_notification_messages';
  static bool _isListening = false;

  /// Check permission and start listening to WhatsApp notifications
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
      // Filter WhatsApp packages
      final pkg = event.packageName ?? '';
      if (pkg == 'com.whatsapp' || pkg == 'com.whatsapp.w4b') {
        final title = event.title ?? '';
        final content = event.content ?? '';

        if (title.isEmpty || content.isEmpty) return;

        // Skip common system notifications like "Checking for new messages"
        if (content.toLowerCase().contains('checking for new messages') ||
            content.toLowerCase().contains('whatsapp web is currently active')) {
          return;
        }

        debugPrint('[WA Notification] Received: $title -> $content');

        // Upsert this chat/group name to our known WhatsApp groups list in the DB
        await whatsappDao.upsertGroup(WhatsappGroupsCompanion(
          jid: Value(title),
          name: Value(title),
          updatedAt: Value(DateTime.now()),
        ));

        // Save this message
        await _saveMessage(title, content);
      }
    });
  }

  /// Store a raw message locally in SharedPreferences
  static Future<void> _saveMessage(String groupName, String rawContent) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_messagesPrefsKey) ?? '[]';
    
    List<dynamic> list = [];
    try {
      list = jsonDecode(cached) as List<dynamic>;
    } catch (_) {}

    // Parse sender name if there is a colon (e.g. "Aman: Hello")
    String sender = 'Unknown';
    String text = rawContent;
    final colonIndex = rawContent.indexOf(':');
    if (colonIndex > 0 && colonIndex < 25) { // reasonable sender name length
      sender = rawContent.substring(0, colonIndex).trim();
      text = rawContent.substring(colonIndex + 1).trim();
    }

    final messageJson = {
      'groupName': groupName,
      'senderName': sender,
      'text': text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    list.add(messageJson);

    // Keep only the last 500 messages to avoid bloat
    if (list.length > 500) {
      list = list.sublist(list.length - 500);
    }

    await prefs.setString(_messagesPrefsKey, jsonEncode(list));
  }

  /// Get messages for a specific group since a given timestamp
  static Future<List<Map<String, dynamic>>> getMessages(String groupName, {DateTime? since}) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_messagesPrefsKey) ?? '[]';

    List<dynamic> list = [];
    try {
      list = jsonDecode(cached) as List<dynamic>;
    } catch (_) {}

    final result = <Map<String, dynamic>>[];
    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;
      if (item['groupName'] == groupName) {
        if (since != null) {
          final tsStr = item['timestamp'] as String?;
          if (tsStr != null) {
            final ts = DateTime.tryParse(tsStr);
            if (ts != null && ts.isBefore(since)) {
              continue;
            }
          }
        }
        result.add(item);
      }
    }
    return result;
  }

  /// Clear messages for a group after generating a digest
  static Future<void> clearMessagesForGroup(String groupName) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_messagesPrefsKey) ?? '[]';

    List<dynamic> list = [];
    try {
      list = jsonDecode(cached) as List<dynamic>;
    } catch (_) {}

    final updated = list.where((item) {
      if (item is Map<String, dynamic>) {
        return item['groupName'] != groupName;
      }
      return true;
    }).toList();

    await prefs.setString(_messagesPrefsKey, jsonEncode(updated));
  }
}
