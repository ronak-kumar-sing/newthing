import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/database.dart';
import 'database_provider.dart';

/// Today's journal entry (reactive — refreshes when invalidated).
final todayJournalProvider = FutureProvider<JournalEntry?>((ref) async {
  final dao = ref.watch(journalDaoProvider);
  return dao.getTodayEntry();
});
