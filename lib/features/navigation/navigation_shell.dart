import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../habit/presentation/dashboard_page.dart';
import '../habit/presentation/weekly_view_page.dart';
import '../habit/presentation/monthly_view_page.dart';
import '../habit/provider/habits_provider.dart';
import '../note/presentation/notes_page.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const WeeklyViewPage(),
    const MonthlyViewPage(),
    const NotesPage(),
  ];

  void _showBackupInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Local Data & Cloud Sync'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SQLite Database Storage',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'All habit records and logs are stored inside a local SQLite database file on your system. This allows complete privacy and high-speed offline operations.',
            ),
            SizedBox(height: 16),
            Text(
              'Future Expansion Roadmap',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            BulletPoint(text: 'Manual SQLite database exports for backups.'),
            BulletPoint(text: 'Auto-syncing to Google Drive AppData folder.'),
            BulletPoint(text: 'Seamless cross-platform sync on iOS & Android using Drift.'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Panel
          Container(
            width: 250,
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF18181A)
                : const Color(0xFFF1F3F5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Header Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.grid_on_rounded,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SmartHabit',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Track with ease',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Navigation Options
                _buildSidebarItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  title: 'Dashboard',
                  index: 0,
                ),
                _buildSidebarItem(
                  icon: Icons.view_week_outlined,
                  activeIcon: Icons.view_week,
                  title: 'Weekly View',
                  index: 1,
                ),
                _buildSidebarItem(
                  icon: Icons.calendar_view_month_outlined,
                  activeIcon: Icons.calendar_view_month,
                  title: 'Monthly View',
                  index: 2,
                ),
                _buildSidebarItem(
                  icon: Icons.note_alt_outlined,
                  activeIcon: Icons.note_alt,
                  title: 'Notes & Workspace',
                  index: 3,
                ),
                const Spacer(),
                // Backup / Export Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: OutlinedButton.icon(
                    onPressed: () => _showBackupInfo(context),
                    icon: const Icon(Icons.cloud_sync_outlined, size: 18),
                    label: const Text('Sync & Backup'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                // Theme Mode Selector
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THEME MODE',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildThemeDot(
                                0,
                                Colors.grey[800]!,
                                'Dark Charcoal',
                                splitColors: const [Color(0xFF121212), Color(0xFF8E8E93)],
                              ),
                              _buildThemeDot(
                                1,
                                Colors.deepPurple[900]!,
                                'Dark Blue/Purple',
                                splitColors: const [Color(0xFF0F0C1B), Color(0xFFBB86FC)],
                              ),
                              _buildThemeDot(
                                2,
                                Colors.white,
                                'Light White',
                                border: true,
                                splitColors: const [Colors.white, Color(0xFF1976D2)],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildThemeDot(
                                3,
                                Colors.teal[500]!,
                                'Light Green',
                                border: true,
                                splitColors: const [Colors.white, Color(0xFF00796B)],
                              ),
                              _buildThemeDot(
                                4,
                                const Color(0xFF08070A),
                                'Neon Dark',
                                splitColors: const [Color(0xFF08070A), Color(0xFF00FF66)],
                              ),
                              _buildThemeDot(
                                5,
                                const Color(0xFFFCFCFD),
                                'Neon Light',
                                border: true,
                                splitColors: const [Color(0xFFFCFCFD), Color(0xFFE0007A)],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Made with ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                            const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 12,
                            ),
                            Text(
                              ' by Biswajit',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Divider Line
          VerticalDivider(width: 1, color: theme.colorScheme.outlineVariant),
          // Main WorkSpace Page
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeDot(
    int index,
    Color color,
    String tooltip, {
    bool border = false,
    List<Color>? splitColors,
  }) {
    final provider = Provider.of<HabitsNotifier>(context, listen: false);
    final isSelected = provider.themeMode == index;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => provider.changeThemeMode(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: splitColors == null ? color : null,
            gradient: splitColors != null
                ? LinearGradient(
                    colors: splitColors,
                    stops: const [0.499, 0.501],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : (border ? Colors.grey[400]! : Colors.transparent),
              width: isSelected ? 3.0 : 1.0,
            ),
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  size: 16,
                  color: (index == 2 || index == 5) ? Colors.black : Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
