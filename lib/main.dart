import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'core/storage/app_database.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/habit/provider/habits_provider.dart';
import 'features/navigation/navigation_shell.dart';
import 'features/welcome/presentation/welcome_modal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  final db = kIsWeb ? null : AppDatabase();
  final storage = StorageService(db);

  runApp(
    ChangeNotifierProvider(
      create: (_) => HabitsNotifier(storage),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final notifier = Provider.of<HabitsNotifier>(context, listen: false);
    await notifier.loadData();
    setState(() {
      _isLoading = false;
    });

    if (notifier.isFirstTimeUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const WelcomeModal(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<HabitsNotifier>(context);

    ThemeData activeTheme;
    switch (notifier.themeMode) {
      case 1:
        activeTheme = AppTheme.darkPurpleTheme;
        break;
      case 2:
        activeTheme = AppTheme.lightWhiteTheme;
        break;
      case 3:
        activeTheme = AppTheme.lightGreenTheme;
        break;
      case 4:
        activeTheme = AppTheme.neonDarkTheme;
        break;
      case 5:
        activeTheme = AppTheme.neonLightTheme;
        break;
      case 6:
        activeTheme = AppTheme.glassTheme;
        break;
      case 7:
        activeTheme = AppTheme.lightGlassTheme;
        break;
      case 8:
        activeTheme = AppTheme.funkyLightTheme;
        break;
      case 9:
        activeTheme = AppTheme.funkyDarkTheme;
        break;
      case 0:
      default:
        activeTheme = AppTheme.darkGreyTheme;
        break;
    }

    return MaterialApp(
      title: 'Smart Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: activeTheme,
      home: _isLoading
          ? AppLoadingScreen(theme: activeTheme)
          : const NavigationShell(),
    );
  }
}

class AppLoadingScreen extends StatefulWidget {
  final ThemeData theme;
  const AppLoadingScreen({super.key, required this.theme});

  @override
  State<AppLoadingScreen> createState() => _AppLoadingScreenState();
}

class _AppLoadingScreenState extends State<AppLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.brightness == Brightness.dark;
    final primaryColor = widget.theme.colorScheme.primary;
    final secondaryColor = widget.theme.colorScheme.secondary;

    return Scaffold(
      backgroundColor: widget.theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Loading bar at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                backgroundColor: primaryColor.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                minHeight: 4,
              ),
            ),
          ),
          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Spinning glowing spiral aura
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              primaryColor,
                              secondaryColor,
                              primaryColor.withOpacity(0.0),
                              primaryColor,
                            ],
                            stops: const [0.0, 0.5, 0.75, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Frosted blur to make it glow
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.35),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: secondaryColor.withOpacity(0.25),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    // Mask/Overlay container to clip inner content and hold logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF130E26) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.05),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.grid_on_rounded,
                                size: 48,
                                color: primaryColor,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Smart Habit Tracker',
                  style: widget.theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Loading your habits...',
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: widget.theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
