import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Gemini API client for Anchor's AI features.
class GeminiApi {
  final Dio _dio;
  String? _apiKey;
  String _model = 'gemini-2.0-flash';

  GeminiApi({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(
    baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Set the Gemini API key.
  void setApiKey(String key) {
    _apiKey = key;
  }

  /// Set the Gemini model to use (e.g., 'gemini-2.0-flash').
  void setModel(String model) {
    _model = model;
  }

  /// Get the current model.
  String get currentModel => _model;

  /// Check if API key is set.
  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  /// Test connectivity — sends a simple prompt and checks for a valid response.
  Future<bool> testConnection() async {
    if (!isConfigured) return false;
    try {
      final response = await _dio.post(
        '/models/$_model:generateContent?key=$_apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {'text': 'Reply with only the word: OK'}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.0,
            'maxOutputTokens': 10,
          },
        },
      );
      final candidates = response.data['candidates'] as List<dynamic>?;
      return candidates != null && candidates.isNotEmpty;
    } catch (e) {
      debugPrint('Gemini testConnection error: $e');
      return false;
    }
  }

  /// List available Gemini models for the current API key.
  Future<List<String>> listModels() async {
    if (!isConfigured) return [];
    try {
      final response = await _dio.get('/models?key=$_apiKey');
      final models = response.data['models'] as List<dynamic>?;
      if (models == null) return [];
      return models
          .map((m) => (m['name'] as String).replaceFirst('models/', ''))
          .where((name) => name.startsWith('gemini'))
          .toList();
    } catch (e) {
      debugPrint('Gemini listModels error: $e');
      return ['gemini-2.0-flash', 'gemini-2.5-flash', 'gemini-2.5-pro'];
    }
  }

  /// Generate the morning briefing text.
  Future<String?> generateMorningBriefing({
    required int daysRemaining,
    required String? independenceLabel,
    required List<String> topTasks,
    required String? yesterdayScreenTime,
    required String? weeklyStudyHours,
    required int overdueTaskCount,
  }) async {
    final prompt = _buildMorningBriefPrompt(
      daysRemaining: daysRemaining,
      independenceLabel: independenceLabel,
      topTasks: topTasks,
      yesterdayScreenTime: yesterdayScreenTime,
      weeklyStudyHours: weeklyStudyHours,
      overdueTaskCount: overdueTaskCount,
    );
    return _generateContent(prompt);
  }

  /// Summarize WhatsApp messages into a digest.
  Future<String?> summarizeWhatsappMessages(String rawMessages) async {
    final prompt = '''
You are Anchor's WhatsApp Digest summarizer. Your job is to read through group chat messages and extract only what matters.

Rules:
- Identify announcements, deadlines, events, and action items
- Ignore forwards, memes, casual replies, greetings, and spam
- Format as clean bullet points
- Highlight anything with a deadline or required action
- Group by topic if multiple related messages exist

Messages to summarize:
$rawMessages

Provide the digest in this format:
- [Bullet point of important info]
- [Another bullet point]
- ACTION REQUIRED: [Specific action with deadline]

If nothing important is found, simply say: "No important updates found."
''';
    return _generateContent(prompt);
  }

  /// Generate AI Coach response based on full context.
  Future<String?> generateCoachResponse({
    required String question,
    required int daysRemaining,
    required String? independenceLabel,
    required List<String> activeTasks,
    required Map<String, dynamic> weeklyProgress,
    required String? screenTimeSummary,
    List<Map<String, String>> chatHistory = const [],
  }) async {
    final historyText = chatHistory.isEmpty
        ? ''
        : '\nRecent conversation:\n${chatHistory.map((m) => '${m['role']}: ${m['content']}').join('\n')}\n';

    final prompt = '''
You are Anchor's AI Daily Coach. You have deep context about the user's life and goals. Your tone is honest, direct, and encouraging — never generic, never cheerleader-like.

User Context:
- Days until ${independenceLabel ?? 'goal'}: $daysRemaining
- Active tasks: ${activeTasks.isEmpty ? 'None' : activeTasks.join(', ')}
- Weekly progress: ${jsonEncode(weeklyProgress)}
- Screen time summary: ${screenTimeSummary ?? 'N/A'}
$historyText
User's Question: $question

Respond with specific, actionable advice based on the context above. Reference actual numbers and tasks. Be concise (2-4 sentences max unless planning a schedule).
''';
    return _generateContent(prompt);
  }

  /// Generate weekly reflection.
  Future<String?> generateWeeklyReflection({
    required Map<String, dynamic> weekData,
  }) async {
    final prompt = '''
You are Anchor's Weekly Reflection writer. Write an honest, direct 3-4 sentence summary of the user's week based on the data below.

Week Data:
${jsonEncode(weekData)}

Rules:
- Be honest, not cheerleading
- Identify the strongest pattern (positive or negative)
- Mention one specific thing to pay attention to next week
- Keep it to 3-4 sentences
- Never use templates or generic phrases like "great week"
''';
    return _generateContent(prompt);
  }

  /// Generate a study/exam plan.
  Future<String?> generateStudyPlan({
    required String examName,
    required DateTime examDate,
    required List<String> topics,
    required int availableHoursPerDay,
  }) async {
    final prompt = '''
You are Anchor's Study Plan Generator. Create a day-by-day study plan.

Exam: $examName
Date: ${examDate.toIso8601String().split('T').first}
Topics to cover: ${topics.join(', ')}
Available hours per day: $availableHoursPerDay

Create a structured plan showing:
1. How to distribute topics across available days
2. Daily schedule with breaks
3. Review sessions
4. Final day buffer

Format as a clear, day-by-day breakdown.
''';
    return _generateContent(prompt);
  }

  /// Generic content generation — uses the current model.
  Future<String?> _generateContent(String prompt) async {
    if (!isConfigured) {
      debugPrint('Gemini API key not configured');
      return null;
    }

    try {
      final response = await _dio.post(
        '/models/$_model:generateContent?key=$_apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1024,
          },
        },
      );

      final candidates = response.data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) return null;

      final content = candidates.first['content'] as Map<String, dynamic>?;
      if (content == null) return null;

      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) return null;

      return parts.first['text'] as String?;
    } catch (e) {
      debugPrint('Gemini API error ($_model): $e');
      return null;
    }
  }

  String _buildMorningBriefPrompt({
    required int daysRemaining,
    required String? independenceLabel,
    required List<String> topTasks,
    required String? yesterdayScreenTime,
    required String? weeklyStudyHours,
    required int overdueTaskCount,
  }) {
    return '''
You are Anchor's Morning Brief writer. Write a single, powerful sentence that serves as the user's daily orientation message.

Context:
- Days until ${independenceLabel ?? 'goal'}: $daysRemaining
- Today's top tasks: ${topTasks.isEmpty ? 'None set' : topTasks.join(', ')}
- Yesterday's screen time: ${yesterdayScreenTime ?? 'N/A'}
- Weekly study hours so far: ${weeklyStudyHours ?? 'N/A'}
- Overdue tasks: $overdueTaskCount

Rules:
- Write ONE sentence (max 2 if needed)
- Be specific, not generic
- If screen time was high yesterday, acknowledge it honestly
- If tasks are overdue, mention it
- If they're on track, acknowledge that too
- Never use clichés like "you got this" or "seize the day"
- The tone is calm, honest, and direct

Write the morning brief message:
''';
  }
}
