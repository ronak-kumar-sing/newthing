import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design/anchor_theme.dart';
import '../../core/widgets/glass_card.dart';
import 'english_word_model.dart';
import 'english_provider.dart';
import 'english_test_screen.dart';

class EnglishWordsListScreen extends ConsumerWidget {
  final List<EnglishWord> words;

  const EnglishWordsListScreen({super.key, required this.words});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final englishState = ref.watch(englishProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text("Today's Words", style: AnchorTheme.display(20)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AnchorTheme.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${words.length} Words",
                      style: AnchorTheme.label(11, color: AnchorTheme.accent),
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.08),
            ),

            // ─── Words List ───
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: words.length,
                itemBuilder: (context, index) {
                  final word = words[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassCard(
                      variant: GlassVariant.surface,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                word.word,
                                style: AnchorTheme.display(22, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              if (word.pronunciation.isNotEmpty)
                                Text(
                                  "/${word.pronunciation}/",
                                  style: AnchorTheme.label(12, color: Colors.white60),
                                ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                                ),
                                child: Text(
                                  word.topic.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AnchorTheme.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            word.meaning,
                            style: AnchorTheme.body(14, color: Colors.white.withOpacity(0.85)),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ─── Sticky Footer (Test Button) ───
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0C0C),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
              ),
              child: englishState.testTaken
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Today's Score",
                              style: AnchorTheme.label(12, color: Colors.white60),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${englishState.testScore} / 10",
                              style: AnchorTheme.display(20, color: AnchorTheme.accent),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.08),
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.1)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => EnglishTestScreen(words: words),
                            ));
                          },
                          child: Text("Retake Test", style: AnchorTheme.body(13, weight: FontWeight.w600)),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AnchorTheme.accent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => EnglishTestScreen(words: words),
                          ));
                        },
                        child: Text(
                          "Take Today's Test",
                          style: AnchorTheme.body(14, color: Colors.black, weight: FontWeight.w600),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
