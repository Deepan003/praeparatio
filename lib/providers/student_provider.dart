import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/lesson_plan_model.dart';
import '../services/supabase_service.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// All students
final allStudentsProvider = FutureProvider<List<UserModel>>((ref) async {
  return SupabaseService.instance.getAllStudents();
});

// Students by batch
final batchStudentsProvider = FutureProvider.family<List<UserModel>, String>((ref, batch) async {
  return SupabaseService.instance.getStudentsByBatch(batch);
});

// Single student
final studentDetailProvider = FutureProvider.family<UserModel?, String>((ref, id) async {
  return SupabaseService.instance.getUserById(id);
});

// ---- LESSON PLANNER ----
final lessonPlansProvider = FutureProvider.family<List<LessonPlanModel>, String>((ref, studentId) async {
  return SupabaseService.instance.getLessonPlans(studentId);
});

class LessonPlanNotifier extends StateNotifier<List<LessonPlanModel>> {
  final String studentId;
  LessonPlanNotifier(this.studentId) : super([]);

  Future<void> load() async {
    final plans = await SupabaseService.instance.getLessonPlans(studentId);
    state = plans;
  }

  Future<void> addPlan(String title, DateTime date, List<LessonTask> tasks, {String? notes, String color = '#4C3FA0'}) async {
    final plan = LessonPlanModel(
      id: _uuid.v4(),
      studentId: studentId,
      title: title,
      date: date,
      tasks: tasks,
      notes: notes,
      color: color,
    );
    await SupabaseService.instance.upsertLessonPlan(plan);
    state = [plan, ...state];
  }

  Future<void> updatePlan(LessonPlanModel plan) async {
    await SupabaseService.instance.upsertLessonPlan(plan);
    state = state.map((p) => p.id == plan.id ? plan : p).toList();
  }

  Future<void> toggleTask(String planId, String taskId) async {
    final plan = state.firstWhere((p) => p.id == planId);
    for (final task in plan.tasks) {
      if (task.id == taskId) task.isDone = !task.isDone;
    }
    plan.isCompleted = plan.tasks.every((t) => t.isDone);
    await SupabaseService.instance.upsertLessonPlan(plan);
    state = [...state];
  }

  Future<void> deletePlan(String id) async {
    await SupabaseService.instance.deleteLessonPlan(id);
    state = state.where((p) => p.id != id).toList();
  }
}

final lessonPlanNotifierProvider = StateNotifierProvider.family<LessonPlanNotifier, List<LessonPlanModel>, String>(
  (ref, studentId) => LessonPlanNotifier(studentId),
);

// ---- PREPCOINS ----
class PrepcoinsNotifier extends StateNotifier<int> {
  PrepcoinsNotifier(int initial) : super(initial);

  Future<void> addCoins(String userId, int amount) async {
    final newAmount = state + amount;
    await SupabaseService.instance.updateUserPrepcoins(userId, newAmount);
    state = newAmount;
  }

  Future<void> deductCoins(String userId, int amount) async {
    final newAmount = (state - amount).clamp(0, 99999);
    await SupabaseService.instance.updateUserPrepcoins(userId, newAmount);
    state = newAmount;
  }

  Future<void> setCoins(String userId, int amount) async {
    final clamped = amount.clamp(0, 99999);
    await SupabaseService.instance.updateUserPrepcoins(userId, clamped);
    state = clamped;
  }
}

final prepcoinsProvider = StateNotifierProvider.family<PrepcoinsNotifier, int, int>(
  (ref, initial) => PrepcoinsNotifier(initial),
);
