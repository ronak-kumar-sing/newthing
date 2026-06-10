import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import 'database_provider.dart';

/// Settings state provider.
final settingsProvider = FutureProvider<AppSetting>((ref) async {
  final dao = ref.watch(settingsDaoProvider);
  return dao.getSettings();
});

/// Days remaining until independence.
final daysRemainingProvider = FutureProvider<int?>((ref) async {
  final dao = ref.watch(settingsDaoProvider);
  return dao.getDaysRemaining();
});

/// Independence date stream (for reactive UI).
final independenceDateProvider = StreamProvider<DateTime?>((ref) async* {
  final dao = ref.watch(settingsDaoProvider);
  // Poll every minute for countdown updates
  while (true) {
    final settings = await dao.getSettings();
    yield settings.independenceDate;
    await Future.delayed(const Duration(minutes: 1));
  }
});
