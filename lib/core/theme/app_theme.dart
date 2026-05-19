import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'neu_theme.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.bioGreen,
        surface: AppColors.neuSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.neuBackground,
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.neuBackground,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme:
            const IconThemeData(color: AppColors.textPrimary, size: 22),
        shadowColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.neuSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neuPressedColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.nunito(
            color: AppColors.textHint, fontSize: 14),
        labelStyle: GoogleFonts.nunito(
            color: AppColors.textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.nunito(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.nunito(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          textStyle: GoogleFonts.nunito(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.border, thickness: 1, space: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.neuSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary),
        contentTextStyle: GoogleFonts.nunito(
            fontSize: 14, color: AppColors.textSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle:
            GoogleFonts.nunito(fontSize: 13, color: Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.nunito(
            fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500),
        dividerColor: AppColors.border,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.neuBackground,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 60,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          final sel = s.contains(WidgetState.selected);
          return GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
            color: sel ? AppColors.primary : AppColors.textHint,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((s) {
          final sel = s.contains(WidgetState.selected);
          return IconThemeData(
            color: sel ? AppColors.primary : AppColors.textHint,
            size: 22,
          );
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.primary : null),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primary
                : Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.border),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.12),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle:
            GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      extensions: const [NeuTheme.light],
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.bioGreen,
        surface: Color(0xFF1A1B2E),
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: Color(0xFFE6E7F5),
      ),
      scaffoldBackgroundColor: const Color(0xFF12131F),
      // Build text theme with dark-mode friendly body colors
      textTheme: _buildDarkTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFF12131F),
        foregroundColor: const Color(0xFFE6E7F5),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFE6E7F5),
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: Color(0xFFE6E7F5), size: 22),
        shadowColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1A1B2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F1020),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.nunito(color: const Color(0xFF484A66), fontSize: 14),
        labelStyle: GoogleFonts.nunito(color: const Color(0xFF8E90AD), fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          textStyle: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
          color: Color(0xFF2A2B42), thickness: 1, space: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1A1B2E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFE6E7F5)),
        contentTextStyle: GoogleFonts.nunito(
            fontSize: 14, color: const Color(0xFF8E90AD)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF242538),
        contentTextStyle: GoogleFonts.nunito(fontSize: 13, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: Color(0xFF2A2B42),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: const Color(0xFF8E90AD),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500),
        dividerColor: const Color(0xFF2A2B42),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF12131F),
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 60,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((s) {
          final sel = s.contains(WidgetState.selected);
          return GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
            color: sel ? AppColors.primary : const Color(0xFF484A66),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((s) {
          final sel = s.contains(WidgetState.selected);
          return IconThemeData(
            color: sel ? AppColors.primary : const Color(0xFF484A66),
            size: 22,
          );
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.primary : null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: Color(0xFF2A2B42), width: 1.5),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColors.primary : Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primary.withOpacity(0.4)
                : const Color(0xFF2A2B42)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: const Color(0xFF2A2B42),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.12),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle:
            GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700),
      ),
      extensions: const [NeuTheme.dark],
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) =>
      GoogleFonts.nunitoTextTheme(base).copyWith(
        displayLarge: _t(57, FontWeight.w900, -1),
        displayMedium: _t(45, FontWeight.w800),
        displaySmall: _t(36, FontWeight.w800),
        headlineLarge: _t(30, FontWeight.w800),
        headlineMedium: _t(26, FontWeight.w700),
        headlineSmall: _t(22, FontWeight.w700),
        titleLarge: _t(18, FontWeight.w700),
        titleMedium: _t(16, FontWeight.w600),
        titleSmall: _t(14, FontWeight.w600),
        bodyLarge: _t(15, FontWeight.w400, 0, AppColors.textPrimary),
        bodyMedium: _t(13, FontWeight.w400, 0, AppColors.textSecondary),
        bodySmall: _t(11, FontWeight.w400, 0, AppColors.textHint),
        labelLarge: _t(13, FontWeight.w700),
        labelMedium: _t(11, FontWeight.w600, 0.3, AppColors.textSecondary),
        labelSmall: _t(10, FontWeight.w500, 0.5, AppColors.textHint),
      );

  static TextStyle _t(double size, FontWeight weight,
          [double spacing = 0, Color color = AppColors.textPrimary]) =>
      GoogleFonts.nunito(
          fontSize: size,
          fontWeight: weight,
          color: color,
          letterSpacing: spacing);

  // Dark-mode text theme — all body/label text uses dark-friendly colors
  static TextTheme _buildDarkTextTheme(TextTheme base) {
    const dp = Color(0xFFE6E7F5); // dark primary text
    const ds = Color(0xFF8E90AD); // dark secondary text
    const dh = Color(0xFF484A66); // dark hint text
    return GoogleFonts.nunitoTextTheme(base).copyWith(
      displayLarge:  _dt(57, FontWeight.w900, -1, dp),
      displayMedium: _dt(45, FontWeight.w800, 0, dp),
      displaySmall:  _dt(36, FontWeight.w800, 0, dp),
      headlineLarge: _dt(30, FontWeight.w800, 0, dp),
      headlineMedium:_dt(26, FontWeight.w700, 0, dp),
      headlineSmall: _dt(22, FontWeight.w700, 0, dp),
      titleLarge:    _dt(18, FontWeight.w700, 0, dp),
      titleMedium:   _dt(16, FontWeight.w600, 0, dp),
      titleSmall:    _dt(14, FontWeight.w600, 0, dp),
      bodyLarge:     _dt(15, FontWeight.w400, 0, dp),
      bodyMedium:    _dt(13, FontWeight.w400, 0, ds),
      bodySmall:     _dt(11, FontWeight.w400, 0, dh),
      labelLarge:    _dt(13, FontWeight.w700, 0, dp),
      labelMedium:   _dt(11, FontWeight.w600, 0.3, ds),
      labelSmall:    _dt(10, FontWeight.w500, 0.5, dh),
    );
  }

  static TextStyle _dt(double size, FontWeight weight, double spacing, Color color) =>
      GoogleFonts.nunito(
          fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing);
}
