import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '/widgets/action_card.dart';
import '/widgets/custom_top_bar.dart';
import '/widgets/custom_bottom_nav.dart'; 
import '/routes/app_routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    
    // Récupération de la route actuelle pour l'état actif du menu
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFBC7400))),
      );
    }

    final bool isClient = user.role.toLowerCase() == 'client';

    return Scaffold(
      backgroundColor: Colors.white,
      // On retire l'appBar classique pour mettre le CustomTopBar dans le Stack
      body: Stack(
        children: [
          // 1. LE CONTENU DE LA PAGE
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            // Le padding top (120) laisse de la place pour la TopBar
            // Le padding bottom (130) laisse de la place pour la BottomNav
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 130), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user.name),
                const SizedBox(height: 35),
                
                ActionCard(
                  index: 0,
                  label: isClient ? "Trouver un prestataire" : "Mes missions",
                  icon: isClient ? Icons.search_rounded : Icons.work_outline_rounded,
                  onTap: () => isClient ? Navigator.pushNamed(context, AppRoutes.findService) : null,
                ),

                ActionCard(
                  index: 1,
                  label: "Mes contrats",
                  icon: Icons.description_rounded,
                  onTap: () {},
                ),

                const SizedBox(height: 40),
                _buildSupportBanner(isClient),
              ],
            ),
          ),
          
          // 2. LA BARRE SUPÉRIEURE (TOPBAR)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomTopBar(
              imagePath: 'assets/images/logo.png',
              onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              onNotificationTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
              onMenuTap: () => Navigator.pushNamed(context, AppRoutes.menu),
            ),
          ),

          // 3. LA BARRE DE NAVIGATION (BOTTOMNAV)
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNav(currentRoute: currentRoute ?? AppRoutes.home),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Tableau de bord".toUpperCase(),
          style: TextStyle(
            fontSize: 11, 
            fontWeight: FontWeight.w800, 
            color: Colors.grey[500], 
            letterSpacing: 1.5
          )),
        const SizedBox(height: 10),
        Text("Bonjour $name",
          style: const TextStyle(
            fontSize: 34, 
            fontWeight: FontWeight.w900, 
            color: Color(0xFF1A1A1A), 
            height: 1.1
          )),
      ],
    );
  }

  Widget _buildSupportBanner(bool isClient) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), 
        borderRadius: BorderRadius.circular(28)
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Besoin d'aide ?", 
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                Text(
                  isClient ? "Un souci avec un pro ?" : "Un souci client ?", 
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, 
              foregroundColor: Colors.white, 
              shape: const StadiumBorder()
            ),
            child: const Text("Aide"),
          ),
        ],
      ),
    );
  }
}