import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/habits_provider.dart';
import '../models/habit.dart';
import 'ambient_glow_wrapper.dart';
import 'glass_wrapper.dart';
import 'pulsing_cell_border.dart';

class YearlyViewPage extends StatefulWidget {
  const YearlyViewPage({super.key});

  @override
  State<YearlyViewPage> createState() => _YearlyViewPageState();
}

class _YearlyViewPageState extends State<YearlyViewPage> {
  int? _selectedHabitId;

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  
  static const List<String> _fullMonthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String _formatTooltipDate(DateTime date) {
    final weekdayStr = _weekdays[date.weekday - 1];
    final monthStr = _fullMonthNames[date.month - 1];
    return '$weekdayStr, $monthStr ${date.day}, ${date.year}';
  }

  // Returns the number of days in a given month of a year
  int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitsNotifier>(context);
    final theme = Theme.of(context);
    final habits = provider.ongoingHabits;

    final isNeon = provider.themeMode == 4 || provider.themeMode == 5;
    final isDarkNeon = provider.themeMode == 4;
    final isGlass = provider.themeMode == 6 || provider.themeMode == 7;
    final isDarkGlass = provider.themeMode == 6;
    final isFunky = provider.themeMode == 8 || provider.themeMode == 9;
    final isDarkFunky = provider.themeMode == 9;

    // Auto-select first habit when habits load for the first time
    if (_selectedHabitId == null && habits.isNotEmpty) {
      _selectedHabitId = habits.first.id;
    }

