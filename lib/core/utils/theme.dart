import 'package:flutter/material.dart';

/// ------------------------------------------------------
///  THEME MODE ENUM
/// ------------------------------------------------------
enum AppThemeMode { light, dark, system }

/// ------------------------------------------------------
///  COLOR TOKENS — Jusel Design System
/// ------------------------------------------------------
class JuselColors {
  // Base
  static const background = Color(0xFFF8FAFF);
  static const border = Color(0xFFE6EDF8);
  static const card = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF0F1724);

  // Brand
  static const primary = Color(0xFF1F6BFF);
  static const primaryForeground = Color(0xFFFFFFFF);

  static const secondary = Color(0xFF0BB07B);
  static const secondaryForeground = Color(0xFFFFFFFF);

  // Accent
  static const accent = Color(0xFF7C5CFF);
  static const accentForeground = Color(0xFFFFFFFF);

  // Muted
  static const muted = Color(0xFFF1F5F9);
  static const mutedForeground = Color(0xFF6B7280);

  // Status
  static const success = Color(0xFF16A34A);
  static const successForeground = Color(0xFFFFFFFF);

  static const warning = Color(0xFFF59E0B);
  static const warningForeground = Color(0xFF92400E);

  static const destructive = Color(0xFFEF4444);
  static const destructiveForeground = Color(0xFFFFFFFF);

  // Sidebar
  static const sidebar = Color(0xFFFFFFFF);
  static const sidebarForeground = Color(0xFF0F1724);
  static const sidebarPrimary = Color(0xFF1F6BFF);
  static const sidebarPrimaryForeground = Color(0xFFFFFFFF);
}

/// ------------------------------------------------------
///  RADII
/// ------------------------------------------------------
class JuselRadii {
  static const small = Radius.circular(6);
  static const medium = Radius.circular(10);
  static const large = Radius.circular(14);
  static const xLarge = Radius.circular(20);
}

/// ------------------------------------------------------
///  SPACING SYSTEM
/// ------------------------------------------------------
class JuselSpacing {
  static const s0 = 0.0;
  static const s2 = 2.0;
  static const s4 = 4.0;
  static const s6 = 6.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s20 = 20.0;
  static const s24 = 24.0;
  static const s28 = 28.0;
  static const s32 = 32.0;
  static const s40 = 40.0;
  static const s48 = 48.0;
  static const s56 = 56.0;
  static const s64 = 64.0;
}

/// ------------------------------------------------------
///  TEXT STYLES (Inter)
/// ------------------------------------------------------
class JuselTextStyles {
  static const fontFamily = "Inter";

  static const headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: JuselColors.foreground,
  );

  static const headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: JuselColors.foreground,
  );

  static const headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: JuselColors.foreground,
  );

  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: JuselColors.foreground,
  );

  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: JuselColors.foreground,
  );

  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: JuselColors.mutedForeground,
  );
}

/// ------------------------------------------------------
///  LIGHT THEME DATA
/// ------------------------------------------------------
ThemeData juselLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: JuselTextStyles.fontFamily,

  scaffoldBackgroundColor: JuselColors.background,
  canvasColor: JuselColors.background,

  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: JuselColors.primary,
    onPrimary: JuselColors.primaryForeground,
    secondary: JuselColors.secondary,
    onSecondary: JuselColors.secondaryForeground,
    error: JuselColors.destructive,
    onError: JuselColors.destructiveForeground,
    surface: JuselColors.card,
    onSurface: JuselColors.foreground,
  ),

  cardTheme: CardThemeData(
    color: JuselColors.card,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black12,
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: JuselColors.muted,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: JuselColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: JuselColors.primary, width: 1.4),
    ),
  ),

  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: JuselColors.background,
    foregroundColor: JuselColors.foreground,
    centerTitle: false,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: const WidgetStatePropertyAll(1),
      backgroundColor: const WidgetStatePropertyAll(JuselColors.primary),
      foregroundColor: const WidgetStatePropertyAll(
        JuselColors.primaryForeground,
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  ),
  dialogTheme: const DialogThemeData(backgroundColor: JuselColors.card),
);

/// ------------------------------------------------------
///  DARK THEME DATA (auto-generated from light theme)
/// ------------------------------------------------------
ThemeData juselDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: JuselTextStyles.fontFamily,

  scaffoldBackgroundColor: const Color(0xFF0B0E14),
  canvasColor: const Color(0xFF0B0E14),

  colorScheme: const ColorScheme.dark(
    primary: JuselColors.primary,
    onPrimary: JuselColors.primaryForeground,
    secondary: JuselColors.secondary,
    onSecondary: JuselColors.secondaryForeground,
    error: JuselColors.destructive,
    onError: JuselColors.destructiveForeground,
    surface: Color(0xFF1A1D24),
    onSurface: Colors.white,
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF1A1D24),
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1A1D24),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF2A2F3A)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: JuselColors.primary),
    ),
  ),
  dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1A1D24)),
);
