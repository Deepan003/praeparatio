import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/ncert_chapters.dart';
import '../../../core/constants/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/exam_model.dart';
import '../../../models/question_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/batch_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../services/ai_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';

const _uuid = Uuid();

class ExamCreatorScreen extends ConsumerStatefulWidget {
  final String? examId;
  /// When true: questions tab is disabled — only settings can be changed.
  /// Used when editing an exam that already has student attempts.
  final bool settingsOnly;
  const ExamCreatorScreen({super.key, this.examId, this.settingsOnly = false});

  @override
  ConsumerState<ExamCreatorScreen> createState() => _ExamCreatorScreenState();
}

class _ExamCreatorScreenState extends ConsumerState<ExamCreatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _isLoading = true;
  bool _isAiMode = false;
  bool _isSaving = false;
  bool _isGenerating = false;
  String? _error;

  // Exam details
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '60');
  final _expRequiredCtrl = TextEditingController(text: '0');
  final _expGainedCtrl = TextEditingController(text: '100');
  final _aiPromptCtrl = TextEditingController();

  String _difficulty = 'Medium';
  String _tag = 'Practice';
  String _avatarId = 'av_01';
  List<String> _targetBatches = [];
  List<String> _selectedChapters = [];
  int? _selectedClass;
  DateTime? _visibilityStart;
  DateTime? _visibilityEnd;
  bool _isPublished = false;
  bool _isNew = true;
  bool _allowDownload = false;
  String _creditMode = 'none';
  int _creditThreshold = 30;

  // Questions
  List<QuestionModel> _questions = [];
  ExamModel? _exam;

  // AI generation
  int _aiCount = 20;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadExam();
  }

  Future<void> _loadExam() async {
    if (widget.examId != null) {
      final exam = await SupabaseService.instance.getExam(widget.examId!);
      final questions = await SupabaseService.instance.getQuestionsForExam(widget.examId!);
      if (mounted && exam != null) {
        setState(() {
          _exam = exam;
          _questions = questions;
          _titleCtrl.text = exam.title;
          _descCtrl.text = exam.description;
          _durationCtrl.text = exam.durationMinutes.toString();
          _expRequiredCtrl.text = exam.expRequired.toString();
          _expGainedCtrl.text = exam.expGained.toString();
          _aiPromptCtrl.text = exam.aiPrompt ?? '';
          _difficulty = exam.difficulty;
          _tag = exam.tag;
          _avatarId = exam.avatarId;
          _targetBatches = List.from(exam.targetBatches);
          _selectedChapters = List.from(exam.chapters);
          _selectedClass = exam.selectedClass;
          _visibilityStart = exam.visibilityStart;
          _visibilityEnd = exam.visibilityEnd;
          _isPublished = exam.isPublished;
          _isNew = exam.isNew;
          _allowDownload = exam.allowDownload;
          _creditMode = exam.creditMode;
          _creditThreshold = exam.creditThreshold;
          _isLoading = false;
        });
      }
    } else {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _generateWithAI() async {
    if (_selectedChapters.isEmpty && _selectedClass == null) {
      _showSnack('Select at least one chapter or a class.', isError: true);
      return;
    }
    setState(() { _isGenerating = true; _error = null; });
    final apiKey = AiService.instance.currentKey ?? '';
    if (apiKey.isEmpty) {
      setState(() { _isGenerating = false; _error = 'No Gemini API key found. Go to Admin → AI Config to set it.'; });
      return;
    }

    final chapters = _selectedChapters.isNotEmpty
        ? _selectedChapters
        : NcertChapters.chaptersForClass(_selectedClass?.toString() ?? '11');

    final creator = ref.read(examCreatorProvider.notifier);
    creator.initNewExam(ref.read(authProvider).value?.id ?? 'admin');

    try {
      await creator.generateWithAI(
        chapters: chapters,
        difficulty: _difficulty,
        count: _aiCount,
        prompt: _aiPromptCtrl.text.trim().isEmpty ? null : _aiPromptCtrl.text.trim(),
        selectedClass: _selectedClass,
        apiKey: apiKey,
      );
      final state = ref.read(examCreatorProvider);
      if (state.error != null) {
        setState(() { _isGenerating = false; _error = state.error; });
      } else {
        setState(() {
          _questions = state.questions;
          _isGenerating = false;
        });
        _tabs.animateTo(2); // Go to questions tab
      }
    } catch (e) {
      setState(() { _isGenerating = false; _error = e.toString(); });
    }
  }

  Future<void> _save({bool publish = false}) async {
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnack('Enter exam title.', isError: true);
      return;
    }
    if (_targetBatches.isEmpty) {
      _showSnack('Select at least one target batch.', isError: true);
      return;
    }
    setState(() { _isSaving = true; });

    final adminId = ref.read(authProvider).value?.id ?? 'admin';
    final exam = ExamModel(
      id: _exam?.id ?? _uuid.v4(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      targetBatches: _targetBatches,
      durationMinutes: int.tryParse(_durationCtrl.text) ?? 60,
      questionIds: _questions.map((q) => q.id).toList(),
      difficulty: _difficulty,
      type: _isAiMode ? 'ai' : 'manual',
      chapters: _selectedChapters,
      isPublished: publish,
      publishedAt: publish ? DateTime.now() : null,
      createdAt: _exam?.createdAt ?? DateTime.now(),
      visibilityStart: _visibilityStart,
      visibilityEnd: _visibilityEnd,
      expRequired: int.tryParse(_expRequiredCtrl.text) ?? 0,
      expGained: int.tryParse(_expGainedCtrl.text) ?? 100,
      tag: _tag,
      avatarId: _avatarId,
      isNew: _isNew,
      allowDownload: _allowDownload,
      aiPrompt: _aiPromptCtrl.text.trim().isEmpty ? null : _aiPromptCtrl.text.trim(),
      createdBy: adminId,
      selectedClass: _selectedClass,
      creditMode: _creditMode,
      creditThreshold: _creditThreshold,
    );

    final linked = _questions.asMap().entries.map((e) => QuestionModel(
          id: e.value.id,
          text: e.value.text,
          optionA: e.value.optionA,
          optionB: e.value.optionB,
          optionC: e.value.optionC,
          optionD: e.value.optionD,
          correctOption: e.value.correctOption,
          imageUrl: e.value.imageUrl,
          explanation: e.value.explanation,
          chapter: e.value.chapter,
          difficulty: e.value.difficulty,
          examId: exam.id,
        )).toList();

    try {
      await SupabaseService.instance.upsertExam(exam);
      await SupabaseService.instance.upsertQuestions(linked);
      
      // If publishing directly from the creator screen and it wasn't published before, send notification
      final bool wasPublished = _exam?.isPublished ?? false;
      if (publish && !wasPublished) {
        NotificationService.instance.notifyExamPublished(
          examTitle: exam.title,
          targetBatches: exam.targetBatches,
          examId: exam.id,
          createdBy: adminId,
        );
      }
      
      ref.invalidate(allExamsProvider);
      if (mounted) {
        setState(() { _isSaving = false; });
        _showSnack(publish ? 'Exam published!' : 'Exam saved as draft!');
        if (context.mounted) context.go(Routes.adminExamEngine);
      }
    } catch (e) {
      setState(() { _isSaving = false; });
      _showSnack('Error: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
    ));
  }

  int _autoTime() {
    final secs = AppConstants.secondsPerQuestion[_difficulty] ?? 72;
    return ((_aiCount * secs) / 60).ceil();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _durationCtrl.dispose();
    _expRequiredCtrl.dispose();
    _expGainedCtrl.dispose();
    _aiPromptCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(Routes.adminExamEngine)),
        title: Text(widget.examId != null ? 'Edit Exam' : 'Create Exam'),
        actions: [
          // Manual / AI mode toggle
          if (MediaQuery.sizeOf(context).width >= 480)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  _ModeBtn('Manual', !_isAiMode, () => setState(() => _isAiMode = false)),
                  _ModeBtn('AI', _isAiMode, () => setState(() => _isAiMode = true)),
                ],
              ),
            )
          else
            IconButton(
              icon: Icon(_isAiMode ? Icons.edit_note_rounded : Icons.auto_awesome_rounded),
              color: AppColors.primary,
              tooltip: _isAiMode ? 'Switch to Manual' : 'Make with AI',
              onPressed: () => setState(() => _isAiMode = !_isAiMode),
            ),
          // On mobile: icon-only save; on desktop: labelled TextButton
          if (MediaQuery.sizeOf(context).width < 480)
            IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Save Draft',
              onPressed: () => _save(publish: false),
            )
          else
            TextButton(onPressed: () => _save(publish: false), child: const Text('Save Draft')),
          const SizedBox(width: 4),
          GradientButton(
            label: MediaQuery.sizeOf(context).width < 480 ? 'Pub' : 'Publish',
            onPressed: () => _save(publish: true),
            isLoading: _isSaving,
            width: MediaQuery.sizeOf(context).width < 480 ? 72 : 110,
          ),
          const SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Step progress bar
              AnimatedBuilder(
                animation: _tabs,
                builder: (_, __) => LinearProgressIndicator(
                  value: (_tabs.index + 1) / 3,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 3,
                ),
              ),
              TabBar(
                controller: _tabs,
                tabs: [
                  const Tab(text: 'Details'),
                  const Tab(text: 'Settings'),
                  Tab(
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (widget.settingsOnly)
                        const Icon(Icons.lock_outline_rounded, size: 13,
                            color: AppColors.warning),
                      if (widget.settingsOnly) const SizedBox(width: 4),
                      const Text('Questions'),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _DetailsTab(
            titleCtrl: _titleCtrl, descCtrl: _descCtrl, durationCtrl: _durationCtrl,
            difficulty: _difficulty, tag: _tag, avatarId: _avatarId,
            targetBatches: _targetBatches, selectedClass: _selectedClass,
            isNew: _isNew,
            allowDownload: _allowDownload,
            onDifficultyChanged: (v) => setState(() { _difficulty = v; _durationCtrl.text = _autoTime().toString(); }),
            onTagChanged: (v) => setState(() => _tag = v),
            onAvatarChanged: (v) => setState(() => _avatarId = v),
            onBatchToggle: (b) => setState(() { if (_targetBatches.contains(b)) _targetBatches.remove(b); else _targetBatches.add(b); }),
            onClassChanged: (v) => setState(() => _selectedClass = v),
            onIsNewToggled: (v) => setState(() => _isNew = v),
            onAllowDownloadToggled: (v) => setState(() => _allowDownload = v),
          ),
          _SettingsTab(
            expRequiredCtrl: _expRequiredCtrl, expGainedCtrl: _expGainedCtrl,
            visibilityStart: _visibilityStart, visibilityEnd: _visibilityEnd,
            isPublished: _isPublished,
            onStartChanged: (d) => setState(() => _visibilityStart = d),
            onEndChanged: (d) => setState(() => _visibilityEnd = d),
            onPublishChanged: (v) => setState(() => _isPublished = v),
            creditMode: _creditMode,
            creditThreshold: _creditThreshold,
            onCreditModeChanged: (v) => setState(() => _creditMode = v),
            onCreditThresholdChanged: (v) => setState(() => _creditThreshold = v),
          ),
          // Questions tab — locked when settingsOnly to prevent inconsistent results
          if (widget.settingsOnly)
            const _QuestionsLockedOverlay()
          else
            _QuestionsTab(
              questions: _questions, isAiMode: _isAiMode, isGenerating: _isGenerating,
              aiCount: _aiCount, aiPromptCtrl: _aiPromptCtrl,
              selectedChapters: _selectedChapters, difficulty: _difficulty,
              error: _error,
              onGenerateAI: _generateWithAI,
              onAiCountChanged: (v) => setState(() => _aiCount = v),
              onChapterToggle: (c) => setState(() { if (_selectedChapters.contains(c)) _selectedChapters.remove(c); else _selectedChapters.add(c); }),
              onClassToggle: (clsKey) => setState(() {
                final all = NcertChapters.chaptersForClass(clsKey);
                final allSel = all.every((c) => _selectedChapters.contains(c));
                if (allSel) {
                  _selectedChapters.removeWhere((c) => all.contains(c));
                } else {
                  for (final c in all) { if (!_selectedChapters.contains(c)) _selectedChapters.add(c); }
                }
              }),
              onAddQuestion: () {
                setState(() => _questions.add(QuestionModel(id: _uuid.v4(), text: '', optionA: '', optionB: '', optionC: '', optionD: '', correctOption: 'A', chapter: _selectedChapters.firstOrNull ?? '')));
              },
              onRemoveQuestion: (id) => setState(() => _questions.removeWhere((q) => q.id == id)),
              onUpdateQuestion: (q) => setState(() { final i = _questions.indexWhere((x) => x.id == q.id); if (i >= 0) _questions[i] = q; }),
              onReorder: (o, n) => setState(() { final q = _questions.removeAt(o); _questions.insert(n, q); }),
            ),
        ],
      ),
    );
  }
}

