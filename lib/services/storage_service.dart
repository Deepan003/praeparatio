import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/exam_model.dart';
import '../models/question_model.dart';
import '../models/exam_result_model.dart';
import '../models/pyq_model.dart';
import '../models/flashcard_model.dart';
import '../models/lesson_plan_model.dart';
import '../models/note_model.dart';
import '../models/offline_test_model.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  late Box _users;
  late Box _exams;
  late Box _questions;
  late Box _results;
  late Box _pyq;
  late Box _flashcards;
  late Box _lessonPlans;
  late Box _notes;
  late Box _offlineTests;
  late Box _settings;

  Future<void> init() async {
    await Hive.initFlutter();
    _users = await Hive.openBox(AppConstants.usersBox);
    _exams = await Hive.openBox(AppConstants.examsBox);
    _questions = await Hive.openBox(AppConstants.questionsBox);
    _results = await Hive.openBox(AppConstants.resultsBox);
    _pyq = await Hive.openBox(AppConstants.pyqBox);
    _flashcards = await Hive.openBox(AppConstants.flashcardsBox);
    _lessonPlans = await Hive.openBox(AppConstants.lessonPlansBox);
    _notes = await Hive.openBox(AppConstants.notesBox);
    _offlineTests = await Hive.openBox(AppConstants.offlineTestsBox);
    _settings = await Hive.openBox(AppConstants.settingsBox);
  }

  // ---- USERS ----
  Future<void> saveUser(UserModel user) async =>
      await _users.put(user.id, user.toMap());

  UserModel? getUser(String id) {
    final data = _users.get(id);
    if (data == null) return null;
    return UserModel.fromMap(Map<String, dynamic>.from(data));
  }

  UserModel? getUserByUsername(String username) {
    for (final key in _users.keys) {
      final data = _users.get(key);
      if (data != null) {
        final map = Map<String, dynamic>.from(data);
        if (map['username'] == username) return UserModel.fromMap(map);
      }
    }
    return null;
  }

  List<UserModel> getAllUsers() {
    return _users.values
        .map((v) => UserModel.fromMap(Map<String, dynamic>.from(v)))
        .where((u) => !u.isAdmin)
        .toList();
  }

  List<UserModel> getUsersByBatch(String batch) =>
      getAllUsers().where((u) => u.batch == batch).toList();

  Future<void> deleteUser(String id) async => await _users.delete(id);

  // ---- EXAMS ----
  Future<void> saveExam(ExamModel exam) async =>
      await _exams.put(exam.id, exam.toMap());

  ExamModel? getExam(String id) {
    final data = _exams.get(id);
    if (data == null) return null;
    return ExamModel.fromMap(Map<String, dynamic>.from(data));
  }

  List<ExamModel> getAllExams() => _exams.values
      .map((v) => ExamModel.fromMap(Map<String, dynamic>.from(v)))
      .toList();

  List<ExamModel> getExamsForBatch(String batch) => getAllExams()
      .where((e) => e.isActive && e.targetBatches.contains(batch))
      .toList();

  Future<void> deleteExam(String id) async {
    final exam = getExam(id);
    if (exam != null) {
      for (final qId in exam.questionIds) await _questions.delete(qId);
    }
    await _exams.delete(id);
  }

  // ---- QUESTIONS ----
  Future<void> saveQuestion(QuestionModel q) async =>
      await _questions.put(q.id, q.toMap());

  QuestionModel? getQuestion(String id) {
    final data = _questions.get(id);
    if (data == null) return null;
    return QuestionModel.fromMap(Map<String, dynamic>.from(data));
  }

  List<QuestionModel> getQuestionsForExam(List<String> ids) => ids
      .map(getQuestion)
      .whereType<QuestionModel>()
      .toList();

  Future<void> saveQuestions(List<QuestionModel> questions) async {
    for (final q in questions) await saveQuestion(q);
  }

  // ---- RESULTS ----
  Future<void> saveResult(ExamResultModel result) async =>
      await _results.put(result.id, result.toMap());

  ExamResultModel? getResult(String id) {
    final data = _results.get(id);
    if (data == null) return null;
    return ExamResultModel.fromMap(Map<String, dynamic>.from(data));
  }

  List<ExamResultModel> getResultsForStudent(String studentId) => _results.values
      .map((v) => ExamResultModel.fromMap(Map<String, dynamic>.from(v)))
      .where((r) => r.studentId == studentId)
      .toList();

  List<ExamResultModel> getFirstAttemptResults(String studentId) =>
      getResultsForStudent(studentId).where((r) => r.isFirstAttempt).toList();

  ExamResultModel? getInProgressExam(String studentId) {
    try {
      return getResultsForStudent(studentId).firstWhere((r) => r.isInProgress);
    } catch (_) { return null; }
  }

  ExamResultModel? getFirstAttemptForExam(String studentId, String examId) {
    try {
      return getResultsForStudent(studentId)
          .firstWhere((r) => r.examId == examId && r.isFirstAttempt);
    } catch (_) { return null; }
  }

  List<ExamResultModel> getAllResultsForExam(String examId) => _results.values
      .map((v) => ExamResultModel.fromMap(Map<String, dynamic>.from(v)))
      .where((r) => r.examId == examId && r.isFirstAttempt)
      .toList();

  // ---- PYQ ----
  Future<void> savePYQBatch(List<PYQModel> questions) async {
    await _pyq.clear();
    for (int i = 0; i < questions.length; i++) {
      await _pyq.put('pyq_$i', questions[i].toMap());
    }
  }

  List<PYQModel> getAllPYQ() => _pyq.values
      .map((v) => PYQModel.fromMap(Map<String, dynamic>.from(v)))
      .toList();

  List<PYQModel> getPYQByChapter(String chapter) =>
      getAllPYQ().where((q) => q.chapter == chapter).toList();

  List<PYQModel> getPYQByYear(String year) =>
      getAllPYQ().where((q) => q.year == year).toList();

  List<PYQModel> getPYQByYears(List<String> years) =>
      getAllPYQ().where((q) => years.contains(q.year)).toList();

  List<PYQModel> getPYQByChapters(List<String> chapters) =>
      getAllPYQ().where((q) => chapters.contains(q.chapter)).toList();

  // ---- FLASHCARDS ----
  Future<void> saveFlashcard(FlashcardModel card) async =>
      await _flashcards.put(card.id, card.toMap());

  Future<void> saveFlashcardsBatch(List<FlashcardModel> cards) async {
    for (final c in cards) await saveFlashcard(c);
  }

  List<FlashcardModel> getFlashcardsByChapter(String chapter) => _flashcards.values
      .map((v) => FlashcardModel.fromMap(Map<String, dynamic>.from(v)))
      .where((c) => c.chapter == chapter)
      .toList();

  List<String> getFlashcardChapters() {
    final chapters = <String>{};
    for (final v in _flashcards.values) {
      final map = Map<String, dynamic>.from(v);
      chapters.add(map['chapter'] as String);
    }
    return chapters.toList()..sort();
  }

  // ---- LESSON PLANS ----
  Future<void> saveLessonPlan(LessonPlanModel plan) async =>
      await _lessonPlans.put(plan.id, plan.toMap());

  List<LessonPlanModel> getLessonPlans(String studentId) => _lessonPlans.values
      .map((v) => LessonPlanModel.fromMap(Map<String, dynamic>.from(v)))
      .where((p) => p.studentId == studentId)
      .toList();

  Future<void> deleteLessonPlan(String id) async => await _lessonPlans.delete(id);

  // ---- NOTES & LINKS ----
  Future<void> saveNote(NoteModel note) async =>
      await _notes.put(note.id, note.toMap());

  List<NoteModel> getAllNotes({bool linksOnly = false, bool notesOnly = false}) {
    final all = _notes.values
        .map((v) => NoteModel.fromMap(Map<String, dynamic>.from(v)))
        .toList();
    if (linksOnly) return all.where((n) => n.isLink).toList();
    if (notesOnly) return all.where((n) => !n.isLink).toList();
    return all;
  }

  List<NoteModel> getNotesForUser(String batch, {bool linksOnly = false}) {
    return getAllNotes(linksOnly: linksOnly).where((n) {
      if (n.visibility == 'all') return true;
      if (n.visibility == '11' && batch == '11 NEET') return true;
      if (n.visibility == '12' && batch == '12 NEET') return true;
      if (n.visibility == 'neet' && batch == 'NEET Exclusive') return true;
      return false;
    }).toList();
  }

  Future<void> deleteNote(String id) async => await _notes.delete(id);

  // ---- OFFLINE TESTS ----
  Future<void> saveOfflineTest(OfflineTestModel test) async =>
      await _offlineTests.put(test.id, test.toMap());

  List<OfflineTestModel> getOfflineTestsByBatch(String batch) => _offlineTests.values
      .map((v) => OfflineTestModel.fromMap(Map<String, dynamic>.from(v)))
      .where((t) => t.batch == batch)
      .toList();

  Future<void> deleteOfflineTest(String id) async => await _offlineTests.delete(id);

  // ---- SETTINGS ----
  Future<void> setSetting(String key, dynamic value) async =>
      await _settings.put(key, value);

  T? getSetting<T>(String key) => _settings.get(key) as T?;

  bool getBoolSetting(String key, {bool defaultValue = false}) =>
      _settings.get(key) as bool? ?? defaultValue;
}
