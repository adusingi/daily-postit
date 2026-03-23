import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  final firebaseConfigured = !_isPlaceholderFirebaseOptions(firebaseOptions);
  if (firebaseConfigured) {
    await Firebase.initializeApp(
      options: firebaseOptions,
    );
  }
  runApp(DailyPostItApp(firebaseConfigured: firebaseConfigured));
}

class DailyPostItApp extends StatelessWidget {
  const DailyPostItApp({super.key, required this.firebaseConfigured});

  final bool firebaseConfigured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Post-it',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFF0E1729),
        fontFamily: 'JetBrainsMono',
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0E1729),
        fontFamily: 'JetBrainsMono',
        cardTheme: const CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: firebaseConfigured ? const _AuthGate() : const _FirebaseSetupNotice(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const SignInScreen();
        }

        return const HomeScreen();
      },
    );
  }
}

class _FirebaseSetupNotice extends StatelessWidget {
  const _FirebaseSetupNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Firebase not configured',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Run flutterfire configure to enable sync and sign-in.',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const SelectableText(
                'cd app\\nflutterfire configure --project=daily-postit-89948',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isPlaceholderFirebaseOptions(FirebaseOptions options) {
  return options.apiKey.trim().isEmpty || options.apiKey == 'REPLACE_ME';
}