// ── Questions locked overlay (settings-only mode) ─────────────
class _QuestionsLockedOverlay extends StatelessWidget {
  const _QuestionsLockedOverlay();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.warning, size: 36),
              ),
              const SizedBox(height: 20),
              const Text('Questions Locked',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              const Text(
                'This exam has been attempted by students.\n'
                'Questions are locked to protect existing results.\n\n'
                'To edit questions you must go back and choose\n"Full Edit (Reset All Results)" — this will\n'
                'permanently delete all student attempts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.55),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.info),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'You can still edit the exam title, duration, '
                      'batch, and coin settings in the Details and Settings tabs.',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.info,
                          height: 1.4),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      );
}

class _ModeBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeBtn(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.primary)),
        ),
      );
}

// ---- DETAILS TAB ----
class _DetailsTab extends ConsumerWidget {
  final TextEditingController titleCtrl, descCtrl, durationCtrl;
  final String difficulty, tag, avatarId;
  final List<String> targetBatches;
  final int? selectedClass;
  final bool isNew;
  final bool allowDownload;
  final ValueChanged<String> onDifficultyChanged, onTagChanged, onAvatarChanged;
  final ValueChanged<String> onBatchToggle;
  final ValueChanged<int?> onClassChanged;
  final ValueChanged<bool> onIsNewToggled;
  final ValueChanged<bool> onAllowDownloadToggled;

