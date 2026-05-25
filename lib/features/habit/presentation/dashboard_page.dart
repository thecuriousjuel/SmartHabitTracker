import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/storage/backup/backup_helper.dart';
import '../models/habit.dart';
import '../provider/habits_provider.dart';
import 'ambient_glow_wrapper.dart';
import 'glass_wrapper.dart';
import 'github_grid.dart';
import 'habit_calendar_dialog.dart';
import 'habit_creation_dialog.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _showUpcoming = false;
  bool _showPast = false;

  Future<void> _exportBackup() async {
    try {
      final provider = Provider.of<HabitsNotifier>(context, listen: false);
      final jsonStr = provider.exportBackupData();
      await saveBackupFile(jsonStr);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup exported successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export backup: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _importBackup() async {
    try {
      final jsonStr = await pickAndReadBackupFile();
      if (jsonStr == null) return; // User cancelled

      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Import Backup'),
          content: const Text(
            'Importing this backup will overwrite all current habits and completion history. Are you sure you want to proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Proceed'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        if (!mounted) return;
        final provider = Provider.of<HabitsNotifier>(context, listen: false);
        await provider.importBackupData(jsonStr);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to import backup: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _openCalendar(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => HabitCalendarDialog(habit: habit),
    );
  }

  void _deleteHabit(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Provider.of<HabitsNotifier>(context, listen: false).deleteHabit(habit.id);
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitsNotifier>(context);

    final ongoing = provider.ongoingHabits;
    final upcoming = provider.upcomingHabits;
    final past = provider.pastHabits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export Backup',
            onPressed: _exportBackup,
          ),
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: 'Import Backup',
            onPressed: _importBackup,
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const HabitCreationDialog(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Habit'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LiveClockWidget(),
            const SizedBox(height: 16),
            // Header Stats/Quote card
            _buildStatBanner(context, ongoing.length),
            const SizedBox(height: 24),

            // Ongoing Habits Section (Always visible)
            _buildSectionHeader('Ongoing Habits', ongoing.length, true, null),
            if (ongoing.isEmpty)
              _buildEmptyState('No ongoing habits. Create one or toggle sections below!')
            else
              _buildHabitGrid(context, ongoing),
            const SizedBox(height: 24),

            // Upcoming Habits Section
            _buildSectionHeader(
              'Upcoming Habits',
              upcoming.length,
              _showUpcoming,
              (val) => setState(() => _showUpcoming = val),
            ),
            if (_showUpcoming)
              upcoming.isEmpty
                  ? _buildEmptyState('No upcoming habits scheduled.')
                  : _buildHabitGrid(context, upcoming),
            const SizedBox(height: 24),

            // Past Habits Section
            _buildSectionHeader(
              'Past Habits',
              past.length,
              _showPast,
              (val) => setState(() => _showPast = val),
            ),
            if (_showPast)
              past.isEmpty
                  ? _buildEmptyState('No past habits completed/ended.')
                  : _buildHabitGrid(context, past),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBanner(BuildContext context, int ongoingCount) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, size: 48, color: theme.colorScheme.primary),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keep the streak alive!',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You currently have $ongoingCount ongoing habits to focus on today.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, bool value, ValueChanged<bool>? onToggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (onToggle != null)
            Switch(
              value: value,
              onChanged: onToggle,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,
      child: Text(
        msg,
        style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, Habit habit) {
    final provider = Provider.of<HabitsNotifier>(context, listen: false);
    final theme = Theme.of(context);
    final activeColor = Color(habit.colorHex);
    final isDoneToday = provider.isCompleted(habit.id, DateTime.now());

    final isNeon = provider.themeMode == 4 || provider.themeMode == 5;
    final isDarkNeon = provider.themeMode == 4;
    final isGlass = provider.themeMode == 6;

    Widget cardWidget = Card(
      margin: (isNeon || isGlass) ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 6.0),
      elevation: isGlass ? 0 : null,
      color: isGlass ? Colors.transparent : null,
      shape: isGlass ? const RoundedRectangleBorder(side: BorderSide.none) : null,
      child: InkWell(
        onTap: () => _openCalendar(context, habit),
        borderRadius: BorderRadius.circular(16),
        hoverColor: theme.colorScheme.primary.withValues(alpha: 0.03),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Habit Info Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: activeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      getHabitIcon(habit.iconCodePoint),
                      color: activeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (habit.description != null && habit.description!.isNotEmpty)
                          Text(
                            habit.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Completion Button
                  IconButton(
                    icon: Icon(
                      isDoneToday ? Icons.check_circle : Icons.check_circle_outline,
                      color: isDoneToday ? activeColor : theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      provider.toggleCompletion(habit.id, DateTime.now());
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                    tooltip: 'Edit Habit',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => HabitCreationDialog(habitToEdit: habit),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                    tooltip: 'Delete Habit',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _deleteHabit(context, habit),
                  )
                ],
              ),
              const SizedBox(height: 12),
              // GitHub Grid
              SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: GitHubGrid(
                    activeColor: activeColor,
                    completedDates: provider.getCompletedDates(habit.id),
                    habitStartDate: habit.startDate,
                    habitEndDate: habit.endDate,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isNeon) {
      cardWidget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: AmbientGlowWrapper(
          enabled: true,
          isDark: isDarkNeon,
          child: cardWidget,
        ),
      );
    } else if (isGlass) {
      cardWidget = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GlassWrapper(
          enabled: true,
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }

  Widget _buildHabitGrid(BuildContext context, List<Habit> habits) {
    final screenWidth = MediaQuery.of(context).size.width;
    final useTwoColumns = screenWidth > 1050;

    if (!useTwoColumns) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: habits.length,
        itemBuilder: (ctx, idx) => _buildHabitCard(context, habits[idx]),
      );
    }

    final leftHabits = <Habit>[];
    final rightHabits = <Habit>[];
    for (int i = 0; i < habits.length; i++) {
      if (i % 2 == 0) {
        leftHabits.add(habits[i]);
      } else {
        rightHabits.add(habits[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftHabits.map((h) => _buildHabitCard(context, h)).toList(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: rightHabits.map((h) => _buildHabitCard(context, h)).toList(),
          ),
        ),
      ],
    );
  }
}



// ----------------------------------------------------
// Real-Time Live Ticking Clock Widget
// ----------------------------------------------------
class LiveClockWidget extends StatefulWidget {
  const LiveClockWidget({super.key});

  @override
  State<LiveClockWidget> createState() => _LiveClockWidgetState();
}

class _LiveClockWidgetState extends State<LiveClockWidget> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDay(DateTime dt) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return weekdays[dt.weekday - 1];
  }

  String _formatMonth(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[dt.month - 1];
  }

  String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${_twoDigits(hour)}:${_twoDigits(dt.minute)}:${_twoDigits(dt.second)} $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayStr = _formatDay(_now);
    final dateStr = '${_formatMonth(_now)} ${_now.day}, ${_now.year}';
    final timeStr = _formatTime(_now);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surface.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayStr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.access_time_filled,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  timeStr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
