import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exam_model.dart';
import '../models/question_model.dart';
import '../models/exam_result_model.dart';
import '../services/supabase_service.dart';
import '../services/ai_service.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// Temporary in-memory store for PYQ results (PYQ exams don't save to Supabase)
final pyqLastResultProvider = StateProvider<ExamResultModel?>((ref) => null);
final pyqLastQuestionsProvider = StateProvider<List<QuestionModel>>((ref) => const []);

// All exams (admin view)
final allExamsProvider = StreamProvider<List<ExamModel>>((ref) {
  return SupabaseService.instance.streamAllExams();
});

// Active exams for a specific batch (student view)
final batchExamsProvider = StreamProvider.family<List<ExamModel>, String>((ref, batch) {
  return SupabaseService.instance.streamActiveExamsForBatch(batch);
});

// Questions for a specific exam
final examQuestionsProvider = FutureProvider.family<List<QuestionModel>, String>((ref, examId) async {
  return SupabaseService.instance.getQuestionsForExam(examId);
});

// Single exam
final examDetailProvider = FutureProvider.family<ExamModel?, String>((ref, examId) async {
  return SupabaseService.instance.getExam(examId);
});

// ---- EXAM CREATION NOTIFIER ----
class ExamCreatorState {
  final ExamModel? exam;
  final List<QuestionModel> questions;
  final bool isGenerating;
  final bool isSaving;
  final String? error;

  const ExamCreatorState({
    this.exam,
    this.questions = const [],
    this.isGenerating = false,
    this.isSaving = false,
    this.error,
  });

  ExamCreatorState copyWith({
    ExamModel? exam,
    List<QuestionModel>? questions,
    bool? isGenerating,
    bool? isSaving,
    String? error,
  }) => ExamCreatorState(
        exam: exam ?? this.exam,
        questions: questions ?? this.questions,
        isGenerating: isGenerating ?? this.isGenerating,
        isSaving: isSaving ?? this.isSaving,
        error: error,
      );
}

class ExamCreatorNotifier extends StateNotifier<ExamCreatorState> {
  ExamCreatorNotifier() : super(const ExamCreatorState());

  void initNewExam(String adminId) {
    final exam = ExamModel(
      id: _uuid.v4(),
      title: '',
      targetBatches: [],
      durationMinutes: 60,
      createdAt: DateTime.now(),
      createdBy: adminId,
    );
    state = ExamCreatorState(exam: exam, questions: []);
  }

  void loadExam(ExamModel exam, List<QuestionModel> questions) {
    state = ExamCreatorState(exam: exam, questions: questions);
  }

  void updateExam(ExamModel exam) {
    state = state.copyWith(exam: exam);
  }

  void addQuestion(QuestionModel q) {
    state = state.copyWith(questions: [...state.questions, q]);
  }

  void removeQuestion(String id) {
    state = state.copyWith(questions: state.questions.where((q) => q.id != id).toList());
  }

  void updateQuestion(QuestionModel q) {
    final updated = state.questions.map((existing) => existing.id == q.id ? q : existing).toList();
    state = state.copyWith(questions: updated);
  }

  void reorderQuestions(int oldIndex, int newIndex) {
    final list = [...state.questions];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(questions: list);
  }

  Future<void> generateWithAI({
    required List<String> chapters,
    required String difficulty,
    required int count,
    String? prompt,
    int? selectedClass,
    required String apiKey,
  }) async {
    state = state.copyWith(isGenerating: true, error: null);
    AiService.instance.setApiKey(apiKey);
    try {
      final questions = await AiService.instance.generateExamQuestions(
        chapters: chapters,
        difficulty: difficulty,
        count: count,
        prompt: prompt,
        selectedClass: selectedClass,
      );
      final withExamId = questions.map((q) => QuestionModel(
        id: q.id, text: q.text, optionA: q.optionA, optionB: q.optionB,
        optionC: q.optionC, optionD: q.optionD, correctOption: q.correctOption,
        imageUrl: q.imageUrl, explanation: q.explanation,
        chapter: q.chapter, difficulty: q.difficulty, examId: state.exam?.id,
      )).toList();
      state = state.copyWith(questions: [...state.questions, ...withExamId], isGenerating: false);
    } catch (e) {
      state = state.copyWith(isGenerating: false, error: e.toString());
    }
  }

  Future<bool> saveExam() async {
    final exam = state.exam;
    if (exam == null) return false;
    state = state.copyWith(isSaving: true, error: null);
    try {
      // Link questions to exam
      final linkedQ = state.questions.asMap().entries.map((e) => QuestionModel(
        id: e.value.id, text: e.value.text, optionA: e.value.optionA,
        optionB: e.value.optionB, optionC: e.value.optionC, optionD: e.value.optionD,
        correctOption: e.value.correctOption, imageUrl: e.value.imageUrl,
        explanation: e.value.explanation, chapter: e.value.chapter,
        difficulty: e.value.difficulty, examId: exam.id,
      )).toList();

      final finalExam = exam.copyWith(
        questionIds: linkedQ.map((q) => q.id).toList(),
      );
      await SupabaseService.instance.upsertExam(finalExam);
      await SupabaseService.instance.upsertQuestions(linkedQ);
      state = state.copyWith(isSaving: false, exam: finalExam);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

final examCreatorProvider = StateNotifierProvider<ExamCreatorNotifier, ExamCreatorState>(
  (_) => ExamCreatorNotifier(),
);

// ---- EXAM RESULTS ----
final studentResultsProvider = StreamProvider.family<List<ExamResultModel>, String>((ref, studentId) {
  return SupabaseService.instance.streamFirstAttemptResults(studentId);
});

final examAllResultsProvider = FutureProvider.family<List<ExamResultModel>, String>((ref, examId) async {
  return SupabaseService.instance.getAllResultsForExam(examId);
});

final inProgressExamProvider = FutureProvider.family<ExamResultModel?, String>((ref, studentId) async {
  return SupabaseService.instance.getInProgressExam(studentId);
});

// Last 10 completed attempts (any attempt) — used for History screen
final studentRecentAttemptsProvider = StreamProvider.family<List<ExamResultModel>, String>((ref, studentId) {
  return SupabaseService.instance.streamStudentResults(studentId).map(
    (results) => results.where((r) => !r.isInProgress).take(10).toList(),
  );
});

// Latest (most recent) completed result for a specific student+exam.
// Derived from the already-streaming studentRecentAttemptsProvider —
// no extra DB connection needed, updates automatically when results change.
final latestExamResultProvider =
    Provider.family<ExamResultModel?, (String, String)>((ref, args) {
  final studentId = args.$1;
  final examId    = args.$2;
  return ref.watch(studentRecentAttemptsProvider(studentId)).when(
    data: (results) {
      final forExam = results
          .where((r) => r.examId == examId && !r.isInProgress)
          .toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return forExam.isEmpty ? null : forExam.first;
    },
    loading: () => null,
    error:   (_, __) => null,
  );
});