  const _DetailsTab({required this.titleCtrl, required this.descCtrl, required this.durationCtrl, required this.difficulty, required this.tag, required this.avatarId, required this.targetBatches, required this.selectedClass, required this.isNew, required this.allowDownload, required this.onDifficultyChanged, required this.onTagChanged, required this.onAvatarChanged, required this.onBatchToggle, required this.onClassChanged, required this.onIsNewToggled, required this.onAllowDownloadToggled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const emojis = ['🦉','🧬','🔬','🧠','🌿','🔵','⚡','⭐','🔥','💎','👑','🏆','☄️','🌌','🦅','🌱','⚛️','❤️','🌍','⛰️'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section('Exam Information', [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Exam Title *')),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
          ]),
          const SizedBox(height: 20),
          _Section('Difficulty & Timing', [
            Wrap(
              spacing: 8,
              children: AppConstants.difficulties.map((d) => ChipButton(
                label: d, selected: difficulty == d, onTap: () => onDifficultyChanged(d),
                selectedColor: _diffColor(d),
              )).toList(),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration (minutes)', suffixText: 'min'))),
              const SizedBox(width: 12),
              Text('Auto: ${_autoTimeLabel(difficulty)} min', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ]),
          const SizedBox(height: 20),
          _Section('Target Batches', [
            Wrap(
              spacing: 8,
              children: (ref.watch(batchNamesProvider).value ?? AppConstants.batches)
                  .map((b) => ChipButton(
                    label: b, selected: targetBatches.contains(b), onTap: () => onBatchToggle(b),
                    selectedColor: _batchColor(b),
                  )).toList(),
            ),
          ]),
          const SizedBox(height: 20),
          _Section('Tag & Class', [
            Wrap(spacing: 8, children: ['Compulsory', 'Practice', 'Revision'].map((t) => ChipButton(label: t, selected: tag == t, onTap: () => onTagChanged(t))).toList()),
            const SizedBox(height: 12),
            Row(children: [
              ChipButton(label: 'All', selected: selectedClass == null, onTap: () => onClassChanged(null)),
              const SizedBox(width: 8),
              ChipButton(label: 'Class 11', selected: selectedClass == 11, onTap: () => onClassChanged(11)),
              const SizedBox(width: 8),
              ChipButton(label: 'Class 12', selected: selectedClass == 12, onTap: () => onClassChanged(12)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Switch(value: isNew, onChanged: onIsNewToggled, activeColor: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Show "NEW" badge on this exam',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Switch(value: allowDownload, onChanged: onAllowDownloadToggled, activeColor: AppColors.success),
              const SizedBox(width: 8),
              const Expanded(child: Text('Allow students to download question paper after first attempt',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            ]),
          ]),
          const SizedBox(height: 20),
          _Section('Exam Avatar', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(emojis.length, (i) {
                final id = 'av_${(i + 1).toString().padLeft(2, '0')}';
                return GestureDetector(
                  onTap: () => onAvatarChanged(id),
                  child: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: avatarId == id ? AppColors.primarySurface : AppColors.neuBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: avatarId == id ? AppColors.primary : AppColors.border, width: avatarId == id ? 2 : 1),
                    ),
                    child: Center(child: Text(emojis[i], style: const TextStyle(fontSize: 24))),
                  ),
                );
              }),
            ),
          ]),
        ],
      ),
    );
  }

