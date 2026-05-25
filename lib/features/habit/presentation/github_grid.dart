import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_habit_tracker/features/habit/presentation/pulsing_cell_border.dart';
import '../provider/habits_provider.dart';

class GitHubGrid extends StatefulWidget {
  final Color activeColor;
  final List<DateTime> completedDates;
  final DateTime habitStartDate;
  final DateTime? habitEndDate;
  /// When true the grid scrolls to the rightmost (most recent) column on first render.
  final bool autoScrollToEnd;

  const GitHubGrid({
    super.key,
    required this.activeColor,
    required this.completedDates,
    required this.habitStartDate,
    this.habitEndDate,
    this.autoScrollToEnd = false,
  });

  @override
  State<GitHubGrid> createState() => _GitHubGridState();
}

class _GitHubGridState extends State<GitHubGrid> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.autoScrollToEnd) {
      // Jump to the end after the first frame so the most recent weeks are visible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Go back 364 days (approx 52 weeks)
    final firstDay = today.subtract(const Duration(days: 364));
    // Align starting date of the grid to Sunday
    final startSunday = firstDay.subtract(Duration(days: firstDay.weekday % 7));

    // Normalizing start/end dates to midnight for accurate comparison
    final normStart = DateTime(widget.habitStartDate.year, widget.habitStartDate.month, widget.habitStartDate.day);
    final normEnd = widget.habitEndDate != null
        ? DateTime(widget.habitEndDate!.year, widget.habitEndDate!.month, widget.habitEndDate!.day)
        : null;

    final provider = Provider.of<HabitsNotifier>(context, listen: false);
    final themeMode = provider.themeMode;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color inactiveColor;
    Color outOfBoundsColor;

    if (themeMode == 0) {
      inactiveColor = const Color(0xFF55555C);
      outOfBoundsColor = const Color(0xFF2C2C30);
    } else if (themeMode == 1) {
      inactiveColor = const Color(0xFF4B466D);
      outOfBoundsColor = const Color(0xFF231F3F);
    } else if (themeMode == 6) {
      inactiveColor = Colors.white.withValues(alpha: 0.22);
      outOfBoundsColor = Colors.white.withValues(alpha: 0.06);
    } else if (themeMode == 7) {
      inactiveColor = Colors.black.withValues(alpha: 0.18);
      outOfBoundsColor = Colors.black.withValues(alpha: 0.05);
    } else if (themeMode == 8) {
      inactiveColor = const Color(0xFFE8E4FF);
      outOfBoundsColor = const Color(0xFFF3F0FF).withOpacity(0.5);
    } else if (themeMode == 9) {
      inactiveColor = const Color(0xFF1B1530);
      outOfBoundsColor = const Color(0xFF0C071A).withOpacity(0.5);
    } else {
      inactiveColor = isDark ? const Color(0xFF3E3E42) : const Color(0xFFCCCCCC);
      outOfBoundsColor = isDark ? const Color(0xFF1B1B20) : const Color(0xFFF5F5F5);
    }

    final isFunky = themeMode == 8 || themeMode == 9;
    final isDarkFunky = themeMode == 9;

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 2.0;
        final double squareSize = ((constraints.maxWidth - (52 * spacing)) / 53).clamp(3.0, 11.0);

        final gridWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(53, (col) {
            return Padding(
              padding: const EdgeInsets.only(right: spacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(7, (row) {
                  final cellDate = startSunday.add(Duration(days: col * 7 + row));

                  final isFuture = cellDate.isAfter(today);
                  final isCompleted = widget.completedDates.any((d) =>
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
                    color = Colors.transparent;
                  } else if (isCompleted) {
                    color = widget.activeColor;
                  } else if (isStartDate) {
                    color = widget.activeColor.withValues(alpha: 0.25);
                  } else if (isBeforeStart || isAfterEnd) {
                    color = outOfBoundsColor;
                  }

                  final isToday = cellDate.year == today.year &&
                      cellDate.month == today.month &&
                      cellDate.day == today.day;
                  final shouldPulse = isToday && !isCompleted && !isBeforeStart && !isAfterEnd;

                  Widget cellWidget = Container(
                    margin: EdgeInsets.only(bottom: spacing, right: isFunky ? spacing * 0.5 : 0),
                    width: isFunky ? squareSize * 1.3 : squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: isFunky ? BorderRadius.circular(2.0) : BorderRadius.circular(1.5),
                      border: isFunky && !isFuture
                          ? Border.all(
                              color: isDarkFunky
                                  ? (isCompleted ? Colors.white : Colors.white.withOpacity(0.2))
                                  : (isCompleted ? Colors.black : Colors.black.withOpacity(0.3)),
                              width: 1.0,
                            )
                          : null,
                    ),
                  );

                  if (shouldPulse) {
                    cellWidget = PulsingCellBorder(
                      color: widget.activeColor,
                      shape: isFunky ? BoxShape.rectangle : BoxShape.circle,
                      borderRadius: isFunky ? BorderRadius.circular(2.0) : BorderRadius.circular(1.5),
                      child: cellWidget,
                    );
                  }

                  return cellWidget;
                }),
              ),
            );
          }),
        );

        // For Funky themes use the scroll controller so we can auto-jump to the end.
        // For other themes keep the existing plain SingleChildScrollView behaviour.
        if (widget.autoScrollToEnd) {
          return SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: gridWidget,
          );
        }

        return gridWidget;
      },
    );
  }
}
