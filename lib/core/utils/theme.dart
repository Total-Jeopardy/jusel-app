import 'package:flutter/material.dart';

/// ------------------------------------------------------
///  THEME MODE ENUM
/// ------------------------------------------------------
enum AppThemeMode { light, dark, system }

/// ------------------------------------------------------
///  COLOR TOKENS — Jusel Design System
/// Theme-aware color system
/// ------------------------------------------------------
class JuselColors {
  // Light theme colors
  static const _lightBackground = Color(0xFFF8FAFF);
  static const _lightBorder = Color(0xFFE6EDF8);
  static const _lightCard = Color(0xFFFFFFFF);
  static const _lightForeground = Color(0xFF0F1724);
  static const _lightMuted = Color(0xFFF1F5F9);
  static const _lightMutedForeground = Color(0xFF6B7280);
  static const _lightSidebar = Color(0xFFFFFFFF);
  static const _lightSidebarForeground = Color(0xFF0F1724);

  // Dark theme colors - WCAG compliant with proper contrast
  static const _darkBackground = Color(0xFF0B0E14); // Base background
  static const _darkCard = Color(0xFF1A1D24); // Elevated surface
  static const _darkCardElevated = Color(0xFF232730); // Higher elevation
  static const _darkBorder = Color(0xFF2A2F3A); // Subtle borders
  static const _darkForeground = Color(0xFFF8FAFF); // Primary text
  static const _darkMuted = Color(0xFF1A1D24); // Input backgrounds
  static const _darkMutedForeground = Color(0xFF9CA3AF); // Secondary text
  static const _darkSidebar = Color(0xFF151821);
  static const _darkSidebarForeground = Color(0xFFF8FAFF);

  // Brand colors (work in both themes, but may need slight adjustments)
  static const primary = Color(0xFF1F6BFF);
  static const primaryForeground = Color(0xFFFFFFFF);
  static const primaryDark = Color(0xFF4D8AFF); // Lighter for dark mode visibility

  static const secondary = Color(0xFF0BB07B);
  static const secondaryForeground = Color(0xFFFFFFFF);
  static const secondaryDark = Color(0xFF10D99F); // Lighter for dark mode

  static const accent = Color(0xFF7C5CFF);
  static const accentForeground = Color(0xFFFFFFFF);
  static const accentDark = Color(0xFF9B7AFF); // Lighter for dark mode

  // Status colors (adjusted for dark mode)
  static const success = Color(0xFF16A34A);
  static const successForeground = Color(0xFFFFFFFF);
  static const successDark = Color(0xFF22C55E); // Brighter for dark

  static const warning = Color(0xFFF59E0B);
  static const warningForeground = Color(0xFF92400E);
  static const warningDark = Color(0xFFFBBF24); // Brighter for dark

  static const destructive = Color(0xFFEF4444);
  static const destructiveForeground = Color(0xFFFFFFFF);
  static const destructiveDark = Color(0xFFF87171); // Softer for dark

  // Theme-aware getters
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkBackground
        : _lightBackground;
  }

  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkCard
        : _lightCard;
  }

  static Color cardElevated(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkCardElevated
        : _lightCard;
  }

  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkBorder
        : _lightBorder;
  }

  static Color foreground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkForeground
        : _lightForeground;
  }

  static Color muted(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkMuted
        : _lightMuted;
  }

  static Color mutedForeground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkMutedForeground
        : _lightMutedForeground;
  }

  static Color sidebar(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkSidebar
        : _lightSidebar;
  }

  static Color sidebarForeground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkSidebarForeground
        : _lightSidebarForeground;
  }

  // Brand colors with dark mode variants
  static Color primaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? primaryDark
        : primary;
  }

  static Color secondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? secondaryDark
        : secondary;
  }

  static Color accentColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? accentDark
        : accent;
  }

  // Status colors with dark mode variants
  static Color successColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? successDark
        : success;
  }

  static Color warningColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? warningDark
        : warning;
  }

  static Color destructiveColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? destructiveDark
        : destructive;
  }

  // Legacy static getters for backward compatibility (use light theme)
  // These return light theme values - migrate to context-based methods for theme support
  static Color get backgroundLight => _lightBackground;
  static Color get cardLight => _lightCard;
  static Color get borderLight => _lightBorder;
  static Color get foregroundLight => _lightForeground;
  static Color get mutedLight => _lightMuted;
  static Color get mutedForegroundLight => _lightMutedForeground;
  static Color get sidebarLight => _lightSidebar;
  static Color get sidebarForegroundLight => _lightSidebarForeground;
  static const sidebarPrimary = primary;
  static const sidebarPrimaryForeground = primaryForeground;
}

