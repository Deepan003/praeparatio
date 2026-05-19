import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/note_model.dart';
import '../../../services/notification_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';

const _uuid = Uuid();

final _notesAdminProvider = StreamProvider<List<NoteModel>>((ref) {
  return SupabaseService.instance.streamAllNotes();
});

class NotesAdminScreen extends ConsumerStatefulWidget {
  const NotesAdminScreen({super.key});

  @override
  ConsumerState<NotesAdminScreen> createState() => _NotesAdminScreenState();
}

class _NotesAdminScreenState extends ConsumerState<NotesAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.neuSurface,
          child: TabBar(
            controller: _tabs,
            tabs: const [Tab(text: 'Notes / PDFs'), Tab(text: 'External Links')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: const [
              _NotesList(isLinks: false),
              _NotesList(isLinks: true),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Notes List with full reorder support ──────────────────────
class _NotesList extends ConsumerStatefulWidget {
  final bool isLinks;
  const _NotesList({required this.isLinks});

  @override
  ConsumerState<_NotesList> createState() => _NotesListState();
}

class _NotesListState extends ConsumerState<_NotesList> {
  String _visFilter = 'all_filter';
  List<String> _sectionOrder = [];
  Map<String, List<NoteModel>> _sections = {};
  bool _initialized = false;
  bool _hasUnsavedChanges = false;   // shows Save button when order changed
  bool _saving = false;
  // Track the count/ids of last-loaded notes — only re-init if structure changed
  int _lastLoadedCount = -1;
  Set<String> _lastLoadedIds = {};

  void _initFrom(List<NoteModel> allNotes) {
    // Track which IDs were loaded so we can detect real changes (add/delete)
    final ids = allNotes.map((n) => n.id).toSet();
    _lastLoadedCount = allNotes.length;
    _lastLoadedIds = ids;

    var notes = allNotes.where((n) => n.isLink == widget.isLinks).toList();

    // Auto-assign sortOrders if all are 0 (first time or column just added)
    final allZero = notes.every((n) => n.sortOrder == 0);
    if (allZero && notes.isNotEmpty) {
      notes = [
        for (int i = 0; i < notes.length; i++)
          notes[i].copyWith(sortOrder: i * 10)
      ];
      // Save assigned orders to DB in background
      for (final n in notes) {
        SupabaseService.instance.upsertNote(n);
      }
    } else {
      notes.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    final secs = <String, List<NoteModel>>{};
    final secOrder = <String>[];
    for (final n in notes) {
      secs.putIfAbsent(n.sectionName, () => []).add(n);
      if (!secOrder.contains(n.sectionName)) secOrder.add(n.sectionName);
    }

    setState(() {
      _sections = secs;
      _sectionOrder = secOrder;
      _initialized = true;
    });
  }

  List<NoteModel> get _allOrdered {
    final result = <NoteModel>[];
    for (final sec in _sectionOrder) {
      result.addAll(_sections[sec] ?? []);
    }
    return result;
  }

  // Mark order as changed — user must press Save to persist
  void _markChanged() => setState(() => _hasUnsavedChanges = true);

  // Explicitly save to Supabase (called by Save button)
  Future<void> _saveOrder() async {
    setState(() => _saving = true);
    try {
      final flat = _allOrdered;
      for (int i = 0; i < flat.length; i++) {
        final expected = i * 10;
        final updated = flat[i].copyWith(sortOrder: expected);
        await SupabaseService.instance.upsertNote(updated);
        // Keep local model in sync
        final sec = flat[i].sectionName;
        final list = _sections[sec];
        if (list != null) {
          final idx = list.indexWhere((n) => n.id == flat[i].id);
          if (idx >= 0) list[idx] = updated;
        }
      }
      setState(() { _hasUnsavedChanges = false; _saving = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Order saved!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  Future<void> _moveNoteUp(String section, int noteIdx) async {
    if (noteIdx <= 0) return;
    final list = List<NoteModel>.from(_sections[section]!);
    final tmp = list[noteIdx];
    list[noteIdx] = list[noteIdx - 1];
    list[noteIdx - 1] = tmp;
    setState(() => _sections[section] = list);
    _markChanged();
  }

  Future<void> _moveNoteDown(String section, int noteIdx) async {
    final list = List<NoteModel>.from(_sections[section]!);
    if (noteIdx >= list.length - 1) return;
    final tmp = list[noteIdx];
    list[noteIdx] = list[noteIdx + 1];
    list[noteIdx + 1] = tmp;
    setState(() => _sections[section] = list);
    _markChanged();
  }

  Future<void> _moveSectionUp(int secIdx) async {
    if (secIdx <= 0) return;
    final order = List<String>.from(_sectionOrder);
    final tmp = order[secIdx];
    order[secIdx] = order[secIdx - 1];
    order[secIdx - 1] = tmp;
    setState(() => _sectionOrder = order);
    _markChanged();
  }

  Future<void> _moveSectionDown(int secIdx) async {
    if (secIdx >= _sectionOrder.length - 1) return;
    final order = List<String>.from(_sectionOrder);
    final tmp = order[secIdx];
    order[secIdx] = order[secIdx + 1];
    order[secIdx + 1] = tmp;
    setState(() => _sectionOrder = order);
    _markChanged();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(_notesAdminProvider);

    return notesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allNotes) {
        // Only re-init when the SET of note IDs changes (add/delete), NOT on every
        // provider rebuild (which uses reference equality and resets local order).
        final currentIds = allNotes.map((n) => n.id).toSet();
        final sameIds = currentIds.length == _lastLoadedIds.length &&
            currentIds.containsAll(_lastLoadedIds);
        final structureChanged = !sameIds || allNotes.length != _lastLoadedCount;

        if (!_initialized || structureChanged) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _initFrom(allNotes));
          if (!_initialized) {
            return const Center(child: CircularProgressIndicator());
          }
        }

        // Build display sections (apply visibility filter without changing order)
        final displayOrder = <String>[];
        final displaySections = <String, List<NoteModel>>{};
        for (final sec in _sectionOrder) {
          final list = (_sections[sec] ?? []).where((n) {
            if (_visFilter == 'all_filter') return true;
            if (n.visibility == 'all') return true;
            return n.visibility == _visFilter;
          }).toList();
          if (list.isNotEmpty) {
            displayOrder.add(sec);
            displaySections[sec] = list;
          }
        }

        return Scaffold(
          body: Column(children: [
            // Filter bar
            Container(
              color: AppColors.neuBackground,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (final f in [
                    ('all_filter', 'All'),
                    ('all', 'All Students'),
                    ('11', 'Class 11'),
                    ('12', 'Class 12'),
                    ('neet', 'NEET Exclusive'),
                    ('private', 'Private'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _visFilter = f.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _visFilter == f.$1
                                ? AppColors.primary
                                : AppColors.neuSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _visFilter == f.$1
                                    ? AppColors.primary
                                    : AppColors.border),
                          ),
                          child: Text(f.$2,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _visFilter == f.$1
                                      ? Colors.white
                                      : AppColors.textSecondary)),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
            // Hint bar + Save button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: _hasUnsavedChanges ? AppColors.warningSurface : AppColors.infoSurface,
              child: Row(children: [
                Icon(
                  _hasUnsavedChanges ? Icons.warning_amber_rounded : Icons.swap_vert_rounded,
                  size: 14,
                  color: _hasUnsavedChanges ? AppColors.warning : AppColors.info,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _hasUnsavedChanges
                        ? 'Order changed — tap Save to persist.'
                        : 'Use ▲▼ to reorder notes and sections. Press Save when done.',
                    style: TextStyle(
                        fontSize: 11,
                        color: _hasUnsavedChanges ? AppColors.warning : AppColors.info),
                  ),
                ),
                if (_hasUnsavedChanges) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: _saving
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_rounded, size: 14),
                    label: Text(_saving ? 'Saving…' : 'Save Order',
                        style: const TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _saving ? null : _saveOrder,
                  ),
                ],
              ]),
            ),
            // Content
            Expanded(
              child: displayOrder.isEmpty
                  ? Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                        Icon(
                            widget.isLinks
                                ? Icons.link_off
                                : Icons.folder_off,
                            size: 48,
                            color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text(
                            'No ${widget.isLinks ? "links" : "notes"} match this filter',
                            style:
                                const TextStyle(color: AppColors.textHint)),
                      ]))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                      children: displayOrder
                          .asMap()
                          .entries
                          .map((secEntry) {
                        final displaySecIdx = secEntry.key;
                        final sec = secEntry.value;
                        final actualSecIdx = _sectionOrder.indexOf(sec);
                        final secNotes = displaySections[sec]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Section header ─────────────────
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 9),
                              margin: EdgeInsets.only(
                                  bottom: 6,
                                  top: displaySecIdx > 0 ? 14 : 0),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2)),
                              ),
                              child: Row(children: [
                                const Icon(Icons.folder_rounded,
                                    size: 15, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(sec,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                            fontSize: 13))),
                                Text('${secNotes.length} items',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                                const SizedBox(width: 8),
                                // Section up/down
                                _ArrowBtn(
                                  Icons.keyboard_arrow_up_rounded,
                                  actualSecIdx > 0,
                                  () => _moveSectionUp(actualSecIdx),
                                  'Move section up',
                                ),
                                _ArrowBtn(
                                  Icons.keyboard_arrow_down_rounded,
                                  actualSecIdx < _sectionOrder.length - 1,
                                  () => _moveSectionDown(actualSecIdx),
                                  'Move section down',
                                ),
                              ]),
                            ),
                            // ── Notes ──────────────────────────
                            ...secNotes.asMap().entries.map((noteEntry) {
                              final displayNoteIdx = noteEntry.key;
                              final n = noteEntry.value;
                              final actualNoteIdx =
                                  (_sections[sec] ?? [])
                                      .indexWhere((x) => x.id == n.id);
                              final sectionLen =
                                  _sections[sec]?.length ?? 0;
                              return _NoteItem(
                                key: ValueKey(n.id),
                                note: n,
                                canMoveUp: actualNoteIdx > 0,
                                canMoveDown:
                                    actualNoteIdx < sectionLen - 1,
                                onMoveUp: () =>
                                    _moveNoteUp(sec, actualNoteIdx),
                                onMoveDown: () =>
                                    _moveNoteDown(sec, actualNoteIdx),
                                onEdit: () => _showAddDialog(context, editing: n),
                                onDelete: () async {
                                  await SupabaseService.instance
                                      .deleteNote(n.id);
                                  setState(() {
                                    _sections[sec]
                                        ?.removeWhere((x) => x.id == n.id);
                                    if (_sections[sec]?.isEmpty == true) {
                                      _sections.remove(sec);
                                      _sectionOrder.remove(sec);
                                    }
                                  });
                                },
                                onToggleEnabled: () async {
                                  // Use isPrivate field — preserves original visibility setting
                                  final updated = n.copyWith(isPrivate: !n.isPrivate);
                                  await SupabaseService.instance
                                      .upsertNote(updated);
                                  setState(() {
                                    final list = _sections[sec]!;
                                    final i =
                                        list.indexWhere((x) => x.id == n.id);
                                    if (i >= 0) list[i] = updated;
                                  });
                                },
                                onChangeVisibility: (v) async {
                                  final updated = n.copyWith(visibility: v);
                                  await SupabaseService.instance
                                      .upsertNote(updated);
                                  setState(() {
                                    final list = _sections[sec]!;
                                    final i =
                                        list.indexWhere((x) => x.id == n.id);
                                    if (i >= 0) list[i] = updated;
                                  });
                                },
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ]),
          floatingActionButton: FloatingActionButton.small(
            tooltip: widget.isLinks ? 'Add Link' : 'Add Note',
            onPressed: () => _showAddDialog(context),
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context,
      {NoteModel? editing}) async {
    final nameCtrl =
        TextEditingController(text: editing?.name ?? '');
    final linkCtrl =
        TextEditingController(text: editing?.link ?? '');
    final sectionCtrl =
        TextEditingController(text: editing?.sectionName ?? '');
    String visibility = editing?.visibility ?? 'all';

    final existingSections = List<String>.from(_sectionOrder);

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(
              '${editing == null ? "Add" : "Edit"} ${widget.isLinks ? "Link" : "Note"}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Display Name *')),
              const SizedBox(height: 10),
              TextField(
                  controller: linkCtrl,
                  decoration: InputDecoration(
                      labelText: widget.isLinks
                          ? 'URL *'
                          : 'PDF Link (Google Drive) *')),
              const SizedBox(height: 10),
              // Section with autocomplete
              Autocomplete<String>(
                optionsBuilder: (v) => existingSections.where(
                    (s) => s.toLowerCase().contains(v.text.toLowerCase())),
                initialValue: TextEditingValue(text: sectionCtrl.text),
                onSelected: (s) => sectionCtrl.text = s,
                fieldViewBuilder: (ctx2, autoCtrl, fn, onSub) {
                  autoCtrl.addListener(() =>
                      sectionCtrl.text = autoCtrl.text);
                  return TextField(
                    controller: autoCtrl,
                    focusNode: fn,
                    decoration: InputDecoration(
                      labelText: 'Section',
                      hintText: existingSections.isEmpty
                          ? 'e.g. Chapter 1'
                          : 'Choose existing or type new',
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: visibility,
                decoration:
                    const InputDecoration(labelText: 'Visibility'),
                items: const [
                  DropdownMenuItem(
                      value: 'all', child: Text('All Students')),
                  DropdownMenuItem(
                      value: '11', child: Text('Class 11 Only')),
                  DropdownMenuItem(
                      value: '12', child: Text('Class 12 Only')),
                  DropdownMenuItem(
                      value: 'neet',
                      child: Text('NEET Exclusive Only')),
                  DropdownMenuItem(
                      value: 'private',
                      child: Text('Private (hidden)')),
                ],
                onChanged: (v) {
                  if (v != null) setSt(() => visibility = v);
                },
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty || linkCtrl.text.isEmpty)
                  return;
                final sectionName = sectionCtrl.text.trim().isEmpty
                    ? 'General'
                    : sectionCtrl.text.trim();
                final sectionId =
                    sectionName.toLowerCase().replaceAll(' ', '_');
                final sectionNotes = _sections[sectionName] ?? [];
                final newOrder = editing?.sortOrder ??
                    (_allOrdered.length * 10);
                final note = NoteModel(
                  id: editing?.id ?? _uuid.v4(),
                  name: nameCtrl.text.trim(),
                  link: linkCtrl.text.trim(),
                  visibility: visibility,
                  sectionId: sectionId,
                  sectionName: sectionName,
                  isLink: widget.isLinks,
                  createdAt: editing?.createdAt ?? DateTime.now(),
                  sortOrder: newOrder,
                );
                await SupabaseService.instance.upsertNote(note);
                // Notify students when a NEW note/PDF is added (not edits)
                if (editing == null && !widget.isLinks) {
                  NotificationService.instance.notifyNotesUploaded(
                    noteName:  note.name,
                    createdBy: 'admin',
                    visibility: note.visibility,
                  );
                }
                setState(() {
                  if (!_sectionOrder.contains(sectionName)) {
                    _sectionOrder.add(sectionName);
                  }
                  final list = _sections.putIfAbsent(
                      sectionName, () => []);
                  if (editing != null) {
                    final i =
                        list.indexWhere((x) => x.id == note.id);
                    if (i >= 0)
                      list[i] = note;
                    else
                      list.add(note);
                  } else {
                    list.add(note);
                  }
                });
                Navigator.pop(ctx);
              },
              child: Text(editing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Arrow button for reordering ────────────────────────────────
class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final String tooltip;
  const _ArrowBtn(this.icon, this.enabled, this.onTap, this.tooltip);

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(icon,
                size: 22,
                color: enabled ? AppColors.primary : AppColors.border),
          ),
        ),
      );
}

// ── Note item card ─────────────────────────────────────────────
class _NoteItem extends ConsumerWidget {
  final NoteModel note;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onToggleEnabled;
  final ValueChanged<String> onChangeVisibility;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final bool canMoveUp;
  final bool canMoveDown;

  const _NoteItem({
    super.key,
    required this.note,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleEnabled,
    required this.onChangeVisibility,
    this.onMoveUp,
    this.onMoveDown,
    this.canMoveUp = false,
    this.canMoveDown = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDisabled = note.isPrivate; // uses isPrivate field, visibility preserved

    return SolidCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        // Up/down controls — prominent column on the left
        Column(mainAxisSize: MainAxisSize.min, children: [
          _ArrowBtn(Icons.keyboard_arrow_up_rounded, canMoveUp,
              onMoveUp ?? () {}, 'Move up'),
          _ArrowBtn(Icons.keyboard_arrow_down_rounded, canMoveDown,
              onMoveDown ?? () {}, 'Move down'),
        ]),
        const SizedBox(width: 8),
        Icon(note.isLink ? Icons.link : Icons.picture_as_pdf_outlined,
            color: isDisabled ? AppColors.textHint : AppColors.primary,
            size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(note.name,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDisabled
                        ? AppColors.textHint
                        : AppColors.textPrimary)),
            Text(note.link,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: 6),
        // Visibility dropdown
        PopupMenuButton<String>(
          tooltip: 'Change visibility',
          child: _visBadge(note.visibility),
          onSelected: onChangeVisibility,
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'all', child: Text('All Students')),
            PopupMenuItem(value: '11', child: Text('Class 11')),
            PopupMenuItem(value: '12', child: Text('Class 12')),
            PopupMenuItem(
                value: 'neet', child: Text('NEET Exclusive')),
            PopupMenuItem(
                value: 'private', child: Text('Private (hidden)')),
          ],
        ),
        const SizedBox(width: 4),
        // On/Off toggle
        Tooltip(
          message: isDisabled
              ? 'Enable (students can see)'
              : 'Disable (hide from students)',
          child: IconButton(
            icon: Icon(
              isDisabled
                  ? Icons.toggle_off_rounded
                  : Icons.toggle_on_rounded,
              color:
                  isDisabled ? AppColors.textHint : AppColors.success,
              size: 28,
            ),
            onPressed: onToggleEnabled,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        const SizedBox(width: 2),
        IconButton(
            icon: const Icon(Icons.edit_outlined,
                size: 16, color: AppColors.info),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints()),
        const SizedBox(width: 2),
        IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 16, color: AppColors.error),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints()),
      ]),
    );
  }

  Widget _visBadge(String v) {
    final colors = {
      'all': AppColors.success,
      '11': AppColors.batch11,
      '12': AppColors.batch12,
      'neet': AppColors.batchNeet,
      'private': AppColors.textHint,
    };
    final labels = {
      'all': 'All',
      '11': '11',
      '12': '12',
      'neet': 'NEET',
      'private': 'Off'
    };
    final color = colors[v] ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(labels[v] ?? v,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(width: 3),
        Icon(Icons.arrow_drop_down, size: 14, color: color),
      ]),
    );
  }
}
