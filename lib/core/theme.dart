import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Colors ──
  static const Color primary = Color(0xFFffc66b);
  static const Color accent = Color(0xFFe8a838); // Primary Amber
  static const Color accentSoft = Color(0x4De8a838); // 30% opacity amber
  static const Color background = Color(0xFF18130b); // 'True Black' foundation
  static const Color surface = Color(0xFF201b13); 
  static const Color surfaceLight = Color(0xFF241f17);
  static const Color surfaceVariant = Color(0xFF2f2921);
  static const Color glassSurface = Color(0xBF121212); // 75% opacity dark fill for Glassmorphism
  static const Color onBackground = Color(0xFFede1d4);
  static const Color onBackgroundMuted = Color(0xFFd5c4af);
  static const Color textPrimary = Color(0xFFede1d4);
  static const Color textSecondary = Color(0xFFd5c4af);
  static const Color textMuted = Color(0xFF9d8e7c);
  static const Color error = Color(0xFFffb4ab);
  static const Color success = Color(0xFF2ECC71);
  static const Color divider = Color(0xFF3a342b);
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color shutterWhite = Color(0xFFFFFFFF);

  // ── Spacing ──
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0; // Margin page
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // ── Border Radius ──
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXl = 20.0; // Buttons
  static const double radius2xl = 24.0; // Cards/Docks
  static const double radius3xl = 32.0; // Bottom sheets
  static const double radiusFull = 999.0; // Pills/Chips

  // ── Text Styles ──
  static const TextStyle displayLg = TextStyle(
    fontFamily: 'Inter',
    color: onBackground,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.64,
    height: 40 / 32,
  );

  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'Inter',
    color: onBackground,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.24,
    height: 32 / 24,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'Inter',
    color: onBackground,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Inter',
    color: onBackground,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Inter',
    color: textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: 'Inter',
    color: onBackground,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6, // 0.05em
    height: 16 / 12,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: 'Inter',
    color: textMuted,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2, // 0.02em
    height: 14 / 10,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Inter',
    color: background,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle brandText = TextStyle(
    fontFamily: 'PlayfairDisplay',
    color: onBackground,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
  );

  static const TextStyle presetLabel = TextStyle(
    fontFamily: 'Inter',
    color: onBackground,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
  );

  // ── ThemeData ──
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: background,
        onSecondary: background,
        onSurface: textPrimary,
        onError: background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headingMedium,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        headlineLarge: displayLg,
        headlineMedium: headingLarge,
        titleLarge: headingMedium,
        titleMedium: bodyLarge,
        bodyLarge: bodyLarge,
        bodyMedium: bodySmall,
        bodySmall: labelLg,
        labelLarge: labelLg,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl), // 20px
          ),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: divider),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusXl),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: textPrimary, size: 24),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1.0),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius3xl)),
        ),
      ),
    );
  }
}
