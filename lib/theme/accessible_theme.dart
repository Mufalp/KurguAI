import 'package:flutter/material.dart';

class AccessibleTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF005A9C), // High contrast blue
        secondary: Color(0xFFC73A00), // High contrast deep orange
        surface: Color(0xFFFFFFFF),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF121212), // Almost black for text
        error: Color(0xFFB00020),
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, color: Color(0xFF121212), height: 1.5),
        bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF121212), height: 1.5),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF005A9C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF005A9C),
          foregroundColor: Colors.white,
          minimumSize: const Size(88, 48), // WCAG Large touch targets (44x44 min)
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF121212), width: 1.5), // high contrast border
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF121212), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF005A9C), width: 2.0),
        ),
        labelStyle: TextStyle(color: Color(0xFF121212)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00E5FF), // Vibrant Cyan
        secondary: Color(0xFFB388FF), // Vibrant Purple
        surface: Color(0xFF1E293B), // Slate 800 for cards
        onPrimary: Color(0xFF0F172A), // Dark text on cyan buttons
        onSecondary: Color(0xFF0F172A),
        onSurface: Color(0xFFF8FAFC), // Slate 50 for text
        error: Color(0xFFFF5252),
        onError: Color(0xFF0F172A),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, color: Color(0xFFF8FAFC), height: 1.5, letterSpacing: 0.3),
        bodyMedium: TextStyle(fontSize: 16, color: Color(0xFFCBD5E1), height: 1.5),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFF8FAFC), letterSpacing: 0.5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Color(0xFF00E5FF),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 1), // Subtle border
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E5FF),
          foregroundColor: const Color(0xFF0F172A),
          minimumSize: const Size(88, 54), // WCAG Large touch targets
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF00E5FF),
        foregroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 2.0),
        ),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
