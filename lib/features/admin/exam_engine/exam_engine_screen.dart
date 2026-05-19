import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../../services/download_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/exam_model.dart';
import '../../../models/exam_result_model.dart';
import '../../../providers/batch_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../services/notification_service.dart';
import '../../../services/pdf_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/download_button.dart';
import '../../../widgets/glass_card.dart';

class ExamEngineScreen extends ConsumerStatefulWidget {
  const ExamEngineScreen({super.key});

  @override
  ConsumerState<ExamEngineScreen> createState() => _ExamEngineScreenState();
}

class _ExamEngineScreenState extends ConsumerState<ExamEngineScreen> {
  String _filter   = 'all';   // all / published / draft / expired
  String _batch    = 'all';   // all / 11 NEET / 12 NEET / NEET Exclusive
  String _search   = '';

  static const _statusFilters = [
    ('all', 'All'),
    ('published', 'Live'),
    ('draft', 'Drafts'),
    ('expired', 'Expired'),
  ];

  @override
  Widget build(BuildContext context) {
    final examsAsync = ref.watch(allExamsProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width > 900;

    return Column(
      children: [
        // ── Toolbar ────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: AppColors.neuSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search exams…',
                        prefixIcon: Icon(Icons.search, size: 18),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Compact on mobile — icon only
                  Builder(builder: (ctx) {
                    final compact = MediaQuery.sizeOf(ctx).width < 480;
                    return compact
                        ? IconButton(
                            icon: const Icon(Icons.add_circle_rounded,
                                color: AppColors.primary, size: 28),
                            onPressed: () => context.go(Routes.adminExamCreate),
                            tooltip: 'Create Exam',
                          )
                        : GradientButton(
                            label: 'Create Exam',
                            icon: Icons.add,
                            onPressed: () => context.go(Routes.adminExamCreate),
                            width: 140,
                          );
                  }),
                ],
              ),
              const SizedBox(height: 10),
              // Status filter row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ..._statusFilters.map((f) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _FilterChip(
                            label: f.$2,
                            selected: _filter == f.$1,
                            onTap: () => setState(() => _filter = f.$1),
                          ),
                        )),
                    Container(width: 1, height: 22, color: AppColors.border,
                        margin: const EdgeInsets.symmetric(horizontal: 6)),
                    // 'All Batches' chip
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _FilterChip(
                        label: 'All Batches',
                        selected: _batch == 'all',
                        color: AppColors.bioGreen,
                        onTap: () => setState(() => _batch = 'all'),
                      ),
                    ),
                    // Dynamic batch chips from DB
                    ...(ref.watch(batchNamesProvider).value ?? AppConstants.batches)
                        .map((b) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: _FilterChip(
                                label: b,
                                selected: _batch == b,
                                color: AppColors.bioGreen,
                                onTap: () => setState(() => _batch = b),
                              ),
                            )),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Exam list ──────────────────────────────────────────
        Expanded(
          child: examsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (exams) {
              // Sort newest first
              final sorted = [...exams]
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

              final filtered = sorted.where((e) {
                if (_search.isNotEmpty &&
                    !e.title.toLowerCase().contains(_search.toLowerCase()))
                  return false;
                if (_filter == 'published' && !e.isPublished) return false;
                if (_filter == 'draft' && e.isPublished) return false;
                if (_filter == 'expired' && !e.isExpired) return false;
                if (_batch != 'all' && !e.targetBatches.contains(_batch))
                  return false;
                return true;
              }).toList();

              if (filtered.isEmpty) {
                return const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.quiz_outlined, size: 56, color: AppColors.textHint),
                    SizedBox(height: 12),
                    Text('No exams match',
                        style: TextStyle(color: AppColors.textHint, fontSize: 15)),
                  ]),
                );
              }

              // Grid layout — compact cards
              if (isWide)
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.55,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _ExamCard(
                    exam: filtered[i],
                    onRefresh: () => ref.invalidate(allExamsProvider),
                  ).animate(delay: (i * 25).ms).fadeIn(duration: 200.ms),
                );
              // Mobile — single-column list (cards are too small in a 2-col grid)
              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: filtered.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ExamCard(
                    exam: filtered[i],
                    onRefresh: () => ref.invalidate(allExamsProvider),
                  ).animate(delay: (i * 25).ms).fadeIn(duration: 200.ms),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Compact exam card ──────────────────────────────────────────
