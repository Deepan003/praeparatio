import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/notification_model.dart';
import '../../../providers/batch_provider.dart';
import '../../../services/notification_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';

class SendNotificationScreen extends ConsumerStatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  ConsumerState<SendNotificationScreen> createState() =>
      _SendNotificationScreenState();
}

class _SendNotificationScreenState
    extends ConsumerState<SendNotificationScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();

  NotificationType _type = NotificationType.announcement;
  String _targetType = 'all';
  final Set<String> _targetBatches = {};
  String? _targetStudentId;
  String  _targetStudentName = '';

  bool _sending = false;
  String? _success;
  String? _error;

  List<NotificationModel> _history = [];
  bool _historyLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final list = await NotificationService.instance.getRecent();
    if (mounted) setState(() { _history = list; _historyLoading = false; });
  }

  static const _typeOptions = [
    (NotificationType.announcement,    'Announcement'),
    (NotificationType.examPublished,   'New Exam'),
    (NotificationType.resultsReleased, 'Results Released'),
    (NotificationType.notesUploaded,   'Notes Uploaded'),
    (NotificationType.pyqAdded,        'PYQ Added'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Title and message are required.');
      return;
    }
    if (_targetType == 'batch' && _targetBatches.isEmpty) {
      setState(() => _error = 'Select at least one batch.');
      return;
    }
    if (_targetType == 'individual' && _targetStudentId == null) {
      setState(() => _error = 'Select a student.');
      return;
    }

    setState(() { _sending = true; _error = null; _success = null; });

    try {
      await NotificationService.instance.send(
        type:            _type,
        title:           _titleCtrl.text.trim(),
        body:            _bodyCtrl.text.trim(),
        targetType:      _targetType,
        targetBatches:   _targetBatches.toList(),
        targetStudentId: _targetType == 'individual' ? _targetStudentId : null,
        createdBy:       'admin',
      );
      setState(() {
        _success = 'Notification sent!';
        _titleCtrl.clear();
        _bodyCtrl.clear();
        _targetType = 'all';
        _targetBatches.clear();
        _targetStudentId = null;
        _targetStudentName = '';
      });
      _loadHistory(); // refresh history after send
    } catch (e) {
      setState(() => _error = 'Failed: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final batches = ref.watch(batchNamesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Type picker ──────────────────────────────────────
          const _Label('Notification Type'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _typeOptions.map((opt) {
              final selected = _type == opt.$1;
              return GestureDetector(
                onTap: () => setState(() => _type = opt.$1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primarySurface
                        : AppColors.neuSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(opt.$1.icon,
                        size: 14,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(opt.$2,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary)),
                  ]),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ── Target ───────────────────────────────────────────
          const _Label('Send To'),
          const SizedBox(height: 8),
          SolidCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _TargetRadio('All Students', 'all', _targetType,
                    (v) => setState(() { _targetType = v; _targetBatches.clear(); _targetStudentId = null; })),
                _TargetRadio('Specific Batch', 'batch', _targetType,
                    (v) => setState(() => _targetType = v)),
                _TargetRadio('Individual Student', 'individual', _targetType,
                    (v) => setState(() => _targetType = v)),

                if (_targetType == 'batch') ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: batches.map((b) {
                      final sel = _targetBatches.contains(b);
                      return GestureDetector(
                        onTap: () => setState(() =>
                            sel ? _targetBatches.remove(b) : _targetBatches.add(b)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primarySurface
                                : AppColors.neuBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.border),
                          ),
                          child: Text(b,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: sel
                                      ? AppColors.primary
                                      : AppColors.textSecondary)),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                if (_targetType == 'individual') ...[
                  const SizedBox(height: 10),
                  _StudentPicker(
                    selectedName: _targetStudentName,
                    onPick: (id, name) =>
                        setState(() {
                          _targetStudentId   = id;
                          _targetStudentName = name;
                        }),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Title ────────────────────────────────────────────
          const _Label('Title'),
          const SizedBox(height: 8),
          TextField(
            controller: _titleCtrl,
            maxLength: 80,
            decoration: const InputDecoration(
              hintText: 'e.g. Results Released for Cell Biology',
              isDense: true,
              counterText: '',
            ),
          ),

          const SizedBox(height: 16),

          // ── Body ─────────────────────────────────────────────
          const _Label('Message'),
          const SizedBox(height: 8),
          TextField(
            controller: _bodyCtrl,
            maxLines: 4,
            maxLength: 200,
            decoration: const InputDecoration(
              hintText: 'Write your notification message here...',
              isDense: true,
              counterText: '',
            ),
          ),

          const SizedBox(height: 24),

          // ── Feedback ─────────────────────────────────────────
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.errorSurface,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.error, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!,
                    style: const TextStyle(color: AppColors.error, fontSize: 12))),
              ]),
            ),

          if (_success != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: AppColors.successSurface,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                Text(_success!,
                    style: const TextStyle(
                        color: AppColors.success, fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ]),
            ),

          GradientButton(
            label: 'Send Notification',
            icon: Icons.send_rounded,
            onPressed: _sending ? null : _send,
            isLoading: _sending,
            width: double.infinity,
          ),

          // ── Recent history ───────────────────────────────────
          const SizedBox(height: 32),
          Row(children: [
            const Text('Recently Sent',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 18),
              onPressed: _loadHistory,
              tooltip: 'Refresh',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ]),
          const SizedBox(height: 10),

          if (_historyLoading)
            const Center(child: CircularProgressIndicator())
          else if (_history.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.neuSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Text('No notifications sent yet',
                    style: TextStyle(color: AppColors.textHint)),
              ),
            )
          else
            ...(_history.asMap().entries.map((e) {
              final n = e.value;
              final color = n.type.color;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neuSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(n.type.icon, size: 17, color: color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(n.body,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(n.timeAgo,
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.textHint)),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            n.targetType == 'all'
                                ? 'All'
                                : n.targetType == 'batch'
                                    ? n.targetBatches.join(', ')
                                    : 'Individual',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: color),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: (e.key * 30).ms).fadeIn(duration: 200.ms);
            })),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: AppColors.textSecondary));
}

