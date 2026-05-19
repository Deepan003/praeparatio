class QuestionModel {
  final String id;
  final String text;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;
  final String? imageUrl;
  final String? explanation;
  final String chapter;
  final String difficulty;
  final String? examId;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    this.imageUrl,
    this.explanation,
    required this.chapter,
    this.difficulty = 'Medium',
    this.examId,
  });

  String optionText(String option) {
    switch (option.toUpperCase()) {
      case 'A': return optionA;
      case 'B': return optionB;
      case 'C': return optionC;
      case 'D': return optionD;
      default: return '';
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id, 'text': text, 'optionA': optionA, 'optionB': optionB,
        'optionC': optionC, 'optionD': optionD, 'correctOption': correctOption,
        'imageUrl': imageUrl, 'explanation': explanation,
        'chapter': chapter, 'difficulty': difficulty, 'examId': examId,
      };

  factory QuestionModel.fromMap(Map<String, dynamic> map) => QuestionModel(
        id: map['id'] ?? '',
        text: map['text'] ?? '',
        optionA: map['optionA'] ?? '',
        optionB: map['optionB'] ?? '',
        optionC: map['optionC'] ?? '',
        optionD: map['optionD'] ?? '',
        correctOption: map['correctOption'] ?? 'A',
        imageUrl: map['imageUrl'],
        explanation: map['explanation'],
        chapter: map['chapter'] ?? '',
        difficulty: map['difficulty'] ?? 'Medium',
        examId: map['examId'],
      );

  QuestionModel copyWith({
    String? text, String? optionA, String? optionB, String? optionC, String? optionD,
    String? correctOption, String? imageUrl, String? explanation, String? chapter, String? difficulty,
  }) => QuestionModel(
        id: id,
        text: text ?? this.text,
        optionA: optionA ?? this.optionA,
        optionB: optionB ?? this.optionB,
        optionC: optionC ?? this.optionC,
        optionD: optionD ?? this.optionD,
        correctOption: correctOption ?? this.correctOption,
        imageUrl: imageUrl ?? this.imageUrl,
        explanation: explanation ?? this.explanation,
        chapter: chapter ?? this.chapter,
        difficulty: difficulty ?? this.difficulty,
        examId: examId,
      );
}
