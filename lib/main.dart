import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'config/main_wrapper.dart';
import 'features/settings/ui/security_page.dart';
import 'providers/theme_provider.dart';
import 'services/app_initialization.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/security_service.dart';
import 'services/toast_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await SecurityService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthService()),
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
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await AppInitialization.initialize(context);
    if (!mounted) return;

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.init();
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.initialize();
    if (!mounted) return;

    await NotificationService.instance.initialize();

    if (!mounted) return;

    final securityEnabled = SecurityService.instance.isPasswordEnabled();
    if (securityEnabled) {
      setState(() {
        _isInitialized = true;
      });
    } else {
      setState(() {
        _isInitialized = true;
        _isUnlocked = true;
      });
    }
  }

  void _handleUnlockSuccess() {
    setState(() {
      _isUnlocked = true;
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
      scaffoldMessengerKey: ToastService.scaffoldKey,
      home: !_isInitialized
          ? const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Loading...'),
                  ],
                ),
              ),
            )
          : SecurityService.instance.isPasswordEnabled() && !_isUnlocked
          ? SecurityPage(
              mode: SecurityPageMode.verify,
              onVerifySuccess: _handleUnlockSuccess,
            )
          : const MainWrapper(),
    );
  }
}
