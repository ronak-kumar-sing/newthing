import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import '../data/remote/whatsapp_bridge_api.dart';
import 'database_provider.dart';

/// Singleton WhatsApp bridge API client.
final whatsappBridgeProvider = Provider<WhatsappBridgeApi>((ref) {
  return WhatsappBridgeApi();
});

/// Current WhatsApp connection status.
final waStatusProvider = FutureProvider<WAStatus>((ref) async {
  if (Platform.isAndroid) {
    final granted = await NotificationListenerService.isPermissionGranted();
    return granted ? WAStatus.connected : WAStatus.disconnected;
  }
  return WAStatus.disconnected;
});

/// Current QR code (base64 data URL) — null if not in QR state.
final waQrCodeProvider = FutureProvider<String?>((ref) async {
  return null;
});

/// All WhatsApp groups from the bridge.
final waGroupsProvider = FutureProvider<List<WAGroup>>((ref) async {
  return const [];
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