class _ExamCard extends ConsumerWidget {
  final ExamModel exam;
  final VoidCallback onRefresh;

  const _ExamCard({required this.exam, required this.onRefresh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagColor = _tagColor(exam.tag);

    return SolidCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.science_outlined, color: tagColor, size: 18),
                  ),
                  if (exam.isNew)
                    Positioned(
                      top: -4, right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text('NEW',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(exam.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Chips
          Wrap(spacing: 4, runSpacing: 3, children: [
            _chip(exam.difficulty, AppColors.primary),
            _chip('${exam.questionIds.length} Qs', AppColors.info),
            _chip('${exam.durationMinutes}m', AppColors.textSecondary),
            ...exam.targetBatches.take(2).map((b) => _chip(b, AppColors.success)),
          ]),

          const Spacer(),

          // Footer: publish toggle + results publish + actions
          LayoutBuilder(builder: (context, constraints) {
            // When card is narrow (desktop grid) hide the ranks text label
            final wide = constraints.maxWidth >= 295;
            return Row(
              children: [
                // Live/Draft switch
                Transform.scale(
                  scale: 0.78,
                  alignment: Alignment.centerLeft,
                  child: Switch(
                    value: exam.isPublished,
                    activeColor: AppColors.success,
                    onChanged: (v) async {
                      exam.isPublished = v;
                      if (v) exam.publishedAt = DateTime.now();
                      await SupabaseService.instance.upsertExam(exam);
                      // Auto-notify students when exam goes LIVE
                      if (v) {
                        NotificationService.instance.notifyExamPublished(
                          examTitle:     exam.title,
                          targetBatches: exam.targetBatches,
                          examId:        exam.id,
                          createdBy:     'admin',
                        );
                      }
                      onRefresh();
                    },
                  ),
                ),
                Text(exam.isPublished ? 'Live' : 'Draft',
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: exam.isPublished ? AppColors.success : AppColors.textHint)),
                const Spacer(),
                // Publish results (ranking) toggle
                Tooltip(
                  message: exam.resultsPublished
                      ? 'Rankings visible to students — tap to hide'
                      : 'Rankings hidden — tap to reveal to students',
                  child: GestureDetector(
                    onTap: () async {
                      exam.resultsPublished = !exam.resultsPublished;
                      await SupabaseService.instance.upsertExam(exam);
                      // Auto-notify students who attempted when rankings go ON
                      if (exam.resultsPublished) {
                        final results = await SupabaseService.instance
                            .getAllResultsForExam(exam.id);
                        final ids = results.map((r) => r.studentId).toList();
                        NotificationService.instance.notifyResultsReleased(
                          examTitle:  exam.title,
                          examId:     exam.id,
                          studentIds: ids,
                          createdBy:  'admin',
                        );
                      }
                      onRefresh();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: wide ? 6 : 4, vertical: 3),
                      decoration: BoxDecoration(
                        color: exam.resultsPublished
                            ? AppColors.primarySurface
                            : AppColors.neuBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: exam.resultsPublished
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          exam.resultsPublished
                              ? Icons.bar_chart_rounded
                              : Icons.bar_chart_outlined,
                          size: 12,
                          color: exam.resultsPublished
                              ? AppColors.primary
                              : AppColors.textHint,
                        ),
                        if (wide) ...[
                          const SizedBox(width: 3),
                          Text(
                            exam.resultsPublished ? 'Ranks ON' : 'Ranks OFF',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: exam.resultsPublished
                                    ? AppColors.primary
                                    : AppColors.textHint),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Question paper download (admin always gets both options)
                _QuestionPaperBtn(exam: exam),
                const SizedBox(width: 2),
                // Action icons
                _ActionBtn(Icons.edit_outlined, AppColors.primary,
                    () => _handleEdit(context, ref)),
                _ActionBtn(Icons.bar_chart_outlined, AppColors.info,
                    () => context.go(Routes.adminExamStats.replaceAll(':examId', exam.id))),
                _ActionBtn(Icons.delete_outline, AppColors.error,
                    () => _confirmDelete(context, ref)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4)),
        child: Text(text,
            style:
                TextStyle(fontSize: 9.5, color: color, fontWeight: FontWeight.w600)),
      );

  // ── Edit guard ────────────────────────────────────────────────
  Future<void> _handleEdit(BuildContext context, WidgetRef ref) async {
    // Check if any students have already attempted this exam
    List<ExamResultModel> attempts = [];
    try {
      attempts = await SupabaseService.instance.getAllResultsForExam(exam.id);
    } catch (_) {}

    if (!context.mounted) return;

    if (attempts.isEmpty) {
      // No attempts — safe to edit directly
      context.go('${Routes.adminExamCreate}?examId=${exam.id}');
      return;
    }

    // Students have attempted — show the republish dialog
    final choice = await showDialog<String>(
      context: context,
      builder: (dx) => _RepublishDialog(
        examTitle: exam.title,
        attemptCount: attempts.length,
      ),
    );

    if (!context.mounted || choice == null) return;

    switch (choice) {
      case 'settings_only':
        // Navigate to creator — admin edits only settings, not questions
        context.go('${Routes.adminExamCreate}?examId=${exam.id}&settingsOnly=true');

      case 'full_reset':
        // Step 1: Unpublish so no one can take it during edit
        exam.isPublished = false;
        await SupabaseService.instance.upsertExam(exam);

        // Step 2: Delete ALL results for this exam (clean slate)
        try {
          await SupabaseService.instance.deleteAllResultsForExam(exam.id);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Could not clear results: $e'),
              backgroundColor: AppColors.error,
            ));
          }
          return;
        }

        onRefresh();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Exam unpublished and results cleared. Edit questions, then republish.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 4),
          ));
          context.go('${Routes.adminExamCreate}?examId=${exam.id}');
        }
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dx) => AlertDialog(
        title: const Text('Delete Exam'),
        content: Text('Delete "${exam.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(dx);
              await SupabaseService.instance.deleteExam(exam.id);
              onRefresh();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _tagColor(String tag) => switch (tag) {
        'Compulsory' => AppColors.error,
        'Revision' => AppColors.info,
        _ => AppColors.success,
      };
}

// ── Admin question paper download — with or without answer key ─
class _QuestionPaperBtn extends StatefulWidget {
  final ExamModel exam;
  const _QuestionPaperBtn({required this.exam});
  @override
  State<_QuestionPaperBtn> createState() => _QuestionPaperBtnState();
}

class _QuestionPaperBtnState extends State<_QuestionPaperBtn> {
  bool _loading = false;

  String get _safeName =>
      widget.exam.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

  Future<void> _downloadPdf(bool withKey) async {
    setState(() => _loading = true);
    try {
      final qs = await SupabaseService.instance.getQuestionsForExam(widget.exam.id);
      final bytes = await PdfService.questionPaperPdf(
          exam: widget.exam, questions: qs, showAnswers: withKey);
      final suffix = withKey ? '_AnswerKey' : '_Questions';
      await Printing.sharePdf(bytes: bytes, filename: '${_safeName}$suffix.pdf');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _downloadDocx(bool withKey) async {
    setState(() => _loading = true);
    try {
      final qs = await SupabaseService.instance.getQuestionsForExam(widget.exam.id);
      final bytes = PdfService.questionPaperRtf(
          exam: widget.exam, questions: qs, showAnswers: withKey);
      final suffix = withKey ? '_AnswerKey' : '_Questions';
      final filename = '${_safeName}$suffix.rtf';
      if (kIsWeb) {
        downloadFile(bytes, filename);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        await File('${dir.path}/$filename').writeAsBytes(bytes);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved: $filename (opens in Word)')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Download Question Paper',
    child: GestureDetector(
      onTap: _loading ? null : () => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.neuBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 36, height: 4,
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Download Question Paper',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Choose format and mode',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              // PDF row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Expanded(child: _PaperModeBtn(
                    label: 'PDF',
                    subtitle: 'Questions only',
                    icon: Icons.picture_as_pdf_rounded,
                    color: AppColors.primary,
                    onTap: () { Navigator.pop(context); _downloadPdf(false); },
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _PaperModeBtn(
                    label: 'PDF + Key',
                    subtitle: 'With answers',
                    icon: Icons.key_rounded,
                    color: AppColors.success,
                    onTap: () { Navigator.pop(context); _downloadPdf(true); },
                  )),
                ]),
              ),
              const SizedBox(height: 10),
              // Word row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Expanded(child: _PaperModeBtn(
                    label: 'Word',
                    subtitle: 'Editable .rtf\n(opens in Word)',
                    icon: Icons.description_outlined,
                    color: AppColors.info,
                    onTap: () { Navigator.pop(context); _downloadDocx(false); },
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _PaperModeBtn(
                    label: 'Word + Key',
                    subtitle: 'Word with\nanswers inside',
                    icon: Icons.fact_check_outlined,
                    color: AppColors.accent,
                    onTap: () { Navigator.pop(context); _downloadDocx(true); },
                  )),
                ]),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: _loading
            ? const Padding(padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.print_rounded, size: 17, color: AppColors.primary),
      ),
    ),
  );
}

