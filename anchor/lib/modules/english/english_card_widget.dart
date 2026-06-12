import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design/anchor_theme.dart';
import '../../core/widgets/glass_card.dart';
import 'english_word_model.dart';

class WordOfTheDayCard extends StatelessWidget {
  final EnglishWord word;
  final VoidCallback onSeeAll;
  final VoidCallback onStartTest;
  final bool testTaken;
  final int testScore;

  const WordOfTheDayCard({
    super.key,
    required this.word,
    required this.onSeeAll,
    required this.onStartTest,
    required this.testTaken,
    required this.testScore,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      variant: GlassVariant.surface,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Text("📖", style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text("Word of the Day", style: AnchorTheme.label(12)),
              const Spacer(),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  "See all 10 →",
                  style: AnchorTheme.label(12, color: const Color(0xFFC6F52C)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Word + pronunciation
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(word.word, style: AnchorTheme.display(28)),
              if (word.pronunciation.isNotEmpty) ...[
                const SizedBox(width: 10),
                Text(
                  "/${word.pronunciation}/",
                  style: AnchorTheme.label(13),
                ),
              ],
            ],
          ),

          const SizedBox(height: 6),

          // Meaning
          Text(
            word.meaning,
            style: AnchorTheme.body(14, color: Colors.white.withOpacity(0.70)),
          ),

          const SizedBox(height: 8),

          // Example sentence
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Text(
              '"${word.exampleSentence}"',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.white.withOpacity(0.55),
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Test button / score
          testTaken
              ? Row(
                  children: [
                    Text("Today's score: ", style: AnchorTheme.label(13)),
                    Text(
                      "$testScore / 10",
                      style: AnchorTheme.display(
                        15,
                        color: testScore >= 7
                            ? const Color(0xFF4ADE80)
                            : testScore >= 5
                                ? const Color(0xFFFF9800)
                                : const Color(0xFFFF4444),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onStartTest,
                      child: Text(
                        "Retake →",
                        style: AnchorTheme.label(12, color: const Color(0xFFC6F52C)),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFC6F52C)),
                      foregroundColor: const Color(0xFFC6F52C),
                    ),
                    onPressed: onStartTest,
                    child: Text(
                      "Take Today's Test",
                      style: AnchorTheme.body(13, color: const Color(0xFFC6F52C)),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
