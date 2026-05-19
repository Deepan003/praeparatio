import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Adds a periodic background refresh to a ConsumerStatefulWidget.
///
/// Usage in State:
///   @override void initState() { super.initState(); _refresher = AutoRefresher(ref, [provider1, provider2], interval: 60); }
///   @override void dispose() { _refresher.cancel(); super.dispose(); }
class AutoRefresher {
  final WidgetRef ref;
  final List<ProviderOrFamily> providers;
  Timer? _timer;

  AutoRefresher(
    this.ref,
    this.providers, {
    int intervalSeconds = 60,
  }) {
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      for (final p in providers) {
        ref.invalidate(p);
      }
    });
  }

  void cancel() => _timer?.cancel();

  /// Force an immediate refresh (useful after manual pull-to-refresh)
  void refresh() {
    for (final p in providers) {
      ref.invalidate(p);
    }
  }
}
