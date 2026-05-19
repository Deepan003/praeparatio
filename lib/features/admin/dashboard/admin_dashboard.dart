import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/exam_model.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/custom_button.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;

  List<ExamModel> _getExamsForDay(List<ExamModel> exams, DateTime day) {
    return exams.where((e) {
      if (e.createdAt.year == day.year && e.createdAt.month == day.month && e.createdAt.day == day.day) return true;
      if (e.visibilityStart != null) {
        final s = e.visibilityStart!;
        if (s.year == day.year && s.month == day.month && s.day == day.day) return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final examsAsync = ref.watch(allExamsProvider);
    final studentsAsync = ref.watch(allStudentsProvider);

    return examsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (exams) {
        final dayExams = _getExamsForDay(exams, _selectedDay);
        final published = exams.where((e) => e.isPublished).length;
        final total = exams.length;
        final upcoming = exams.where((e) => e.isPublished && e.visibilityStart != null && e.visibilityStart!.isAfter(DateTime.now())).length;
        final studentCount = studentsAsync.value?.length ?? 0;

        return LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          final isMobile = constraints.maxWidth < 600;
          final hPad = isMobile ? 14.0 : 24.0;

          return SingleChildScrollView(
            // Extra bottom padding so content isn't hidden under the admin
            // bottom navigation bar that was added for mobile.
            padding: EdgeInsets.fromLTRB(hPad, hPad, hPad, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row
                _buildStatsRow(total, published, upcoming, exams, studentCount)
                    .animate().fadeIn(duration: 300.ms),
                SizedBox(height: isMobile ? 16 : 24),

                // Main content: side-by-side on wide, stacked on mobile
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _buildCalendar(exams, isMobile)),
                      const SizedBox(width: 24),
                      Expanded(flex: 4, child: _buildDayPanel(dayExams, isMobile)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildCalendar(exams, isMobile),
                      const SizedBox(height: 14),
                      _buildDayPanel(dayExams, isMobile),
                    ],
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildStatsRow(int total, int published, int upcoming, List<ExamModel> exams, int studentCount) {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth < 400 ? 2 : constraints.maxWidth < 700 ? 3 : 5;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: cols,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: cols <= 2 ? 1.4 : 1.5,
        children: [
          _StatMini('Students', '$studentCount', Icons.people_outline, AppColors.accent),
          _StatMini('Total Exams', '$total', Icons.quiz_outlined, AppColors.primary),
          _StatMini('Published', '$published', Icons.check_circle_outline, AppColors.success),
          _StatMini('Upcoming', '$upcoming', Icons.upcoming_outlined, AppColors.info),
          _StatMini('Expired', '${exams.where((e) => e.isExpired).length}', Icons.timer_off_outlined, AppColors.warning),
        ],
      );
    });
  }

  Widget _buildCalendar(List<ExamModel> exams, bool isMobile) {
    return SolidCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Exam Calendar',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                SizedBox(
                  height: 40,
                  child: GradientButton(
                    label: 'New Exam',
                    icon: Icons.add,
                    onPressed: () => context.go(Routes.adminExamCreate),
                    width: isMobile ? 120 : 130,
                  ),
                ),
              ],
            ),
          ),
          TableCalendar<ExamModel>(
            firstDay: DateTime(2024),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
            calendarFormat: _calendarFormat,
            eventLoader: (d) => _getExamsForDay(exams, d),
            onDaySelected: (selected, focused) => setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            }),
            onFormatChanged: (f) => setState(() => _calendarFormat = f),
            onPageChanged: (f) => setState(() => _focusedDay = f),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), shape: BoxShape.circle),
              todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
              markerDecoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              markersMaxCount: 3,
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonDecoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              formatButtonTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayPanel(List<ExamModel> dayExams, bool isMobile) {
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat(isMobile ? 'MMM d, yyyy' : 'MMMM d, yyyy')
                      .format(_selectedDay),
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                onPressed: () => context.go(
                    '${Routes.adminExamCreate}?date=${_selectedDay.toIso8601String()}'),
              ),
            ],
          ),
          const Divider(height: 16),
          if (dayExams.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_available,
                        size: 36, color: AppColors.textHint),
                    SizedBox(height: 8),
                    Text('No exams on this day',
                        style: TextStyle(color: AppColors.textHint)),
                  ],
                ),
              ),
            )
          else
            ...dayExams.map((exam) => _ExamDayCard(exam: exam)).toList(),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatMini(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ExamDayCard extends ConsumerWidget {
  final ExamModel exam;
  const _ExamDayCard({required this.exam});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color tagColor;
    switch (exam.tag) {
      case 'Compulsory': tagColor = AppColors.error; break;
      case 'Revision': tagColor = AppColors.info; break;
      default: tagColor = AppColors.success;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.neuBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(exam.avatarId.contains('av_') ? _avatarEmoji(exam.avatarId) : '📝', style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exam.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Tag(exam.difficulty, AppColors.primary),
                    _Tag(exam.tag, tagColor),
                    _Tag('${exam.durationMinutes}m', AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: exam.isPublished ? AppColors.successSurface : AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  exam.isPublished ? 'Live' : 'Draft',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: exam.isPublished ? AppColors.success : AppColors.warning),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
                onSelected: (val) {
                  if (val == 'edit') context.go('${Routes.adminExamCreate}?examId=${exam.id}');
                  if (val == 'stats') context.go(Routes.adminExamStats.replaceAll(':examId', exam.id));
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'stats', child: Text('Statistics')),
                  PopupMenuItem(value: 'copy', child: Text('Copy')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _avatarEmoji(String id) {
    const emojis = ['🦉','🧬','🔬','🧠','🌿','🔵','⚡','⭐','🔥','💎','👑','🏆','☄️','🌌','🦅','🌱','⚛️','❤️','🌍','⛰️'];
    final idx = int.tryParse(id.replaceAll('av_', '')) ?? 1;
    return emojis[(idx - 1) % emojis.length];
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
      );
}
