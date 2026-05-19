import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/batch_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/batch_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';

class BatchManagementScreen extends ConsumerStatefulWidget {
  const BatchManagementScreen({super.key});

  @override
  ConsumerState<BatchManagementScreen> createState() =>
      _BatchManagementScreenState();
}

class _BatchManagementScreenState
    extends ConsumerState<BatchManagementScreen> {
  bool _busy = false;

  // Cached student counts per batch
  final Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCounts());
  }

  Future<void> _loadCounts() async {
    final batches = await ref.read(batchesProvider.future).catchError((_) => <BatchModel>[]);
    for (final b in batches) {
      final c = await SupabaseService.instance.getBatchStudentCount(b.name);
      if (mounted) setState(() => _counts[b.name] = c);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.success,
      duration: Duration(seconds: error ? 5 : 2),
    ));
  }

  // ── Create batch ─────────────────────────────────────────────

  Future<void> _showCreateDialog() async {
    final nameCtrl = TextEditingController();
    String classLevel = '11';

    final result = await showDialog<bool>(
      context: context,
      builder: (dx) => StatefulBuilder(
        builder: (dx, setSt) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('New Batch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Batch Name',
                  hintText: 'e.g. 12 NEET \'26',
                ),
              ),
              const SizedBox(height: 20),
              const Text('Class Level',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _LevelChip(
                    label: 'Class 11',
                    selected: classLevel == '11',
                    onTap: () => setSt(() => classLevel = '11'),
                  ),
                  _LevelChip(
                    label: 'Class 12',
                    selected: classLevel == '12',
                    onTap: () => setSt(() => classLevel = '12'),
                  ),
                  _LevelChip(
                    label: 'NEET',
                    selected: classLevel == 'neet',
                    onTap: () => setSt(() => classLevel = 'neet'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dx, false),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(dx, true);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;

    setState(() => _busy = true);
    try {
      final existing = ref.read(batchesProvider).value ?? [];
      final order = existing.isEmpty
          ? 1
          : existing.map((b) => b.displayOrder).reduce((a, b) => a > b ? a : b) + 1;
      await SupabaseService.instance.upsertBatch(BatchModel(
        name: name,
        classLevel: classLevel,
        displayOrder: order,
      ));
      ref.invalidate(batchesProvider);
      ref.invalidate(batchNamesProvider);
      _snack('Batch "$name" created');
      await _loadCounts();
    } catch (e) {
      _snack('Failed to create batch: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── Edit (rename + class change) ─────────────────────────────

  Future<void> _showEditDialog(BatchModel batch) async {
    final nameCtrl = TextEditingController(text: batch.name);
    String classLevel = batch.classLevel;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dx) => StatefulBuilder(
        builder: (dx, setSt) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.edit_rounded, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('Edit Batch'),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Batch Name',
                  hintText: 'e.g. 12 NEET \'26',
                ),
              ),
              const SizedBox(height: 20),
              const Text('Class Level',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _LevelChip(label: 'Class 11', selected: classLevel == '11', onTap: () => setSt(() => classLevel = '11')),
                  _LevelChip(label: 'Class 12', selected: classLevel == '12', onTap: () => setSt(() => classLevel = '12')),
                  _LevelChip(label: 'NEET',     selected: classLevel == 'neet', onTap: () => setSt(() => classLevel = 'neet')),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'This renames the batch everywhere — student records, exam targets, and offline tests are all updated automatically.',
                      style: TextStyle(fontSize: 11, color: AppColors.warning),
                    ),
                  ),
                ]),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dx, false), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(dx, true);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;
    final newName = nameCtrl.text.trim();
    if (newName.isEmpty) return;

    // If nothing changed, skip
    if (newName == batch.name && classLevel == batch.classLevel) return;

    setState(() => _busy = true);
    try {
      await SupabaseService.instance.renameBatch(batch.name, newName, classLevel);
      if (newName != batch.name) _counts[newName] = _counts.remove(batch.name) ?? 0;
      ref.invalidate(batchesProvider);
      ref.invalidate(batchNamesProvider);
      _snack('Batch updated successfully');
      await _loadCounts();
    } catch (e) {
      _snack('Update failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── Promote ──────────────────────────────────────────────────

  Future<void> _showPromoteDialog(BatchModel batch) async {
    final batches = ref.read(batchesProvider).value ?? [];
    final others = batches.where((b) => b.name != batch.name).toList();
    if (others.isEmpty) {
      _snack('No other batch to promote into. Create one first.', error: true);
      return;
    }

    String? destination = others.first.name;
    final count = _counts[batch.name] ?? 0;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dx) => StatefulBuilder(
        builder: (dx, setSt) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.upgrade_rounded,
                color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('Promote Students'),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Move all $count students from',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              _InfoTag(batch.name, AppColors.primary),
              const SizedBox(height: 6),
              const Text('→  into',
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: destination,
                decoration: const InputDecoration(
                    labelText: 'Destination Batch', isDense: true),
                items: others
                    .map((b) => DropdownMenuItem(
                        value: b.name, child: Text(b.name)))
                    .toList(),
                onChanged: (v) => setSt(() => destination = v),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppColors.warning.withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline,
                      size: 14, color: AppColors.warning),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Student records, fee history, and exam results are preserved.',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.warning),
                    ),
                  ),
                ]),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dx, false),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary),
              onPressed: destination == null
                  ? null
                  : () => Navigator.pop(dx, true),
              child: const Text('Promote'),
            ),
          ],
        ),
      ),
    );

    if (confirm != true || destination == null) return;
    setState(() => _busy = true);
    try {
      await SupabaseService.instance.promoteStudents(batch.name, destination!);
      // Sync student_class to match the destination batch's class_level
      final batches = ref.read(batchesProvider).value ?? [];
      final destBatch = batches.firstWhere(
        (b) => b.name == destination,
        orElse: () => BatchModel(name: destination!, classLevel: '11'),
      );
      await SupabaseService.instance.syncStudentClassForBatch(destination!, destBatch.classLevel);
      ref.invalidate(batchesProvider);
      ref.invalidate(batchNamesProvider);
      _snack('$count students moved to "$destination" (Class ${destBatch.classLevel})');
      await _loadCounts();
    } catch (e) {
      _snack('Promote failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── Delete ───────────────────────────────────────────────────

  Future<void> _showDeleteDialog(BatchModel batch) async {
    final count = _counts[batch.name] ?? 0;
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure = true;
    String? errorText;

    final admin = ref.read(authProvider).value;
    if (admin == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dx) => StatefulBuilder(
        builder: (dx, setSt) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.delete_forever_rounded,
                color: AppColors.error, size: 20),
            SizedBox(width: 8),
            Text('Delete Batch'),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorSurface,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.warning_rounded,
                          color: AppColors.error, size: 16),
                      SizedBox(width: 6),
                      Text('Permanent Action',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.error,
                              fontSize: 13)),
                    ]),
                    const SizedBox(height: 6),
                    Text(
                      'This will permanently delete:\n'
                      '• $count student accounts\n'
                      '• All their exam results\n'
                      '• All fee records\n'
                      '• All offline test data\n\n'
                      'This cannot be undone. Export CSV first.',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.error),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Type batch name
              TextField(
                controller: confirmCtrl,
                decoration: InputDecoration(
                  labelText: 'Type batch name to confirm',
                  hintText: batch.name,
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              // Admin password
              TextField(
                controller: passwordCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'Your Admin Password',
                  isDense: true,
                  errorText: errorText,
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18),
                    onPressed: () => setSt(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dx, false),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error),
              onPressed: () {
                if (confirmCtrl.text.trim() != batch.name) {
                  setSt(() => errorText = 'Batch name does not match');
                  return;
                }
                final hash = AuthService.hashPassword(passwordCtrl.text);
                if (hash != admin.passwordHash) {
                  setSt(() => errorText = 'Incorrect password');
                  return;
                }
                Navigator.pop(dx, true);
              },
              child: const Text('Delete Everything'),
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;
    setState(() => _busy = true);
    try {
      await SupabaseService.instance.deleteBatch(batch.name);
      ref.invalidate(batchesProvider);
      ref.invalidate(batchNamesProvider);
      _counts.remove(batch.name);
      _snack('Batch "${batch.name}" and all its data deleted');
    } catch (e) {
      _snack('Delete failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(batchesProvider);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              color: AppColors.neuSurface,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Batch Management',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text(
                          'Create, promote, and remove batches. Deleting a batch permanently removes all student data.',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                GradientButton(
                  label: 'New Batch',
                  icon: Icons.add,
                  onPressed: _busy ? null : _showCreateDialog,
                  width: 130,
                ),
              ]),
            ),
            const Divider(height: 1),
            // Batch list
            Expanded(
              child: batchesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                    child: Text('Error loading batches: $e',
                        style:
                            const TextStyle(color: AppColors.textSecondary))),
                data: (batches) {
                  if (batches.isEmpty) {
                    return Center(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.group_off_outlined,
                                size: 56, color: AppColors.textHint),
                            const SizedBox(height: 12),
                            const Text('No batches yet',
                                style: TextStyle(
                                    color: AppColors.textHint, fontSize: 15)),
                            const SizedBox(height: 16),
                            GradientButton(
                              label: 'Create First Batch',
                              icon: Icons.add,
                              onPressed: _showCreateDialog,
                              width: 180,
                            ),
                          ]),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: batches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _BatchCard(
                          batch: batches[i],
                          studentCount: _counts[batches[i].name],
                          onEdit: () => _showEditDialog(batches[i]),
                          onPromote: () => _showPromoteDialog(batches[i]),
                          onDelete: () => _showDeleteDialog(batches[i]),
                          busy: _busy,
                        ).animate(delay: (i * 50).ms).fadeIn(duration: 250.ms).slideY(begin: 0.1),
                  );
                },
              ),
            ),
          ],
        ),
        if (_busy)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x55FFFFFF),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

