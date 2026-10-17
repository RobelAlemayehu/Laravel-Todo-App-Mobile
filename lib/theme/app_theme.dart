import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

ThemeData buildChocolateTheme() {
  const radius14 = BorderRadius.all(Radius.circular(14));
  const radius10 = BorderRadius.all(Radius.circular(10));

  OutlineInputBorder _border(Color c, {double width = 1}) => OutlineInputBorder(
        borderRadius: radius10,
        borderSide: BorderSide(color: c, width: width),
      );

  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: appBg,
    colorScheme: const ColorScheme.light(
      primary: choc700,
      onPrimary: cream,
      primaryContainer: appSurface2,
      onPrimaryContainer: choc900,
      secondary: choc500,
      onSecondary: cream,
      surface: appSurface,
      onSurface: choc900,
      surfaceContainerHighest: appSurface2,
      outline: appBorder,
      error: appDanger,
      onError: cream,
    ),
    splashColor: choc700.withOpacity(0.08),
    highlightColor: choc700.withOpacity(0.05),
    focusColor: caramel.withOpacity(0.12),
  );

  return base.copyWith(
    // ── Typography ────────────────────────────────────────────────────────────
    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.fraunces(
          fontSize: 32, fontWeight: FontWeight.w700, color: choc900),
      displayMedium: GoogleFonts.fraunces(
          fontSize: 28, fontWeight: FontWeight.w700, color: choc900),
      headlineMedium: GoogleFonts.fraunces(
          fontSize: 22, fontWeight: FontWeight.w700, color: choc900),
      headlineSmall: GoogleFonts.fraunces(
          fontSize: 18, fontWeight: FontWeight.w700, color: choc900),
      titleLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w600, color: choc900),
      bodyLarge: GoogleFonts.inter(fontSize: 15, color: choc900),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: choc900),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: choc500),
      labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: choc500,
          letterSpacing: 0.8),
    ),

    // ── AppBar ────────────────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: appSurface,
      foregroundColor: choc900,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
    ),

    // ── Input ─────────────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: appSurface,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: _border(appBorder),
      enabledBorder: _border(appBorder),
      focusedBorder: _border(caramel, width: 2),
      errorBorder: _border(appDanger),
      focusedErrorBorder: _border(appDanger, width: 2),
      labelStyle: GoogleFonts.inter(fontSize: 14, color: choc500),
      hintStyle: GoogleFonts.inter(fontSize: 14, color: appMuted),
      errorStyle: GoogleFonts.inter(fontSize: 12, color: appDanger),
      suffixIconColor: choc500,
      prefixIconColor: choc500,
      isDense: true,
    ),

    // ── Buttons ───────────────────────────────────────────────────────────────
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: choc700,
        foregroundColor: cream,
        disabledBackgroundColor: appSurface2,
        disabledForegroundColor: appMuted,
        shape: const RoundedRectangleBorder(borderRadius: radius10),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        minimumSize: const Size(0, 48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: choc700,
        side: const BorderSide(color: appBorder),
        shape: const RoundedRectangleBorder(borderRadius: radius10),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(0, 44),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: choc700,
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: choc700,
        foregroundColor: cream,
        shape: const RoundedRectangleBorder(borderRadius: radius10),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),

    // ── Checkbox ──────────────────────────────────────────────────────────────
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return choc700;
        return appSurface;
      }),
      checkColor: WidgetStateProperty.all(cream),
      side: const BorderSide(color: appBorder, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),

    // ── Dialog ────────────────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: appSurface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: radius14),
      elevation: 8,
      titleTextStyle: GoogleFonts.fraunces(
          fontSize: 20, fontWeight: FontWeight.w700, color: choc900),
      contentTextStyle:
          GoogleFonts.inter(fontSize: 14, color: choc500),
    ),

    // ── BottomSheet ───────────────────────────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: appSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      showDragHandle: false,
      elevation: 8,
    ),

    // ── SnackBar (toasts) ─────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: choc900,
      contentTextStyle: GoogleFonts.inter(fontSize: 14, color: cream),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
    ),

    // ── DatePicker ────────────────────────────────────────────────────────────
    datePickerTheme: DatePickerThemeData(
      backgroundColor: appSurface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: radius14),
      dayStyle: GoogleFonts.inter(fontSize: 13),
      headerBackgroundColor: choc700,
      headerForegroundColor: cream,
      headerHeadlineStyle:
          GoogleFonts.fraunces(fontSize: 26, fontWeight: FontWeight.w700),
      headerHelpStyle: GoogleFonts.inter(fontSize: 12, color: cream.withOpacity(0.7)),
      todayBorder: const BorderSide(color: caramel, width: 1.5),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return cream;
        return caramel;
      }),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return cream;
        if (states.contains(WidgetState.disabled)) return appMuted;
        return choc900;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return choc700;
        return null;
      }),
      rangePickerHeaderBackgroundColor: choc700,
      weekdayStyle: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600, color: choc500),
      yearStyle: GoogleFonts.inter(fontSize: 13),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return cream;
        return choc900;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return choc700;
        return null;
      }),
    ),

    // ── Divider ───────────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: appBorder,
      thickness: 1,
      space: 0,
    ),

    // ── Progress indicator ────────────────────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: choc700,
      linearTrackColor: appSurface2,
    ),

    // ── Chip ─────────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: appSurface2,
      labelStyle: GoogleFonts.inter(fontSize: 12, color: choc500),
      side: const BorderSide(color: appBorder),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),

    // ── Switch / Radio ────────────────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return cream;
        return appMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return choc700;
        return appSurface2;
      }),
    ),

    // ── ListTile ─────────────────────────────────────────────────────────────
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      textColor: choc900,
      iconColor: choc500,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
  );
}

// ── Convenience text styles ───────────────────────────────────────────────────
TextStyle serifTitle([double size = 28]) =>
    GoogleFonts.fraunces(fontSize: size, fontWeight: FontWeight.w700, color: choc900);

TextStyle sectionLabel() => GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: choc500,
      letterSpacing: 0.8,
    );

TextStyle bodyText([Color? color]) =>
    GoogleFonts.inter(fontSize: 15, color: color ?? choc900);

TextStyle metaText([Color? color]) =>
    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: color ?? choc500);
