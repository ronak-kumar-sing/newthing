import 'dart:io';

import 'package:flutter/services.dart';

/// Service for interacting with Android UsageStatsManager via platform channel.
///
/// Provides methods to:
/// - Check if usage stats permission is granted
/// - Request usage stats permission (opens system settings)
/// - Query actual app usage data from the system
///
/// This only works on Android. On iOS or other platforms, all methods
/// return empty/denied results.
class UsageStatsService {
  static const _channel = MethodChannel('com.example.anchor/usage_stats');

  /// Singleton instance.
  static final UsageStatsService _instance = UsageStatsService._internal();
  factory UsageStatsService() => _instance;
  UsageStatsService._internal();

  /// Check if the app has been granted usage stats permission.
  ///
  /// On Android, `PACKAGE_USAGE_STATS` is a special permission that cannot
  /// be requested via the normal runtime permission dialog. The user must
  /// manually enable it in Settings > Apps > Special app access > Usage access.
  ///
  /// Returns `true` if granted, `false` otherwise (or on non-Android platforms).
  Future<bool> hasPermission() async {
    if (!Platform.isAndroid) return false;
    try {
      final granted = await _channel.invokeMethod<bool>('checkUsageStatsPermission');
      return granted ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Open the system Usage Access settings page.
  ///
  /// This is the only way to request usage stats permission on Android.
  /// The user must manually toggle the permission on. Call [hasPermission]
  /// after the user returns to check if they granted it.
  Future<void> requestPermission() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('requestUsageStatsPermission');
    } catch (e) {
      // Ignore errors
    }
  }

