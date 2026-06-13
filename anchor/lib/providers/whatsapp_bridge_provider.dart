import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import '../data/local/database.dart';
import '../data/remote/whatsapp_bridge_api.dart';
import 'database_provider.dart';

/// Singleton WhatsApp bridge API client.
final whatsappBridgeProvider = Provider<WhatsappBridgeApi>((ref) {
  return WhatsappBridgeApi();
});

/// Current WhatsApp connection status.
///
/// On Android this reflects notification-listener permission. On desktop it
/// starts the Node.js bridge and returns its reported status.
final waStatusProvider = FutureProvider<WAStatus>((ref) async {
  if (kIsWeb) return WAStatus.disconnected;

  if (Platform.isAndroid) {
    final granted = await NotificationListenerService.isPermissionGranted();
    return granted ? WAStatus.connected : WAStatus.disconnected;
  }

  // Desktop: try to start the sidecar and report its status.
  final bridge = ref.read(whatsappBridgeProvider);
  final started = await bridge.startBridge();
  if (!started) return WAStatus.disconnected;
  return bridge.getStatus();
});

/// Current QR code (base64 data URL) — null if not in QR state.
final waQrCodeProvider = FutureProvider<String?>((ref) async {
  if (kIsWeb || Platform.isAndroid || Platform.isIOS) return null;

  final bridge = ref.read(whatsappBridgeProvider);
  final status = await bridge.getStatus();
  if (status != WAStatus.qrPending) return null;
  return bridge.getQrCode();
});

/// All WhatsApp groups from the bridge (desktop) or local DB fallback.
final waGroupsProvider = FutureProvider<List<WAGroup>>((ref) async {
  if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
    return const [];
  }

  final bridge = ref.read(whatsappBridgeProvider);
  final status = await bridge.getStatus();
  if (status != WAStatus.connected) return const [];

  final groups = await bridge.getGroups();

  // Persist discovered groups to the local DB for tracking.
  final dao = ref.read(whatsappDaoProvider);
  for (final g in groups) {
    await dao.upsertGroup(
      WhatsappGroupsCompanion(
        jid: Value(g.jid),
        name: Value(g.name),
        participantCount: Value(g.participantCount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  return groups;
});

/// Tracked WhatsApp groups from the local DB.
final trackedGroupsProvider = FutureProvider((ref) async {
  final dao = ref.watch(whatsappDaoProvider);
  return dao.getTrackedGroups();
});

/// All known WhatsApp groups from the local DB.
final allLocalGroupsProvider = StreamProvider((ref) {
  final dao = ref.watch(whatsappDaoProvider);
  return dao.watchAllGroups();
});

/// Today's WhatsApp digests.
final todayDigestsProvider = StreamProvider((ref) {
  final dao = ref.watch(whatsappDaoProvider);
  return dao.watchTodayDigests();
});

/// Recent digests (last 20).
final recentDigestsProvider = FutureProvider((ref) async {
  final dao = ref.watch(whatsappDaoProvider);
  return dao.getRecentDigests(20);
});

/// Unprocessed raw message counts per group.
final unprocessedMessageCountsProvider = StreamProvider<Map<String, int>>((ref) {
  final dao = ref.watch(whatsappDaoProvider);
  return dao.watchUnprocessedMessageCountsByGroup();
});
