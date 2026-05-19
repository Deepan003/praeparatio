import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/exam_model.dart';
import '../../../models/exam_result_model.dart';
import '../../../models/user_model.dart';
import '../../../models/offline_test_model.dart';
import '../../../models/batch_model.dart';
import '../../../providers/batch_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/csv_service.dart';
import '../../../services/pdf_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/download_button.dart';
import '../../../widgets/glass_card.dart';

const _uuid = Uuid();

class DatabaseScreen extends ConsumerStatefulWidget {
  const DatabaseScreen({super.key});

  @override
  ConsumerState<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends ConsumerState<DatabaseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  String? _activeBatch;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final batchNames = ref.watch(batchNamesProvider).value ?? AppConstants.batches;
    // Default to first batch once loaded
    _activeBatch ??= batchNames.isNotEmpty ? batchNames.first : AppConstants.batch11;

    return Column(
      children: [
        // Batch selector + tab bar
        Container(
          color: AppColors.neuSurface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Batch:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(width: 12),
                ...batchNames.map((b) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChipButton(
                    label: b, selected: _activeBatch == b,
                    onTap: () => setState(() => _activeBatch = b),
                    selectedColor: AppColors.primary,
                  ),
                )),
              ],
            ),
          ),
        ),
        Container(
          color: AppColors.neuSurface,
          child: TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Students'),
              Tab(text: 'Fees'),
              Tab(text: 'Offline Marks'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _StudentsSheet(batch: _activeBatch!, key: ValueKey('students_$_activeBatch')),
              _FeesSheet(batch: _activeBatch!, key: ValueKey('fees_$_activeBatch')),
              _OfflineMarksSheet(batch: _activeBatch!, key: ValueKey('marks_$_activeBatch')),
            ],
          ),
        ),
      ],
    );
  }
}

// ---- STUDENTS SHEET ----
class _StudentsSheet extends ConsumerStatefulWidget {
  final String batch;
  const _StudentsSheet({required this.batch, super.key});

  @override
  ConsumerState<_StudentsSheet> createState() => _StudentsSheetState();
}

class _StudentsSheetState extends ConsumerState<_StudentsSheet> {
  List<UserModel> _students = [];
  bool _loading = true;
  bool _saving = false;
  String _search = '';
  bool _showAllPasswords = false;
  final Set<String> _revealedIds = {};

  @override
  void initState() { super.initState(); _load(); }

  /// Returns '11' or '12' based on the batch's class_level from the DB.
  String _studentClassForBatch() {
    final batches = ref.read(batchesProvider).value ?? [];
    final info = batches.firstWhere(
      (b) => b.name == widget.batch,
      orElse: () => BatchModel(name: widget.batch, classLevel: '11'),
    );
    return (info.classLevel == '12' || info.classLevel == 'neet') ? '12' : '11';
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final students = await SupabaseService.instance.getStudentsByBatch(widget.batch);
    setState(() { _students = students; _loading = false; });
  }

