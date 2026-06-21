import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/remote/gemini_api.dart';

/// Caches the AI-generated morning brief once per day.
class DailyBriefService {
  static const String _cacheKeyPrefix = 'anchor_brief_';

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String _cacheKey() => '$_cacheKeyPrefix${_todayKey()}';

  /// Returns today's cached brief, or null if not yet generated.
  static Future<String?> _getCachedBrief() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey();
    final cached = prefs.getString(key);
    if (cached != null && cached.trim().isNotEmpty) {
      return cached;
    }
    return null;
  }

  static Future<void> _cacheBrief(String brief) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey(), brief);
  }

  /// Returns the morning brief for today. Generates and caches it only once per day.
  static Future<String> getBrief({
    required GeminiApi gemini,
    required int daysRemaining,
    required String? independenceLabel,
    required List<String> topTasks,
    required String? yesterdayScreenTime,
    required String? weeklyStudyHours,
    required int overdueTaskCount,
  }) async {
    final cached = await _getCachedBrief();
    if (cached != null) return cached;

    String brief;
    if (!gemini.isConfigured) {
      brief = 'Welcome back! Start today with purpose. Make every hour count towards your long-term goals.';
    } else {
      try {
        final generated = await gemini.generateMorningBriefing(
          daysRemaining: daysRemaining,
          independenceLabel: independenceLabel,
          topTasks: topTasks,
          yesterdayScreenTime: yesterdayScreenTime,
          weeklyStudyHours: weeklyStudyHours,
          overdueTaskCount: overdueTaskCount,
        );
        brief = generated ??
            'Welcome back! Prioritize your top focus tasks, minimize distractions, and stay disciplined today.';
      } catch (e) {
        debugPrint('Error generating morning brief: $e');
        brief = 'Welcome back! Prioritize your top focus tasks, minimize distractions, and stay disciplined today.';
      }
    }

    await _cacheBrief(brief);
    return brief;
  }
}
