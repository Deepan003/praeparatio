import 'package:flutter/services.dart';

class HapticService {
  static Future<void> selection() => HapticFeedback.selectionClick();
  static Future<void> light() => HapticFeedback.lightImpact();
  static Future<void> medium() => HapticFeedback.mediumImpact();
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// Double-tap feel — used for exam submit, confirm destructive actions
  static Future<void> submit() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
  }

  /// 3-pulse celebration — used when coins are awarded
  static Future<void> celebrate() async {
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 60));
    }
  }

  /// Single heavy — wrong answer in games
  static Future<void> error() => HapticFeedback.heavyImpact();
}
