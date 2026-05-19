import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pyq_model.dart';
import '../services/supabase_service.dart';

final allPYQProvider = FutureProvider<List<PYQModel>>((ref) async {
  return SupabaseService.instance.getAllPYQ();
});

final pyqYearsProvider = FutureProvider<List<String>>((ref) async {
  return SupabaseService.instance.getAvailablePYQYears();
});

final pyqChaptersProvider = FutureProvider<List<String>>((ref) async {
  return SupabaseService.instance.getAvailablePYQChapters();
});

final pyqByChapterProvider = FutureProvider.family<List<PYQModel>, String>((ref, chapter) async {
  return SupabaseService.instance.getPYQByChapter(chapter);
});

final pyqByYearsProvider = FutureProvider.family<List<PYQModel>, List<String>>((ref, years) async {
  return SupabaseService.instance.getPYQByYears(years);
});

final pyqByYearProvider = FutureProvider.family<List<PYQModel>, String>((ref, year) async {
  return SupabaseService.instance.getPYQByYears([year]);
});

final pyqByChaptersProvider = FutureProvider.family<List<PYQModel>, List<String>>((ref, chapters) async {
  return SupabaseService.instance.getPYQByChapters(chapters);
});

// PYQ Test state
class PYQTestState {
  final List<PYQModel> questions;
  final Map<String, String> answers;
  final int currentIndex;
  final bool isSubmitted;
  final int? correctCount;
  final int? incorrectCount;

  const PYQTestState({
    this.questions = const [],
    this.answers = const {},
    this.currentIndex = 0,
    this.isSubmitted = false,
    this.correctCount,
    this.incorrectCount,
  });

  PYQTestState copyWith({
    List<PYQModel>? questions,
    Map<String, String>? answers,
    int? currentIndex,
    bool? isSubmitted,
    int? correctCount,
    int? incorrectCount,
  }) => PYQTestState(
        questions: questions ?? this.questions,
        answers: answers ?? Map.from(this.answers),
        currentIndex: currentIndex ?? this.currentIndex,
        isSubmitted: isSubmitted ?? this.isSubmitted,
        correctCount: correctCount ?? this.correctCount,
        incorrectCount: incorrectCount ?? this.incorrectCount,
      );
}

class PYQTestNotifier extends StateNotifier<PYQTestState> {
  PYQTestNotifier() : super(const PYQTestState());

  void startTest(List<PYQModel> questions) {
    state = PYQTestState(questions: questions);
  }

  void answerQuestion(String questionId, String option) {
    final answers = Map<String, String>.from(state.answers);
    answers[questionId] = option;
    state = state.copyWith(answers: answers);
  }

  void goToQuestion(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void submit() {
    int correct = 0, incorrect = 0;
    for (final q in state.questions) {
      final ans = state.answers[q.id];
      if (ans == null) continue;
      if (ans == q.correctOption) correct++;
      else incorrect++;
    }
    state = state.copyWith(isSubmitted: true, correctCount: correct, incorrectCount: incorrect);
  }

  void reset() => state = const PYQTestState();
}

final pyqTestProvider = StateNotifierProvider<PYQTestNotifier, PYQTestState>(
  (_) => PYQTestNotifier(),
);
