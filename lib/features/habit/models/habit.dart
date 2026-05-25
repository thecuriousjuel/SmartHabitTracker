import 'package:flutter/material.dart';

// Generated Habit model is loaded from Drift database
export '../../../core/storage/app_database.dart' show Habit;

/// Helper function to resolve icon codepoints to constant IconData.
/// This prevents dynamic IconData instantiation, allowing release builds
/// to run Icon Tree Shaking successfully.
IconData getHabitIcon(int codePoint) {
  const icons = [
    Icons.directions_run,
    Icons.book,
    Icons.code,
    Icons.fitness_center,
    Icons.local_cafe,
    Icons.water_drop,
    Icons.self_improvement, // Meditation
    Icons.smoke_free,
    Icons.bed,
    Icons.music_note,
    Icons.brush,
    Icons.pets,
    Icons.menu_book,
    Icons.alarm,
    Icons.savings,
  ];

  for (final icon in icons) {
    if (icon.codePoint == codePoint) {
      return icon;
    }
  }
  return Icons.star; // Fallback icon
}

bool isEmojiCodePoint(int codePoint) {
  // If it falls back to star and it's not actually the star icon code point, it is an emoji!
  return getHabitIcon(codePoint) == Icons.star && codePoint != Icons.star.codePoint;
}

Widget buildHabitIconWidget(int codePoint, {required Color color, double size = 20}) {
  if (isEmojiCodePoint(codePoint)) {
    return Center(
      child: Text(
        String.fromCharCode(codePoint),
        style: TextStyle(
          fontSize: size * 0.85,
          height: 1.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  } else {
    return Icon(
      getHabitIcon(codePoint),
      color: color,
      size: size,
    );
  }
}