    final selectedHabit = habits.isEmpty
        ? null
        : habits.cast<Habit?>().firstWhere(
            (h) => h!.id == _selectedHabitId,
            orElse: () => habits.first,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yearly View',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: habits.isEmpty
          ? const Center(
              child: Text(
                'No ongoing habits to display. Create a habit to get started!',
                style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left Panel: Habit Selector ──────────────────────────────
                Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: isGlass
                        ? (isDarkGlass
                            ? Colors.black.withValues(alpha: 0.12)
                            : Colors.white.withValues(alpha: 0.25))
                        : (theme.brightness == Brightness.dark
                            ? const Color(0xFF18181A)
                            : const Color(0xFFF1F3F5)),
                    border: Border(
                      right: BorderSide(
                        color: isGlass
                            ? (isDarkGlass
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.05))
                            : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Text(
                          'HABITS',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: habits.length,
                          itemBuilder: (ctx, idx) {
                            final habit = habits[idx];
                            final activeColor = Color(habit.colorHex);
                            final isSelected = habit.id == (selectedHabit?.id);

                            return InkWell(
                              onTap: () => setState(() => _selectedHabitId = habit.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? activeColor.withValues(alpha: 0.15)
                                      : Colors.transparent,
                                  borderRadius: isFunky
                                      ? BorderRadius.circular(4)
                                      : BorderRadius.circular(12),
                                  border: isFunky
                                      ? Border.all(
                                          color: isSelected
                                              ? (isDarkFunky ? Colors.white : Colors.black)
                                              : Colors.transparent,
                                          width: 2,
                                        )
                                      : (isSelected
                                          ? Border.all(color: activeColor.withValues(alpha: 0.4), width: 1.5)
                                          : null),
                                  boxShadow: isFunky && isSelected
                                      ? [
                                          BoxShadow(
                                            color: isDarkFunky
                                                ? Colors.black
                                                : Colors.black.withOpacity(0.2),
                                            offset: const Offset(3, 3),
                                            blurRadius: 0,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    buildHabitIconWidget(
                                      habit.iconCodePoint,
                                      color: activeColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        habit.name,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected
                                              ? activeColor
                                              : theme.colorScheme.onSurface,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.chevron_right, size: 16, color: activeColor),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Right Panel: Yearly History ──────────────────────────────
                Expanded(
                  child: selectedHabit == null
                      ? const Center(
                          child: Text(
                            'Select a habit to view its yearly history.',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        )
                      : _buildYearlyPanel(
                          context,
                          provider,
                          theme,
                          selectedHabit,
                          isNeon: isNeon,
                          isDarkNeon: isDarkNeon,
                          isGlass: isGlass,
                          isFunky: isFunky,
                          isDarkFunky: isDarkFunky,
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildYearlyPanel(
    BuildContext context,
    HabitsNotifier provider,
    ThemeData theme,
    Habit habit, {
    required bool isNeon,
    required bool isDarkNeon,
    required bool isGlass,
    required bool isFunky,
    required bool isDarkFunky,
  }) {
    final now = DateTime.now();
    final currentYear = now.year;
    final activeColor = Color(habit.colorHex);
    final completedDates = provider.getCompletedDates(habit.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Habit header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.12),
                  borderRadius: isFunky ? BorderRadius.circular(6) : BorderRadius.circular(12),
                  border: isFunky
                      ? Border.all(color: isDarkFunky ? Colors.white : Colors.black, width: 2)
                      : Border.all(color: activeColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Center(
                  child: buildHabitIconWidget(habit.iconCodePoint, color: activeColor, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (habit.description != null && habit.description!.isNotEmpty)
                      Text(
                        habit.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              // Streak badge
              _buildStreakBadge(completedDates, activeColor, theme, isFunky, isDarkFunky),
            ],
          ),

          const SizedBox(height: 28),

          // Current year card
          _buildYearCard(
            context,
            provider,
            theme,
            habit,
            year: currentYear,
            completedDates: completedDates,
            activeColor: activeColor,
            isNeon: isNeon,
            isDarkNeon: isDarkNeon,
            isGlass: isGlass,
            isFunky: isFunky,
            isDarkFunky: isDarkFunky,
            isCurrent: true,
          ),

          const SizedBox(height: 24),

          // Previous year card
          _buildYearCard(
            context,
            provider,
            theme,
            habit,
            year: currentYear - 1,
            completedDates: completedDates,
            activeColor: activeColor,
            isNeon: isNeon,
            isDarkNeon: isDarkNeon,
            isGlass: isGlass,
            isFunky: isFunky,
            isDarkFunky: isDarkFunky,
            isCurrent: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge(
    List<DateTime> completedDates,
    Color activeColor,
    ThemeData theme,
    bool isFunky,
    bool isDarkFunky,
  ) {
    // Calculate current streak
    int streak = 0;
    final now = DateTime.now();
    var check = DateTime(now.year, now.month, now.day);
    while (completedDates.any((d) =>
        d.year == check.year && d.month == check.month && d.day == check.day)) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.12),
        borderRadius: isFunky ? BorderRadius.circular(6) : BorderRadius.circular(12),
        border: isFunky
            ? Border.all(color: isDarkFunky ? Colors.white : Colors.black, width: 2)
            : Border.all(color: activeColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: isFunky
            ? [
                BoxShadow(
                  color: isDarkFunky ? Colors.black : Colors.black.withOpacity(0.2),
                  offset: const Offset(3, 3),
                  blurRadius: 0,
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            '🔥 $streak',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: activeColor,
            ),
          ),
          Text(
            'day streak',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearCard(
    BuildContext context,
    HabitsNotifier provider,
    ThemeData theme,
    Habit habit, {
    required int year,
    required List<DateTime> completedDates,
    required Color activeColor,
    required bool isNeon,
    required bool isDarkNeon,
    required bool isGlass,
    required bool isFunky,
    required bool isDarkFunky,
    required bool isCurrent,
  }) {
    final int themeMode = provider.themeMode;
    final Color inactiveColor;
    final Color outOfBoundsColor;

    if (themeMode == 0) {
      inactiveColor = const Color(0xFF3A3A3D);
      outOfBoundsColor = const Color(0xFF242426);
    } else if (themeMode == 1) {
      inactiveColor = const Color(0xFF332F52);
      outOfBoundsColor = const Color(0xFF211D3B);
    } else if (themeMode == 2) {
      inactiveColor = const Color(0xFFD1D1D6);
      outOfBoundsColor = const Color(0xFFE5E5EA);
    } else if (themeMode == 3) {
      inactiveColor = const Color(0xFFC7DBCF);
      outOfBoundsColor = const Color(0xFFE2EFE7);
    } else if (themeMode == 4) {
      inactiveColor = const Color(0xFF2B2244);
      outOfBoundsColor = const Color(0xFF160F25);
    } else if (themeMode == 5) {
      inactiveColor = const Color(0xFFF3C6D7);
      outOfBoundsColor = const Color(0xFFFCE3EE);
    } else if (themeMode == 6) {
      inactiveColor = Colors.white.withOpacity(0.18);
      outOfBoundsColor = Colors.white.withOpacity(0.04);
    } else if (themeMode == 7) {
      inactiveColor = Colors.black.withOpacity(0.14);
      outOfBoundsColor = Colors.black.withOpacity(0.04);
    } else if (themeMode == 8) {
      inactiveColor = const Color(0xFFE8E4FF);
      outOfBoundsColor = const Color(0xFFF3F0FF).withOpacity(0.5);
    } else if (themeMode == 9) {
      inactiveColor = const Color(0xFF3E356A);
      outOfBoundsColor = const Color(0xFF1B1333);
    } else {
      inactiveColor = theme.brightness == Brightness.dark ? const Color(0xFF3E3E42) : const Color(0xFFCCCCCC);
      outOfBoundsColor = theme.brightness == Brightness.dark ? const Color(0xFF1B1B20) : const Color(0xFFF5F5F5);
    }

    // Total days in this year (handles leap years)
    final totalDays = DateTime(year, 12, 31).difference(DateTime(year, 1, 1)).inDays + 1;
    final completedThisYear = completedDates.where(
      (d) => d.year == year,
    ).length;
    final percentage = totalDays > 0 ? (completedThisYear / totalDays * 100) : 0.0;

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year title row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? activeColor.withValues(alpha: 0.15)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: isFunky ? BorderRadius.circular(4) : BorderRadius.circular(8),
                    border: isFunky
                        ? Border.all(
                            color: isDarkFunky ? Colors.white : Colors.black,
                            width: isCurrent ? 2.0 : 1.5,
                          )
                        : (isCurrent
                            ? Border.all(color: activeColor.withValues(alpha: 0.4), width: 1.5)
                            : null),
                  ),
                  child: Text(
                    '$year',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCurrent
                          ? activeColor
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: isFunky ? BorderRadius.circular(3) : BorderRadius.circular(20),
                      border: isFunky
                          ? Border.all(
                              color: isDarkFunky ? Colors.white : Colors.black,
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Text(
                      'Current Year',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '$completedThisYear / $totalDays days  ·  ${percentage.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(isFunky ? 2 : 4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: isFunky ? 8 : 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(activeColor),
          ),
        ),

        const SizedBox(height: 20),

        // Month-by-month grid
        _buildMonthGrid(
          theme,
          habit,
          year,
          completedDates,
          activeColor,
          inactiveColor: inactiveColor,
          outOfBoundsColor: outOfBoundsColor,
          isFunky: isFunky,
          isDarkFunky: isDarkFunky,
        ),

        const SizedBox(height: 16),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _legendItem(
              inactiveColor,
              'Not done',
              theme,
              isFunky: isFunky,
              isDarkFunky: isDarkFunky,
            ),
            const SizedBox(width: 16),
            _legendItem(
              activeColor,
              'Completed',
              theme,
              isFunky: isFunky,
              isDarkFunky: isDarkFunky,
            ),
          ],
        ),
      ],
    );

    Widget card = Card(
      margin: EdgeInsets.zero,
      elevation: isGlass ? 0 : null,
      color: isGlass ? Colors.transparent : null,
      shape: isGlass ? const RoundedRectangleBorder(side: BorderSide.none) : null,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: cardContent,
      ),
    );

    if (isNeon) {
      card = AmbientGlowWrapper(
        enabled: true,
        isDark: isDarkNeon,
        child: card,
      );
    } else if (isGlass) {
      card = GlassWrapper(
        enabled: true,
        child: card,
      );
    }

    return card;
  }

  Widget _buildMonthGrid(
    ThemeData theme,
    Habit habit,
    int year,
    List<DateTime> completedDates,
    Color activeColor, {
    required Color inactiveColor,
    required Color outOfBoundsColor,
    required bool isFunky,
    required bool isDarkFunky,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normStart = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
    final normEnd = habit.endDate != null
        ? DateTime(habit.endDate!.year, habit.endDate!.month, habit.endDate!.day)
        : null;

    // Cell sizing: for Funky make them rectangles, others are small squares
    final double cellW = isFunky ? 16 : 13;
    final double cellH = isFunky ? 12 : 11;
    final double cellGap = isFunky ? 2.5 : 2.0;
    final double cellRadius = isFunky ? 2.0 : 2.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(12, (monthIdx) {
        final month = monthIdx + 1;
        final days = _daysInMonth(year, month);
        // The day-of-week of the 1st (Sun=0…Sat=6)
        final firstWeekday = DateTime(year, month, 1).weekday % 7;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month label
              SizedBox(
                width: 36,
                child: Padding(
                  padding: EdgeInsets.only(top: (cellH + cellGap) * (firstWeekday / 7)),
                  child: Text(
                    _monthNames[monthIdx],
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),

              // Day cells laid out in columns of 7 rows (Mon→Sun)
              Flexible(
                child: Wrap(
                  direction: Axis.horizontal,
                  spacing: cellGap,
                  runSpacing: cellGap,
                  children: [
                    // Leading blank cells to align weekday
                    ...List.generate(firstWeekday, (_) => SizedBox(width: cellW, height: cellH)),

                    ...List.generate(days, (dayIdx) {
                      final day = DateTime(year, month, dayIdx + 1);
                      final isFuture = day.isAfter(today);
                      final isBeforeStart = day.isBefore(normStart);
                      final isAfterEnd = normEnd != null && day.isAfter(normEnd);
                      final isOutOfRange = isBeforeStart || isAfterEnd;
                      final isCompleted = completedDates.any((d) =>
                          d.year == day.year && d.month == day.month && d.day == day.day);
                      final isToday = day.year == today.year &&
                          day.month == today.month &&
                          day.day == today.day;
                      final shouldPulse = isToday && !isCompleted && !isOutOfRange;

                      Color cellColor;
                      if (isFuture || isOutOfRange) {
                        cellColor = outOfBoundsColor;
                      } else if (isCompleted) {
                        cellColor = activeColor;
                      } else {
                        cellColor = inactiveColor;
                      }

                      Widget cell = Container(
                        width: cellW,
                        height: cellH,
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(cellRadius),
                          border: isFunky && !isFuture && !isOutOfRange
                              ? Border.all(
                                  color: isDarkFunky
                                      ? (isCompleted ? Colors.white : Colors.white.withOpacity(0.15))
                                      : (isCompleted ? Colors.black : Colors.black.withOpacity(0.2)),
                                  width: 0.75,
                                )
                              : (isToday && !isFuture && !isOutOfRange
                                  ? Border.all(color: activeColor, width: 1.5)
                                  : null),
                        ),
                      );

                      if (shouldPulse) {
                        cell = PulsingCellBorder(
                          color: activeColor,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(cellRadius),
                          child: cell,
                        );
                      }

                      if (!isFuture && !isOutOfRange) {
                        cell = Tooltip(
                          message: _formatTooltipDate(day),
                          waitDuration: Duration.zero,
                          showDuration: const Duration(seconds: 2),
                          child: cell,
                        );
                      }

                      return cell;
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _legendItem(
    Color color,
    String label,
    ThemeData theme, {
    required bool isFunky,
    required bool isDarkFunky,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(isFunky ? 2 : 3),
            border: isFunky
                ? Border.all(
                    color: isDarkFunky ? Colors.white : Colors.black,
                    width: 1,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
