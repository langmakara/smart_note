import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/main_wrapper.dart';
import 'features/auth/ui/login_page.dart';
import 'providers/theme_provider.dart';
import 'services/app_initialization.dart';
import 'services/google_drive_service.dart';
import 'services/notification_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => GoogleDriveService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;
  bool _showLogin = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final appContext = context;
    await AppInitialization.initialize(appContext);
    if (mounted) {
      final themeProvider = Provider.of<ThemeProvider>(
        // ignore: use_build_context_synchronously
        appContext,
        listen: false,
      );
      await themeProvider.init();
      if (!mounted) return;

      final driveService = Provider.of<GoogleDriveService>(
        // ignore: use_build_context_synchronously
        appContext,
        listen: false,
      );
      driveService.initialize(
        webClientId: 'YOUR_ACTUAL_WEB_CLIENT_ID.apps.googleusercontent.com',
        iosClientId: 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com',
      );

      await NotificationService.instance.initialize();

      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _handleLoginSuccess() {
    setState(() {
      _showLogin = false;
    });
  }

  void _handleSkip() {
    setState(() {
      _showLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _showLogin
          ? LoginPage(onLoginSuccess: _handleLoginSuccess, onSkip: _handleSkip)
          : _isInitialized
          ? const MainWrapper()
          : const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Initializing database...'),
                  ],
                ),
              ),
            ),
    );
  }
}
