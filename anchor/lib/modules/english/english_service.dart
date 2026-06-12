import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'english_word_model.dart';

class EnglishService {
  static const String _cacheKeyPrefix = 'anchor_english_';

  // Returns today's 10 words.
  // Uses cached version if already fetched today.
  // Only calls Gemini if no cache for today exists.
  static Future<List<EnglishWord>> getTodayWords({
    required String geminiApiKey,
    required String geminiModel,
  }) async {
    final today = _todayKey();
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$_cacheKeyPrefix$today');

    if (cached != null && cached.isNotEmpty) {
      try {
        final List json = jsonDecode(cached) as List;
        return json.map((j) => EnglishWord.fromJson(j as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    final words = await _fetchFromGemini(
      apiKey: geminiApiKey,
      model: geminiModel,
    );

    final encoded = jsonEncode(words.map((w) => w.toJson()).toList());
    await prefs.setString('$_cacheKeyPrefix$today', encoded);

    _cleanOldCache(prefs);

    return words;
  }

  static Future<List<EnglishWord>> _fetchFromGemini({
    required String apiKey,
    required String model,
  }) async {
    final prompt = """
Generate exactly 10 English words that are useful for daily communication,
especially for an Indian college student in professional and social situations.

Rules:
- Choose practical words used in conversations, emails, interviews, discussions.
- Mix of formal and casual words.
- Meanings should be simple and clear (1 sentence max).
- Example sentences should be realistic and relatable.

Return ONLY a valid JSON array. No markdown, no explanation, no code blocks.
Just the raw JSON array:
[
  {
    "word": "articulate",
    "meaning": "to express ideas clearly and effectively",
    "example": "She was very articulate during the group discussion.",
    "pronunciation": "ar-TIK-yoo-let",
    "topic": "professional"
  }
]
""";

    final response = await http.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '$model:generateContent?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [{'parts': [{'text': prompt}]}],
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 1500,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final text = data['candidates'][0]['content']['parts'][0]['text'] as String;

    final cleaned = text
      .replaceAll('```json', '')
      .replaceAll('```', '')
      .trim();

    final List parsed = jsonDecode(cleaned) as List;
    return parsed.take(10).map((j) => EnglishWord.fromJson(j as Map<String, dynamic>)).toList();
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }

  static void _cleanOldCache(SharedPreferences prefs) {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final keys = prefs.getKeys().where((k) => k.startsWith(_cacheKeyPrefix));
    for (final k in keys) {
      if (k.startsWith('${_cacheKeyPrefix}test_')) continue;
      final datePart = k.substring(_cacheKeyPrefix.length);
      try {
        final date = DateTime.parse(datePart);
        if (date.isBefore(cutoff)) prefs.remove(k);
      } catch (_) {}
    }
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