class _PaperModeBtn extends StatelessWidget {
  final String label, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _PaperModeBtn({required this.label, required this.subtitle,
      required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(subtitle, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.4)),
      ]),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(icon, size: 20, color: color),
        onPressed: onTap,
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        visualDensity: VisualDensity.compact,
      );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? color : AppColors.neuPressedColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: selected ? color : AppColors.border,
                width: selected ? 1.5 : 1),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textSecondary)),
        ),
      );
}

// ── Republish / Edit Guard Dialog ─────────────────────────────
class _RepublishDialog extends StatelessWidget {
  final String examTitle;
  final int attemptCount;
  const _RepublishDialog(
      {required this.examTitle, required this.attemptCount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.warningSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exam has attempts',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      Text('Choose edit mode carefully',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              // Info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$attemptCount student${attemptCount == 1 ? '' : 's'} '
                  'have already taken "$examTitle".\n\n'
                  'Changing questions will make their review '
                  'inconsistent with their stored scores.',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.5),
                ),
              ),
              const SizedBox(height: 20),

              // Option 1 — Settings only
              _OptionTile(
                icon: Icons.tune_rounded,
                color: AppColors.info,
                title: 'Edit Settings Only',
                subtitle:
                    'Change title, duration, batch, coin cost — scores stay valid. '
                    'Questions are locked.',
                onTap: () => Navigator.pop(context, 'settings_only'),
              ),
              const SizedBox(height: 10),

              // Option 2 — Full reset
              _OptionTile(
                icon: Icons.restart_alt_rounded,
                color: AppColors.error,
                title: 'Full Edit  (Reset All Results)',
                subtitle:
                    'Unpublishes the exam, deletes all ${attemptCount} student '
                    'result${attemptCount == 1 ? '' : 's'}, then opens the editor. '
                    'Students must retake. This cannot be undone.',
                onTap: () => Navigator.pop(context, 'full_reset'),
                danger: true,
              ),
              const SizedBox(height: 16),

              // Cancel
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _OptionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: danger ? AppColors.errorSurface : AppColors.neuBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: danger
                    ? AppColors.error.withOpacity(0.4)
                    : AppColors.border,
                width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: danger ? AppColors.error : AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            height: 1.4)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: color.withOpacity(0.6), size: 18),
            ],
          ),
        ),
      );
}
