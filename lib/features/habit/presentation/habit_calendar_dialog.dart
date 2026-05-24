import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/habits_provider.dart';
import '../models/habit.dart';

class HabitCalendarDialog extends StatefulWidget {
  final Habit habit;

  const HabitCalendarDialog({super.key, required this.habit});

  @override
  State<HabitCalendarDialog> createState() => _HabitCalendarDialogState();
}

class _HabitCalendarDialogState extends State<HabitCalendarDialog> {
  late DateTime _currentMonth;

  static const List<String> _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitsNotifier>(context);
    final theme = Theme.of(context);
    final activeColor = Color(widget.habit.colorHex);

    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final offset = firstDayOfMonth.weekday % 7; // Sunday is index 0
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final totalCells = ((offset + daysInMonth) / 7).ceil() * 7;

    final monthName = _getMonthName(_currentMonth.month);
    final year = _currentMonth.year;

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    final normStart = DateTime(widget.habit.startDate.year, widget.habit.startDate.month, widget.habit.startDate.day);
    final normEnd = widget.habit.endDate != null
        ? DateTime(widget.habit.endDate!.year, widget.habit.endDate!.month, widget.habit.endDate!.day)
        : null;

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  getHabitIcon(widget.habit.iconCodePoint),
                  color: activeColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.habit.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Calendar Navigator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevMonth,
                ),
                Text(
                  '$monthName $year',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Days Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekdays.map((d) {
                return SizedBox(
                  width: 32,
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // Calendar Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: totalCells,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final indexInMonth = index - offset;
                if (indexInMonth < 0 || indexInMonth >= daysInMonth) {
                  return const SizedBox.shrink();
                }

                final dayNum = indexInMonth + 1;
                final cellDate = DateTime(_currentMonth.year, _currentMonth.month, dayNum);

                final isFuture = cellDate.isAfter(todayMidnight);
                final isCompleted = provider.isCompleted(widget.habit.id, cellDate);
                final isBeforeStart = !widget.habit.isLifelong && cellDate.isBefore(normStart);
                final isAfterEnd = normEnd != null && cellDate.isAfter(normEnd);
                final isOutOfRange = isBeforeStart || isAfterEnd;

                final isToday = cellDate.year == todayMidnight.year &&
                    cellDate.month == todayMidnight.month &&
                    cellDate.day == todayMidnight.day;

                Color? bgColor;
                Color textColor = theme.colorScheme.onSurface;

                if (isCompleted) {
                  bgColor = activeColor;
                  textColor = Colors.white;
                } else if (isOutOfRange || isFuture) {
                  textColor = theme.colorScheme.onSurface.withOpacity(0.25);
                } else if (isToday) {
                  bgColor = theme.colorScheme.primaryContainer;
                }

                final canToggle = !isFuture && !isOutOfRange;

                return InkWell(
                  onTap: canToggle
                      ? () {
                          provider.toggleCompletion(widget.habit.id, cellDate);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      border: isToday && !isCompleted
                          ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$dayNum',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: isToday || isCompleted ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month - 1];
  }
}
