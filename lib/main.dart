import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports Providers - Utilisation stricte des minuscules pour les noms de fichiers
import 'providers/auth_provider.dart';
import 'providers/find_service_provider.dart'; 
import 'providers/notification_provider.dart'; 

// Imports Routes & Screens
import 'routes/app_pages.dart';
import 'screens/auth/complete_profile_page.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FindServiceProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CopPlus',
          onGenerateRoute: AppPages.onGenerateRoute, 
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFBC7400),
              primary: const Color(0xFFBC7400),
            ),
            useMaterial3: true,
          ),
          home: _getHome(auth),
        );
      },
    );
  }

  Widget _getHome(AuthProvider auth) {
    if (!auth.initialized) return const AnimatedSplashScreen();
    
    if (auth.isAuthenticated) {
      if (auth.isProfileIncomplete) {
        return const CompleteProfilePage();
      }
      return const HomeView();
    }
    return const WelcomePage();
  }
}