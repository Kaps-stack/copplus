import 'package:flutter/material.dart';

// Modèles
import '../Model/service_request_model.dart'; 
import '../Model/contract.dart'; // Ajout du modèle Contract

// Écrans Auth
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_view.dart';
import '../screens/auth/complete_profile_page.dart';
import '../screens/auth/register_form.dart';
import '../screens/auth/reset_password_screen.dart';

// Écrans Client / Missions
import '../screens/client/notifications_page.dart';
import '../screens/client/request_details_page.dart'; 
import '../screens/missions_view.dart';
import '../screens/appointements_view.dart';
import '../screens/payment_view.dart';

// Écrans Contrats (Nouveaux)
import '../screens/contract_list_screen.dart';
import '../screens/contract_detail_screen.dart';

// Écrans Home & Profil
import '../screens/home/home_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';

// Écrans Statiques
import '../screens/static/about_page.dart';
import '../screens/static/menu_screen.dart';

// Configuration
import 'app_routes.dart';

class AppPages {
  /// 1. Définition des routes statiques (sans arguments complexes)
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      AppRoutes.login: (context) => const LoginView(),
      AppRoutes.home: (context) => const HomeView(),
      AppRoutes.forgotPassword: (context) => const ForgotPasswordPage(),
      AppRoutes.resetPassword: (context) => const ResetPasswordPage(),
      AppRoutes.about: (context) => const AboutUsPage(),
      AppRoutes.editProfile: (context) => const EditProfileView(),
      AppRoutes.profile: (context) => const ProfileScreen(),
      AppRoutes.menu: (context) => const MenuView(),
      AppRoutes.notifications: (context) => const NotificationsPage(),
      AppRoutes.completeProfile: (context) => const CompleteProfilePage(),
      AppRoutes.missions: (context) => const MissionsView(),
      AppRoutes.myAppointments: (context) => const ClientAppointmentsView(),
      AppRoutes.payment: (context) => const PaymentView(),
    };
  }

  /// 2. Gestion des routes dynamiques (avec passage d'arguments)
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    
    // --- CAS : REGISTER (Rôle) ---
    if (settings.name == AppRoutes.register) {
      final role = settings.arguments as String? ?? 'client';
      return MaterialPageRoute(
        builder: (context) => RegisterForm(role: role),
      );
    }

    // --- CAS : LISTE DES CONTRATS (Argument: bool isClient) ---
    if (settings.name == '/contracts') { // Utilise AppRoutes.contracts si défini
      final bool isClient = settings.arguments as bool? ?? true;
      return MaterialPageRoute(
        builder: (context) => ContractListScreen(isClient: isClient),
      );
    }

    // --- CAS : DÉTAILS CONTRAT (Arguments: Map avec 'contract' et 'isClient') ---
    if (settings.name == '/contract-details') { // Utilise AppRoutes.contractDetails
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (context) => ContractDetailScreen(
          contract: args['contract'] as Contract,
          isClient: args['isClient'] as bool? ?? true,
        ),
      );
    }

    // --- CAS : DÉTAILS DEMANDE (ServiceRequest) ---
    if (settings.name == AppRoutes.myRequestDetails || settings.name == AppRoutes.requestDetails) {
      ServiceRequest request;

      if (settings.arguments is ServiceRequest) {
        request = settings.arguments as ServiceRequest;
      } else {
        final int requestId = settings.arguments as int? ?? 0;
        request = ServiceRequest(
          id: requestId,
          reference: '#$requestId',
          serviceName: 'Chargement...',
          commune: 'Non spécifiée',
          status: 'pending',
          salaryAmount: '0',
          days: [],
        );
      }

      return MaterialPageRoute(
        builder: (context) => RequestDetailsPage(r: request),
      );
    }

    // --- VÉRIFICATION DES ROUTES STATIQUES ---
    final Map<String, WidgetBuilder> routes = getRoutes();
    final WidgetBuilder? builder = routes[settings.name];

    if (builder != null) {
      return MaterialPageRoute(
        settings: settings,
        builder: (context) => builder(context),
      );
    }

    // --- ROUTE PAR DÉFAUT (404) ---
    return MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: Center(
          child: Text(
            "Oups ! Cette page n'existe pas.",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}