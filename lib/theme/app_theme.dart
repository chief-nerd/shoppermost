import 'package:flutter/material.dart';

/// Central theme configuration for Shoppermost.
///
/// Usage:  `theme: AppTheme.light,  darkTheme: AppTheme.dark`
/// All colours, shapes, and component styles are defined here so every screen
/// picks them up automatically via `Theme.of(context)`.
class AppTheme {
  AppTheme._();

  // ── Brand colours ───────────────────────────────────────────────────────
  static const _primaryLight = Color(0xFF00B894);
  static const _primaryDark = Color(0xFF55EFC4);
  static const _secondary = Color(0xFFFF7675);
  static const _tertiary = Color(0xFFFDCB6E);

  // ── Neutral palette ─────────────────────────────────────────────────────
  static const _surfaceLight = Color(0xFFF8F9FD);
  static const _surfaceDark = Color(0xFF161622);
  static const _cardLight = Color(0xFFFFFFFF);
  static const _cardDark = Color(0xFF1E1E30);

  // ── Corner radius tokens ────────────────────────────────────────────────
  static const double radiusS = 12;
  static const double radiusM = 16;
  static const double radiusL = 24;
  static const double radiusXL = 32;

  // ── Shared shape ────────────────────────────────────────────────────────
  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radiusM),
  );

  // ═══════════════════════════════════════════════════════════════════════
  //  LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryLight,
      primary: _primaryLight,
      secondary: _secondary,
      tertiary: _tertiary,
      surface: _surfaceLight,
      brightness: Brightness.light,
    );

    return _buildTheme(colorScheme, _cardLight, Brightness.light);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  DARK THEME
  // ═══════════════════════════════════════════════════════════════════════
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryDark,
      primary: _primaryDark,
      secondary: _secondary,
      tertiary: _tertiary,
      surface: _surfaceDark,
      brightness: Brightness.dark,
    );

    return _buildTheme(colorScheme, _cardDark, Brightness.dark);
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  SHARED BUILDER
  // ═══════════════════════════════════════════════════════════════════════
  static ThemeData _buildTheme(
    ColorScheme cs,
    Color cardColor,
    Brightness brightness,
  ) {
    final isLight = brightness == Brightness.light;
    final onSurfaceVariant =
        isLight ? const Color(0xFF5F6368) : const Color(0xFFB0B3B8);
    final divider = isLight ? const Color(0xFFE8ECF1) : const Color(0xFF2C2C3E);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,

      // ── Typography ────────────────────────────────────────────────────
      textTheme: _textTheme(cs, onSurfaceVariant),

      // ── App bar ───────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'sans-serif',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
          letterSpacing: -0.5,
        ),
      ),

      // ── Cards ─────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: _shape,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ── Elevated buttons ──────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ── Filled buttons ────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ── Outlined buttons ──────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.error,
          side: BorderSide(color: cs.error.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text buttons ──────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusS),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Icon buttons ──────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: cs.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusS),
          ),
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
      ),

      // ── Input fields ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? const Color(0xFFF0F2F6) : const Color(0xFF252538),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusM),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        hintStyle: TextStyle(
          color: onSurfaceVariant.withValues(alpha: 0.6),
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── Dropdown menus ────────────────────────────────────────────────
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor:
              isLight ? const Color(0xFFF0F2F6) : const Color(0xFF252538),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusM),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      // ── Snack bars ────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusS),
        ),
        backgroundColor:
            isLight ? const Color(0xFF2D3436) : const Color(0xFFE0E0E0),
        contentTextStyle: TextStyle(
          color: isLight ? Colors.white : const Color(0xFF1A1A2E),
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Dialogs ───────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        backgroundColor: cardColor,
      ),

      // ── Bottom sheets ─────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        backgroundColor: cardColor,
        showDragHandle: true,
      ),

      // ── List tiles ────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),

      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      // ── Progress indicators ───────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
      ),

      // ── Chips ─────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusS),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  TYPOGRAPHY
  // ═══════════════════════════════════════════════════════════════════════
  static TextTheme _textTheme(ColorScheme cs, Color secondary) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: cs.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: cs.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: cs.onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: cs.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: cs.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondary,
      ),
    );
  }
}
