import 'package:flutter/material.dart';

@immutable
class NeuTheme extends ThemeExtension<NeuTheme> {
  final Color bg;
  final Color surface;
  final Color shadowLight;
  final Color shadowDark;
  final Color insetFill;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color primarySurface;
  final Color successSurface;
  final Color errorSurface;
  final Color warningSurface;
  final Color infoSurface;

  const NeuTheme({
    required this.bg,
    required this.surface,
    required this.shadowLight,
    required this.shadowDark,
    required this.insetFill,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.primarySurface,
    required this.successSurface,
    required this.errorSurface,
    required this.warningSurface,
    required this.infoSurface,
  });

  // Neumorphic raised shadow list
  List<BoxShadow> get raisedSoft => [
    BoxShadow(color: shadowLight, offset: const Offset(-4, -4), blurRadius: 10),
    BoxShadow(color: shadowDark.withOpacity(0.55), offset: const Offset(4, 4), blurRadius: 10),
  ];

  List<BoxShadow> get raisedStrong => [
    BoxShadow(color: shadowLight, offset: const Offset(-8, -8), blurRadius: 20, spreadRadius: 1),
    BoxShadow(color: shadowDark.withOpacity(0.8), offset: const Offset(8, 8), blurRadius: 20, spreadRadius: 1),
  ];

  List<BoxShadow> get inset => [
    BoxShadow(color: shadowDark.withOpacity(0.5), offset: const Offset(3, 3), blurRadius: 8),
    BoxShadow(color: shadowLight, offset: const Offset(-2, -2), blurRadius: 6),
  ];

  static const light = NeuTheme(
    bg:             Color(0xFFEDF0F7),
    surface:        Color(0xFFEDF0F7),
    shadowLight:    Color(0xFFFFFFFF),
    shadowDark:     Color(0xFFC8CCDC),
    insetFill:      Color(0xFFE2E5F0),
    border:         Color(0xFFDDE0EC),
    textPrimary:    Color(0xFF1E1B4B),
    textSecondary:  Color(0xFF6B7280),
    textHint:       Color(0xFFB0B7C9),
    primarySurface: Color(0xFFEDEBFF),
    successSurface: Color(0xFFDCFCE7),
    errorSurface:   Color(0xFFFFE4E4),
    warningSurface: Color(0xFFFEF3C7),
    infoSurface:    Color(0xFFEFF6FF),
  );

  static const dark = NeuTheme(
    bg:             Color(0xFF12131F),
    surface:        Color(0xFF1A1B2E),
    shadowLight:    Color(0xFF242538),
    shadowDark:     Color(0xFF080910),
    insetFill:      Color(0xFF0F1020),
    border:         Color(0xFF2A2B42),
    textPrimary:    Color(0xFFE6E7F5),
    textSecondary:  Color(0xFF8E90AD),
    textHint:       Color(0xFF484A66),
    primarySurface: Color(0xFF1E1C3E),
    successSurface: Color(0xFF0F2018),
    errorSurface:   Color(0xFF251010),
    warningSurface: Color(0xFF251E0A),
    infoSurface:    Color(0xFF0F1830),
  );

  @override
  NeuTheme copyWith({
    Color? bg, Color? surface, Color? shadowLight, Color? shadowDark,
    Color? insetFill, Color? border, Color? textPrimary, Color? textSecondary,
    Color? textHint, Color? primarySurface, Color? successSurface,
    Color? errorSurface, Color? warningSurface, Color? infoSurface,
  }) => NeuTheme(
    bg: bg ?? this.bg, surface: surface ?? this.surface,
    shadowLight: shadowLight ?? this.shadowLight, shadowDark: shadowDark ?? this.shadowDark,
    insetFill: insetFill ?? this.insetFill, border: border ?? this.border,
    textPrimary: textPrimary ?? this.textPrimary, textSecondary: textSecondary ?? this.textSecondary,
    textHint: textHint ?? this.textHint, primarySurface: primarySurface ?? this.primarySurface,
    successSurface: successSurface ?? this.successSurface, errorSurface: errorSurface ?? this.errorSurface,
    warningSurface: warningSurface ?? this.warningSurface, infoSurface: infoSurface ?? this.infoSurface,
  );

  @override
  NeuTheme lerp(NeuTheme? other, double t) {
    if (other == null) return this;
    return NeuTheme(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      shadowLight: Color.lerp(shadowLight, other.shadowLight, t)!,
      shadowDark: Color.lerp(shadowDark, other.shadowDark, t)!,
      insetFill: Color.lerp(insetFill, other.insetFill, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      primarySurface: Color.lerp(primarySurface, other.primarySurface, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      errorSurface: Color.lerp(errorSurface, other.errorSurface, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      infoSurface: Color.lerp(infoSurface, other.infoSurface, t)!,
    );
  }
}

extension NeuThemeX on BuildContext {
  NeuTheme get neu => Theme.of(this).extension<NeuTheme>() ?? NeuTheme.light;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
