import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/batch_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';

class CreditsScreen extends ConsumerStatefulWidget {
  const CreditsScreen({super.key});

  @override
  ConsumerState<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends ConsumerState<CreditsScreen> {
  String _activeBatch = 'all';
  bool _loading = false;

  Future<void> _refillAll(List<UserModel> students) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dx) => AlertDialog(
        title: const Text('Add PrepCoins'),
        content: Text('Add ${AppConstants.defaultMonthlyPrepcoins} PrepCoins to each of the ${students.length} students? (Adds to existing balance, does not reset.)'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            onPressed: () => Navigator.pop(dx, true),
            child: const Text('Add to All'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _loading = true);
    for (final s in students) {
      // ADD to existing balance, not reset
      await SupabaseService.instance.updateUserPrepcoins(
          s.id, s.prepcoins + AppConstants.defaultMonthlyPrepcoins);
    }
    setState(() => _loading = false);
    ref.invalidate(allStudentsProvider);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('+${AppConstants.defaultMonthlyPrepcoins} PrepCoins added to all students!'), backgroundColor: AppColors.success));
  }

  Future<void> _adjustStudent(UserModel student, bool isAdd) async {
    final ctrl = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (dx) => AlertDialog(
        title: Text('${isAdd ? "Add" : "Deduct"} PrepCoins — ${student.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current balance: ${student.prepcoins} 🪙', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(isAdd ? Icons.add : Icons.remove, color: isAdd ? AppColors.success : AppColors.error),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isAdd ? AppColors.success : AppColors.error),
            onPressed: () => Navigator.pop(dx, int.tryParse(ctrl.text) ?? 0),
            child: Text(isAdd ? 'Add' : 'Deduct'),
          ),
        ],
      ),
    );
    if (result == null || result <= 0) return;
    final newAmount = isAdd ? student.prepcoins + result : (student.prepcoins - result).clamp(0, 99999);
    await SupabaseService.instance.updateUserPrepcoins(student.id, newAmount);
    ref.invalidate(allStudentsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(allStudentsProvider);

    return studentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allStudents) {
        final batches = ['all', ...ref.watch(batchNamesProvider)];
        final students = _activeBatch == 'all' ? allStudents : allStudents.where((s) => s.batch == _activeBatch).toList();
        final totalCoins = students.fold<int>(0, (s, u) => s + u.prepcoins);

        return Column(
          children: [
            // Header
            Container(
              color: AppColors.neuSurface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                children: [
                  // Batch filter
                  Wrap(
                    spacing: 8,
                    children: batches.map((b) => ChipButtonInline2(
                      label: b == 'all' ? 'All Batches' : b,
                      selected: _activeBatch == b,
                      onTap: () => setState(() => _activeBatch = b),
                    )).toList(),
                  ),
                  const Spacer(),
                  Text('Total: $totalCoins 🪙 | ${students.length} students', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 16),
                  GradientButton(
                    label: '+${AppConstants.defaultMonthlyPrepcoins} to All',
                    icon: Icons.add_circle_outline,
                    onPressed: _loading ? null : () => _refillAll(students),
                    isLoading: _loading,
                    width: 180,
                  ),
                ],
              ),
            ),

            // Table header
            Container(
              color: AppColors.primarySurface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text('Student', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary))),
                  Expanded(flex: 2, child: Text('Batch', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary))),
                  Expanded(flex: 2, child: Text('PrepCoins', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary))),
                  Expanded(flex: 2, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary))),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (_, i) {
                  final s = students[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                        Expanded(flex: 2, child: Text(s.batch, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text('${s.prepcoins}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: s.prepcoins < 20 ? AppColors.error : s.prepcoins < 50 ? AppColors.warning : AppColors.success)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: AppColors.success, size: 22),
                                onPressed: () async { await _adjustStudent(s, true); },
                                tooltip: 'Add PrepCoins',
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 22),
                                onPressed: () async { await _adjustStudent(s, false); },
                                tooltip: 'Deduct PrepCoins',
                              ),
                              IconButton(
                                icon: const Icon(Icons.replay, color: AppColors.info, size: 20),
                                onPressed: () async {
                                  await SupabaseService.instance.updateUserPrepcoins(s.id, AppConstants.defaultMonthlyPrepcoins);
                                  ref.invalidate(allStudentsProvider);
                                },
                                tooltip: 'Reset to default',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: (i * 15).ms).fadeIn(duration: 150.ms);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class ChipButtonInline2 extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const ChipButtonInline2({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.neuBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.textSecondary)),
        ),
      );
}
