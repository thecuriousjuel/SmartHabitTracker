import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  /// Applies Inter text theme to any ThemeData. Preserves custom titleTextStyle
  /// on AppBarTheme by only overriding font family, not the colour/weight set
  /// per theme.
  static ThemeData _withInter(ThemeData base) {
    final interTextTheme = GoogleFonts.interTextTheme(base.textTheme);
    return base.copyWith(
      textTheme: interTextTheme,
      primaryTextTheme: GoogleFonts.interTextTheme(base.primaryTextTheme),
      // Preserve per-theme AppBar title style but apply Inter font family
      appBarTheme: base.appBarTheme.titleTextStyle != null
          ? base.appBarTheme.copyWith(
              titleTextStyle: GoogleFonts.inter(
                textStyle: base.appBarTheme.titleTextStyle,
              ),
            )
          : base.appBarTheme,
    );
  }

  // 1. Dark Charcoal
  static ThemeData get darkGreyTheme {
    return _withInter(ThemeData(
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
    ));
  }

  // 2. Dark Blue/Purple
  static ThemeData get darkPurpleTheme {
    return _withInter(ThemeData(
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
    ));
  }

  // 3. Light White
  static ThemeData get lightWhiteTheme {
    return _withInter(ThemeData(
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
    ));
  }

  // 4. Light Green
  static ThemeData get lightGreenTheme {
    return _withInter(ThemeData(
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
    ));
  }

  // 5. Neon Dark
  static ThemeData get neonDarkTheme {
    return _withInter(ThemeData(
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
        primary: const Color(0xFF00FFFF),
        secondary: const Color(0xFFFF007F),
        surface: const Color(0xFF100F15),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF100F15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ));
  }

  // 6. Neon Light
  static ThemeData get neonLightTheme {
    return _withInter(ThemeData(
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
        primary: const Color(0xFFE0007A),
        secondary: const Color(0xFFFF5E00),
        surface: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ));
  }

  // 7. Dark Glassmorphism
  static ThemeData get glassTheme {
    return _withInter(ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.06),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.12), width: 1.0),
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFFBB86FC),
        secondary: Colors.cyanAccent,
        surface: Colors.white.withOpacity(0.04),
        onSurface: Colors.white,
        outlineVariant: Colors.white.withOpacity(0.1),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1C2E).withOpacity(0.85),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.15), width: 1.0),
        ),
      ),
    ));
  }

  // 8. Light Glassmorphism
  static ThemeData get lightGlassTheme {
    return _withInter(ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1E1C2E)),
        titleTextStyle: TextStyle(color: Color(0xFF1E1C2E), fontSize: 20, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.4),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 1.0),
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF8E24AA),
        secondary: const Color(0xFF00ACC1),
        surface: Colors.white.withValues(alpha: 0.3),
        onSurface: const Color(0xFF1E1C2E),
        outlineVariant: Colors.black.withValues(alpha: 0.08),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFFF5F5FA).withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.7), width: 1.0),
        ),
      ),
    ));
  }

  // 9. Funky 3D Light
  static ThemeData get funkyLightTheme {
    return _withInter(ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF3F0FF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w900),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 2.5),
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF007F),
        secondary: Color(0xFF00C8FF),
        surface: Colors.white,
        onSurface: Colors.black,
        outlineVariant: Colors.black,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.black, width: 2.5),
        ),
      ),
    ));
  }

  // 10. Funky 3D Dark
  static ThemeData get funkyDarkTheme {
    return _withInter(ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0C071A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1735),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white, width: 2.0),
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF00FF),
        secondary: Color(0xFF00FFCC),
        surface: Color(0xFF1E1735),
        onSurface: Colors.white,
        outlineVariant: Colors.white,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF130E26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white, width: 2.0),
        ),
      ),
    ));
  }
}
