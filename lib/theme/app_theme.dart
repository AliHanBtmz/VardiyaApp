import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primary = Color(0xFFD34E4E); // Red
  static const Color _background = Color(0xFFF9E7B2); // Light Yellow
  static const Color _secondary = Color(0xFFCE7E5A); // Orange
  static const Color _tertiary = Color(0xFFDDC57A); // Gold
  static const Color _error = Color(0xFFB00020);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: _primary,
        onPrimary: _background,
        primaryContainer: _primary.withOpacity(0.8),
        onPrimaryContainer: _background,
        secondary: _secondary,
        onSecondary: _background,
        secondaryContainer: _secondary.withOpacity(0.8),
        onSecondaryContainer: _background,
        tertiary: _tertiary,
        onTertiary: _primary,
        error: _error,
        onError: Colors.grey.shade200,
        errorContainer: const Color(0xFFF9DEDC), // Light Red for container
        onErrorContainer: const Color(0xFF410002), // Dark Red for text on container
        surface: _background,
        onSurface: _primary,
        surfaceContainer: Colors.grey.withOpacity(0.8),
        onSurfaceVariant: _primary,
        outline: _secondary,
      ),
      scaffoldBackgroundColor: _background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: _primary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: _primary),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black12,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: _background,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _background,
        elevation: 8,
        titleTextStyle: const TextStyle(
          color: _primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: _primary,
          fontSize: 16,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade200,
        labelStyle: TextStyle(color: _primary.withOpacity(0.8)),
        hintStyle: TextStyle(color: _primary.withOpacity(0.5)),
        prefixIconColor: _primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primary.withOpacity(0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      iconTheme: const IconThemeData(
        color: _primary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _primary,
        contentTextStyle: TextStyle(color: _background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