  Color _diffColor(String d) {
    switch (d) {
      case 'Easy': return AppColors.easy;
      case 'Medium': return AppColors.medium;
      case 'Hard': return AppColors.hard;
      default: return AppColors.neetLevel;
    }
  }

  Color _batchColor(String b) {
    switch (b) {
      case '11 NEET': return AppColors.batch11;
      case '12 NEET': return AppColors.batch12;
      default: return AppColors.batchNeet;
    }
  }

  int _autoTimeLabel(String diff) {
    final secs = AppConstants.secondsPerQuestion[diff] ?? 72;
    return (20 * secs / 60).ceil();
  }
}

// ---- SETTINGS TAB ----
class _SettingsTab extends StatefulWidget {
  final TextEditingController expRequiredCtrl, expGainedCtrl;
  final DateTime? visibilityStart, visibilityEnd;
  final bool isPublished;
  final ValueChanged<DateTime?> onStartChanged, onEndChanged;
  final ValueChanged<bool> onPublishChanged;
  final String creditMode;
  final int creditThreshold;
  final ValueChanged<String> onCreditModeChanged;
  final ValueChanged<int> onCreditThresholdChanged;

  const _SettingsTab({
    required this.expRequiredCtrl, required this.expGainedCtrl,
    required this.visibilityStart, required this.visibilityEnd,
    required this.isPublished,
    required this.onStartChanged, required this.onEndChanged,
    required this.onPublishChanged,
    required this.creditMode, required this.creditThreshold,
    required this.onCreditModeChanged, required this.onCreditThresholdChanged,
  });

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  @override
  Widget build(BuildContext context) {
    final hasCost = (int.tryParse(widget.expRequiredCtrl.text) ?? 0) > 0;
    final hasReward = (int.tryParse(widget.expGainedCtrl.text) ?? 0) > 0;
    final creditEnabled = widget.creditMode != 'none';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PrepCoins
          _Section('PrepCoins', [
            Row(children: [
              Expanded(child: TextField(
                controller: widget.expRequiredCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Coins Required (0 = free)',
                  prefixIcon: Icon(Icons.monetization_on_outlined, size: 16)),
              )),
              const SizedBox(width: 12),
              Expanded(child: TextField(
                controller: widget.expGainedCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Coins Earned on Completion',
                  prefixIcon: Icon(Icons.add_circle_outline, size: 16)),
              )),
            ]),
          ]),

          // Credit Earning Rules (only when coins are involved)
          if (hasReward) ...[
            const SizedBox(height: 20),
            _Section('Credit Earning Rules', [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.infoSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: AppColors.info),
                  SizedBox(width: 8),
                  Flexible(child: Text(
                    'By default students earn coins on any first attempt. '
                    'Enable a threshold to require minimum effort before coins are awarded.',
                    style: TextStyle(fontSize: 11, color: AppColors.info, height: 1.4),
                  )),
                ]),
              ),
              const SizedBox(height: 12),
              // Mode toggle
              Row(children: [
                const Expanded(child: Text('Minimum Effort Threshold',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                Switch(
                  value: creditEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (v) => widget.onCreditModeChanged(v ? 'attempts' : 'none'),
                ),
              ]),
              if (creditEnabled) ...[
                const SizedBox(height: 12),
                // Mode selection
                Row(children: [
                  const Text('Measure by:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  _ModeChip('Questions Answered', 'attempts', widget.creditMode,
                      () => widget.onCreditModeChanged('attempts')),
                  const SizedBox(width: 8),
                  _ModeChip('Time Spent', 'time', widget.creditMode,
                      () => widget.onCreditModeChanged('time')),
                ]),
                const SizedBox(height: 12),
                // Threshold slider
                Row(children: [
                  Expanded(child: Slider(
                    value: widget.creditThreshold.toDouble(),
                    min: 10, max: 90, divisions: 8,
                    activeColor: AppColors.primary,
                    label: '${widget.creditThreshold}%',
                    onChanged: (v) => widget.onCreditThresholdChanged(v.round()),
                  )),
                  Container(
                    width: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${widget.creditThreshold}%',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            fontSize: 14)),
                  ),
                ]),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.creditMode == 'attempts'
                        ? 'Student must answer at least ${widget.creditThreshold}% of questions '
                          '(${((widget.expGainedCtrl.text.isNotEmpty ? int.tryParse(widget.expGainedCtrl.text) : 0) ?? 0)} coins) to earn coins.'
                        : 'Student must spend at least ${widget.creditThreshold}% of the exam duration to earn coins.',
                    style: const TextStyle(fontSize: 11, color: AppColors.warning, height: 1.4),
                  ),
                ),
              ],
            ]),
          ],

          const SizedBox(height: 20),
          // Visibility window
          _Section('Visibility Window', [
            Row(children: [
              Expanded(child: _DatePicker('Start Date (optional)', widget.visibilityStart, widget.onStartChanged)),
              const SizedBox(width: 12),
              Expanded(child: _DatePicker('End Date (optional)', widget.visibilityEnd, widget.onEndChanged)),
            ]),
            const SizedBox(height: 8),
            const Text('Leave end date blank for unlimited visibility.',
                style: TextStyle(fontSize: 12, color: AppColors.textHint)),
          ]),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label, value, current;
  final VoidCallback onTap;
  const _ModeChip(this.label, this.value, this.current, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: current == value ? AppColors.primary : AppColors.neuBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: current == value ? AppColors.primary : AppColors.border),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: current == value ? Colors.white : AppColors.textSecondary)),
        ),
      );
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChange;
  const _DatePicker(this.label, this.value, this.onChange);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime(2030),
        );
        onChange(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text(value != null ? '${value!.day}/${value!.month}/${value!.year}' : 'Not set', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            )),
            if (value != null)
              GestureDetector(onTap: () => onChange(null), child: const Icon(Icons.close, size: 16, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}

// ---- QUESTIONS TAB ----
class _QuestionsTab extends StatelessWidget {
  final List<QuestionModel> questions;
  final bool isAiMode, isGenerating;
  final int aiCount;
  final TextEditingController aiPromptCtrl;
  final List<String> selectedChapters;
  final String difficulty;
  final String? error;
  final VoidCallback onGenerateAI, onAddQuestion;
  final ValueChanged<int> onAiCountChanged;
  final ValueChanged<String> onChapterToggle;
  final ValueChanged<String> onClassToggle;
  final ValueChanged<String> onRemoveQuestion;
  final ValueChanged<QuestionModel> onUpdateQuestion;
  final void Function(int, int) onReorder;

  const _QuestionsTab({required this.questions, required this.isAiMode, required this.isGenerating, required this.aiCount, required this.aiPromptCtrl, required this.selectedChapters, required this.difficulty, this.error, required this.onGenerateAI, required this.onAiCountChanged, required this.onChapterToggle, required this.onClassToggle, required this.onAddQuestion, required this.onRemoveQuestion, required this.onUpdateQuestion, required this.onReorder});

  @override
  Widget build(BuildContext context) {
    final aiPanel = _AiPanel(
      aiCount: aiCount, aiPromptCtrl: aiPromptCtrl,
      selectedChapters: selectedChapters, difficulty: difficulty, error: error,
      isGenerating: isGenerating,
      onGenerate: onGenerateAI,
      onCountChanged: onAiCountChanged,
      onChapterToggle: onChapterToggle,
      onClassToggle: onClassToggle,
    );

    final questionsArea = Column(
      children: [
        // Questions header
        Container(
          color: AppColors.neuSurface,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Text('${questions.length} Questions', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const Spacer(),
              PrimaryButton(label: 'Add Question', icon: Icons.add, onPressed: onAddQuestion),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.quiz_outlined, size: 60, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(isAiMode ? 'Generate questions using AI →' : 'Add questions manually using the button above', style: const TextStyle(color: AppColors.textHint), textAlign: TextAlign.center),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  onReorder: onReorder,
                  itemBuilder: (_, i) => _QuestionRow(
                    key: ValueKey(questions[i].id),
                    question: questions[i],
                    index: i,
                    onRemove: () => onRemoveQuestion(questions[i].id),
                    onUpdate: onUpdateQuestion,
                  ),
                ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAiMode)
                SizedBox(width: 340, child: aiPanel),
              Expanded(
                child: isGenerating
                    ? _GeneratingAnimation(questionCount: aiCount)
                    : questionsArea,
              ),
            ],
          );
        } else {
          // Mobile: when not AI mode, just show questions full-height
          if (!isAiMode) return questionsArea;

          // When generating on mobile, take full screen for animation
          if (isGenerating) {
            return _GeneratingAnimation(questionCount: aiCount);
          }

          // AI panel takes more space so chapter chips are usable
          return Column(
            children: [
              Expanded(flex: 55, child: aiPanel),
              const Divider(height: 3, thickness: 3, color: AppColors.border),
              Expanded(flex: 45, child: questionsArea),
            ],
          );
        }
      },
    );
  }
}

