// Re-export NeuButton/NeuPrimaryButton under the old names
// so every existing import keeps working without changes.
export 'neu_widgets.dart'
    show NeuPrimaryButton, NeuButton, NeuChip, NeuCard, SolidCard,
         GlassCard, GradientCard, InfoChip, TiltCard;

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'neu_widgets.dart';

// ── PrimaryButton — kept for backward compat ──────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: NeuPrimaryButton(
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          gradient: color != null
              ? LinearGradient(colors: [color!, color!])
              : AppColors.primaryGradient,
        ),
      );
}

// ── GradientButton — kept for backward compat ─────────────────
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final Gradient? gradient;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        child: NeuPrimaryButton(
          label: label,
          onPressed: onPressed,
          isLoading: isLoading,
          icon: icon,
          gradient: gradient ?? AppColors.primaryGradient,
        ),
      );
}

// ── ChipButton — kept for backward compat ─────────────────────
class ChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;
  final Color? unselectedColor;

  const ChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) => NeuChip(
        label: label,
        selected: selected,
        onTap: onTap,
        selectedColor: selectedColor,
      );
}
