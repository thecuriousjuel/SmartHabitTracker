import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/habits_provider.dart';
import '../models/habit.dart';

class WeeklyViewPage extends StatelessWidget {
  const WeeklyViewPage({super.key});

  List<DateTime> _getCurrentWeekDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Find the Monday of the current week
    // ISO-8601: Monday is 1, Sunday is 7
    final daysToSubtract = today.weekday - 1;
    final monday = today.subtract(Duration(days: daysToSubtract));

    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  String _getWeekdayAbbreviation(int weekday) {
    const abbrev = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return abbrev[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitsNotifier>(context);
    final theme = Theme.of(context);
    final habits = provider.ongoingHabits;

    final weekDays = _getCurrentWeekDays();
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly View', style: TextStyle(fontWeight: FontWeight.bold)),
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
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Habit Name spacing | Mon | Tue | Wed | Thu | Fri | Sat | Sun
                      Row(
                        children: [
                          const Expanded(
                            flex: 3,
                            child: Text(
                              'Habit',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          ...weekDays.map((day) {
                            final isToday = day.year == todayMidnight.year &&
                                day.month == todayMidnight.month &&
                                day.day == todayMidnight.day;
                            return Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    _getWeekdayAbbreviation(day.weekday),
                                    style: TextStyle(
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                      color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                      color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                      const Divider(height: 24),
                      // Habit rows
                      ListView.separated(
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

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                // Habit Header
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      Icon(
                                        getHabitIcon(habit.iconCodePoint),
                                        color: activeColor,
                                        size: 20,
                                      ),
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
                                // 7 Day cells
                                ...weekDays.map((day) {
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

                                  return Expanded(
                                    child: Center(
                                      child: InkWell(
                                        onTap: canToggle
                                            ? () => provider.toggleCompletion(habit.id, day)
                                            : null,
                                        borderRadius: BorderRadius.circular(100),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: cellColor,
                                            shape: BoxShape.circle,
                                            border: isFuture || isOutOfRange
                                                ? Border.all(
                                                    color: theme.colorScheme.onSurface.withOpacity(0.1),
                                                    width: 1,
                                                    style: BorderStyle.solid,
                                                  )
                                                : null,
                                          ),
                                          alignment: Alignment.center,
                                          child: isCompleted
                                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                                              : (isFuture || isOutOfRange
                                                  ? Icon(
                                                      Icons.block,
                                                      size: 14,
                                                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                                                    )
                                                  : null),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
