import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/batch_model.dart';
import '../services/supabase_service.dart';
import '../core/constants/app_constants.dart';

/// Live stream — rebuilds whenever admin creates, renames, or deletes a batch.
final batchesProvider = StreamProvider<List<BatchModel>>((ref) {
  return SupabaseService.instance.streamBatches();
});

/// Just the names — derived from the live batchesProvider stream.
/// Falls back to AppConstants.batches while loading or on error.
final batchNamesProvider = Provider<List<String>>((ref) {
  return ref.watch(batchesProvider).when(
    data: (batches) => batches.isEmpty
        ? AppConstants.batches
        : batches.map((b) => b.name).toList(),
    loading: () => AppConstants.batches,
    error: (_, __) => AppConstants.batches,
  );
});
