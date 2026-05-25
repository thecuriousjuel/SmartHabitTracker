import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../habit/presentation/dashboard_page.dart';
import '../habit/presentation/weekly_view_page.dart';
import '../habit/presentation/monthly_view_page.dart';
import '../habit/presentation/yearly_view_page.dart';
import '../habit/provider/habits_provider.dart';
import '../note/presentation/notes_page.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _selectedIndex = 0;
  int _logoClickCount = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const WeeklyViewPage(),
    const MonthlyViewPage(),
    const YearlyViewPage(),
    const NotesPage(),
  ];

  void _showFunkyCheatDialog(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<HabitsNotifier>(context, listen: false);
    final isDark = provider.themeMode == 9;
    final primaryColor = isDark ? const Color(0xFFFF00FF) : const Color(0xFFFF007F);
    final borderColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF130E26) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 2.5),
        ),
        title: Text(
          '=== FUNKY CHEAT ACTIVATED ===',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🕺 🦄 🦖 ⚡ 🌈',
              style: TextStyle(fontSize: 28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'CONGRATULATIONS!\n\n'
              'You found the hidden developer terminal. 3D Funky theme is now running at maximum coolness!',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: borderColor, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'COOL!',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
    final provider = Provider.of<HabitsNotifier>(context);
    final isGlass = provider.themeMode == 6 || provider.themeMode == 7;

    Widget shell = Scaffold(
      body: Row(
        children: [
          // Sidebar Panel
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: isGlass
                  ? (provider.themeMode == 6
                      ? Colors.black.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.25))
                  : (theme.brightness == Brightness.dark
                      ? const Color(0xFF18181A)
                      : const Color(0xFFF1F3F5)),
              border: isGlass
                  ? Border(
                      right: BorderSide(
                        color: provider.themeMode == 6
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Header Logo
                GestureDetector(
                  onTap: () {
                    final provider = Provider.of<HabitsNotifier>(context, listen: false);
                    if (provider.themeMode == 8 || provider.themeMode == 9) {
                      setState(() {
                        _logoClickCount++;
                      });
                      if (_logoClickCount >= 5) {
                        _logoClickCount = 0;
                        _showFunkyCheatDialog(context);
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/logo.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
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
                              );
                            },
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
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  title: 'Yearly View',
                  index: 3,
                ),
                _buildSidebarItem(
                  icon: Icons.note_alt_outlined,
                  activeIcon: Icons.note_alt,
                  title: 'Notes & Workspace',
                  index: 4,
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
                if (provider.themeMode == 8 || provider.themeMode == 9)
                  const Funky3DSpriteWidget(),
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
                              _buildThemeDot(
                                3,
                                Colors.teal[500]!,
                                'Light Green',
                                border: true,
                                splitColors: const [Colors.white, Color(0xFF00796B)],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                              _buildThemeDot(
                                6,
                                Colors.blueGrey,
                                'Dark Glassmorphism',
                                splitColors: const [Color(0xFF7F00FF), Color(0xFF00E5FF)],
                              ),
                              _buildThemeDot(
                                7,
                                Colors.white,
                                'Light Glassmorphism',
                                border: true,
                                splitColors: const [Color(0xFFF9F7FC), Color(0xFFFFB6C1)],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildThemeDot(
                                8,
                                const Color(0xFFFF007F),
                                'Funky 3D Light',
                                splitColors: const [Color(0xFFFF007F), Color(0xFF00C8FF)],
                              ),
                              const SizedBox(width: 24),
                              _buildThemeDot(
                                9,
                                const Color(0xFFFF00FF),
                                'Funky 3D Dark',
                                splitColors: const [Color(0xFFFF00FF), Color(0xFF00FFCC)],
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

    if (isGlass) {
      return Stack(
        children: [
          provider.themeMode == 6
              ? const _GlassBackground()
              : const _LightGlassBackground(),
          shell,
        ],
      );
    }
    return shell;
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
    final isFunkyActive = provider.themeMode == 8 || provider.themeMode == 9;
    final borderSideColor = provider.themeMode == 9 ? Colors.white : Colors.black;

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
            shape: BoxShape.rectangle,
            borderRadius: isFunkyActive ? BorderRadius.circular(8) : BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : (isFunkyActive
                      ? borderSideColor.withOpacity(0.4)
                      : (border ? Colors.grey[400]! : Colors.transparent)),
              width: isSelected ? 3.0 : 1.0,
            ),
            boxShadow: isFunkyActive
                ? [
                    BoxShadow(
                      color: provider.themeMode == 9 ? Colors.black : Colors.black.withOpacity(0.2),
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  size: 16,
                  color: (index == 2 || index == 5 || index == 7 || index == 8) ? Colors.black : Colors.white,
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

class _GlassBackground extends StatelessWidget {
  const _GlassBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F0C20),
                Color(0xFF15102A),
                Color(0xFF06040B),
              ],
            ),
          ),
        ),
        Positioned(
          top: -120,
          left: -120,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF007F).withValues(alpha: 0.24),
                  const Color(0xFFFF007F).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          right: -150,
          child: Container(
            width: 550,
            height: 550,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00E5FF).withValues(alpha: 0.22),
                  const Color(0xFF00E5FF).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: -50,
          child: Container(
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7F00FF).withValues(alpha: 0.22),
                  const Color(0xFF7F00FF).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LightGlassBackground extends StatelessWidget {
  const _LightGlassBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF9F7FC),
                Color(0xFFF1F3FE),
                Color(0xFFE8ECFD),
              ],
            ),
          ),
        ),
        Positioned(
          top: -120,
          left: -120,
          child: Container(
            width: 450,
            height: 450,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFB6C1).withValues(alpha: 0.35),
                  const Color(0xFFFFB6C1).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          right: -150,
          child: Container(
            width: 550,
            height: 550,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFB2EBF2).withValues(alpha: 0.35),
                  const Color(0xFFB2EBF2).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: -50,
          child: Container(
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFE1BEE7).withValues(alpha: 0.35),
                  const Color(0xFFE1BEE7).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class Funky3DSpriteWidget extends StatefulWidget {
  const Funky3DSpriteWidget({super.key});

  @override
  State<Funky3DSpriteWidget> createState() => _Funky3DSpriteWidgetState();
}

class _Funky3DSpriteWidgetState extends State<Funky3DSpriteWidget> {
  int _quoteIndex = 0;
  int _spriteIndex = 0;

  final List<String> _sprites = ['🕺', '🦄', '🦖', '😎', '🛸', '🍕', '🍩'];

  final List<String> _quotes = [
    "Unleash the magic! Track those habits!",
    "Stay cool, keep tracking!",
    "Funky mode activated! You're crushing it!",
    "A habit a day keeps the chaos away!",
    "Progress is funky! Keep moving!",
    "Streak active! Level Up your life!",
    "Feed your inner dino, hit your goals!",
    "Confetti awaits you at the finish line!",
    "Rock on! You're doing amazing today!",
  ];

  void _clickSprite() {
    setState(() {
      _quoteIndex = (_quoteIndex + 1) % _quotes.length;
      _spriteIndex = (_spriteIndex + 1) % _sprites.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitsNotifier>(context);
    final isDark = provider.themeMode == 9;
    final borderColor = isDark ? Colors.white : Colors.black;
    final primaryColor = isDark ? const Color(0xFFFF00FF) : const Color(0xFFFF007F);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1735) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black : Colors.black.withOpacity(0.2),
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _clickSprite,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF130E26) : const Color(0xFFF3F0FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black : Colors.black.withOpacity(0.15),
                        offset: const Offset(2, 2),
                        blurRadius: 0,
                      )
                    ],
                  ),
                  child: Text(
                    _sprites[_spriteIndex],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'TAP ME!',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C071A) : const Color(0xFFFAF9F6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor.withOpacity(0.2), width: 1),
            ),
            child: Text(
              _quotes[_quoteIndex],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
