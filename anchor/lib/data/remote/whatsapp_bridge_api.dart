import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// WhatsApp connection status from the Baileys bridge.
enum WAStatus { disconnected, qrPending, connected }

/// A WhatsApp group entry.
class WAGroup {
  final String jid;
  final String name;
  final int participantCount;

  const WAGroup({
    required this.jid,
    required this.name,
    required this.participantCount,
  });

  factory WAGroup.fromJson(Map<String, dynamic> json) {
    return WAGroup(
      jid: json['jid'] as String,
      name: json['name'] as String,
      participantCount: json['participantCount'] as int? ?? 0,
    );
  }
}

/// A WhatsApp message from a group.
class WAMessage {
  final String id;
  final String sender;
  final String senderName;
  final String text;
  final DateTime timestamp;

  const WAMessage({
    required this.id,
    required this.sender,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  factory WAMessage.fromJson(Map<String, dynamic> json) {
    return WAMessage(
      id: json['id'] as String,
      sender: json['sender'] as String,
      senderName: json['senderName'] as String? ?? json['sender'] as String,
      text: json['text'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        (json['timestamp'] as num).toInt(),
      ),
    );
  }
}

/// Dart client for the Anchor WhatsApp Bridge Node.js sidecar.
///
/// The bridge runs as a child process on localhost:3847.
/// This client spawns, manages, and communicates with it.
class WhatsappBridgeApi {
  static const int _port = 3847;
  static const String _baseUrl = 'http://127.0.0.1:$_port';

  final Dio _dio;
  Process? _nodeProcess;
  bool _isStarting = false;

  WhatsappBridgeApi()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// Whether the bridge sidecar process is running.
  bool get isProcessRunning => _nodeProcess != null;

  /// Start the Node.js WhatsApp bridge sidecar process.
  /// Returns true if started successfully (or already running).
  Future<bool> startBridge() async {
    if (_isStarting) return false;

    // Check if bridge is already responding on the port
    if (await _isHealthy()) return true;

    _isStarting = true;
    try {
      // Locate the bridge directory relative to the app
      final scriptPath = _findBridgePath();
      if (scriptPath == null) {
        debugPrint('[WA Bridge] server.js not found — WhatsApp unavailable');
        return false;
      }

      debugPrint('[WA Bridge] Starting Node.js bridge at $scriptPath');

      _nodeProcess = await Process.start(
        'node',
        ['server.js'],
        workingDirectory: scriptPath,
        mode: ProcessStartMode.normal,
      );

      _nodeProcess!.stdout
          .transform(const SystemEncoding().decoder)
          .listen((line) => debugPrint('[WA Bridge OUT] $line'));
      _nodeProcess!.stderr
          .transform(const SystemEncoding().decoder)
          .listen((line) => debugPrint('[WA Bridge ERR] $line'));

      _nodeProcess!.exitCode.then((code) {
        debugPrint('[WA Bridge] Process exited with code $code');
        _nodeProcess = null;
      });

      // Wait for bridge to start accepting connections (max 8 seconds)
      for (int i = 0; i < 16; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (await _isHealthy()) {
          debugPrint('[WA Bridge] Bridge is ready');
          _isStarting = false;
          return true;
        }
      }

      debugPrint('[WA Bridge] Bridge did not start in time');
      _isStarting = false;
      return false;
    } catch (e) {
      debugPrint('[WA Bridge] Failed to start: $e');
      _isStarting = false;
      return false;
    }
  }

  /// Stop the Node.js bridge process.
  Future<void> stopBridge() async {
    try {
      await _dio.post('/disconnect');
    } catch (_) {}
    _nodeProcess?.kill(ProcessSignal.sigterm);
    _nodeProcess = null;
  }

  /// Check if the bridge is responding.
  Future<bool> _isHealthy() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Get current WhatsApp connection status.
  Future<WAStatus> getStatus() async {
    try {
      final response = await _dio.get('/status');
      final status = response.data['status'] as String?;
      return switch (status) {
        'connected' => WAStatus.connected,
        'qr_pending' => WAStatus.qrPending,
        _ => WAStatus.disconnected,
      };
    } catch (_) {
      return WAStatus.disconnected;
    }
  }

  /// Get current QR code as a base64 data URL string, or null if not available.
  Future<String?> getQrCode() async {
    try {
      final response = await _dio.get('/qr');
      return response.data['qr'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Get all available WhatsApp groups.
  Future<List<WAGroup>> getGroups() async {
    try {
      final response = await _dio.get('/groups');
      final list = response.data['groups'] as List<dynamic>?;
      return list
              ?.map((g) => WAGroup.fromJson(g as Map<String, dynamic>))
              .toList() ??
          [];
    } catch (e) {
      debugPrint('[WA Bridge] getGroups error: $e');
      return [];
    }
  }

  /// Get all buffered messages for a group.
  Future<List<WAMessage>> getMessages(String groupJid) async {
    try {
      final response = await _dio.get('/messages/$groupJid');
      final list = response.data['messages'] as List<dynamic>?;
      return list
              ?.map((m) => WAMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [];
    } catch (e) {
      debugPrint('[WA Bridge] getMessages error: $e');
      return [];
    }
  }

  /// Get messages for a group since a specific timestamp.
  Future<List<WAMessage>> getMessagesSince(
    String groupJid,
    DateTime since,
  ) async {
    try {
      final ts = since.millisecondsSinceEpoch;
      final response = await _dio.get('/messages/$groupJid/since/$ts');
      final list = response.data['messages'] as List<dynamic>?;
      return list
              ?.map((m) => WAMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [];
    } catch (e) {
      debugPrint('[WA Bridge] getMessagesSince error: $e');
      return [];
    }
  }

  /// Disconnect WhatsApp session (clears credentials).
  Future<bool> disconnect() async {
    try {
      await _dio.post('/disconnect');
      return true;
    } catch (e) {
      debugPrint('[WA Bridge] disconnect error: $e');
      return false;
    }
  }

  /// Find the whatsapp-bridge directory relative to this executable.
  String? _findBridgePath() {
    // Try paths relative to the working directory
    final candidates = [
      'whatsapp-bridge',
      '../whatsapp-bridge',
      '../../whatsapp-bridge',
    ];
    for (final candidate in candidates) {
      final dir = Directory(candidate);
      final serverFile = File('$candidate/server.js');
      if (dir.existsSync() && serverFile.existsSync()) {
        return dir.absolute.path;
      }
    }
    return null;
  }
}
