import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// A consistently styled [RefreshIndicator] wrapper that uses [AppColors.primary]
/// and a standard displacement/strokeWidth across the whole app.
class NeuRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const NeuRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.neuSurface,
      displacement: 60.0,
      strokeWidth: 2.5,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
