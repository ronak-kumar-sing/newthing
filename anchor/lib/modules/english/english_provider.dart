import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'english_word_model.dart';
import 'english_service.dart';

final englishProvider = StateNotifierProvider<EnglishNotifier, EnglishState>((ref) {
  return EnglishNotifier();
});

class EnglishState {
  final List<EnglishWord> words;
  final bool isLoading;
  final String? error;
  final int testScore;

  EnglishState({
    this.words = const [],
    this.isLoading = false,
    this.error,
    this.testScore = -1,
  });

  EnglishState copyWith({
    List<EnglishWord>? words,
    bool? isLoading,
    String? error,
    int? testScore,
  }) {
    return EnglishState(
      words: words ?? this.words,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      testScore: testScore ?? this.testScore,
    );
  }

  bool get hasWords => words.isNotEmpty;
  bool get testTaken => testScore >= 0;
  EnglishWord? get wordOfDay => words.isNotEmpty ? words.first : null;
}

class EnglishNotifier extends StateNotifier<EnglishState> {
  EnglishNotifier() : super(EnglishState());

  Future<void> loadTodayWords({
    required String geminiApiKey,
    required String geminiModel,
  }) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final words = await EnglishService.getTodayWords(
        geminiApiKey: geminiApiKey,
        geminiModel: geminiModel,
      );
      final score = await EnglishService.getTodayTestResult();
      state = state.copyWith(words: words, testScore: score, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> submitTestScore(int score) async {
    await EnglishService.saveTestResult(score);
    state = state.copyWith(testScore: score);
  }
}
