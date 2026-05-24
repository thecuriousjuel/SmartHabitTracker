import 'package:flutter/material.dart';

class AppTheme {
  // Theme Modes (4 Options)
  // 1. Dark mode with black/grey theme
  static ThemeData get darkGreyTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      colorScheme: ColorScheme.dark(
        primary: Colors.grey[300]!,
        secondary: Colors.grey[600]!,
        surface: const Color(0xFF1E1E1E),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  // 2. Dark mode with blue/purple theme
  static ThemeData get darkPurpleTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F0C1B),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1633),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFFBB86FC),
        secondary: Colors.blueAccent,
        surface: const Color(0xFF1A1633),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1A1633),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  // 3. Light mode with white theme
  static ThemeData get lightWhiteTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      colorScheme: ColorScheme.light(
        primary: Colors.blue[700]!,
        secondary: Colors.blueAccent,
        surface: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  // 4. Light mode with a greenish theme
  static ThemeData get lightGreenTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF1F6F4),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.teal.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      colorScheme: ColorScheme.light(
        primary: Colors.teal[700]!,
        secondary: Colors.tealAccent[700]!,
        surface: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  // 5. Neon Dark Theme
  static ThemeData get neonDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF08070A),
      cardTheme: CardThemeData(
        color: const Color(0xFF100F15),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2C194D), width: 1),
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF00FFFF), // Neon Cyan
        secondary: const Color(0xFFFF007F), // Neon Pink
        surface: const Color(0xFF100F15),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF100F15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  // 6. Neon Light Theme
  static ThemeData get neonLightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFFCFCFD),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: const Color(0xFFE0007A).withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFCE3EE), width: 1),
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFE0007A), // Neon Magenta
        secondary: const Color(0xFFFF5E00), // Neon Orange
        surface: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
