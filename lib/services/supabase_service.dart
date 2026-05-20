import 'dart:math' as math;
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/batch_model.dart';
import '../models/user_model.dart';
import '../models/exam_model.dart';
import '../models/question_model.dart';
import '../models/exam_result_model.dart';
import '../models/pyq_model.dart';
import '../models/lesson_plan_model.dart';
import '../models/note_model.dart';
import '../models/offline_test_model.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  SupabaseService._();

  SupabaseClient get _db => Supabase.instance.client;

  // ---- USERS ----
  Future<void> upsertUser(UserModel user) async {
    await _db.from('users').upsert({
      'id': user.id,
      'name': user.name,
      'username': user.username,
      'password_hash': user.passwordHash,
      'password_plain': user.passwordPlain,
      'student_class': user.studentClass,
      'batch': user.batch,
      'prepcoins': user.prepcoins,
      'is_admin': user.isAdmin,
      'is_banned': user.isBanned,
      'earned_badge_ids': user.earnedBadgeIds,
      'selected_avatar_id': user.selectedAvatarId,
      'claimed_avatar_ids': user.claimedAvatarIds,
      'monthly_payments': user.monthlyPayments,
      'fee_exempt_months': user.feeExemptMonths,
      'login_streak': user.loginStreak,
      'last_login': user.lastLogin?.toIso8601String(),
    });
  }

  Future<UserModel?> getUserById(String id) async {
    final res = await _db.from('users').select().eq('id', id).maybeSingle();
    return res != null ? _mapToUser(res) : null;
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final res = await _db.from('users').select().eq('username', username).maybeSingle();
    return res != null ? _mapToUser(res) : null;
  }

  Future<List<UserModel>> getAllStudents() async {
    final res = await _db.from('users').select().eq('is_admin', false).order('name');
    return (res as List).map((r) => _mapToUser(r)).toList();
  }

  Future<List<UserModel>> getStudentsByBatch(String batch) async {
    final res = await _db.from('users').select().eq('batch', batch).eq('is_admin', false).order('name');
    return (res as List).map((r) => _mapToUser(r)).toList();
  }

  // ── Realtime streams for admin screens ───────────────────────

  /// Live stream of all non-admin students — updates instantly when any user row changes.
  Stream<List<UserModel>> streamAllStudents() {
    return _db
        .from('users')
        .stream(primaryKey: ['id'])
        .order('name')
        .map((rows) => rows
            .where((r) => r['is_admin'] != true)
            .map((r) => _mapToUser(Map<String, dynamic>.from(r)))
            .toList());
  }

  /// Live stream of students for a specific batch.
  Stream<List<UserModel>> streamStudentsByBatch(String batch) {
    return _db
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('batch', batch)
        .order('name')
        .map((rows) => rows
            .where((r) => r['is_admin'] != true)
            .map((r) => _mapToUser(Map<String, dynamic>.from(r)))
            .toList());
  }

  /// Lightweight search for the notification student picker — returns id+name+batch only.
  Future<List<Map<String, dynamic>>> searchStudents(String query) async {
    final res = await _db
        .from('users')
        .select('id, name, batch')
        .eq('is_admin', false)
        .ilike('name', '%$query%')
        .limit(8);
    return List<Map<String, dynamic>>.from(res as List);
  }

  /// Delete user AND all their associated data (cascade)
  Future<void> deleteUser(String id) async {
    // Delete all exam results for this student
    await _db.from('exam_results').delete().eq('student_id', id);
    // Delete lesson plans
    try { await _db.from('lesson_plans').delete().eq('student_id', id); } catch (_) {}
    // Finally delete the user
    await _db.from('users').delete().eq('id', id);
  }

  Future<void> updateUserPrepcoins(String userId, int amount) async {
    await _db.from('users').update({'prepcoins': amount}).eq('id', userId);
  }

  Future<void> updateUserBan(String userId, bool isBanned) async {
    await _db.from('users').update({'is_banned': isBanned}).eq('id', userId);
  }

  Future<void> bulkImportUsers(List<UserModel> users) async {
    final data = users.map((u) => {
          'id': u.id,
          'name': u.name,
          'username': u.username,
          'password_hash': u.passwordHash,
          'student_class': u.studentClass,
          'batch': u.batch,
          'prepcoins': u.prepcoins,
          'is_admin': false,
          'is_banned': false,
        }).toList();
    await _db.from('users').upsert(data);
  }

  // ---- BATCHES ----

  Future<List<BatchModel>> getBatches() async {
    final res = await _db.from('batches').select().order('display_order');
    return (res as List).map((r) => BatchModel.fromMap(r)).toList();
  }

  /// Live stream of batches — updates instantly when admin creates/renames/deletes.
  Stream<List<BatchModel>> streamBatches() {
    return _db
        .from('batches')
        .stream(primaryKey: ['id'])
        .order('display_order')
        .map((rows) => rows
            .map((r) => BatchModel.fromMap(Map<String, dynamic>.from(r)))
            .toList());
  }

  /// Live stream of offline tests for a batch — updates when admin enters marks.
  Stream<List<OfflineTestModel>> streamOfflineTestsByBatch(String batch) {
    return _db
        .from('offline_tests')
        .stream(primaryKey: ['id'])
        .eq('batch', batch)
        .order('test_date', ascending: false)
        .map((rows) => rows
            .map((r) => OfflineTestModel(
                  id: r['id'] as String,
                  name: r['name'] as String,
                  date: DateTime.parse(r['test_date'] as String),
                  fullMarks: (r['full_marks'] as num).toInt(),
                  batch: r['batch'] as String,
                  studentMarks: Map<String, int?>.from(r['student_marks'] ?? {}),
                ))
            .toList());
  }

  /// Live stream of a single student's full user row (coins, badges, etc.).
  Stream<UserModel?> streamUser(String userId) {
    return _db
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((rows) => rows.isEmpty
            ? null
            : _mapToUser(Map<String, dynamic>.from(rows.first)));
  }

  Future<void> upsertBatch(BatchModel batch) async {
    await _db.from('batches').upsert(batch.toMap());
    // Sync every student in this batch so their student_class
    // always matches the batch's class_level.
    await syncStudentClassForBatch(batch.name, batch.classLevel);
  }

  /// Update student_class for ALL students in [batchName] to [classLevel].
  /// Call this after any batch class_level change or on demand.
  Future<void> syncStudentClassForBatch(String batchName, String classLevel) async {
    await _db
        .from('users')
        .update({'student_class': classLevel})
        .eq('batch', batchName)
        .eq('is_admin', false);
  }

  /// Sync ALL students across ALL batches (run once to fix legacy data).
  Future<void> syncAllStudentClasses() async {
    final batches = await getBatches();
    for (final b in batches) {
      await syncStudentClassForBatch(b.name, b.classLevel);
    }
  }

  Future<int> getBatchStudentCount(String batchName) async {
    final res = await _db
        .from('users')
        .select('id')
        .eq('batch', batchName)
        .eq('is_admin', false);
    return (res as List).length;
  }

  /// Rename a batch in-place: updates batches table, all student records,
  /// offline_tests, and exam target_batches arrays. Also syncs student_class
  /// if classLevel changed.
  Future<void> renameBatch(
      String oldName, String newName, String newClassLevel) async {
    // 1. Update the batch record itself
    await _db.from('batches')
        .update({'name': newName, 'class_level': newClassLevel})
        .eq('name', oldName);

    // 2. Update all students in this batch
    await _db.from('users')
        .update({'batch': newName, 'student_class': newClassLevel})
        .eq('batch', oldName)
        .eq('is_admin', false);

    // 3. Update offline_tests that reference this batch
    try {
      await _db.from('offline_tests')
          .update({'batch': newName})
          .eq('batch', oldName);
    } catch (_) {}

    // 4. Update exams whose target_batches array contains oldName
    try {
      final examsRes = await _db.from('exams')
          .select('id, target_batches')
          .contains('target_batches', [oldName]);
      for (final r in (examsRes as List)) {
        final newBatches = (r['target_batches'] as List)
            .map((b) => b == oldName ? newName : b)
            .toSet()
            .toList();
        await _db.from('exams')
            .update({'target_batches': newBatches})
            .eq('id', r['id']);
      }
    } catch (_) {}
  }

  /// Move all students from [fromBatch] to [toBatch].
  /// Also migrates offline tests and exam targets to the new batch.
  Future<void> promoteStudents(String fromBatch, String toBatch) async {
    // 1. Move students
    await _db.from('users')
        .update({'batch': toBatch})
        .eq('batch', fromBatch)
        .eq('is_admin', false);
        
    // 2. Migrate Offline Tests
    try {
      await _db.from('offline_tests')
          .update({'batch': toBatch})
          .eq('batch', fromBatch);
    } catch (e) {
      debugPrint('[promoteStudents] offline_tests update error: $e');
    }

    // 3. Migrate Online Exams (target_batches array)
    try {
      final examsRes = await _db.from('exams').select().contains('target_batches', [fromBatch]);
      final examsToUpdate = (examsRes as List).map((r) => _mapToExam(r)).toList();
      for (final exam in examsToUpdate) {
        // Replace fromBatch with toBatch and deduplicate using a Set
        final newBatches = exam.targetBatches.map((b) => b == fromBatch ? toBatch : b).toSet().toList();
        await _db.from('exams').update({'target_batches': newBatches}).eq('id', exam.id);
      }
    } catch (e) {
      debugPrint('[promoteStudents] exams update error: $e');
    }
  }

  /// Delete a batch and ALL associated data: students (+ their results/plans)
  /// and offline tests. Requires the caller to have already verified admin password.
  Future<void> deleteBatch(String batchName) async {
    // 1. Get all student IDs in this batch
    final students = await getStudentsByBatch(batchName);

    // 2. Bulk-delete exam results for these students
    if (students.isNotEmpty) {
      final ids = students.map((s) => s.id).toList();
      await _db.from('exam_results').delete().inFilter('student_id', ids);
      try {
        await _db.from('lesson_plans').delete().inFilter('student_id', ids);
      } catch (_) {}
      // 3. Delete the students themselves
      await _db.from('users').delete().inFilter('id', ids);
    }

    // 4. Delete offline tests for this batch
    await _db.from('offline_tests').delete().eq('batch', batchName);

    // 5. Remove the batch entry
    await _db.from('batches').delete().eq('name', batchName);
  }

  /// Bulk upsert only the fee-related fields for a list of users in one API call.
  Future<void> bulkUpsertFeeData(List<UserModel> users) async {
    if (users.isEmpty) return;
    final data = users.map((u) => {
      'id': u.id,
      'name': u.name,
      'username': u.username,
      'password_hash': u.passwordHash,
      'student_class': u.studentClass,
      'batch': u.batch,
      'prepcoins': u.prepcoins,
      'is_admin': u.isAdmin,
      'is_banned': u.isBanned,
      'earned_badge_ids': u.earnedBadgeIds,
      'selected_avatar_id': u.selectedAvatarId,
      'claimed_avatar_ids': u.claimedAvatarIds,
      'monthly_payments': u.monthlyPayments,
      'fee_exempt_months': u.feeExemptMonths,
      'login_streak': u.loginStreak,
      'last_login': u.lastLogin?.toIso8601String(),
      'created_at': u.createdAt.toIso8601String(),
    }).toList();
    await _db.from('users').upsert(data);
  }

  UserModel _mapToUser(Map<String, dynamic> r) => UserModel(
        id: r['id'],
        name: r['name'],
        username: r['username'],
        passwordHash: r['password_hash'],
        passwordPlain: r['password_plain'] ?? '',
        studentClass: r['student_class'] ?? '11',
        batch: r['batch'] ?? '11 NEET',
        prepcoins: r['prepcoins'] ?? 80,
        isAdmin: r['is_admin'] ?? false,
        isBanned: r['is_banned'] ?? false,
        earnedBadgeIds: List<String>.from(r['earned_badge_ids'] ?? []),
        gamesPlayed: List<String>.from(r['games_played'] ?? []),
        bioLabCompleted: List<String>.from(r['biolab_completed'] ?? []),
        selectedAvatarId: r['selected_avatar_id'],
        claimedAvatarIds: List<String>.from(r['claimed_avatar_ids'] ?? []),
        monthlyPayments: (r['monthly_payments'] as Map? ?? {})
            .map((k, v) => MapEntry(k.toString(), v == true)),
        feeExemptMonths: List<String>.from(r['fee_exempt_months'] ?? []),
        loginStreak: Map<String, int>.from(r['login_streak'] ?? {}),
        createdAt: DateTime.parse(r['created_at']),
        lastLogin: r['last_login'] != null ? DateTime.parse(r['last_login']) : null,
      );

  // ---- EXAMS ----
  Future<void> upsertExam(ExamModel exam) async {
    await _db.from('exams').upsert({
      'id': exam.id,
      'title': exam.title,
      'description': exam.description,
      'target_batches': exam.targetBatches,
      'duration_minutes': exam.durationMinutes,
      'difficulty': exam.difficulty,
      'type': exam.type,
      'chapters': exam.chapters,
      'is_published': exam.isPublished,
      'exp_required': exam.expRequired,
      'exp_gained': exam.expGained,
      'tag': exam.tag,
      'avatar_id': exam.avatarId,
      'is_new': exam.isNew,
      'ai_prompt': exam.aiPrompt,
      'created_by': exam.createdBy,
      'selected_class': exam.selectedClass,
      'question_ids': exam.questionIds,
      'visibility_start': exam.visibilityStart?.toIso8601String(),
      'visibility_end': exam.visibilityEnd?.toIso8601String(),
      'published_at': exam.publishedAt?.toIso8601String(),
      'credit_mode': exam.creditMode,
      'credit_threshold': exam.creditThreshold,
      'results_published': exam.resultsPublished,
      'allow_download': exam.allowDownload,
    });
  }

  Future<ExamModel?> getExam(String id) async {
    final res = await _db.from('exams').select().eq('id', id).maybeSingle();
    return res != null ? _mapToExam(res) : null;
  }

  Future<List<ExamModel>> getAllExams() async {
    final res = await _db.from('exams').select().order('created_at', ascending: false);
    return (res as List).map((r) => _mapToExam(r)).toList();
  }

  Stream<List<ExamModel>> streamAllExams() {
    return _db.from('exams').stream(primaryKey: ['id'])
        .map((list) {
          final mapped = list.map((r) => _mapToExam(r)).toList();
          mapped.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return mapped;
        });
  }

  Future<List<ExamModel>> getActiveExamsForBatch(String batch) async {
    final now = DateTime.now().toIso8601String();
    final res = await _db
        .from('exams')
        .select()
        .eq('is_published', true)
        .contains('target_batches', [batch])
        .or('visibility_start.is.null,visibility_start.lte.$now')
        .or('visibility_end.is.null,visibility_end.gt.$now')
        .order('created_at', ascending: false);
    return (res as List).map((r) => _mapToExam(r)).toList();
  }

  Stream<List<ExamModel>> streamActiveExamsForBatch(String batch) {
    return _db.from('exams').stream(primaryKey: ['id'])
        .map((list) {
          final now = DateTime.now();
          final mapped = list.map((r) => _mapToExam(r)).where((e) {
            if (!e.isPublished) return false;
            if (!e.targetBatches.contains(batch)) return false;
            if (e.visibilityStart != null && now.isBefore(e.visibilityStart!)) return false;
            if (e.visibilityEnd != null && now.isAfter(e.visibilityEnd!)) return false;
            return true;
          }).toList();
          mapped.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return mapped;
        });
  }

  /// Delete exam AND all its results (cascade clean)
  Future<void> deleteExam(String id) async {
    // Remove all results for this exam so they don't appear in student history
    await _db.from('exam_results').delete().eq('exam_id', id);
    // Remove questions
    try { await _db.from('questions').delete().eq('exam_id', id); } catch (_) {}
    // Delete the exam itself
    await _db.from('exams').delete().eq('id', id);
  }

  ExamModel _mapToExam(Map<String, dynamic> r) => ExamModel(
        id: r['id'],
        title: r['title'],
        description: r['description'] ?? '',
        targetBatches: List<String>.from(r['target_batches'] ?? []),
        durationMinutes: r['duration_minutes'] ?? 60,
        difficulty: r['difficulty'] ?? 'Medium',
        type: r['type'] ?? 'manual',
        chapters: List<String>.from(r['chapters'] ?? []),
        questionIds: List<String>.from(r['question_ids'] ?? []), // was missing — fixes "0 Qs" bug
        isPublished: r['is_published'] ?? false,
        expRequired: r['exp_required'] ?? 0,
        expGained: r['exp_gained'] ?? 100,
        tag: r['tag'] ?? 'Practice',
        avatarId: r['avatar_id'] ?? 'av_01',
        isNew: r['is_new'] ?? true,
        aiPrompt: r['ai_prompt'],
        createdBy: r['created_by'] ?? 'admin',
        selectedClass: r['selected_class'],
        visibilityStart: r['visibility_start'] != null ? DateTime.parse(r['visibility_start']) : null,
        visibilityEnd: r['visibility_end'] != null ? DateTime.parse(r['visibility_end']) : null,
        publishedAt: r['published_at'] != null ? DateTime.parse(r['published_at']) : null,
        createdAt: DateTime.parse(r['created_at']),
        creditMode: r['credit_mode'] ?? 'none',
        creditThreshold: r['credit_threshold'] ?? 30,
        resultsPublished: r['results_published'] ?? false,
        allowDownload: r['allow_download'] ?? false,
      );

  // ---- QUESTIONS ----
  Future<void> upsertQuestion(QuestionModel q, {int sortOrder = 0}) async {
    await _db.from('questions').upsert({
      'id': q.id,
      'exam_id': q.examId,
      'text': q.text,
      'option_a': q.optionA,
      'option_b': q.optionB,
      'option_c': q.optionC,
      'option_d': q.optionD,
      'correct_option': q.correctOption,
      'image_url': q.imageUrl,
      'explanation': q.explanation,
      'chapter': q.chapter,
      'difficulty': q.difficulty,
      'sort_order': sortOrder,
    });
  }

  Future<void> upsertQuestions(List<QuestionModel> questions) async {
    final data = questions.asMap().entries.map((e) => {
          'id': e.value.id,
          'exam_id': e.value.examId,
          'text': e.value.text,
          'option_a': e.value.optionA,
          'option_b': e.value.optionB,
          'option_c': e.value.optionC,
          'option_d': e.value.optionD,
          'correct_option': e.value.correctOption,
          'image_url': e.value.imageUrl,
          'explanation': e.value.explanation,
          'chapter': e.value.chapter,
          'difficulty': e.value.difficulty,
          'sort_order': e.key,
        }).toList();
    await _db.from('questions').upsert(data);
  }

  Future<List<QuestionModel>> getQuestionsForExam(String examId) async {
    final res = await _db
        .from('questions')
        .select()
        .eq('exam_id', examId)
        .order('sort_order');
    return (res as List).map((r) => _mapToQuestion(r)).toList();
  }

  Future<void> deleteQuestionsForExam(String examId) async {
    await _db.from('questions').delete().eq('exam_id', examId);
  }

  QuestionModel _mapToQuestion(Map<String, dynamic> r) => QuestionModel(
        id: r['id'],
        text: r['text'],
        optionA: r['option_a'],
        optionB: r['option_b'],
        optionC: r['option_c'],
        optionD: r['option_d'],
        correctOption: r['correct_option'],
        imageUrl: r['image_url'],
        explanation: r['explanation'],
        chapter: r['chapter'] ?? '',
        difficulty: r['difficulty'] ?? 'Medium',
        examId: r['exam_id'],
      );

  // ---- EXAM RESULTS ----

  /// Saves exam progress. Uses a two-stage approach so missing DB columns
  /// (is_in_progress, started_at, remaining_seconds) never block the exam.
  ///
  /// Stage 1 — full upsert with every column.
  /// Stage 2 — fallback without the 3 columns added by SQL migration.
  ///   CRITICAL: Stage 2 MUST include correct_count / incorrect_count /
  ///   unattempted_count so that after submission the orphan-detection heuristic
  ///   (counts == 0 → in-progress) correctly returns false for the finished exam.
  Future<void> upsertResult(ExamResultModel result) async {
    // ── Stage 1: full upsert (works when SQL migration has been run) ──────
    try {
      await _db.from('exam_results').upsert(
        {
          'id':                 result.id,
          'exam_id':            result.examId,
          'student_id':         result.studentId,
          'score':              result.score,
          'total_questions':    result.totalQuestions,
          'answers':            result.answers,
          'time_taken_seconds': result.timeTakenSeconds,
          'submitted_at':       result.submittedAt.toIso8601String(),
          'is_first_attempt':   result.isFirstAttempt,
          'correct_count':      result.correctCount,
          'incorrect_count':    result.incorrectCount,
          'unattempted_count':  result.unattemptedCount,
          'data_retained':      result.dataRetained,
          'exam_title':         result.examTitle,
          'exam_type':          result.examType,
          'is_in_progress':     result.isInProgress,     // ← new column
          'started_at':         result.startedAt?.toIso8601String(), // ← new
          'remaining_seconds':  result.remainingSeconds,  // ← new
        },
        onConflict: 'id',
      );
      return;
    } catch (e) {
      debugPrint('[upsertResult] Stage-1 failed (new columns missing?): $e');
    }

    // ── Stage 2: fallback without the 3 migration-added columns ──────────
    // Includes counts so the orphan heuristic works correctly after submission.
    try {
      await _db.from('exam_results').upsert(
        {
          'id':                 result.id,
          'exam_id':            result.examId,
          'student_id':         result.studentId,
          'score':              result.score,
          'total_questions':    result.totalQuestions,
          'answers':            result.answers,
          'time_taken_seconds': result.timeTakenSeconds,
          'submitted_at':       result.submittedAt.toIso8601String(),
          'is_first_attempt':   result.isFirstAttempt,
          // These tell orphan-detection that the exam was submitted (counts > 0):
          'correct_count':      result.correctCount,
          'incorrect_count':    result.incorrectCount,
          'unattempted_count':  result.unattemptedCount,
          'data_retained':      result.dataRetained,
          'exam_title':         result.examTitle,
          'exam_type':          result.examType,
        },
        onConflict: 'id',
      );
      debugPrint('[upsertResult] Stage-2 OK — run the SQL migration for '
          'full timer persistence across sessions.');
    } catch (e) {
      debugPrint('[upsertResult] Stage-2 also failed: $e');
      rethrow;
    }
  }

  // ── Helper: is a loaded row a completed (submitted) exam? ───────────────
  // _submit() is the ONLY place that sets correctCount/incorrectCount/
  // unattemptedCount. All three being 0 means the exam was never submitted.
  // Works without the is_in_progress column.
  static bool _rowIsCompleted(ExamResultModel r) =>
      r.correctCount > 0 || r.incorrectCount > 0 || r.unattemptedCount > 0;

  /// Parse a raw Supabase list response defensively.
  List<ExamResultModel> _parseRows(dynamic res) =>
      (res as List)
          .map((r) {
            try { return _mapToResult(r); } catch (_) { return null; }
          })
          .whereType<ExamResultModel>()
          .toList();

  /// Run a query that filters by is_in_progress=false.
  /// Falls back to no filter + Dart-side check when the column is missing.
  /// Takes two lambdas — withFilter and withoutFilter — both return Future<dynamic>
  /// so the Supabase builder chain is unrestricted (no type mismatch).
  Future<List<ExamResultModel>> _fetchCompleted({
    required Future<dynamic> Function() withFilter,
    required Future<dynamic> Function() withoutFilter,
  }) async {
    try {
      return _parseRows(await withFilter());
    } catch (_) {
      try {
        return _parseRows(await withoutFilter()).where(_rowIsCompleted).toList();
      } catch (_) {
        return [];
      }
    }
  }

  Future<List<ExamResultModel>> getStudentResults(String studentId) =>
      _fetchCompleted(
        withFilter: () => _db.from('exam_results').select()
            .eq('student_id', studentId)
            .eq('is_in_progress', false)
            .order('submitted_at', ascending: false),
        withoutFilter: () => _db.from('exam_results').select()
            .eq('student_id', studentId)
            .order('submitted_at', ascending: false),
      );

  Stream<List<ExamResultModel>> streamStudentResults(String studentId) {
    return _db.from('exam_results').stream(primaryKey: ['id']).eq('student_id', studentId)
        .map((list) {
          final mapped = _parseRows(list).where(_rowIsCompleted).toList();
          mapped.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
          return mapped;
        });
  }

  /// All first-attempt results for multiple students (batch report)
  Future<List<ExamResultModel>> getFirstAttemptResultsForStudents(
      List<String> studentIds) async {
    if (studentIds.isEmpty) return [];
    return _fetchCompleted(
      withFilter: () => _db.from('exam_results').select()
          .inFilter('student_id', studentIds)
          .eq('is_first_attempt', true)
          .eq('is_in_progress', false)
          .order('submitted_at', ascending: false),
      withoutFilter: () => _db.from('exam_results').select()
          .inFilter('student_id', studentIds)
          .eq('is_first_attempt', true)
          .order('submitted_at', ascending: false),
    );
  }

  Future<List<ExamResultModel>> getFirstAttemptResults(String studentId) =>
      _fetchCompleted(
        withFilter: () => _db.from('exam_results').select()
            .eq('student_id', studentId)
            .eq('is_first_attempt', true)
            .eq('is_in_progress', false)
            .order('submitted_at', ascending: false),
        withoutFilter: () => _db.from('exam_results').select()
            .eq('student_id', studentId)
            .eq('is_first_attempt', true)
            .order('submitted_at', ascending: false),
      );

  Stream<List<ExamResultModel>> streamFirstAttemptResults(String studentId) {
    return _db.from('exam_results').stream(primaryKey: ['id'])
        .eq('student_id', studentId)
        .map((list) {
          final mapped = _parseRows(list).where((r) => _rowIsCompleted(r) && r.isFirstAttempt).toList();
          mapped.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
          return mapped;
        });
  }

  /// All completed attempts by a student for one exam, oldest first.
  Future<List<ExamResultModel>> getStudentResultsForExam(
      String studentId, String examId) =>
      _fetchCompleted(
        withFilter: () => _db.from('exam_results').select()
            .eq('student_id', studentId)
            .eq('exam_id', examId)
            .eq('is_in_progress', false)
            .order('submitted_at', ascending: true),
        withoutFilter: () => _db.from('exam_results').select()
            .eq('student_id', studentId)
            .eq('exam_id', examId)
            .order('submitted_at', ascending: true),
      );

  /// Returns the top NEET score among all first attempts for an exam.
  Future<({int topScore, int tiedCount})> getTopScoreForExam(String examId) async {
    final rows = await _fetchCompleted(
      withFilter: () => _db.from('exam_results').select()
          .eq('exam_id', examId)
          .eq('is_first_attempt', true)
          .eq('is_in_progress', false),
      withoutFilter: () => _db.from('exam_results').select()
          .eq('exam_id', examId)
          .eq('is_first_attempt', true),
    );
    if (rows.isEmpty) return (topScore: 0, tiedCount: 0);
    final scores = rows.map((r) => r.neetScore).toList();
    final top  = scores.reduce((a, b) => a > b ? a : b);
    final tied = scores.where((s) => s == top).length;
    return (topScore: top, tiedCount: tied);
  }

  Future<ExamResultModel?> getFirstAttemptForExam(
      String studentId, String examId) async {
    final rows = await _fetchCompleted(
      withFilter: () => _db.from('exam_results').select()
          .eq('student_id', studentId)
          .eq('exam_id', examId)
          .eq('is_in_progress', false)
          .order('submitted_at', ascending: true),
      withoutFilter: () => _db.from('exam_results').select()
          .eq('student_id', studentId)
          .eq('exam_id', examId)
          .order('submitted_at', ascending: true),
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<ExamResultModel?> getResultById(String resultId) async {
    final res = await _db
        .from('exam_results')
        .select()
        .eq('id', resultId)
        .maybeSingle();
    return res != null ? _mapToResult(res) : null;
  }

  // DEPRECATED: use getInProgressForExam(studentId, examId) which scopes by exam
  Future<ExamResultModel?> getInProgressExam(String studentId) async {
    final res = await _db
        .from('exam_results')
        .select()
        .eq('student_id', studentId)
        .eq('is_in_progress', true)
        .order('submitted_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return res != null ? _mapToResult(res) : null;
  }

  /// Returns the in-progress attempt for a specific exam.
  ///
  /// Strategy: fetch the 10 most recent rows for this student+exam (without
  /// filtering on is_in_progress in SQL, because that column may have been
  /// added after rows were created and would default to false on old rows).
  /// Then identify the in-progress one in Dart — it is the row where
  ///   • isInProgress == true   (new rows set explicitly)
  ///   • OR the row has answers/startedAt but no correctCount (never submitted)
  ///   and was created recently relative to exam duration.
  Future<ExamResultModel?> getInProgressForExam(
      String studentId, String examId) async {
    try {
      final res = await _db
          .from('exam_results')
          .select()
          .eq('student_id', studentId)
          .eq('exam_id', examId)
          .order('submitted_at', ascending: false)
          .limit(10);

      final rows = (res as List)
          .map((r) {
            try {
              return _mapToResult(r);
            } catch (_) {
              return null;
            }
          })
          .whereType<ExamResultModel>()
          .toList();

      // Primary check: explicit is_in_progress flag (set on newly created rows)
      final explicit = rows.firstWhereOrNull((r) => r.isInProgress);
      if (explicit != null) return explicit;

      // Fallback: detect in-progress rows on older DB schemas where
      // is_in_progress column doesn't exist (defaults to false).
      // Key insight: _submit() is the ONLY place that sets correctCount,
      // incorrectCount, unattemptedCount. If all three are 0, the exam
      // was never submitted — it's in-progress.
      // We do NOT require answers.isNotEmpty — students who close before
      // answering any question must also be resumeable.
      final orphan = rows.firstWhereOrNull((r) =>
          !r.isInProgress &&
          r.correctCount == 0 &&
          r.incorrectCount == 0 &&
          r.unattemptedCount == 0 &&
          r.dataRetained);

      if (orphan != null) {
        // Patch the flag in DB so future queries find it correctly
        try {
          await _db
              .from('exam_results')
              .update({'is_in_progress': true})
              .eq('id', orphan.id);
        } catch (_) {}
        return orphan.copyWithInProgress(true);
      }

      return null;
    } catch (e) {
      debugPrint('[getInProgressForExam] $e');
      return null;
    }
  }

  /// Returns one result per student — the EARLIEST (first) completed attempt.
  Future<List<ExamResultModel>> getAllResultsForExam(String examId) async {
    final all = await _fetchCompleted(
      withFilter: () => _db.from('exam_results').select()
          .eq('exam_id', examId)
          .eq('is_in_progress', false)
          .order('submitted_at', ascending: true),
      withoutFilter: () => _db.from('exam_results').select()
          .eq('exam_id', examId)
          .order('submitted_at', ascending: true),
    );
    final seen = <String>{};
    return all.where((r) => seen.add(r.studentId)).toList();
  }

  /// Returns the student's most recent completed attempt (for "last attempt" display)
  Future<ExamResultModel?> getLatestResultForExam(
      String studentId, String examId) async {
    final rows = await _fetchCompleted(
      withFilter: () => _db.from('exam_results').select()
          .eq('student_id', studentId)
          .eq('exam_id', examId)
          .eq('is_in_progress', false)
          .order('submitted_at', ascending: false),
      withoutFilter: () => _db.from('exam_results').select()
          .eq('student_id', studentId)
          .eq('exam_id', examId)
          .order('submitted_at', ascending: false),
    );
    return rows.isEmpty ? null : rows.first;
  }

  /// Deletes in-progress record for a specific student+exam so retakes start clean
  Future<void> clearInProgressForExam(String studentId, String examId) async {
    await _db
        .from('exam_results')
        .delete()
        .eq('student_id', studentId)
        .eq('exam_id', examId)
        .eq('is_in_progress', true);
  }

  Future<void> clearExamData(String examId) async {
    await _db
        .from('exam_results')
        .update({'data_retained': false, 'answers': {}})
        .eq('exam_id', examId);
  }

  /// Permanently delete ALL results for an exam (used for the full republish reset)
  Future<void> deleteAllResultsForExam(String examId) async {
    await _db.from('exam_results').delete().eq('exam_id', examId);
  }

  ExamResultModel _mapToResult(Map<String, dynamic> r) {
    // Use tryParse everywhere — a parse failure used to silently swallow the
    // entire row inside getInProgressForExam's catch block, making resume fail.
    final submittedAt = r['submitted_at'] != null
        ? (DateTime.tryParse(r['submitted_at'].toString()) ?? DateTime.now())
        : DateTime.now();
    final startedAt = r['started_at'] != null
        ? DateTime.tryParse(r['started_at'].toString())
        : null;

    // answers column: values must all be Strings — coerce defensively
    Map<String, String> answers = {};
    try {
      final raw = r['answers'];
      if (raw is Map) {
        answers = raw.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}

    return ExamResultModel(
      id:               r['id'] ?? '',
      examId:           r['exam_id'] ?? '',
      studentId:        r['student_id'] ?? '',
      score:            r['score'] ?? 0,
      totalQuestions:   r['total_questions'] ?? 0,
      answers:          answers,
      timeTakenSeconds: r['time_taken_seconds'] ?? 0,
      submittedAt:      submittedAt,
      isFirstAttempt:   r['is_first_attempt'] ?? true,
      correctCount:     r['correct_count'] ?? 0,
      incorrectCount:   r['incorrect_count'] ?? 0,
      unattemptedCount: r['unattempted_count'] ?? 0,
      dataRetained:     r['data_retained'] ?? true,
      examTitle:        r['exam_title'] ?? '',
      examType:         r['exam_type'] ?? 'online',
      isInProgress:     r['is_in_progress'] ?? false,
      startedAt:        startedAt,
      remainingSeconds: r['remaining_seconds'] ?? 0,
    );
  }

  // ---- PYQ ----
  Future<void> replacePYQ(List<PYQModel> questions) async {
    if (questions.isEmpty) return;

    final data = questions.map((q) => {
          'year':          q.year,
          'chapter':       q.chapter,
          'question':      q.question,
          'option_a':      q.optionA,
          'option_b':      q.optionB,
          'option_c':      q.optionC,
          'option_d':      q.optionD,
          'correct_option': q.correctOption,
          'image_url':     q.imageUrl,
          'explanation':   q.explanation,
        }).toList();

    // ── Safe replacement strategy ─────────────────────────────────
    // 1. Insert all chunks FIRST into the live table
    //    (Supabase allows duplicate content — new rows get new UUIDs)
    // 2. Only AFTER all inserts succeed, delete old rows
    // This ensures no data loss if a mid-upload failure occurs.
    //
    // Chunk size 100: each row ≈ 1–2 KB → 100 rows ≈ 100–200 KB (safe)
    const chunkSize = 100;
    final insertedIds = <String>[];

    for (int i = 0; i < data.length; i += chunkSize) {
      final chunk = data.sublist(i, math.min(i + chunkSize, data.length));
      final result = await _db.from('pyq').insert(chunk).select('id');
      // Collect newly inserted IDs so we can delete only the OLD rows
      if (result is List) {
        insertedIds.addAll(result.map((r) => r['id'].toString()));
      }
    }

    // Delete rows that were NOT part of this upload (the old data)
    if (insertedIds.isNotEmpty) {
      await _db.from('pyq').delete().not('id', 'in', insertedIds);
    } else {
      // Fallback: delete everything (shouldn't reach here normally)
      await _db.from('pyq').delete().neq('id', '00000000-0000-0000-0000-000000000000');
    }
  }

  Future<List<PYQModel>> getAllPYQ() async {
    final res = await _db.from('pyq').select().order('year').order('chapter').limit(20000);
    return (res as List).map((r) => _mapToPYQ(r)).toList();
  }

  Future<List<PYQModel>> getPYQByChapter(String chapter) async {
    final res = await _db.from('pyq').select().eq('chapter', chapter).order('year').limit(20000);
    return (res as List).map((r) => _mapToPYQ(r)).toList();
  }

  Future<List<PYQModel>> getPYQByYears(List<String> years) async {
    final res = await _db.from('pyq').select().inFilter('year', years).limit(20000);
    return (res as List).map((r) => _mapToPYQ(r)).toList();
  }

  Future<List<PYQModel>> getPYQByChapters(List<String> chapters) async {
    final res = await _db.from('pyq').select().inFilter('chapter', chapters).limit(20000);
    return (res as List).map((r) => _mapToPYQ(r)).toList();
  }

  Future<List<String>> getAvailablePYQYears() async {
    final res = await _db.from('pyq').select('year').limit(20000);
    // Deduplicate and sort newest-first numerically, with non-numeric suffixes after
    final years = (res as List)
        .map((r) => r['year']?.toString().trim() ?? '')
        .where((y) => y.isNotEmpty)
        .toSet()
        .toList();
    years.sort((a, b) {
      final na = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final nb = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final cmp = nb.compareTo(na); // descending (newest first)
      return cmp != 0 ? cmp : a.compareTo(b);
    });
    return years;
  }

  Future<List<String>> getAvailablePYQChapters() async {
    final res = await _db.from('pyq').select('chapter').limit(20000);
    return (res as List)
        .map((r) => r['chapter']?.toString().trim() ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
  }

  // ---- PYQ ----
  Future<void> replacePYQForYear(String yearName, List<PYQModel> questions) async {
    if (questions.isEmpty) return;

    final data = questions.map((q) => {
          'year':          yearName,
          'chapter':       q.chapter,
          'question':      q.question,
          'option_a':      q.optionA,
          'option_b':      q.optionB,
          'option_c':      q.optionC,
          'option_d':      q.optionD,
          'correct_option': q.correctOption,
          'image_url':     q.imageUrl,
          'explanation':   q.explanation,
        }).toList();

    const chunkSize = 100;
    final insertedIds = <String>[];

    for (int i = 0; i < data.length; i += chunkSize) {
      final chunk = data.sublist(i, math.min(i + chunkSize, data.length));
      final result = await _db.from('pyq').insert(chunk).select('id');
      if (result is List) {
        insertedIds.addAll(result.map((r) => r['id'].toString()));
      }
    }

    if (insertedIds.isNotEmpty) {
      await _db.from('pyq').delete().eq('year', yearName).not('id', 'in', insertedIds);
    }
  }

  PYQModel _mapToPYQ(Map<String, dynamic> r) => PYQModel(
        id:            r['id']?.toString() ?? '',
        year:          r['year']?.toString().trim() ?? '',
        chapter:       r['chapter']?.toString().trim() ?? '',
        question:      r['question']?.toString() ?? '',
        optionA:       r['option_a']?.toString() ?? '',
        optionB:       r['option_b']?.toString() ?? '',
        optionC:       r['option_c']?.toString() ?? '',
        optionD:       r['option_d']?.toString() ?? '',
        correctOption: (r['correct_option']?.toString() ?? 'A').toUpperCase().trim(),
        imageUrl:      r['image_url']?.toString(),
        explanation:   r['explanation']?.toString(),
      );

  // ---- LESSON PLANS ----
  Future<void> upsertLessonPlan(LessonPlanModel plan) async {
    await _db.from('lesson_plans').upsert({
      'id': plan.id,
      'student_id': plan.studentId,
      'title': plan.title,
      'plan_date': plan.date.toIso8601String().split('T')[0],
      'notes': plan.notes,
      'is_completed': plan.isCompleted,
      'color': plan.color,
    });
    // upsert tasks
    await _db.from('lesson_tasks').delete().eq('plan_id', plan.id);
    if (plan.tasks.isNotEmpty) {
      final tasks = plan.tasks.asMap().entries.map((e) => {
            'id': e.value.id,
            'plan_id': plan.id,
            'title': e.value.title,
            'is_done': e.value.isDone,
            'chapter': e.value.chapter,
            'type': e.value.type,
            'sort_order': e.key,
          }).toList();
      await _db.from('lesson_tasks').insert(tasks);
    }
  }

  Future<List<LessonPlanModel>> getLessonPlans(String studentId) async {
    final plans = await _db
        .from('lesson_plans')
        .select()
        .eq('student_id', studentId)
        .order('plan_date', ascending: false);
    final result = <LessonPlanModel>[];
    for (final p in (plans as List)) {
      final tasks = await _db
          .from('lesson_tasks')
          .select()
          .eq('plan_id', p['id'])
          .order('sort_order');
      final taskList = (tasks as List).map((t) => LessonTask(
            id: t['id'],
            title: t['title'],
            isDone: t['is_done'] ?? false,
            chapter: t['chapter'],
            type: t['type'] ?? 'study',
          )).toList();
      result.add(LessonPlanModel(
        id: p['id'],
        studentId: p['student_id'],
        title: p['title'],
        date: DateTime.parse(p['plan_date']),
        tasks: taskList,
        notes: p['notes'],
        isCompleted: p['is_completed'] ?? false,
        color: p['color'] ?? '#4C3FA0',
      ));
    }
    return result;
  }

  Future<void> deleteLessonPlan(String id) async {
    await _db.from('lesson_plans').delete().eq('id', id);
  }

  // ---- NOTES ----
  Future<void> upsertNote(NoteModel note) async {
    await _db.from('notes').upsert({
      'id': note.id,
      'name': note.name,
      'link': note.link,
      'visibility': note.visibility,
      'section_id': note.sectionId,
      'section_name': note.sectionName,
      'is_link': note.isLink,
      'is_private': note.isPrivate,
      'sort_order': note.sortOrder,   // ← was missing — fixes reorder not saving
    });
  }

  Future<List<NoteModel>> getAllNotes() async {
    // Order by sort_order so the initial fetch respects saved order
    final res = await _db.from('notes').select().order('sort_order');
    return (res as List).map((r) => NoteModel(
          id: r['id'],
          name: r['name'],
          link: r['link'],
          visibility: r['visibility'] ?? 'all',
          sectionId: r['section_id'] ?? '',
          sectionName: r['section_name'] ?? 'General',
          isLink: r['is_link'] ?? false,
          isPrivate: r['is_private'] ?? false,
          createdAt: DateTime.parse(r['created_at']),
          sortOrder: r['sort_order'] ?? 0,   // ← was missing — fixes load
        )).toList();
  }

  Stream<List<NoteModel>> streamAllNotes() {
    return _db.from('notes').stream(primaryKey: ['id'])
        .map((list) {
          final mapped = list.map((r) => NoteModel(
            id: r['id'],
            name: r['name'],
            link: r['link'],
            visibility: r['visibility'] ?? 'all',
            sectionId: r['section_id'] ?? '',
            sectionName: r['section_name'] ?? 'General',
            isLink: r['is_link'] ?? false,
            isPrivate: r['is_private'] ?? false,
            createdAt: DateTime.parse(r['created_at']),
            sortOrder: r['sort_order'] ?? 0,
          )).toList();
          mapped.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          return mapped;
        });
  }

  Future<void> deleteNote(String id) async {
    await _db.from('notes').delete().eq('id', id);
  }

  // ---- OFFLINE TESTS ----
  Future<void> upsertOfflineTest(OfflineTestModel test) async {
    await _db.from('offline_tests').upsert({
      'id': test.id,
      'name': test.name,
      'test_date': test.date.toIso8601String().split('T')[0],
      'full_marks': test.fullMarks,
      'batch': test.batch,
      'student_marks': test.studentMarks,
    });
  }

  Future<List<OfflineTestModel>> getOfflineTestsByBatch(String batch) async {
    final res = await _db
        .from('offline_tests')
        .select()
        .eq('batch', batch)
        .order('test_date', ascending: false);
    return (res as List).map((r) => OfflineTestModel(
          id: r['id'],
          name: r['name'],
          date: DateTime.parse(r['test_date']),
          fullMarks: r['full_marks'],
          batch: r['batch'],
          studentMarks: Map<String, int?>.from(r['student_marks'] ?? {}),
        )).toList();
  }

  Future<void> deleteOfflineTest(String id) async {
    await _db.from('offline_tests').delete().eq('id', id);
  }

  // ---- SETTINGS ----
  Future<void> setSetting(String key, dynamic value) async {
    await _db.from('app_settings').upsert({'key': key, 'value': value});
  }

  Future<dynamic> getSetting(String key) async {
    final res = await _db.from('app_settings').select('value').eq('key', key).maybeSingle();
    return res?['value'];
  }

  // ---- CHATBOT USAGE (rate limiting) ----

  Future<int> getChatbotUsageToday(String studentId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      final res = await _db
          .from('chatbot_usage')
          .select('count')
          .eq('student_id', studentId)
          .eq('date', today)
          .maybeSingle();
      return (res?['count'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Sum of all chatbot questions ever asked by this student
  Future<int> getChatbotUsageTotal(String studentId) async {
    try {
      final res = await _db
          .from('chatbot_usage')
          .select('count')
          .eq('student_id', studentId);
      return (res as List).fold<int>(0, (s, r) => s + ((r['count'] as int?) ?? 0));
    } catch (_) { return 0; }
  }

  /// Update earned badges list in DB
  Future<void> updateEarnedBadges(String studentId, List<String> badgeIds) async {
    try {
      await _db.from('users').update({'earned_badge_ids': badgeIds}).eq('id', studentId);
    } catch (e) { debugPrint('[Supabase] updateEarnedBadges: $e'); }
  }

  /// Update games played list in DB
  Future<void> updateGamesPlayed(String studentId, List<String> games) async {
    try {
      await _db.from('users').update({'games_played': games}).eq('id', studentId);
    } catch (e) { debugPrint('[Supabase] updateGamesPlayed: $e'); }
  }

  /// Update bio lab completed list in DB
  Future<void> updateBioLabCompleted(String studentId, List<String> processIds) async {
    try {
      await _db.from('users').update({'biolab_completed': processIds}).eq('id', studentId);
    } catch (e) { debugPrint('[Supabase] updateBioLabCompleted: $e'); }
  }

  /// Get all exam results for a student (first attempts + retakes)
  Future<List<ExamResultModel>> getAllStudentResults(String studentId) async {
    try {
      final res = await _db
          .from('exam_results')
          .select()
          .eq('student_id', studentId)
          .eq('is_in_progress', false)
          .order('submitted_at', ascending: false);
      return _parseRows(res);
    } catch (_) { return []; }
  }

  Future<void> incrementChatbotUsage(String studentId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      // Read current count, then write count+1.
      // The upsert approach was wrong — it always set count=1, resetting the value.
      final existing = await _db
          .from('chatbot_usage')
          .select('id, count')
          .eq('student_id', studentId)
          .eq('date', today)
          .maybeSingle();
      if (existing == null) {
        await _db.from('chatbot_usage').insert(
            {'student_id': studentId, 'date': today, 'count': 1});
      } else {
        await _db.from('chatbot_usage')
            .update({'count': (existing['count'] as int? ?? 0) + 1})
            .eq('id', existing['id']);
      }
    } catch (e) {
      debugPrint('[SupabaseService] incrementChatbotUsage failed: $e');
    }
  }

  // ---- DEVELOPER INFO ----
  Future<Map<String, dynamic>?> getDeveloperInfo() async {
    try {
      final res = await _db.from('developer_info').select().maybeSingle();
      return res;
    } catch (_) {
      return null;
    }
  }

  Stream<Map<String, dynamic>?> streamDeveloperInfo() {
    return _db.from('developer_info').stream(primaryKey: ['id']).map((list) {
      if (list.isEmpty) return null;
      return list.first;
    });
  }

  Future<void> upsertDeveloperInfo(Map<String, dynamic> data) async {
    final existing = await _db.from('developer_info').select('id').maybeSingle();
    if (existing != null) {
      await _db.from('developer_info').update(data).eq('id', existing['id']);
    } else {
      await _db.from('developer_info').insert(data);
    }
  }
}