// Legacy compatibility class - use JuselColors methods with context instead
class JuselColorsLegacy {
  static const background = JuselColors._lightBackground;
  static const card = JuselColors._lightCard;
  static const border = JuselColors._lightBorder;
  static const foreground = JuselColors._lightForeground;
  static const muted = JuselColors._lightMuted;
  static const mutedForeground = JuselColors._lightMutedForeground;
  static const sidebar = JuselColors._lightSidebar;
  static const sidebarForeground = JuselColors._lightSidebarForeground;
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
///  TEXT STYLES (Inter) - Theme-aware
/// ------------------------------------------------------
class JuselTextStyles {
  static const fontFamily = "Inter";

  static TextStyle headlineLarge(BuildContext context) {
    return const TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ).copyWith(color: JuselColors.foreground(context));
  }

  static TextStyle headlineMedium(BuildContext context) {
    return const TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ).copyWith(color: JuselColors.foreground(context));
  }

  static TextStyle headlineSmall(BuildContext context) {
    return const TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ).copyWith(color: JuselColors.foreground(context));
  }

  static TextStyle bodyLarge(BuildContext context) {
    return const TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ).copyWith(color: JuselColors.foreground(context));
  }

  static TextStyle bodyMedium(BuildContext context) {
    return const TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ).copyWith(color: JuselColors.foreground(context));
  }

  static TextStyle bodySmall(BuildContext context) {
    return const TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ).copyWith(color: JuselColors.mutedForeground(context));
  }

}

// Legacy compatibility class - use JuselTextStyles methods with context instead
class JuselTextStylesLegacy {
  static const fontFamily = JuselTextStyles.fontFamily;
  
  static const headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: JuselColors._lightForeground,
  );
  static const headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: JuselColors._lightForeground,
  );
  static const headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: JuselColors._lightForeground,
  );
  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: JuselColors._lightForeground,
  );
  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: JuselColors._lightForeground,
  );
  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: JuselColors._lightMutedForeground,
  );
}

/// ------------------------------------------------------
///  LIGHT THEME DATA
/// ------------------------------------------------------
ThemeData juselLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: JuselTextStyles.fontFamily,

  scaffoldBackgroundColor: JuselColors._lightBackground,
  canvasColor: JuselColors._lightBackground,

  colorScheme: ColorScheme.light(
    brightness: Brightness.light,
    primary: JuselColors.primary,
    onPrimary: JuselColors.primaryForeground,
    secondary: JuselColors.secondary,
    onSecondary: JuselColors.secondaryForeground,
    error: JuselColors.destructive,
    onError: JuselColors.destructiveForeground,
    surface: JuselColors._lightCard,
    onSurface: JuselColors._lightForeground,
    surfaceContainerHighest: JuselColors._lightMuted,
    outline: JuselColors._lightBorder,
    outlineVariant: JuselColors._lightBorder.withOpacity(0.5),
  ),

  cardTheme: CardThemeData(
    color: JuselColors._lightCard,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black.withOpacity(0.12),
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: JuselColors._lightMuted,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: JuselColors._lightBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: JuselColors._lightBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: JuselColors.primary, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: JuselColors.destructive),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: JuselColors.destructive, width: 1.4),
    ),
  ),

  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: JuselColors._lightBackground,
    foregroundColor: JuselColors._lightForeground,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
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

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: const WidgetStatePropertyAll(JuselColors.primary),
      side: const WidgetStatePropertyAll(
        BorderSide(color: JuselColors.primary),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(JuselColors.primary),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: JuselColors._lightCard,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),

  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: JuselColors._lightCard,
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: JuselRadii.large),
    ),
  ),

  dividerTheme: DividerThemeData(
    color: JuselColors._lightBorder.withOpacity(0.5),
    thickness: 1,
    space: 1,
  ),

  listTileTheme: ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: JuselSpacing.s16,
      vertical: JuselSpacing.s8,
    ),
  ),
);