  /// Get aggregated usage stats for a time range.
  ///
  /// [start] and [end] define the time window. Returns a list of
  /// [AppUsageStat] objects with package name and foreground time.
  ///
  /// Returns empty list if permission is not granted or on non-Android.
  Future<List<AppUsageStat>> getUsageStats(DateTime start, DateTime end) async {
    if (!Platform.isAndroid) return [];
    try {
      final result = await _channel.invokeListMethod<Map>('getUsageStats', {
        'startTime': start.millisecondsSinceEpoch,
        'endTime': end.millisecondsSinceEpoch,
      });
      if (result == null) return [];
      return result.map((m) => AppUsageStat.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get granular usage events (app open/close) for a time range.
  ///
  /// [start] and [end] define the time window. Returns a list of
  /// [UsageEvent] objects with package name, timestamp, and event type.
  ///
  /// Returns empty list if permission is not granted or on non-Android.
  Future<List<UsageEvent>> getUsageEvents(DateTime start, DateTime end) async {
    if (!Platform.isAndroid) return [];
    try {
      final result = await _channel.invokeListMethod<Map>('getUsageEvents', {
        'startTime': start.millisecondsSinceEpoch,
        'endTime': end.millisecondsSinceEpoch,
      });
      if (result == null) return [];
      return result.map((m) => UsageEvent.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get today's usage stats (from midnight to now).
  ///
  /// Convenience method that wraps [getUsageStats] with today's date range.
  Future<List<AppUsageStat>> getTodayUsageStats() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return getUsageStats(start, now);
  }

  /// Watch for permission changes by polling.
  ///
  /// [interval] controls how often to check. Useful to detect when
  /// the user returns from the system settings after granting permission.
  ///
  /// Returns a stream that emits `true` when permission is granted.
  /// The stream completes when permission is granted or after [maxAttempts].
  Stream<bool> watchPermission({
    Duration interval = const Duration(seconds: 1),
    int maxAttempts = 30,
  }) async* {
    if (!Platform.isAndroid) {
      yield false;
      return;
    }
    for (var i = 0; i < maxAttempts; i++) {
      final granted = await hasPermission();
      yield granted;
      if (granted) return;
      await Future.delayed(interval);
    }
  }
}

/// Aggregated usage stat for a single app.
class AppUsageStat {
  final String packageName;
  final int totalTimeInForegroundMs;
  final DateTime? lastTimeUsed;

  AppUsageStat({
    required this.packageName,
    required this.totalTimeInForegroundMs,
    this.lastTimeUsed,
  });

  /// Total time in foreground in minutes.
  int get totalMinutes => totalTimeInForegroundMs ~/ 60000;

  factory AppUsageStat.fromMap(Map map) {
    return AppUsageStat(
      packageName: map['packageName'] as String? ?? '',
      totalTimeInForegroundMs: map['totalTimeInForeground'] as int? ?? 0,
      lastTimeUsed: map['lastTimeUsed'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastTimeUsed'] as int)
          : null,
    );
  }
}

/// Individual usage event (app open/close/move to background).
class UsageEvent {
  final String packageName;
  final DateTime timestamp;
  final int eventType;

  UsageEvent({
    required this.packageName,
    required this.timestamp,
    required this.eventType,
  });

  /// Event type constants matching Android's UsageEvents.Event.
  static const int none = 0;
  static const int activityResumed = 1; // App moved to foreground
  static const int activityPaused = 2; // App moved to background
  static const int configurationChange = 5;
  static const int userInteraction = 7;
  static const int shortcutInvocation = 8;
  static const int chooserAction = 9;
  static const int deviceShutdown = 26;
  static const int deviceStartup = 27;

  bool get isForeground => eventType == activityResumed;
  bool get isBackground => eventType == activityPaused;

  factory UsageEvent.fromMap(Map map) {
    return UsageEvent(
      packageName: map['packageName'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timeStamp'] as int),
      eventType: map['eventType'] as int? ?? 0,
    );
  }
}

/// Human-readable app names for common packages.
final Map<String, String> _appNameMap = {
  'com.whatsapp': 'WhatsApp',
  'com.instagram.android': 'Instagram',
  'com.facebook.katana': 'Facebook',
  'com.facebook.orca': 'Messenger',
  'com.twitter.android': 'X (Twitter)',
  'com.discord': 'Discord',
  'com.spotify.music': 'Spotify',
  'com.netflix.mediaclient': 'Netflix',
  'com.google.android.youtube': 'YouTube',
  'com.google.android.gm': 'Gmail',
  'com.google.android.apps.maps': 'Maps',
  'com.google.android.calendar': 'Calendar',
  'com.google.android.apps.docs': 'Google Docs',
  'com.google.android.apps.tachyon': 'Google Meet',
  'com.slack': 'Slack',
  'com.microsoft.teams': 'Microsoft Teams',
  'com.linkedin.android': 'LinkedIn',
  'com.reddit.frontpage': 'Reddit',
  'com.snapchat.android': 'Snapchat',
  'com.zhiliaoapp.musically': 'TikTok',
  'com.tencent.mm': 'WeChat',
  'com.google.android.apps.messaging': 'Messages',
  'com.android.chrome': 'Chrome',
  'com.google.android.apps.photos': 'Photos',
  'com.google.android.dialer': 'Phone',
  'com.android.settings': 'Settings',
  'com.android.vending': 'Play Store',
  'com.google.android.apps.nbu.files': 'Files',
  'com.google.android.calculator': 'Calculator',
  'com.google.android.contacts': 'Contacts',
  'com.google.android.keep': 'Keep',
  'com.google.android.apps.translate': 'Translate',
  'com.android.camera': 'Camera',
  'com.google.android.apps.wallpaper': 'Wallpapers',
  'com.google.android.deskclock': 'Clock',
  'com.google.android.music': 'Music',
  'com.google.android.videos': 'Videos',
};

/// Get a human-readable app name from a package name.
String getAppDisplayName(String packageName) {
  return _appNameMap[packageName] ??
      packageName.split('.').last.replaceFirst('_', ' ').toUpperCase();
}

/// Default category mapping for common apps.
/// Maps package name prefix or full name to a category.
String getDefaultCategory(String packageName) {
  final productive = [
    'com.google.android.apps.docs', // Google Docs
    'com.google.android.apps.tachyon', // Meet
    'com.slack',
    'com.microsoft.teams',
    'com.microsoft.office',
    'com.microsoft.office.word',
    'com.microsoft.office.excel',
    'com.microsoft.office.powerpoint',
    'com.notion.id',
    'com.todoist',
    'com.google.android.apps.tasks',
    'com.google.android.keep',
    'com.google.android.calendar',
    'com.google.android.gm',
    'com.linkedin.android',
    'com.coursera.android',
    'com.udemy.android',
    'com.duolingo',
    'com.amazon.kindle',
    'com.google.android.apps.books',
    'com.github.android',
    'com.gitlab',
    'com.android.chrome',
    'org.mozilla.firefox',
    'com.termux',
    'com.google.android.apps.classroom',
    'com.zoom.us',
    'com.webex.meetings',
    'com.google.android.apps.meetings',
    'com.google.android.apps.dynamite', // Google Chat/Spaces
    'com.asana.app',
    'com.atlassian.jira',
    'com.trello',
    'com.evernote',
    'com.google.android.apps.nbu.files', // Files
  ];

  final distracted = [
    'com.whatsapp',
    'com.instagram.android',
    'com.facebook.katana',
    'com.facebook.orca',
    'com.twitter.android',
    'com.discord',
    'com.snapchat.android',
    'com.zhiliaoapp.musically', // TikTok
    'com.reddit.frontpage',
    'com.netflix.mediaclient',
    'com.google.android.youtube',
    'com.spotify.music',
    'com.tinder',
    'com.bumble.app',
    'com.pinterest',
    'com.tumblr',
    'com.vkontakte.android',
    'com.ok.android',
    'com.tencent.mm',
    'com.linecorp.line',
    'com.kakao.talk',
    'com.ubercab',
    'com.grubhub.android',
    'com.doordash.driverapp',
    'com.yelp.android',
    'com.airbnb.android',
    'com.booking',
    'com.amazon.mShop.android.shopping',
    'com.google.android.apps.youtube.music',
    'com.google.android.apps.youtube.kids',
    'tv.twitch.android.app',
    'com.disney.disneyplus',
    'com.hulu.plus',
    'com.amazon.avod.thirdpartyclient', // Prime Video
    'com.apple.android.music',
    'com.soundcloud.android',
    'com.shazam.android',
    'com.audible.application',
    'com.roblox.client',
    'com.supercell.clashofclans',
    'com.supercell.brawlstars',
    'com.king.candycrushsaga',
    'com.king.candycrushsodasaga',
    'com.ea.game.pvz2_row',
    'com.imangi.templerun',
    'com.imangi.templerun2',
    'com.activision.callofduty.shooter',
    'com.dts.freefireth',
    'com.dts.freefiremax',
    'com.pubg.imobile',
    'com.mojang.minecraftpe',
  ];

  for (final prefix in productive) {
    if (packageName.startsWith(prefix)) return 'productive';
  }
  for (final prefix in distracted) {
    if (packageName.startsWith(prefix)) return 'distracted';
  }
  return 'neutral';
}
