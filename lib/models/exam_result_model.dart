class ExamResultModel {
  final String id;
  final String examId;
  final String studentId;
  int score;
  final int totalQuestions;
  Map<String, String> answers;  // questionId -> selected option
  int timeTakenSeconds;
  final DateTime submittedAt;
  final bool isFirstAttempt;
  int correctCount;
  int incorrectCount;
  int unattemptedCount;
  bool dataRetained;
  final String examTitle;
  final String examType;

  // In-progress state
  bool isInProgress;
  DateTime? startedAt;
  int remainingSeconds;

  ExamResultModel({
    required this.id,
    required this.examId,
    required this.studentId,
    this.score = 0,
    required this.totalQuestions,
    Map<String, String>? answers,
    this.timeTakenSeconds = 0,
    required this.submittedAt,
    this.isFirstAttempt = true,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.unattemptedCount = 0,
    this.dataRetained = true,
    this.examTitle = '',
    this.examType = 'online',
    this.isInProgress = false,
    this.startedAt,
    this.remainingSeconds = 0,
  }) : answers = answers ?? {};

  // NEET marking: +4 correct, -1 wrong
  int get neetScore => (correctCount * 4) - incorrectCount;
  double get percentage => totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 0;

  ExamResultModel copyWithInProgress(bool inProgress) => ExamResultModel(
    id: id, examId: examId, studentId: studentId, score: score,
    totalQuestions: totalQuestions, answers: Map.from(answers),
    timeTakenSeconds: timeTakenSeconds, submittedAt: submittedAt,
    isFirstAttempt: isFirstAttempt, correctCount: correctCount,
    incorrectCount: incorrectCount, unattemptedCount: unattemptedCount,
    dataRetained: dataRetained, examTitle: examTitle, examType: examType,
    isInProgress: inProgress, startedAt: startedAt,
    remainingSeconds: remainingSeconds,
  );

  Map<String, dynamic> toMap() => {
        'id': id, 'examId': examId, 'studentId': studentId,
        'score': score, 'totalQuestions': totalQuestions,
        'answers': answers, 'timeTakenSeconds': timeTakenSeconds,
        'submittedAt': submittedAt.toIso8601String(),
        'isFirstAttempt': isFirstAttempt,
        'correctCount': correctCount, 'incorrectCount': incorrectCount,
        'unattemptedCount': unattemptedCount, 'dataRetained': dataRetained,
        'examTitle': examTitle, 'examType': examType,
        'isInProgress': isInProgress,
        'startedAt': startedAt?.toIso8601String(),
        'remainingSeconds': remainingSeconds,
      };

  factory ExamResultModel.fromMap(Map<String, dynamic> map) => ExamResultModel(
        id: map['id'],
        examId: map['examId'],
        studentId: map['studentId'],
        score: map['score'] ?? 0,
        totalQuestions: map['totalQuestions'] ?? 0,
        answers: Map<String, String>.from(map['answers'] ?? {}),
        timeTakenSeconds: map['timeTakenSeconds'] ?? 0,
        submittedAt: DateTime.parse(map['submittedAt']),
        isFirstAttempt: map['isFirstAttempt'] ?? true,
        correctCount: map['correctCount'] ?? 0,
        incorrectCount: map['incorrectCount'] ?? 0,
        unattemptedCount: map['unattemptedCount'] ?? 0,
        dataRetained: map['dataRetained'] ?? true,
        examTitle: map['examTitle'] ?? '',
        examType: map['examType'] ?? 'online',
        isInProgress: map['isInProgress'] ?? false,
        startedAt: map['startedAt'] != null ? DateTime.parse(map['startedAt']) : null,
        remainingSeconds: map['remainingSeconds'] ?? 0,
      );
}
