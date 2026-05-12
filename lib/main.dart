import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <--- AJOUTÉ

// Providers
import 'providers/auth_provider.dart';
import 'providers/find_service_provider.dart'; 
import 'providers/contract_provider.dart';
import 'providers/notification_provider.dart'; 

// Routes & Screens
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
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => FindServiceProvider()),
        ChangeNotifierProvider(create: (_) => ContractProvider()),
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
          
          // --- CONFIGURATION FRANÇAIS POUR DATEPICKER ---
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('fr', 'FR'), // Français
            Locale('en', 'US'), // Anglais
          ],
          locale: const Locale('fr', 'FR'), // Force le français par défaut
          // ----------------------------------------------

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
    debugPrint("🏠 [ROUTING] Calcul de l'écran d'accueil...");

    // 1. Splash Screen pendant que le storage est lu
    if (!auth.initialized) {
      debugPrint("-> Écran : Splash (chargement storage)");
      return const AnimatedSplashScreen();
    }
    
    // 2. Si l'utilisateur est connecté
    if (auth.isAuthenticated) {
      debugPrint("-> État : Connecté");
      
      // Ici, on impose la page CompleteProfilePage si le profil n'est pas fini
      if (auth.isProfileIncomplete) {
        debugPrint("-> Écran : CompleteProfile (champs obligatoires manquants)");
        return const CompleteProfilePage();
      }
      
      debugPrint("-> Écran : HomeView (Profil complet)");
      return const HomeView();
    }

    // 3. Par défaut : Écran de bienvenue
    debugPrint("-> État : Non connecté -> Écran : Welcome");
    return const WelcomePage();
  }
}