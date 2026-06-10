import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/gemini_api.dart';
import '../data/remote/todoist_api.dart';
import '../data/remote/weather_api.dart';
import '../data/remote/whatsapp_bridge_api.dart';

/// Todoist API client provider.
final todoistApiProvider = Provider<TodoistApi>((ref) {
  return TodoistApi();
});

/// Gemini API client provider.
final geminiApiProvider = Provider<GeminiApi>((ref) {
  return GeminiApi();
});

/// Weather API client provider.
final weatherApiProvider = Provider<WeatherApi>((ref) {
  return WeatherApi();
});

/// WhatsApp Bridge API client provider.
final whatsappBridgeApiProvider = Provider<WhatsappBridgeApi>((ref) {
  return WhatsappBridgeApi();
});