class _TargetRadio extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;
  const _TargetRadio(this.label, this.value, this.groupValue, this.onChanged);
  @override
  Widget build(BuildContext context) => RadioListTile<String>(
        title: Text(label, style: const TextStyle(fontSize: 13)),
        value: value,
        groupValue: groupValue,
        dense: true,
        contentPadding: EdgeInsets.zero,
        activeColor: AppColors.primary,
        onChanged: (v) { if (v != null) onChanged(v); },
      );
}

class _StudentPicker extends StatefulWidget {
  final String selectedName;
  final void Function(String? id, String name) onPick;
  const _StudentPicker({required this.selectedName, required this.onPick});
  @override
  State<_StudentPicker> createState() => _StudentPickerState();
}

class _StudentPickerState extends State<_StudentPicker> {
  final _ctrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Future<void> _search(String q) async {
    if (q.trim().length < 2) { setState(() => _results = []); return; }
    setState(() => _loading = true);
    try {
      final res = await SupabaseService.instance.searchStudents(q.trim());
      if (mounted) setState(() => _results = res);
    } catch (_) {} finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _ctrl,
          decoration: InputDecoration(
            hintText: 'Search student by name…',
            isDense: true,
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : null,
          ),
          onChanged: _search,
        ),
        if (widget.selectedName.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.person_rounded,
                  size: 14, color: AppColors.success),
              const SizedBox(width: 6),
              Expanded(
                child: Text(widget.selectedName,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: AppColors.success)),
              ),
              GestureDetector(
                onTap: () => widget.onPick(null, ''),
                child: const Icon(Icons.close_rounded, size: 16, color: AppColors.success),
              )
            ]),
          ),
        ],
        if (_results.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.neuSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: _results.map((s) => ListTile(
                dense: true,
                title: Text(s['name'] as String? ?? '',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text(s['batch'] as String? ?? '',
                    style: const TextStyle(fontSize: 11)),
                onTap: () {
                  widget.onPick(s['id'] as String, s['name'] as String);
                  _ctrl.clear();
                  setState(() => _results = []);
                },
              )).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
