import 'package:flutter/material.dart';

class GitHubGrid extends StatelessWidget {
  final Color activeColor;
  final List<DateTime> completedDates;
  final DateTime habitStartDate;
  final DateTime? habitEndDate;

  const GitHubGrid({
    super.key,
    required this.activeColor,
    required this.completedDates,
    required this.habitStartDate,
    this.habitEndDate,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Go back 364 days (approx 52 weeks)
    final firstDay = today.subtract(const Duration(days: 364));
    // Align starting date of the grid to Sunday
    final startSunday = firstDay.subtract(Duration(days: firstDay.weekday % 7));

    // Normalizing start/end dates to midnight for accurate comparison
    final normStart = DateTime(habitStartDate.year, habitStartDate.month, habitStartDate.day);
    final normEnd = habitEndDate != null
        ? DateTime(habitEndDate!.year, habitEndDate!.month, habitEndDate!.day)
        : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? const Color(0xFF3E3E42) : const Color(0xFFCCCCCC);
    final outOfBoundsColor = isDark ? const Color(0xFF1B1B20) : const Color(0xFFF5F5F5);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Grid spacing of 2px
        const double spacing = 2.0;
        
        // Calculate cell size, with a fallback constraint limit between 3.0 and 11.0 to cover horizontal width
        final double squareSize = ((constraints.maxWidth - (52 * spacing)) / 53).clamp(3.0, 11.0);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(53, (col) {
            return Padding(
              padding: const EdgeInsets.only(right: spacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(7, (row) {
                  final cellDate = startSunday.add(Duration(days: col * 7 + row));

                  final isFuture = cellDate.isAfter(today);
                  final isCompleted = completedDates.any((d) =>
                      d.year == cellDate.year &&
                      d.month == cellDate.month &&
                      d.day == cellDate.day);

                  final isBeforeStart = cellDate.isBefore(normStart);
                  final isAfterEnd = normEnd != null && cellDate.isAfter(normEnd);
                  final isStartDate = cellDate.year == normStart.year &&
                      cellDate.month == normStart.month &&
                      cellDate.day == normStart.day;

                  Color color = inactiveColor;
                  if (isFuture) {
                    color = Colors.transparent; // Future dates are hidden
                  } else if (isCompleted) {
                    color = activeColor;
                  } else if (isStartDate) {
                    // Highlight when the habit was created with a subtle light tint
                    color = activeColor.withValues(alpha: 0.25);
                  } else if (isBeforeStart || isAfterEnd) {
                    color = outOfBoundsColor; // Days before habit start or after end
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: spacing),
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }
}