  Future<void> _importCsv() async {
    final bytes = await CsvService.pickCsvFile();
    if (bytes == null) return;
    final users = CsvService.parseStudentsCsv(bytes);
    if (users.isEmpty) { _snack('No valid rows found in CSV'); return; }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dx) => AlertDialog(
        title: const Text('Import Students'),
        content: Text('Import ${users.length} students? They will be added to batch "${widget.batch}".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(dx, true), child: const Text('Import')),
        ],
      ),
    );
    if (confirm != true) return;
    final batchedUsers = users.map((u) => UserModel(id: u.id, name: u.name, username: u.username, passwordHash: u.passwordHash, studentClass: _studentClassForBatch(), batch: widget.batch, createdAt: DateTime.now())).toList();
    await SupabaseService.instance.bulkImportUsers(batchedUsers);
    _snack('Imported ${users.length} students');
    _load();
  }

  Future<Uint8List> _buildBatchPdf() async {
    final studentIds = _students.map((s) => s.id).toList();
    final allResults = await SupabaseService.instance
        .getFirstAttemptResultsForStudents(studentIds);
    final offlineTests = await SupabaseService.instance
        .getOfflineTestsByBatch(widget.batch);
    final examIds = allResults.map((r) => r.examId).toSet().toList();
    final exams = <ExamModel>[];
    for (final id in examIds) {
      final e = await SupabaseService.instance.getExam(id);
      if (e != null) exams.add(e);
    }
    exams.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return PdfService.batchReportPdf(
      students: _students,
      exams: exams,
      allResults: allResults,
      offlineTests: offlineTests,
      batch: widget.batch,
    );
  }

  Future<Uint8List> _buildBatchCsv() async {
    final studentIds = _students.map((s) => s.id).toList();
    final allResults = await SupabaseService.instance
        .getFirstAttemptResultsForStudents(studentIds);
    final offlineTests = await SupabaseService.instance
        .getOfflineTestsByBatch(widget.batch);
    final examIds = allResults.map((r) => r.examId).toSet().toList();
    final exams = <ExamModel>[];
    for (final id in examIds) {
      final e = await SupabaseService.instance.getExam(id);
      if (e != null) exams.add(e);
    }
    exams.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return CsvService.exportBatchReport(_students, exams, allResults, offlineTests);
  }

  Future<void> _addStudent() async {
    final result = await _showStudentDialog(null);
    if (result != null) { await SupabaseService.instance.upsertUser(result); _load(); }
  }

  Future<void> _editStudent(UserModel student) async {
    final result = await _showStudentDialog(student);
    if (result != null) { await SupabaseService.instance.upsertUser(result); _load(); }
  }

  Future<UserModel?> _showStudentDialog(UserModel? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final usernameCtrl = TextEditingController(text: existing?.username ?? '');
    final passwordCtrl = TextEditingController(
        text: existing != null ? existing.passwordPlain : '');
    bool obscure = true;
    return showDialog<UserModel>(
      context: context,
      builder: (dx) => StatefulBuilder(
        builder: (dx, setSt) => AlertDialog(
          title: Text(existing == null ? 'Add Student' : 'Edit Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 10),
              TextField(controller: usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Username')),
              const SizedBox(height: 10),
              TextField(
                controller: passwordCtrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: existing == null ? 'Password' : 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                    onPressed: () => setSt(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (passwordCtrl.text.trim().isEmpty && existing == null) return; // require password for new users
                final plain = passwordCtrl.text.trim().isEmpty && existing != null
                    ? existing.passwordPlain
                    : passwordCtrl.text.trim();
                final hash = passwordCtrl.text.trim().isEmpty && existing != null
                    ? existing.passwordHash
                    : AuthService.hashPassword(plain);
                Navigator.pop(dx, UserModel(
                  id: existing?.id ?? _uuid.v4(),
                  name: nameCtrl.text.trim(),
                  username: usernameCtrl.text.trim(),
                  passwordHash: hash,
                  passwordPlain: plain,
                  studentClass: _studentClassForBatch(),
                  batch: widget.batch,
                  prepcoins: existing?.prepcoins ?? 80,
                  createdAt: existing?.createdAt ?? DateTime.now(),
                  earnedBadgeIds: existing?.earnedBadgeIds,
                  monthlyPayments: existing?.monthlyPayments,
                ));
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final filtered = _search.isEmpty ? _students : _students.where((s) => s.name.toLowerCase().contains(_search.toLowerCase()) || s.username.toLowerCase().contains(_search.toLowerCase())).toList();

    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Column(
      children: [
        // Toolbar — compact on mobile
        Container(
          color: AppColors.neuBackground,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(children: [
            Row(children: [
              Expanded(child: TextField(
                decoration: const InputDecoration(
                    hintText: 'Search…',
                    prefixIcon: Icon(Icons.search, size: 18),
                    isDense: true),
                onChanged: (v) => setState(() => _search = v),
              )),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.upload_file, size: 16),
                label: isMobile ? const SizedBox.shrink() : const Text('Import'),
                onPressed: _importCsv,
              ),
              // Export students list — CSV only (contains passwords, no PDF)
              DownloadButton(
                label: 'Export Students',
                filename: 'Students_${widget.batch.replaceAll(' ', '_')}',
                csvBuilder: () async => CsvService.exportStudentsCsv(_students),
                compact: isMobile,
              ),
              const SizedBox(width: 4),
              // Batch report — PDF + CSV
              DownloadButton(
                label: 'Batch Report',
                filename: 'Batch_Report_${widget.batch.replaceAll(' ', '_')}',
                csvBuilder: _buildBatchCsv,
                pdfBuilder: _buildBatchPdf,
                icon: Icons.summarize_outlined,
                compact: isMobile,
              ),
              const SizedBox(width: 4),
              // Sync student_class for this batch from batch's class_level
              Tooltip(
                message: 'Sync class level from batch settings',
                child: IconButton(
                  icon: const Icon(Icons.sync_rounded, size: 18),
                  color: AppColors.info,
                  onPressed: () async {
                    final classLevel = _studentClassForBatch();
                    await SupabaseService.instance.syncStudentClassForBatch(widget.batch, classLevel);
                    _load();
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Synced: all students in "${widget.batch}" set to Class $classLevel'), backgroundColor: AppColors.success),
                    );
                  },
                ),
              ),
              const SizedBox(width: 2),
              GradientButton(label: isMobile ? '' : 'Add', icon: Icons.person_add, onPressed: _addStudent, width: isMobile ? 46 : 90),
            ]),
          ]),
        ),
        // Table header — hidden on mobile (cards used instead)
        if (!isMobile) ...[
          Container(
            color: AppColors.primarySurface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              const SizedBox(width: 36),
              const _H('Name', flex: 3), const _H('Username', flex: 2),
              Expanded(flex: 2, child: Row(children: [
                const Text('Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => setState(() => _showAllPasswords = !_showAllPasswords),
                  child: Icon(_showAllPasswords ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 14, color: AppColors.primary),
                ),
              ])),
              const _H('PrepCoins', flex: 1), const _H('Status', flex: 1), const _H('Actions', flex: 2),
            ]),
          ),
          const Divider(height: 1),
        ],
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No students found', style: TextStyle(color: AppColors.textHint)))
              : ListView.builder(
                  padding: isMobile ? const EdgeInsets.all(8) : EdgeInsets.zero,
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => isMobile
                      ? _StudentCard(
                          student: filtered[i],
                          batch: widget.batch,
                          onEdit: () => _editStudent(filtered[i]),
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (dx) => AlertDialog(
                                title: const Text('Delete Student'),
                                content: Text('Delete ${filtered[i].name}?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(dx, false), child: const Text('Cancel')),
                                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), onPressed: () => Navigator.pop(dx, true), child: const Text('Delete')),
                                ],
                              ),
                            );
                            if (confirm == true) { await SupabaseService.instance.deleteUser(filtered[i].id); _load(); }
                          },
                          onToggleBan: () async {
                            final s = filtered[i];
                            await SupabaseService.instance.updateUserBan(s.id, !s.isBanned);
                            _load();
                          },
                        )
                      : _StudentRow(
                    student: filtered[i],
                    batch: widget.batch,
                    showPassword: _showAllPasswords || _revealedIds.contains(filtered[i].id),
                    onToggleReveal: () => setState(() {
                      if (_revealedIds.contains(filtered[i].id)) {
                        _revealedIds.remove(filtered[i].id);
                      } else {
                        _revealedIds.add(filtered[i].id);
                      }
                    }),
                    onEdit: () => _editStudent(filtered[i]),
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dx) => AlertDialog(
                          title: const Text('Delete Student'),
                          content: Text('Delete ${filtered[i].name}? This cannot be undone.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dx, false), child: const Text('Cancel')),
                            ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), onPressed: () => Navigator.pop(dx, true), child: const Text('Delete')),
                          ],
                        ),
                      );
                      if (confirm == true) { await SupabaseService.instance.deleteUser(filtered[i].id); _load(); }
                    },
                    onToggleBan: () async {
                      final s = filtered[i];
                      await SupabaseService.instance.updateUserBan(s.id, !s.isBanned);
                      _load();
                    },
                  ).animate(delay: (i * 20).ms).fadeIn(duration: 150.ms),
                ), // ListView

        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('${filtered.length} students in ${widget.batch}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

class _H extends StatelessWidget {
  final String text;
  final int flex;
  const _H(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) => Expanded(
        flex: flex,
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
      );
}

class _StudentRow extends StatelessWidget {
  final UserModel student;
  final bool showPassword;
  final VoidCallback onEdit, onDelete, onToggleBan, onToggleReveal;
  final String batch;

  const _StudentRow({
    required this.student,
    required this.showPassword,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleBan,
    required this.onToggleReveal,
    required this.batch,
  });

  Future<Uint8List> _csvReport() async {
    final online = await SupabaseService.instance.getFirstAttemptResults(student.id);
    final offline = await SupabaseService.instance.getOfflineTestsByBatch(batch);
    return CsvService.exportStudentReport(student, online, offline);
  }

  Future<Uint8List> _pdfReport() async {
    final online = await SupabaseService.instance.getFirstAttemptResults(student.id);
    final offline = await SupabaseService.instance.getOfflineTestsByBatch(batch);
    return PdfService.studentReportPdf(student: student, onlineResults: online, offlineTests: offline);
  }

  @override
  Widget build(BuildContext context) {
    const maskedPw = '••••••••';
    final hasPlain = student.passwordPlain.isNotEmpty;
    final displayPw = showPassword
        ? (hasPlain ? student.passwordPlain : '(not stored)')
        : maskedPw;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
            child: Center(child: Text(student.name.isNotEmpty ? student.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(flex: 2, child: Text(student.username, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
          // Password column
          Expanded(
            flex: 2,
            child: Row(children: [
              Text(displayPw,
                  style: TextStyle(
                      fontSize: 11,
                      fontFamily: showPassword ? null : 'monospace',
                      color: showPassword ? AppColors.textSecondary : AppColors.textHint)),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onToggleReveal,
                child: Icon(showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 13, color: AppColors.textHint),
              ),
            ]),
          ),
          Expanded(flex: 1, child: Row(children: [
            const Icon(Icons.monetization_on_rounded, size: 13, color: AppColors.accent),
            const SizedBox(width: 3),
            Text('${student.prepcoins}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ])),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: student.isBanned ? AppColors.errorSurface : AppColors.successSurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(student.isBanned ? 'Banned' : 'Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: student.isBanned ? AppColors.error : AppColors.success)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: onEdit, tooltip: 'Edit'),
                IconButton(icon: Icon(student.isBanned ? Icons.lock_open_outlined : Icons.block_outlined, size: 16, color: student.isBanned ? AppColors.success : AppColors.warning), onPressed: onToggleBan, tooltip: student.isBanned ? 'Unban' : 'Ban'),
                DownloadButton(label: 'Student Report', filename: 'Student_${student.name.replaceAll(' ', '_')}', csvBuilder: _csvReport, pdfBuilder: _pdfReport, compact: true),
                IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error), onPressed: onDelete, tooltip: 'Delete'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mobile-friendly student card (replaces wide table row on small screens) ─
class _StudentCard extends StatelessWidget {
  final UserModel student;
  final String batch;
  final VoidCallback onEdit, onDelete, onToggleBan;

  const _StudentCard({
    required this.student,
    required this.batch,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleBan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.neuSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.neuRaisedSoft,
        border: student.isBanned ? Border.all(color: AppColors.error.withOpacity(0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + status
          Row(children: [
            Container(
              width: 34, height: 34,
              decoration: const BoxDecoration(
                  color: AppColors.primarySurface, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text('@${student.username}  ·  ${student.batch}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            )),
            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: student.isBanned
                    ? AppColors.errorSurface
                    : AppColors.successSurface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                student.isBanned ? 'Banned' : 'Active',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: student.isBanned ? AppColors.error : AppColors.success),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          // Coins row + action buttons
          Row(children: [
            const Icon(Icons.monetization_on_rounded, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text('${student.prepcoins} coins',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent)),
            const Spacer(),
            // Actions: Edit, Ban, Delete
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
              onPressed: onEdit,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              tooltip: 'Edit',
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                student.isBanned
                    ? Icons.lock_open_outlined
                    : Icons.block_outlined,
                size: 18,
                color: student.isBanned ? AppColors.success : AppColors.warning,
              ),
              onPressed: onToggleBan,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              tooltip: student.isBanned ? 'Unban' : 'Ban',
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              onPressed: onDelete,
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              tooltip: 'Delete',
            ),
          ]),
        ],
      ),
    );
  }
}

// ---- FEES SHEET ----
class _FeesSheet extends ConsumerStatefulWidget {
  final String batch;
  const _FeesSheet({required this.batch, super.key});

  @override
  ConsumerState<_FeesSheet> createState() => _FeesSheetState();
}

class _FeesSheetState extends ConsumerState<_FeesSheet> {
  List<UserModel> _students = [];
  bool _loading = true;
  late String _selectedMonth;
  late List<String> _activeMonths;
  final _monthScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final cur = DateFormat('yyyy-MM').format(DateTime.now());
    _selectedMonth = cur;
    _activeMonths = [cur];
    _load();
  }

  @override
  void dispose() {
    _monthScrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final s = await SupabaseService.instance.getStudentsByBatch(widget.batch);
    // Derive active months from all student data persisted in DB
    final allMonths = <String>{};
    for (final student in s) {
      allMonths.addAll(student.monthlyPayments.keys);
      allMonths.addAll(student.feeExemptMonths);
    }
    // Always show at least the current month
    if (allMonths.isEmpty) {
      allMonths.add(DateFormat('yyyy-MM').format(DateTime.now()));
    }
    final sorted = allMonths.toList()..sort();
    setState(() {
      _students = s;
      _activeMonths = sorted;
      if (!_activeMonths.contains(_selectedMonth)) {
        _selectedMonth = _activeMonths.last;
      }
      _loading = false;
    });
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.error : AppColors.success,
      duration: Duration(seconds: error ? 5 : 2),
    ));
  }

  Future<void> _addMonthLeft() async {
    final first = DateTime.parse('${_activeMonths.first}-01');
    final y = first.month == 1 ? first.year - 1 : first.year;
    final m = first.month == 1 ? 12 : first.month - 1;
    final key = DateFormat('yyyy-MM').format(DateTime(y, m));
    if (_activeMonths.contains(key)) return;
    for (final s in _students) {
      if (!s.monthlyPayments.containsKey(key) && !s.feeExemptMonths.contains(key)) {
        s.monthlyPayments[key] = false;
      }
    }
    try {
      await SupabaseService.instance.bulkUpsertFeeData(_students);
      await _load();
      setState(() => _selectedMonth = key);
    } catch (e) {
      _snack('Failed to add month: $e', error: true);
      await _load();
    }
  }

  Future<void> _addMonthRight() async {
    final last = DateTime.parse('${_activeMonths.last}-01');
    final y = last.month == 12 ? last.year + 1 : last.year;
    final m = last.month == 12 ? 1 : last.month + 1;
    final key = DateFormat('yyyy-MM').format(DateTime(y, m));
    if (_activeMonths.contains(key)) return;
    for (final s in _students) {
      if (!s.monthlyPayments.containsKey(key) && !s.feeExemptMonths.contains(key)) {
        s.monthlyPayments[key] = false;
      }
    }
    try {
      await SupabaseService.instance.bulkUpsertFeeData(_students);
      await _load();
      setState(() => _selectedMonth = key);
    } catch (e) {
      _snack('Failed to add month: $e', error: true);
      await _load();
    }
  }

  Future<void> _deleteMonth(String month) async {
    for (final s in _students) {
      s.monthlyPayments.remove(month);
      s.feeExemptMonths.remove(month);
    }
    try {
      await SupabaseService.instance.bulkUpsertFeeData(_students);
      await _load();
    } catch (e) {
      _snack('Failed to delete month: $e', error: true);
      await _load();
    }
  }

  Future<void> _togglePaid(UserModel s, String month) async {
    final wasExempt = s.feeExemptMonths.contains(month);
    final wasPaid = s.monthlyPayments[month] == true;
    if (wasExempt) {
      s.feeExemptMonths.remove(month);
      s.monthlyPayments[month] = true;
    } else {
      s.monthlyPayments[month] = !wasPaid;
    }
    try {
      await SupabaseService.instance.upsertUser(s);
      setState(() {});
    } catch (e) {
      // Revert in-memory change on failure
      if (wasExempt) {
        s.feeExemptMonths.add(month);
        s.monthlyPayments.remove(month);
      } else {
        s.monthlyPayments[month] = wasPaid;
      }
      _snack('Save failed: $e', error: true);
      setState(() {});
    }
  }

  Future<void> _toggleExempt(UserModel s, String month) async {
    final wasExempt = s.feeExemptMonths.contains(month);
    final hadPayment = s.monthlyPayments.containsKey(month);
    final prevPayment = s.monthlyPayments[month];
    if (wasExempt) {
      s.feeExemptMonths.remove(month);
      s.monthlyPayments[month] = false;
    } else {
      s.feeExemptMonths.add(month);
      s.monthlyPayments.remove(month);
    }
    try {
      await SupabaseService.instance.upsertUser(s);
      setState(() {});
    } catch (e) {
      // Revert
      if (wasExempt) {
        s.feeExemptMonths.add(month);
        if (hadPayment) s.monthlyPayments[month] = prevPayment!;
        else s.monthlyPayments.remove(month);
      } else {
        s.feeExemptMonths.remove(month);
        if (hadPayment) s.monthlyPayments[month] = prevPayment!;
      }
      _snack('Save failed: $e', error: true);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final currentMonthKey = DateFormat('yyyy-MM').format(DateTime.now());

    return Column(children: [
      // Month selector
      Container(
        color: AppColors.neuBackground,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
        child: Row(children: [
          // + left
          _MonthAddButton(icon: Icons.add, onTap: _addMonthLeft, tooltip: 'Add earlier month'),
          const SizedBox(width: 6),
          // Scrollable chips
          Expanded(
            child: Scrollbar(
              controller: _monthScrollCtrl,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _monthScrollCtrl,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: _activeMonths.map((m) {
                    final isSelected = m == _selectedMonth;
                    final isCurrent = m == currentMonthKey;
                    final label = DateFormat('MMM yy').format(DateTime.parse('$m-01'));
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected ? null : AppColors.neuSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isSelected ? AppColors.primary
                                : isCurrent ? AppColors.accent : AppColors.border,
                            width: isCurrent && !isSelected ? 1.5 : 1),
                        boxShadow: isSelected ? AppColors.glow(AppColors.primary, intensity: 0.2) : AppColors.neuRaisedSoft,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _selectedMonth = m),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
                              child: Text(label,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? Colors.white : AppColors.textPrimary)),
                            ),
                          ),
                          GestureDetector(
                            onTap: _activeMonths.length == 1 ? null : () => _deleteMonth(m),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 6, 7, 6),
                              child: Icon(Icons.close_rounded,
                                  size: 11,
                                  color: _activeMonths.length == 1
                                      ? Colors.transparent
                                      : isSelected
                                          ? Colors.white.withOpacity(0.6)
                                          : AppColors.textHint),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // + right
          _MonthAddButton(icon: Icons.add, onTap: _addMonthRight, tooltip: 'Add later month'),
        ]),
      ),

      // Table header
      Container(
        color: AppColors.primarySurface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Expanded(flex: 3, child: Text('Name · ${DateFormat("MMMM yyyy").format(DateTime.parse("$_selectedMonth-01"))}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary))),
          const SizedBox(width: 8),
          // Legend
          const _FeeStatusChip('Paid', AppColors.success),
          const SizedBox(width: 4),
          const _FeeStatusChip('Not Required', Color(0xFF0891B2)),
        ]),
      ),
      const Divider(height: 1),

      // Student list
      Expanded(
        child: ListView.builder(
          itemCount: _students.length,
          itemBuilder: (_, i) {
            final s = _students[i];
            final status = s.feeStatusFor(_selectedMonth);
            final paid = status == 'paid';
            final exempt = status == 'exempt';

            Color rowBg = Colors.transparent;
            if (paid) rowBg = AppColors.success.withOpacity(0.05);
            else if (exempt) rowBg = const Color(0xFF0891B2).withOpacity(0.05);
            else rowBg = AppColors.error.withOpacity(0.04);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: const Border(bottom: BorderSide(color: AppColors.border)),
                color: rowBg,
              ),
              child: Row(children: [
                Expanded(
                  flex: 3,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    Text(s.username, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ]),
                ),
                // Paid toggle button
                GestureDetector(
                  onTap: () => _togglePaid(s, _selectedMonth),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40, height: 36,
                    decoration: BoxDecoration(
                      color: paid ? AppColors.success : AppColors.neuBackground,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                      border: Border.all(
                          color: paid ? AppColors.success : AppColors.border,
                          width: paid ? 1.5 : 1),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.check_rounded,
                          color: paid ? Colors.white : AppColors.textHint.withOpacity(0.4),
                          size: 18),
                    ]),
                  ),
                ),
                // Exempt toggle button (Not Required)
                GestureDetector(
                  onTap: () => _toggleExempt(s, _selectedMonth),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40, height: 36,
                    decoration: BoxDecoration(
                      color: exempt ? const Color(0xFF0891B2) : AppColors.neuBackground,
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                      border: Border.all(
                          color: exempt ? const Color(0xFF0891B2) : AppColors.border,
                          width: exempt ? 1.5 : 1),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.do_not_disturb_rounded,
                          color: exempt ? Colors.white : AppColors.textHint.withOpacity(0.4),
                          size: 16),
                    ]),
                  ),
                ),
              ]),
            );
          },
        ),
      ),

      // Legend footer
      Container(
        padding: const EdgeInsets.all(12),
        color: AppColors.neuSurface,
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.check_rounded, color: AppColors.success, size: 14),
          SizedBox(width: 4),
          Text('Paid', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          SizedBox(width: 16),
          Icon(Icons.do_not_disturb_rounded, color: Color(0xFF0891B2), size: 14),
          SizedBox(width: 4),
          Text('Not Required', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          SizedBox(width: 16),
          Icon(Icons.circle_outlined, color: AppColors.error, size: 14),
          SizedBox(width: 4),
          Text('Not Paid', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ),
    ]);
  }
}