// ── Batch card ────────────────────────────────────────────────

class _BatchCard extends StatelessWidget {
  final BatchModel batch;
  final int? studentCount;
  final VoidCallback onEdit;
  final VoidCallback onPromote;
  final VoidCallback onDelete;
  final bool busy;

  const _BatchCard({
    required this.batch,
    required this.studentCount,
    required this.onEdit,
    required this.onPromote,
    required this.onDelete,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = batch.classLevel == '12'
        ? AppColors.info
        : batch.classLevel == 'neet'
            ? AppColors.accent
            : AppColors.primary;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    final levelBadge = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: levelColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: levelColor.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          batch.classLevel == 'neet' ? 'N' : batch.classLevel,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w900, color: levelColor),
        ),
      ),
    );

    final nameInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(batch.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Row(children: [
          _InfoTag(batch.classLevelLabel, levelColor),
          const SizedBox(width: 6),
          _InfoTag(
            studentCount == null
                ? '…'
                : '$studentCount student${studentCount == 1 ? '' : 's'}',
            AppColors.textSecondary,
          ),
        ]),
      ],
    );

    // On mobile: compact icon-only buttons
    final actions = isMobile
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            _IconBtn(Icons.edit_rounded,     AppColors.info,    busy ? null : onEdit,    'Edit'),
            _IconBtn(Icons.upgrade_rounded,  AppColors.primary, busy ? null : onPromote, 'Promote'),
            _IconBtn(Icons.delete_forever_rounded, AppColors.error, busy ? null : onDelete, 'Delete'),
          ])
        : Row(mainAxisSize: MainAxisSize.min, children: [
            Tooltip(
              message: 'Edit batch name and class level',
              child: OutlinedButton.icon(
                onPressed: busy ? null : onEdit,
                icon: const Icon(Icons.edit_rounded, size: 15),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.info,
                  side: BorderSide(color: AppColors.info.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Promote students to another batch',
              child: OutlinedButton.icon(
                onPressed: busy ? null : onPromote,
                icon: const Icon(Icons.upgrade_rounded, size: 15),
                label: const Text('Promote'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Delete batch and all student data',
              child: OutlinedButton.icon(
                onPressed: busy ? null : onDelete,
                icon: const Icon(Icons.delete_forever_rounded, size: 15),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ]);

    return SolidCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          levelBadge,
          const SizedBox(width: 12),
          Expanded(child: nameInfo),
          const SizedBox(width: 8),
          actions,
        ],
      ),
    );
  }
}

// ── Compact icon button for mobile batch card ─────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final String tooltip;
  const _IconBtn(this.icon, this.color, this.onPressed, this.tooltip);

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon,
                size: 19,
                color: onPressed == null ? AppColors.border : color),
          ),
        ),
      );
}

// ── Small helpers ─────────────────────────────────────────────

class _InfoTag extends StatelessWidget {
  final String text;
  final Color color;
  const _InfoTag(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: color)),
      );
}

class _LevelChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LevelChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary
                : AppColors.neuBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.border),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : AppColors.textPrimary)),
        ),
      );
}
