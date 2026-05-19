import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/pyq_provider.dart';
import '../../../services/csv_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';

class PYQUploadScreen extends ConsumerStatefulWidget {
  const PYQUploadScreen({super.key});

  @override
  ConsumerState<PYQUploadScreen> createState() => _PYQUploadScreenState();
}

class _PYQUploadScreenState extends ConsumerState<PYQUploadScreen> {
  bool _uploading = false;
  String? _message;
  bool _isError = false;
  String _uploadStatus = '';

  final TextEditingController _yearController = TextEditingController();

  int _currentCount = 0;
  Map<String, int> _yearsCount = {};

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _loadCount() async {
    try {
      final pyq = await SupabaseService.instance.getAllPYQ();
      final counts = <String, int>{};
      for (var q in pyq) {
        counts[q.year] = (counts[q.year] ?? 0) + 1;
      }
      setState(() {
        _currentCount = pyq.length;
        _yearsCount = counts;
      });
    } catch (e) {
      debugPrint('Error loading PYQ counts: $e');
    }
  }

  Future<void> _uploadCsv() async {
    final yearName = _yearController.text.trim();
    if (yearName.isEmpty) {
      setState(() {
        _isError = true;
        _message = 'Please enter a year name (e.g. "2025 Cancelled") before uploading.';
      });
      return;
    }

    final bytes = await CsvService.pickCsvFile();
    if (bytes == null) return;

    setState(() { _uploading = true; _message = null; });

    try {
      setState(() => _uploadStatus = 'Parsing CSV…');
      final questions = CsvService.parsePYQCsv(bytes, yearName);
      if (questions.isEmpty) {
        setState(() {
          _uploading = false;
          _message = 'No valid questions found in CSV.\n\nCheck:\n• File uses UTF-8 encoding\n• At least 8 columns per row\n• Correct option is A/B/C/D';
          _isError = true;
        });
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (dx) => AlertDialog(
          title: const Text('Replace PYQ Data for Year'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Found ${questions.length} questions.'),
              const SizedBox(height: 8),
              Text('Target Year: $yearName',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'This will REPLACE all existing PYQ data for THIS YEAR ONLY. Continue?',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dx, false),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(dx, true),
              child: const Text('Replace'),
            ),
          ],
        ),
      );

      if (confirm != true) { setState(() => _uploading = false); return; }

      setState(() => _uploadStatus = 'Uploading ${questions.length} questions…');
      await SupabaseService.instance.replacePYQForYear(yearName, questions);

      await _loadCount();

      ref.invalidate(allPYQProvider);
      ref.invalidate(pyqYearsProvider);
      ref.invalidate(pyqChaptersProvider);

      NotificationService.instance.notifyPyqAdded(
        paperTitle: 'PYQ Papers ($yearName)',
        createdBy:  'admin',
      );

      setState(() {
        _uploading = false;
        _message = 'Uploaded ${questions.length} questions for year "$yearName" successfully!';
        _isError = false;
        _yearController.clear();
      });
    } catch (e) {
      setState(() { _uploading = false; _message = 'Error: $e'; _isError = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Previous Year Questions Upload',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text(
            'Upload CSV files for a specific year. You can type any year name (e.g. "2025", "2024 Cancelled").',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // ── Stats row ──────────────────────────────────────────
          Row(children: [
            Expanded(
              child: SolidCard(
                child: Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.history_edu, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$_currentCount',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    const Text('Total Questions',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ]),
                ]),
              ).animate().fadeIn(duration: 300.ms),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SolidCard(
                child: Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.calendar_month, color: AppColors.info, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${_yearsCount.length}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.info)),
                    const Text('Years Available',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ]),
                ]),
              ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Upload card ────────────────────────────────────────
          SolidCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.upload_file, color: AppColors.accent, size: 20),
                  SizedBox(width: 10),
                  Text('Upload Year Data',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 16),

                TextField(
                  controller: _yearController,
                  decoration: const InputDecoration(
                    labelText: 'Year Name (e.g. 2025, 2024 Retest)',
                    hintText: 'Enter the year name to attach to these questions',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                ),
                const SizedBox(height: 20),

                if (_uploading) ...[
                  const Center(
                      child: CircularProgressIndicator(color: AppColors.primary)),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(_uploadStatus,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                  ),
                ] else
                  GradientButton(
                    label: 'Select CSV & Upload',
                    icon: Icons.file_upload_outlined,
                    width: double.infinity,
                    onPressed: _uploadCsv,
                  ),

                if (_message != null && !_uploading) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isError ? AppColors.errorSurface : AppColors.successSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _isError ? AppColors.error : AppColors.success),
                    ),
                    child: Text(
                      _message!,
                      style: TextStyle(
                          color: _isError ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ).animate().slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOut).fadeIn(),

          const SizedBox(height: 24),

          // ── Uploaded years quick look ──────────────────────────
          const Text('Uploaded Years', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (_yearsCount.isEmpty)
            const Text('No years uploaded yet.',
                style: TextStyle(color: AppColors.textHint))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _yearsCount.entries.map((e) => Chip(
                label: Text('${e.key}  (${e.value} Qs)',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                backgroundColor: AppColors.neuBackground,
                side: const BorderSide(color: AppColors.border),
                avatar: const Icon(Icons.folder_open, size: 16, color: AppColors.textSecondary),
              )).toList(),
            ),

          const SizedBox(height: 24),

          // ── CSV format guide ───────────────────────────────────
          const SolidCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 18),
                  SizedBox(width: 8),
                  Text('CSV Format', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ]),
                SizedBox(height: 12),
                Text(
                  'Row 1: header (skipped)\nColumns: year | chapter | question | optA | optB | optC | optD | correct (A/B/C/D) | imageUrl (opt) | explanation (opt)',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.6),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}