class _FeeStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _FeeStatusChip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: color)),
      );
}

class _MonthAddButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  const _MonthAddButton({required this.icon, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}

// ---- OFFLINE MARKS SHEET ----
class _OfflineMarksSheet extends ConsumerStatefulWidget {
  final String batch;
  const _OfflineMarksSheet({required this.batch, super.key});

  @override
  ConsumerState<_OfflineMarksSheet> createState() => _OfflineMarksSheetState();
}

class _OfflineMarksSheetState extends ConsumerState<_OfflineMarksSheet> {
  List<UserModel> _students = [];
  List<OfflineTestModel> _tests = [];
  bool _loading = true;
  OfflineTestModel? _selectedTest;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final students = await SupabaseService.instance.getStudentsByBatch(widget.batch);
    final tests = await SupabaseService.instance.getOfflineTestsByBatch(widget.batch);
    setState(() { _students = students; _tests = tests; _loading = false; if (_tests.isNotEmpty && _selectedTest == null) _selectedTest = _tests.first; });
  }

  Future<Uint8List> _progressCsv() async =>
      CsvService.exportTestProgressReport(_tests, _students);

  Future<Uint8List> _progressPdf() async =>
      PdfService.testProgressPdf(tests: _tests, students: _students, batch: widget.batch);

  Future<void> _addTest() async {
    final nameCtrl = TextEditingController();
    final marksCtrl = TextEditingController(text: '100');
    DateTime date = DateTime.now();
    final result = await showDialog<OfflineTestModel>(
      context: context,
      builder: (dx) => StatefulBuilder(
        builder: (dx, setSt) => AlertDialog(
          title: const Text('Add Offline Test'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Test Name')),
              const SizedBox(height: 10),
              TextField(controller: marksCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Full Marks')),
              const SizedBox(height: 10),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today_outlined, size: 16),
                label: Text(DateFormat('dd/MM/yyyy').format(date)),
                onPressed: () async {
                  final d = await showDatePicker(context: dx, initialDate: date, firstDate: DateTime(2024), lastDate: DateTime.now());
                  if (d != null) setSt(() => date = d);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(dx, OfflineTestModel(id: _uuid.v4(), name: nameCtrl.text.trim(), date: date, fullMarks: int.tryParse(marksCtrl.text) ?? 100, batch: widget.batch)),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    if (result != null) {
      await SupabaseService.instance.upsertOfflineTest(result);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Row(
      children: [
        // Test list panel
        SizedBox(
          width: 220,
          child: Column(
            children: [
              Container(
                color: AppColors.primarySurface,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Expanded(child: Text('Tests', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary))),
                    if (_tests.isNotEmpty && _students.isNotEmpty)
                      DownloadButton(label: 'Progress Report', filename: 'Test_Progress_${widget.batch.replaceAll(' ', '_')}', csvBuilder: _progressCsv, pdfBuilder: _progressPdf, compact: true),
                    IconButton(icon: const Icon(Icons.add, size: 18, color: AppColors.primary), onPressed: _addTest, tooltip: 'Add test'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _tests.length,
                  itemBuilder: (_, i) {
                    final t = _tests[i];
                    return ListTile(
                      selected: _selectedTest?.id == t.id,
                      selectedTileColor: AppColors.primarySurface,
                      dense: true,
                      title: Text(t.name, style: const TextStyle(fontSize: 13)),
                      subtitle: Text(DateFormat('dd MMM yyyy').format(t.date), style: const TextStyle(fontSize: 11)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 14, color: AppColors.error),
                        onPressed: () async {
                          await SupabaseService.instance.deleteOfflineTest(t.id);
                          _load();
                        },
                      ),
                      onTap: () => setState(() => _selectedTest = t),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Marks sheet
        Expanded(
          child: _selectedTest == null
              ? const Center(child: Text('Select or add a test', style: TextStyle(color: AppColors.textHint)))
              : _MarksTable(test: _selectedTest!, students: _students, onSave: _load),
        ),
      ],
    );
  }
}

class _MarksTable extends StatefulWidget {
  final OfflineTestModel test;
  final List<UserModel> students;
  final VoidCallback onSave;
  const _MarksTable({required this.test, required this.students, required this.onSave});

  @override
  State<_MarksTable> createState() => _MarksTableState();
}

class _MarksTableState extends State<_MarksTable> {
  late Map<String, TextEditingController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = {for (final s in widget.students) s.id: TextEditingController(text: widget.test.studentMarks[s.id]?.toString() ?? '')};
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    for (final s in widget.students) {
      final text = _ctrls[s.id]?.text ?? '';
      widget.test.studentMarks[s.id] = text.isEmpty ? null : int.tryParse(text);
    }
    await SupabaseService.instance.upsertOfflineTest(widget.test);
    widget.onSave();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marks saved!')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.neuBackground,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(widget.test.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(width: 12),
              Text('Full Marks: ${widget.test.fullMarks}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const Spacer(),
              GradientButton(label: 'Save Marks', icon: Icons.save, onPressed: _save, width: 130),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: widget.students.length,
            itemBuilder: (_, i) {
              final s = widget.students[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                child: Row(
                  children: [
                    Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _ctrls[s.id],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Marks',
                          suffixText: '/${widget.test.fullMarks}',
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
