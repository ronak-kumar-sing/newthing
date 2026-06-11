import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/usage_stats_service.dart';

/// Tracks whether all required permissions have been granted.
///
/// This provider checks SharedPreferences first. If permissions were
/// previously granted, it returns true. Otherwise, it checks the actual
/// permission states and returns the combined result.
final permissionsGrantedProvider = FutureProvider<bool>((ref) async {
  if (kIsWeb) return true;
  final prefs = await SharedPreferences.getInstance();
  final previouslyGranted = prefs.getBool('permissions_granted') ?? false;

  if (previouslyGranted) {
    // Even if previously granted, verify usage stats is still valid
    // (user may have revoked it in settings)
    final usageStats = UsageStatsService();
    final hasUsage = await usageStats.hasPermission();
    if (!hasUsage) {
      await prefs.setBool('permissions_granted', false);
      return false;
    }
    return true;
  }

  return false;
});

/// Whether usage stats permission is currently granted.
///
/// This provider polls for changes and can be invalidated to refresh.
final usageStatsPermissionProvider = FutureProvider<bool>((ref) async {
  if (kIsWeb) return false;
  final usageStats = UsageStatsService();
  return usageStats.hasPermission();
});
