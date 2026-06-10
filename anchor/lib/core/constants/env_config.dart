import 'dart:io';
import 'package:flutter/foundation.dart';

/// Environment configuration loader for Anchor.
/// Reads API keys and settings from .env file on desktop,
/// or uses defaults/empty values on web.
class EnvConfig {
  EnvConfig._();

  static final Map<String, String> _env = {};
  static bool _loaded = false;

  /// Load environment variables from .env file.
  static Future<void> load() async {
    if (_loaded) return;
    if (kIsWeb) {
      _loaded = true;
      return;
    }

    try {
      final envFile = File('.env');
      if (await envFile.exists()) {
        final lines = await envFile.readAsLines();
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
          final idx = trimmed.indexOf('=');
          if (idx > 0) {
            final key = trimmed.substring(0, idx).trim();
            final value = trimmed.substring(idx + 1).trim();
            _env[key] = value;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load .env file: $e');
    }
    _loaded = true;
  }

  /// Get a value from the environment.
  static String? get(String key) => _env[key];

  /// Get a value or return default.
  static String getOrDefault(String key, String defaultValue) {
    return _env[key] ?? defaultValue;
  }

  // API Keys
  static String? get todoistApiToken => get('TODOIST_API_TOKEN');
  static String? get geminiApiKey => get('GEMINI_API_KEY');
  static String get geminiModel => get('GEMINI_MODEL') ?? 'gemini-2.0-flash';


  // Weather
  static double? get weatherLat {
    final v = get('WEATHER_LAT');
    return v != null ? double.tryParse(v) : null;
  }

  static double? get weatherLon {
    final v = get('WEATHER_LON');
    return v != null ? double.tryParse(v) : null;
  }

  static String? get weatherCity => get('WEATHER_CITY');

  // App Config
  static String? get userName => get('USER_NAME');
  static DateTime? get independenceDate {
    final v = get('INDEPENDENCE_DATE');
    return v != null ? DateTime.tryParse(v) : null;
  }

  static String? get independenceLabel => get('INDEPENDENCE_LABEL');
  static int get distractionLimitMinutes {
    final v = get('DISTRACTION_LIMIT_MINUTES');
    return v != null ? int.tryParse(v) ?? 120 : 120;
  }

  static String? get newsCategory => get('NEWS_CATEGORY');

  /// Check if API keys are configured.
  static bool get hasTodoistToken =>
      todoistApiToken != null && todoistApiToken!.isNotEmpty && !todoistApiToken!.contains('your_');
  static bool get hasGeminiKey =>
      geminiApiKey != null && geminiApiKey!.isNotEmpty && !geminiApiKey!.contains('your_');
}
