import 'package:flutter/material.dart';

class AppColors {
  // ── Neumorphic base ────────────────────────────────────────
  static const Color neuBackground   = Color(0xFFEDF0F7);
  static const Color neuSurface      = Color(0xFFEDF0F7);
  static const Color neuShadowLight  = Color(0xFFFFFFFF);
  static const Color neuShadowDark   = Color(0xFFC8CCDC);
  static const Color neuPressedColor = Color(0xFFE2E5F0);  // inset fill

  // ── Backward-compat aliases ────────────────────────────────
  static const Color background     = neuBackground;
  static const Color surface        = neuSurface;
  static const Color surfaceVariant = neuPressedColor;
  static const Color cardSurface    = neuSurface;
  static const Color glassShadow    = neuShadowDark;       // old name

  // ── Brand palette ──────────────────────────────────────────
  static const Color primary        = Color(0xFF4E46A8);
  static const Color primaryLight   = Color(0xFF7B6FD4);
  static const Color primaryDark    = Color(0xFF2D2670);
  static const Color primarySurface = Color(0xFFEDEBFF);

  static const Color bioGreen       = Color(0xFF22A06B);
  static const Color bioGreenLight  = Color(0xFF34D399);
  static const Color bioGreenSurface= Color(0xFFDCFCE7);

  static const Color accent         = Color(0xFFF59E0B);
  static const Color accentLight    = Color(0xFFFFCF7A);
  static const Color accentSurface  = Color(0xFFFEF3C7);

  // ── Semantic ───────────────────────────────────────────────
  static const Color success        = Color(0xFF16A34A);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color error          = Color(0xFFDC2626);
  static const Color errorSurface   = Color(0xFFFFE4E4);
  static const Color warning        = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color info           = Color(0xFF2563EB);
  static const Color infoSurface    = Color(0xFFEFF6FF);

  // ── Text ───────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF1E1B4B);
  static const Color textSecondary  = Color(0xFF6B7280);
  static const Color textHint       = Color(0xFFB0B7C9);
  static const Color textOnPrimary  = Color(0xFFFFFFFF);

  // ── Borders ────────────────────────────────────────────────
  static const Color border         = Color(0xFFDDE0EC);

  // ── Batch ──────────────────────────────────────────────────
  static const Color batch11        = Color(0xFF2563EB);
  static const Color batch12        = Color(0xFF16A34A);
  static const Color batchNeet      = Color(0xFFDC2626);

  // ── Difficulty ─────────────────────────────────────────────
  static const Color easy           = Color(0xFF16A34A);
  static const Color medium         = Color(0xFFD97706);
  static const Color hard           = Color(0xFFDC2626);
  static const Color neetLevel      = Color(0xFF7C3AED);

  // ── Badge tiers ────────────────────────────────────────────
  static const Color bronze         = Color(0xFFB45309);
  static const Color silver         = Color(0xFF64748B);
  static const Color gold           = Color(0xFFD97706);
  static const Color platinum       = Color(0xFF0891B2);
  static const Color diamond        = Color(0xFF7C3AED);

  // ── Neumorphic shadow helpers ──────────────────────────────
  /// Raised: floats above the surface
  static List<BoxShadow> get neuRaised => [
    const BoxShadow(
        color: neuShadowLight, offset: Offset(-6, -6), blurRadius: 14),
    BoxShadow(
        color: neuShadowDark.withOpacity(0.7),
        offset: const Offset(6, 6),
        blurRadius: 14),
  ];

  /// Softly raised — primary surface card
  static List<BoxShadow> get neuRaisedSoft => [
    const BoxShadow(
        color: neuShadowLight, offset: Offset(-4, -4), blurRadius: 10),
    BoxShadow(
        color: neuShadowDark.withOpacity(0.55),
        offset: const Offset(4, 4),
        blurRadius: 10),
  ];

  /// Backward-compat alias for neuRaisedSoft
  static List<BoxShadow> get softShadow => neuRaisedSoft;

  /// Inset / pressed — selected state or input
  static List<BoxShadow> get neuInset => [
    BoxShadow(
        color: neuShadowDark.withOpacity(0.5),
        offset: const Offset(3, 3),
        blurRadius: 8),
    const BoxShadow(
        color: neuShadowLight, offset: Offset(-2, -2), blurRadius: 6),
  ];

  /// Strong raised — dialogs, modals
  static List<BoxShadow> get neuRaisedStrong => [
    const BoxShadow(
        color: neuShadowLight, offset: Offset(-8, -8), blurRadius: 20, spreadRadius: 1),
    BoxShadow(
        color: neuShadowDark.withOpacity(0.8),
        offset: const Offset(8, 8),
        blurRadius: 20,
        spreadRadius: 1),
  ];

  /// Backward-compat alias for neuInset
  static List<BoxShadow> get neuPressed => neuInset;

  /// Backward-compat — elevated shadow with purple tint
  static List<BoxShadow> get elevatedShadow => neuRaisedStrong;

  // ── Gradients ──────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4E46A8), Color(0xFF7B6FD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bioGradient = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient deepGradient = LinearGradient(
    colors: [Color(0xFF1E1560), Color(0xFF2D2670), Color(0xFF4E46A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFFCF7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aquaGradient = LinearGradient(
    colors: [Color(0xFF0891B2), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF4ADE80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFEDF0F7), Color(0xFFE8EBF5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = primaryGradient;

  // ── Glow / accent shadows ──────────────────────────────────
  static List<BoxShadow> glow(Color color, {double intensity = 0.35}) => [
    BoxShadow(
        color: color.withOpacity(intensity),
        blurRadius: 20,
        spreadRadius: 2,
        offset: const Offset(0, 6)),
  ];

  /// Backward-compat
  static List<BoxShadow> accentGlow(Color color) => glow(color);
}
