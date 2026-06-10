import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database.dart';
import 'database_provider.dart';

/// Current active chat session ID.
/// Generates a new one on every cold start.
final chatSessionProvider = StateProvider<String>(
  (ref) => 'session_${DateTime.now().millisecondsSinceEpoch}',
);

/// Messages for the current chat session as a reactive stream.
final chatMessagesProvider = StreamProvider<List<ChatMessage>>((ref) {
  final sessionId = ref.watch(chatSessionProvider);
  final dao = ref.watch(chatDaoProvider);
  return dao.watchSessionMessages(sessionId);
});

/// All past sessions (latest message per session), for history view.
final chatSessionsProvider = FutureProvider<List<ChatMessage>>((ref) async {
  final dao = ref.watch(chatDaoProvider);
  return dao.getLatestMessagePerSession();
});
