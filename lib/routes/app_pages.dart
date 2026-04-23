import 'package:flutter/material.dart';

import '../Model/service_request_model.dart'; // Import crucial pour ServiceRequest
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_view.dart';
import '../screens/auth/register_view.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/client/find_service_screen.dart';
import '../screens/client/my_requests_page.dart';
import '../screens/client/notifications_page.dart';
import '../screens/client/request_details_page.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/static/about_page.dart';
import '../screens/static/menu_screen.dart';
import 'app_routes.dart';

class AppPages {
  // 1. On garde les routes simples ici
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      AppRoutes.login: (context) => const LoginPage(),
      AppRoutes.register: (context) => const RegisterPage(),
      AppRoutes.home: (context) => const HomeView(),
      AppRoutes.forgotPassword: (context) => const ForgotPasswordPage(),
      AppRoutes.resetPassword: (context) => const ResetPasswordPage(),
      AppRoutes.about: (context) => const AboutUsPage(),
      AppRoutes.editProfile: (context) => const EditProfileView(),
      AppRoutes.profile: (context) => const ProfileView(),
      AppRoutes.menu: (context) => const MenuView(),
      AppRoutes.findService: (context) => const FindServicePage(),
      AppRoutes.myRequests: (context) => const MyRequestsPage(),
      AppRoutes.notifications: (context) => const NotificationsPage(),
    };
  }

  // 2. On crée une fonction spéciale pour les routes avec ARGUMENTS (Détails)
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == AppRoutes.myRequestDetails) {
      // On récupère l'objet ServiceRequest passé lors du Navigator.push
      final args = settings.arguments as ServiceRequest;
      return MaterialPageRoute(
        builder: (context) => RequestDetailsPage(r: args),
      );
    }

    if (settings.name == AppRoutes.requestDetails) {
      // Route pour les détails de demande depuis les notifications
      final requestId = settings.arguments as int?;
      return MaterialPageRoute(
        builder: (context) => RequestDetailsPage(
          r: ServiceRequest(
            id: requestId ?? 0,
            reference: '#$requestId',
            serviceName: 'Service',
            commune: 'Kinshasa',
            status: 'pending',
            salary: '0',
            days: [],
          ),
        ),
      );
    }

    // Si la route est dans la Map simple, on la retourne
    final routes = getRoutes();
    if (routes.containsKey(settings.name)) {
      return MaterialPageRoute(
        builder: (context) => routes[settings.name]!(context),
      );
    }

    // Route par défaut (erreur)
    return MaterialPageRoute(
      builder: (context) =>
          const Scaffold(body: Center(child: Text("Route inconnue"))),
    );
  }
}
