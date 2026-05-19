import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/batch_model.dart';
import '../services/supabase_service.dart';
import '../core/constants/app_constants.dart';

final batchesProvider = FutureProvider<List<BatchModel>>((ref) async {
  return SupabaseService.instance.getBatches();
});

/// Just the names — use this everywhere a List<String> of batch names is needed.
/// Falls back to AppConstants.batches while loading or on error.
final batchNamesProvider = FutureProvider<List<String>>((ref) async {
  final batches = await ref.watch(batchesProvider.future);
  if (batches.isEmpty) return AppConstants.batches;
  return batches.map((b) => b.name).toList();
});
