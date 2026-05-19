class PYQModel {
  final String id;
  final String year;
  final String chapter;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;
  final String? imageUrl;
  final String? explanation;

  const PYQModel({
    required this.id,
    required this.year,
    required this.chapter,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    this.imageUrl,
    this.explanation,
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
        'id': id, 'year': year, 'chapter': chapter, 'question': question,
        'optionA': optionA, 'optionB': optionB, 'optionC': optionC, 'optionD': optionD,
        'correctOption': correctOption, 'imageUrl': imageUrl, 'explanation': explanation,
      };

  factory PYQModel.fromMap(Map<String, dynamic> map) => PYQModel(
        id: map['id'] ?? '',
        year: map['year']?.toString() ?? '2024',
        chapter: map['chapter'] ?? '',
        question: map['question'] ?? '',
        optionA: map['optionA'] ?? '',
        optionB: map['optionB'] ?? '',
        optionC: map['optionC'] ?? '',
        optionD: map['optionD'] ?? '',
        correctOption: map['correctOption'] ?? 'A',
        imageUrl: map['imageUrl'],
        explanation: map['explanation'],
      );

  factory PYQModel.fromCsvRow(List<dynamic> row, int index, String yearName) {
    // We expect at least 8 columns. Usually year was column 0.
    // We assign `yearName` instead of parsing row[0].
    // If the CSV still has a year column, row[1] is chapter.
    // To support old CSV formats, we assume row[1] is chapter, row[2] is question.
    return PYQModel(
      id: 'pyq_${index}_${DateTime.now().millisecondsSinceEpoch}',
      year: yearName,
      chapter: row[1].toString(),
      question: row[2].toString(),
      optionA: row[3].toString(),
      optionB: row[4].toString(),
      optionC: row[5].toString(),
      optionD: row[6].toString(),
      correctOption: row[7].toString().toUpperCase(),
      imageUrl: row.length > 8 && row[8].toString().isNotEmpty ? row[8].toString() : null,
      explanation: row.length > 9 && row[9].toString().isNotEmpty ? row[9].toString() : null,
    );
  }
}