// ── AI Generation skeleton animation ─────────────────────────────
class _GeneratingAnimation extends StatefulWidget {
  final int questionCount;
  const _GeneratingAnimation({required this.questionCount});

  @override
  State<_GeneratingAnimation> createState() => _GeneratingAnimationState();
}

class _GeneratingAnimationState extends State<_GeneratingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _msgIdx = 0;
  static const _messages = [
    'Connecting to Gemini AI...',
    'Parsing NCERT curriculum...',
    'Generating question stems...',
    'Decrypting answer patterns...',
    'Validating NEET format...',
    'Applying difficulty calibration...',
    'Inserting distractors...',
    'Cross-referencing past papers...',
    'Assembling question bank...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted) return false;
      setState(() => _msgIdx = (_msgIdx + 1) % _messages.length);
      return mounted;
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neuBackground,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rotating AI orb
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  return Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: const [Color(0xFF6C63FF), Color(0xFF48CAE4), Color(0xFF06D6A0), Color(0xFF6C63FF)],
                        transform: GradientRotation(_ctrl.value * 6.28),
                      ),
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 24, spreadRadius: 4)],
                    ),
                    child: const Center(
                      child: Icon(Icons.auto_awesome, color: Colors.white, size: 38),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              Text('Generating ${widget.questionCount} Questions',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: 12),

              // Rotating status messages
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(anim),
                    child: child,
                  ),
                ),
                child: Text(
                  _messages[_msgIdx],
                  key: ValueKey(_msgIdx),
                  style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 32),

              // Skeleton question placeholders
              ...List.generate(4, (i) => _SkeletonQuestion(delay: i * 200)),
              const SizedBox(height: 16),

              Text('This may take 30–60 seconds for ${widget.questionCount} questions.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: AppColors.textHint, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonQuestion extends StatefulWidget {
  final int delay;
  const _SkeletonQuestion({required this.delay});

  @override
  State<_SkeletonQuestion> createState() => _SkeletonQuestionState();
}

