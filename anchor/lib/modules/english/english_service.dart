import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'english_word_model.dart';

class EnglishService {
  static const String _cacheKeyPrefix = 'anchor_english_';

  static const List<EnglishWord> _demoWords = [
    EnglishWord(
      word: "Articulate",
      meaning: "expressing ideas clearly and effectively in speech or writing",
      exampleSentence: "She was highly articulate during the job interview, impressing the panel.",
      pronunciation: "ar-TIK-yoo-lit",
      topic: "Professional",
    ),
    EnglishWord(
      word: "Collaborate",
      meaning: "to work together with others to achieve a common goal",
      exampleSentence: "We need to collaborate on this project to finish it by Friday.",
      pronunciation: "kuh-LAB-uh-reyt",
      topic: "Teamwork",
    ),
    EnglishWord(
      word: "Resilient",
      meaning: "able to withstand or recover quickly from difficult conditions",
      exampleSentence: "Indian startup founders are resilient and adapt to market shifts quickly.",
      pronunciation: "ri-ZIL-yuhnt",
      topic: "Personal Growth",
    ),
    EnglishWord(
      word: "Pragmatic",
      meaning: "dealing with things sensibly and realistically, based on practical experience",
      exampleSentence: "We need to take a pragmatic approach to solve this engineering bug.",
      pronunciation: "prag-MAT-ik",
      topic: "Problem Solving",
    ),
    EnglishWord(
      word: "Empathetic",
      meaning: "showing an ability to understand and share the feelings of others",
      exampleSentence: "An empathetic leader listens carefully to team members' concerns.",
      pronunciation: "em-puh-THET-ik",
      topic: "Leadership",
    ),
    EnglishWord(
      word: "Ambiguous",
      meaning: "open to more than one interpretation; having a double meaning",
      exampleSentence: "The instructions in the email were ambiguous, causing confusion.",
      pronunciation: "am-BIG-yoo-uhs",
      topic: "Communication",
    ),
    EnglishWord(
      word: "Meticulous",
      meaning: "showing great attention to detail; very careful and precise",
      exampleSentence: "She did a meticulous job preparing the slide deck for the seminar.",
      pronunciation: "muh-TIK-yuh-luhs",
      topic: "Work Ethic",
    ),
    EnglishWord(
      word: "Obsolete",
      meaning: "no longer produced or used; out of date",
      exampleSentence: "Without continuous learning, programming languages quickly become obsolete.",
      pronunciation: "ob-suh-LEET",
      topic: "Technology",
    ),
    EnglishWord(
      word: "Subtle",
      meaning: "so delicate or precise as to be difficult to analyze or describe",
      exampleSentence: "There was a subtle change in his tone when we discussed the budget.",
      pronunciation: "SUHT-l",
      topic: "Communication",
    ),
    EnglishWord(
      word: "Vibrant",
      meaning: "full of energy and enthusiasm",
      exampleSentence: "The university campus has a vibrant tech community.",
      pronunciation: "VAHY-bruhnt",
      topic: "Social",
    ),
  ];

  // Returns today's 10 words.
  // Uses demo words directly to ensure offline reliability and avoid API failures.
  static Future<List<EnglishWord>> getTodayWords({
    required String geminiApiKey,
    required String geminiModel,
  }) async {
    return _demoWords;
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<void> saveTestResult(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_cacheKeyPrefix}test_${_todayKey()}', score);
  }

  static Future<int> getTodayTestResult() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_cacheKeyPrefix}test_${_todayKey()}') ?? -1;
  }
}
