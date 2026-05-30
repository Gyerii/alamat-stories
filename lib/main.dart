import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0F0E1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const AlamatApp());
}

class AlamatApp extends StatelessWidget {
  const AlamatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alamat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0E1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC9A84C),
          surface: Color(0xFF1B1A2E),
        ),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _DarkFadeTransition(),
            TargetPlatform.iOS: _DarkFadeTransition(),
          },
        ),
      ),
      // Forces ALL screens to extend behind status bar
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Color(0xFF0F0E1A),
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}

class _DarkFadeTransition extends PageTransitionsBuilder {
  const _DarkFadeTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    );
  }
}