class _SkeletonQuestionState extends State<_SkeletonQuestion>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) {
      final alpha = (0.08 + _ctrl.value * 0.18).clamp(0.0, 1.0);
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(alpha),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(height: 10, width: double.infinity,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(5))),
          const SizedBox(height: 8),
          Row(children: [
            for (final w in [80.0, 100.0]) ...[
              Container(height: 8, width: w,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 8),
            ],
          ]),
        ]),
      );
    },
  );
}

class _AiPanel extends StatefulWidget {
  final int aiCount;
  final TextEditingController aiPromptCtrl;
  final List<String> selectedChapters;
  final String difficulty;
  final String? error;
  final bool isGenerating;
  final VoidCallback onGenerate;
  final ValueChanged<int> onCountChanged;
  final ValueChanged<String> onChapterToggle;
  final ValueChanged<String> onClassToggle;

  const _AiPanel({
    required this.aiCount,
    required this.aiPromptCtrl,
    required this.selectedChapters,
    required this.difficulty,
    this.error,
    required this.isGenerating,
    required this.onGenerate,
    required this.onCountChanged,
    required this.onChapterToggle,
    required this.onClassToggle,
  });

  @override
  State<_AiPanel> createState() => _AiPanelState();
}

class _AiPanelState extends State<_AiPanel> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neuSurface,
      child: Column(
        children: [
          // Header
          Container(
            color: AppColors.primarySurface,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('AI Exam Generator',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
                // Model badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AiService.instance.currentModel,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── API KEY STATUS ───────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AiService.instance.hasApiKey
                          ? AppColors.successSurface
                          : AppColors.warningSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AiService.instance.hasApiKey
                            ? AppColors.success.withOpacity(0.4)
                            : AppColors.warning.withOpacity(0.4),
                      ),
                    ),
                    child: Row(children: [
                      Icon(
                        AiService.instance.hasApiKey ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
                        size: 15,
                        color: AiService.instance.hasApiKey ? AppColors.success : AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AiService.instance.hasApiKey
                              ? 'Gemini API key is configured.'
                              : 'No API key found. Set it in Admin → AI Config.',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AiService.instance.hasApiKey ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const Divider(height: 24),

                  // ── QUESTION COUNT ───────────────────────────────
                  const Text('Number of Questions',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary)),
                  Slider(
                    value: widget.aiCount.toDouble(),
                    min: 5,
                    max: 100,
                    divisions: 19,
                    label: '${widget.aiCount}',
                    activeColor: AppColors.primary,
                    onChanged: (v) => widget.onCountChanged(v.round()),
                  ),
                  Center(
                    child: Text('${widget.aiCount} questions',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 16),

                  // ── CHAPTER SELECTOR ─────────────────────────────
                  const Text('Chapters',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  ...['11', '12'].map((clsKey) {
                    final chapters = NcertChapters.chaptersForClass(clsKey);
                    final selectedCount = chapters.where((c) => widget.selectedChapters.contains(c)).length;
                    final allSelected = selectedCount == chapters.length;
                    final someSelected = selectedCount > 0 && !allSelected;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Class row — checkbox + label
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => widget.onClassToggle(clsKey),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(children: [
                              SizedBox(
                                width: 24, height: 24,
                                child: Checkbox(
                                  value: someSelected ? null : allSelected,
                                  tristate: true,
                                  activeColor: AppColors.primary,
                                  onChanged: (_) => widget.onClassToggle(clsKey),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('Class $clsKey',
                                  style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                              const SizedBox(width: 6),
                              Text('($selectedCount / ${chapters.length})',
                                  style: const TextStyle(
                                      fontSize: 10, color: AppColors.textSecondary)),
                            ]),
                          ),
                        ),
                        // Individual chapter chips — compact on mobile
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 10),
                          child: LayoutBuilder(builder: (ctx, box) {
                            final compact = box.maxWidth < 320;
                            return Wrap(
                              spacing: compact ? 3 : 4,
                              runSpacing: compact ? 3 : 4,
                              children: chapters.map((c) {
                                final sel = widget.selectedChapters.contains(c);
                                if (compact) {
                                  // Tiny numbered pill on very narrow screens
                                  final num = NcertChapters.chapterNumber(c);
                                  return GestureDetector(
                                    onTap: () => widget.onChapterToggle(c),
                                    child: Tooltip(
                                      message: c,
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 150),
                                        width: 28, height: 28,
                                        decoration: BoxDecoration(
                                          color: sel ? AppColors.primary : AppColors.neuBackground,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                                        ),
                                        child: Center(
                                          child: Text('$num',
                                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                                  color: sel ? Colors.white : AppColors.textSecondary)),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return ChipButton(label: c, selected: sel, onTap: () => widget.onChapterToggle(c));
                              }).toList(),
                            );
                          }),
                        ),
                      ],
                    );
                  }),

                  // ── PROMPT ───────────────────────────────────────
                  const SizedBox(height: 8),
                  const Text('Additional Prompt (optional)',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: widget.aiPromptCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        hintText: 'e.g., only statement-based questions, focus on diagrams...',
                        isDense: true),
                  ),

                  // ── ERROR ────────────────────────────────────────
                  if (widget.error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.errorSurface,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(widget.error!,
                          style: const TextStyle(color: AppColors.error, fontSize: 12)),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // ── GENERATE BUTTON ───────────────────────────────
                  GradientButton(
                    label: widget.isGenerating ? 'Generating...' : 'Generate Questions',
                    icon: Icons.auto_awesome,
                    onPressed: widget.isGenerating ? null : widget.onGenerate,
                    isLoading: widget.isGenerating,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionRow extends StatefulWidget {
  final QuestionModel question;
  final int index;
  final VoidCallback onRemove;
  final ValueChanged<QuestionModel> onUpdate;

  const _QuestionRow({super.key, required this.question, required this.index, required this.onRemove, required this.onUpdate});

  @override
  State<_QuestionRow> createState() => _QuestionRowState();
}

class _QuestionRowState extends State<_QuestionRow> {
  bool _expanded = false;
  late TextEditingController _textCtrl, _aCtrl, _bCtrl, _cCtrl, _dCtrl, _expCtrl;
  late String _correct;

  @override
  void initState() {
    super.initState();
    _textCtrl = TextEditingController(text: widget.question.text);
    _aCtrl = TextEditingController(text: widget.question.optionA);
    _bCtrl = TextEditingController(text: widget.question.optionB);
    _cCtrl = TextEditingController(text: widget.question.optionC);
    _dCtrl = TextEditingController(text: widget.question.optionD);
    _expCtrl = TextEditingController(text: widget.question.explanation ?? '');
    _correct = widget.question.correctOption;
  }

  void _save() {
    widget.onUpdate(QuestionModel(
      id: widget.question.id,
      text: _textCtrl.text,
      optionA: _aCtrl.text,
      optionB: _bCtrl.text,
      optionC: _cCtrl.text,
      optionD: _dCtrl.text,
      correctOption: _correct,
      explanation: _expCtrl.text.trim().isEmpty ? null : _expCtrl.text.trim(),
      chapter: widget.question.chapter,
      difficulty: widget.question.difficulty,
      examId: widget.question.examId,
    ));
  }

  @override
  void dispose() {
    _textCtrl.dispose(); _aCtrl.dispose(); _bCtrl.dispose(); _cCtrl.dispose(); _dCtrl.dispose(); _expCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.drag_handle, color: AppColors.textHint, size: 18),
              const SizedBox(width: 8),
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(6)),
                child: Center(child: Text('${widget.index + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.question.text.isEmpty ? '(No question text)' : widget.question.text,
                  style: TextStyle(fontSize: 13, color: widget.question.text.isEmpty ? AppColors.textHint : AppColors.textPrimary, fontWeight: FontWeight.w500),
                  maxLines: _expanded ? null : 2,
                  overflow: _expanded ? null : TextOverflow.ellipsis,
                ),
              ),
              IconButton(icon: Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18), onPressed: () => setState(() => _expanded = !_expanded)),
              IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error), onPressed: widget.onRemove),
            ],
          ),
          if (_expanded) ...[
            const Divider(height: 16),
            TextField(controller: _textCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Question', isDense: true), onChanged: (_) => _save()),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _OptionField('A', _aCtrl, _correct == 'A',
                  () { setState(() => _correct = 'A'); _save(); }, onSave: _save)),
              const SizedBox(width: 8),
              Expanded(child: _OptionField('B', _bCtrl, _correct == 'B',
                  () { setState(() => _correct = 'B'); _save(); }, onSave: _save)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _OptionField('C', _cCtrl, _correct == 'C',
                  () { setState(() => _correct = 'C'); _save(); }, onSave: _save)),
              const SizedBox(width: 8),
              Expanded(child: _OptionField('D', _dCtrl, _correct == 'D',
                  () { setState(() => _correct = 'D'); _save(); }, onSave: _save)),
            ]),
            const SizedBox(height: 8),
            TextField(controller: _expCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Explanation (optional)', isDense: true), onChanged: (_) => _save()),
          ],
        ],
      ),
    );
  }
}

class _OptionField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool isCorrect;
  final VoidCallback onSetCorrect;
  // onSave fires on every keystroke — fixes the bug where option text was
  // never persisted to the parent's question list because no onChanged existed
  final VoidCallback onSave;

  const _OptionField(this.label, this.ctrl, this.isCorrect, this.onSetCorrect,
      {required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onSetCorrect,
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCorrect ? AppColors.success : AppColors.neuBackground,
              border: Border.all(
                  color: isCorrect ? AppColors.success : AppColors.border),
            ),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isCorrect ? Colors.white : AppColors.textSecondary)),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: TextField(
            controller: ctrl,
            onChanged: (_) => onSave(), // ← THE FIX: save on every keystroke
            decoration: InputDecoration(
              labelText: 'Option $label',
              isDense: true,
              filled: true,
              fillColor: isCorrect ? AppColors.successSurface : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section(this.title, this.children);

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
