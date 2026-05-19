import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/ncert_chapters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/lesson_plan_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';

const _uuid = Uuid();

class LessonPlannerScreen extends ConsumerStatefulWidget {
  const LessonPlannerScreen({super.key});

  @override
  ConsumerState<LessonPlannerScreen> createState() =>
      _LessonPlannerScreenState();
}

class _LessonPlannerScreenState extends ConsumerState<LessonPlannerScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  CalendarFormat _format = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    if (user == null) return const SizedBox.shrink();

    final plans = ref.watch(lessonPlanNotifierProvider(user.id));

    List<LessonPlanModel> _plansForDay(DateTime day) => plans
        .where((p) =>
            p.date.year == day.year &&
            p.date.month == day.month &&
            p.date.day == day.day)
        .toList();

    final dayPlans = _plansForDay(_selected);

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 800;

      return Row(
        children: [
          // Calendar side
          SizedBox(
            width: isWide ? 360 : constraints.maxWidth,
            child: Column(
              children: [
                TableCalendar<LessonPlanModel>(
                  firstDay: DateTime(2024),
                  lastDay: DateTime(2030),
                  focusedDay: _focused,
                  selectedDayPredicate: (d) => isSameDay(_selected, d),
                  calendarFormat: _format,
                  eventLoader: _plansForDay,
                  onDaySelected: (sel, foc) =>
                      setState(() { _selected = sel; _focused = foc; }),
                  onFormatChanged: (f) =>
                      setState(() => _format = f),
                  onPageChanged: (f) =>
                      setState(() => _focused = f),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    todayDecoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        shape: BoxShape.circle),
                    markerDecoration: const BoxDecoration(
                        color: AppColors.accent, shape: BoxShape.circle),
                  ),
                ),
                const Divider(),
                if (!isWide) _DayPlanList(
                  date: _selected,
                  plans: dayPlans,
                  userId: user.id,
                  onAdd: () => _showAddDialog(context, user.id),
                ),
              ],
            ),
          ),

          if (isWide) ...[
            const VerticalDivider(width: 1),
            Expanded(
              child: _DayPlanList(
                date: _selected,
                plans: dayPlans,
                userId: user.id,
                onAdd: () => _showAddDialog(context, user.id),
              ),
            ),
          ],
        ],
      );
    });
  }

  void _showAddDialog(BuildContext context, String userId) {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final List<Map<String, dynamic>> tasks = [];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(
              'Plan for ${DateFormat("MMM d, yyyy").format(_selected)}'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: titleCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Plan Title *')),
                  const SizedBox(height: 10),
                  // Add tasks
                  ...tasks.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(e.value['title'] ?? '',
                                  style: const TextStyle(fontSize: 13)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () =>
                                  setSt(() => tasks.removeAt(e.key)),
                            ),
                          ],
                        ),
                      )),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Task'),
                    onPressed: () => _showTaskDialog(ctx, (task) {
                      setSt(() => tasks.add(task));
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                      controller: notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                          labelText: 'Notes (optional)')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty) return;
                final taskList = tasks
                    .map((t) => LessonTask(
                          id: _uuid.v4(),
                          title: t['title'],
                          chapter: t['chapter'],
                          type: t['type'] ?? 'study',
                        ))
                    .toList();
                await ref
                    .read(lessonPlanNotifierProvider(userId).notifier)
                    .addPlan(titleCtrl.text.trim(), _selected, taskList,
                        notes: notesCtrl.text.trim().isEmpty
                            ? null
                            : notesCtrl.text.trim());
                Navigator.pop(ctx);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDialog(
      BuildContext context, ValueChanged<Map<String, dynamic>> onAdd) {
    final ctrl = TextEditingController();
    String? chapter;
    String type = 'study';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(labelText: 'Task title')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: null,
                hint: const Text('Chapter (optional)'),
                items: NcertChapters.allChapters
                    .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12))))
                    .toList(),
                onChanged: (v) => setSt(() => chapter = v),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: ['study', 'practice', 'revision', 'test']
                    .map((t) => FilterChip(
                          label: Text(t),
                          selected: type == t,
                          onSelected: (_) => setSt(() => type = t),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.isEmpty) return;
                onAdd({'title': ctrl.text.trim(), 'chapter': chapter, 'type': type});
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayPlanList extends ConsumerWidget {
  final DateTime date;
  final List<LessonPlanModel> plans;
  final String userId;
  final VoidCallback onAdd;

  const _DayPlanList(
      {required this.date,
      required this.plans,
      required this.userId,
      required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Text(DateFormat('EEEE, MMMM d').format(date),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const Spacer(),
                GradientButton(
                    label: 'Add Plan',
                    icon: Icons.add,
                    onPressed: onAdd,
                    width: 110),
              ],
            ),
          ),
          Expanded(
            child: plans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.event_note_outlined,
                            size: 48, color: AppColors.textHint),
                        const SizedBox(height: 8),
                        const Text('No plans for this day',
                            style: TextStyle(color: AppColors.textHint)),
                        const SizedBox(height: 12),
                        TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Create a plan'),
                            onPressed: onAdd),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: plans.length,
                    itemBuilder: (_, i) => _PlanCard(
                      plan: plans[i],
                      userId: userId,
                    ).animate(delay: (i * 30).ms).fadeIn(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  final LessonPlanModel plan;
  final String userId;

  const _PlanCard({required this.plan, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = plan.progress;

    return SolidCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(plan.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15))),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 16, color: AppColors.error),
                onPressed: () async {
                  await ref
                      .read(lessonPlanNotifierProvider(userId).notifier)
                      .deletePlan(plan.id);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1 ? AppColors.success : AppColors.primary),
            minHeight: 5,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text(
            '${plan.completedTasks}/${plan.tasks.length} tasks done',
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          ...plan.tasks.map((task) => CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: task.isDone,
                onChanged: (_) async {
                  await ref
                      .read(lessonPlanNotifierProvider(userId).notifier)
                      .toggleTask(plan.id, task.id);
                },
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 13,
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone
                        ? AppColors.textHint
                        : AppColors.textPrimary,
                  ),
                ),
                subtitle: task.chapter != null
                    ? Text(task.chapter!,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.primary))
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.success,
              )),
          if (plan.notes != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.neuBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(plan.notes!,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic)),
            ),
          ],
        ],
      ),
    );
  }
}
