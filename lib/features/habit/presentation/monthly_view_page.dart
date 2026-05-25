import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/habits_provider.dart';
import '../models/habit.dart';
import 'ambient_glow_wrapper.dart';
import 'glass_wrapper.dart';
import 'pulsing_cell_border.dart';

class MonthlyViewPage extends StatelessWidget {
  const MonthlyViewPage({super.key});

  List<DateTime> _getCurrentMonthDays() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return List.generate(daysInMonth, (i) => DateTime(now.year, now.month, i + 1));
  }

  String _getMonthName(int monthNum) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[monthNum - 1];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitsNotifier>(context);
    final theme = Theme.of(context);
    final habits = provider.ongoingHabits;

    final monthDays = _getCurrentMonthDays();
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final currentMonthName = _getMonthName(now.month);

    final isNeon = provider.themeMode == 4 || provider.themeMode == 5;
    final isDarkNeon = provider.themeMode == 4;
    final isGlass = provider.themeMode == 6;

    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly View - $currentMonthName ${now.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: habits.isEmpty
          ? const Center(
              child: Text(
                'No ongoing habits to display. Create a habit to get started!',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: AmbientGlowWrapper(
                enabled: isNeon,
                isDark: isDarkNeon,
                child: GlassWrapper(
                  enabled: isGlass,
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: isGlass ? 0 : null,
                    color: isGlass ? Colors.transparent : null,
                    shape: isGlass ? const RoundedRectangleBorder(side: BorderSide.none) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: Habit title (width 180) + Day numbers
                        Row(
                          children: [
                            const SizedBox(
                              width: 180,
                              child: Text(
                                'Habits',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            ...monthDays.map((day) {
                              final isToday = day.year == todayMidnight.year &&
                                  day.month == todayMidnight.month &&
                                  day.day == todayMidnight.day;
                              return Container(
                                width: 38,
                                alignment: Alignment.center,
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                    color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const Divider(height: 24),
                        // List of habit rows
                        SizedBox(
                          width: 180 + (monthDays.length * 38.0),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: habits.length,
                            separatorBuilder: (ctx, idx) => const Divider(),
                            itemBuilder: (ctx, idx) {
                              final habit = habits[idx];
                              final activeColor = Color(habit.colorHex);
                              final normStart = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
                              final normEnd = habit.endDate != null
                                  ? DateTime(habit.endDate!.year, habit.endDate!.month, habit.endDate!.day)
                                  : null;

                              return Row(
                                children: [
                                  // Habit header details
                                  SizedBox(
                                    width: 180,
                                    child: Row(
                                      children: [
                                        buildHabitIconWidget(habit.iconCodePoint, color: activeColor, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            habit.name,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Month cells
                                  ...monthDays.map((day) {
                                    final isFuture = day.isAfter(todayMidnight);
                                    final isCompleted = provider.isCompleted(habit.id, day);
                                    final isBeforeStart = !habit.isLifelong && day.isBefore(normStart);
                                    final isAfterEnd = normEnd != null && day.isAfter(normEnd);
                                    final isOutOfRange = isBeforeStart || isAfterEnd;

                                    final canToggle = !isFuture && !isOutOfRange;

                                    Color? cellColor;
                                    if (isCompleted) {
                                      cellColor = activeColor;
                                    } else if (isOutOfRange || isFuture) {
                                      cellColor = Colors.transparent;
                                    } else {
                                      cellColor = theme.brightness == Brightness.dark
                                          ? const Color(0xFF2D2D2D)
                                          : const Color(0xFFE0E0E0);
                                    }

                                    final isToday = day.year == todayMidnight.year &&
                                        day.month == todayMidnight.month &&
                                        day.day == todayMidnight.day;
                                    final shouldPulse = isToday && !isCompleted && !isOutOfRange;

                                    final isFunky = provider.themeMode == 8 || provider.themeMode == 9;
                                    final isDarkFunky = provider.themeMode == 9;
                                    Widget cellWidget = AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: cellColor,
                                        shape: BoxShape.rectangle,
                                        borderRadius: isFunky ? BorderRadius.circular(6) : BorderRadius.circular(14),
                                        border: isFuture || isOutOfRange
                                            ? Border.all(
                                                color: theme.colorScheme.onSurface.withOpacity(0.1),
                                                width: 1,
                                              )
                                            : (isFunky
                                                ? Border.all(
                                                    color: isDarkFunky ? Colors.white : Colors.black,
                                                    width: 2,
                                                  )
                                                : null),
                                        boxShadow: isFunky && !isFuture && !isOutOfRange
                                            ? [
                                                BoxShadow(
                                                  color: isDarkFunky ? Colors.black : Colors.black.withOpacity(0.25),
                                                  offset: const Offset(2, 2),
                                                  blurRadius: 0,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: isCompleted
                                          ? Icon(Icons.check, color: isDarkFunky ? Colors.black : Colors.white, size: 14)
                                          : (isFuture || isOutOfRange
                                              ? Icon(
                                                  Icons.block,
                                                  size: 12,
                                                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                                                )
                                              : null),
                                    );

                                     if (shouldPulse) {
                                       cellWidget = PulsingCellBorder(
                                         color: activeColor,
                                         shape: BoxShape.rectangle,
                                         borderRadius: isFunky ? BorderRadius.circular(6) : BorderRadius.circular(14),
                                         child: cellWidget,
                                       );
                                     }

                                    return Container(
                                      width: 38,
                                      alignment: Alignment.center,
                                      child: InkWell(
                                        onTap: canToggle
                                            ? () => provider.toggleCompletion(habit.id, day)
                                            : null,
                                        borderRadius: isFunky ? BorderRadius.circular(6) : BorderRadius.circular(100),
                                        child: cellWidget,
                                      ),
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ),
    );
  }
}
