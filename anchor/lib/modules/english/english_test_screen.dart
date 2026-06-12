import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/anchor_theme.dart';
import '../../core/widgets/glass_card.dart';
import 'english_word_model.dart';
import 'english_provider.dart';

class EnglishTestScreen extends ConsumerStatefulWidget {
  final List<EnglishWord> words;

  const EnglishTestScreen({super.key, required this.words});

  @override
  ConsumerState<EnglishTestScreen> createState() => _EnglishTestScreenState();
}

class _EnglishTestScreenState extends ConsumerState<EnglishTestScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _isFinished = false;
  
  late List<_Question> _questions;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    final random = Random();
    _questions = widget.words.map((word) {
      final otherWords = widget.words.where((w) => w.word != word.word).toList();
      otherWords.shuffle(random);
      
      final options = [
        word.meaning,
        otherWords[0].meaning,
        otherWords[1].meaning,
        otherWords[2].meaning,
      ];
      options.shuffle(random);
      
      return _Question(
        word: word.word,
        correctMeaning: word.meaning,
        options: options,
      );
    }).toList();
    _questions.shuffle(random);
  }

  void _answerQuestion(String selectedOption) {
    if (selectedOption == _questions[_currentIndex].correctMeaning) {
      _score++;
    }
    
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      setState(() {
        _isFinished = true;
      });
      ref.read(englishProvider.notifier).submitTestScore(_score);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text("Daily Test", style: AnchorTheme.display(18)),
                  const Spacer(),
                  if (!_isFinished)
                    Text(
                      "${_currentIndex + 1} / ${_questions.length}",
                      style: AnchorTheme.label(14),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _isFinished ? _buildResults() : _buildQuestion(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final question = _questions[_currentIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "What is the meaning of...",
            style: AnchorTheme.label(14, color: Colors.white.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            question.word,
            style: AnchorTheme.display(32),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...question.options.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => _answerQuestion(option),
                  borderRadius: BorderRadius.circular(16),
                  child: GlassCard(
                    variant: GlassVariant.surface,
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      option,
                      style: AnchorTheme.body(15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _score >= 7 ? "Great Job! 🎉" : "Keep Practicing! 💪",
          style: AnchorTheme.display(24),
        ),
        const SizedBox(height: 20),
        Text(
          "Your Score",
          style: AnchorTheme.label(14, color: Colors.white.withOpacity(0.6)),
        ),
        const SizedBox(height: 8),
        Text(
          "$_score / ${_questions.length}",
          style: AnchorTheme.display(48, color: const Color(0xFFC6F52C)),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC6F52C),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text("Done", style: AnchorTheme.body(16, color: Colors.black)),
        ),
      ],
    );
  }
}

class _Question {
  final String word;
  final String correctMeaning;
  final List<String> options;

  _Question({
    required this.word,
    required this.correctMeaning,
    required this.options,
  });
}
