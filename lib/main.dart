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
      case 0:
      default:
        activeTheme = AppTheme.darkGreyTheme;
        break;
    }

    return MaterialApp(
      title: 'SmartHabitTracker',
      debugShowCheckedModeBanner: false,
      theme: activeTheme,
      home: _isLoading
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : const NavigationShell(),
    );
  }
}
