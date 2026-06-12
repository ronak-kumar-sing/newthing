class EnglishWord {
  final String word;
  final String meaning;
  final String exampleSentence;
  final String pronunciation;
  final String topic;

  const EnglishWord({
    required this.word,
    required this.meaning,
    required this.exampleSentence,
    this.pronunciation = '',
    this.topic = 'communication',
  });

  factory EnglishWord.fromJson(Map<String, dynamic> j) => EnglishWord(
    word: j['word'] ?? '',
    meaning: j['meaning'] ?? '',
    exampleSentence: j['example'] ?? '',
    pronunciation: j['pronunciation'] ?? '',
    topic: j['topic'] ?? 'communication',
  );

  Map<String, dynamic> toJson() => {
    'word': word, 'meaning': meaning, 'example': exampleSentence,
    'pronunciation': pronunciation, 'topic': topic,
  };
}

class DailyEnglishSession {
  final String date;
  final List<EnglishWord> words;
  final int testScore;
  final List<int> testAnswers;

  const DailyEnglishSession({
    required this.date,
    required this.words,
    this.testScore = -1,
    this.testAnswers = const [],
  });
}