/// ------------------------------------------------------
///  DARK THEME DATA - Comprehensive dark theme
/// ------------------------------------------------------
ThemeData juselDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: JuselTextStyles.fontFamily,

  scaffoldBackgroundColor: JuselColors._darkBackground,
  canvasColor: JuselColors._darkBackground,

  colorScheme: ColorScheme.dark(
    brightness: Brightness.dark,
    primary: JuselColors.primaryDark,
    onPrimary: JuselColors.primaryForeground,
    secondary: JuselColors.secondaryDark,
    onSecondary: JuselColors.secondaryForeground,
    error: JuselColors.destructiveDark,
    onError: JuselColors.destructiveForeground,
    surface: JuselColors._darkCard,
    onSurface: JuselColors._darkForeground,
    surfaceContainerHighest: JuselColors._darkCardElevated,
    outline: JuselColors._darkBorder,
    outlineVariant: JuselColors._darkBorder.withOpacity(0.5),
  ),

  cardTheme: CardThemeData(
    color: JuselColors._darkCard,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black.withOpacity(0.4),
    elevation: 0, // Use subtle borders instead of elevation in dark
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(
        color: JuselColors._darkBorder.withOpacity(0.3),
        width: 1,
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: JuselColors._darkMuted,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: JuselColors._darkBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: JuselColors._darkBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: JuselColors.primaryDark,
        width: 1.4,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: JuselColors.destructiveDark),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: JuselColors.destructiveDark,
        width: 1.4,
      ),
    ),
  ),

  appBarTheme: AppBarTheme(
    elevation: 0,
    backgroundColor: JuselColors._darkBackground,
    foregroundColor: JuselColors._darkForeground,
    centerTitle: false,
    surfaceTintColor: Colors.transparent,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: const WidgetStatePropertyAll(JuselColors.primaryDark),
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

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: const WidgetStatePropertyAll(JuselColors.primaryDark),
      side: const WidgetStatePropertyAll(
        BorderSide(color: JuselColors.primaryDark),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: const WidgetStatePropertyAll(JuselColors.primaryDark),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: JuselColors._darkCard,
    surfaceTintColor: Colors.transparent,
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  ),

  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: JuselColors._darkCard,
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: JuselRadii.large),
    ),
  ),

  dividerTheme: DividerThemeData(
    color: JuselColors._darkBorder.withOpacity(0.5),
    thickness: 1,
    space: 1,
  ),

  listTileTheme: ListTileThemeData(
    contentPadding: const EdgeInsets.symmetric(
      horizontal: JuselSpacing.s16,
      vertical: JuselSpacing.s8,
    ),
  ),

  // Icon theme for better visibility in dark mode
  iconTheme: IconThemeData(
    color: JuselColors._darkForeground.withOpacity(0.9),
    size: 24,
  ),

  // Chip theme
  chipTheme: ChipThemeData(
    backgroundColor: JuselColors._darkCardElevated,
    selectedColor: JuselColors.primaryDark.withOpacity(0.2),
    labelStyle: TextStyle(color: JuselColors._darkForeground),
    secondaryLabelStyle: TextStyle(color: JuselColors._darkMutedForeground),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: JuselColors._darkBorder),
    ),
  ),
);
