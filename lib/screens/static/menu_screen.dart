import 'package:flutter/material.dart';
import '/routes/app_routes.dart';
import '/widgets/custom_bottom_nav.dart';
import '/widgets/custom_top_bar.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 1. POSITIONNEMENT UNIQUE DU NAV (Règle le problème du double nav)
      bottomNavigationBar: const CustomBottomNav(currentRoute: AppRoutes.menu),
      
      body: Stack(
        children: [
          // 2. CONTENU SCROLLABLE
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            // Padding adapté pour ne pas être caché par la TopBar et le Nav flottant
            padding: const EdgeInsets.fromLTRB(20, 110, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Paramètres du compte"),
                _buildMenuTile(
                  context,
                  icon: Icons.person_outline_rounded,
                  title: "Modifier les infos du profil",
                  subtitle: "Nom, téléphone, adresse et documents",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                ),
                _buildMenuTile(
                  context,
                  icon: Icons.lock_outline_rounded,
                  title: "Sécurité & Mot de passe",
                  subtitle: "Gérer votre accès et vos codes",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                ),

                const SizedBox(height: 30),

                _buildSectionHeader("À propos de COP PLUS"),
                Wrap(
                  spacing: 10,
                  runSpacing: 12,
                  children: [
                    _buildPillButton("Qui Sommes-nous ?", () {
                      Navigator.pushNamed(context, AppRoutes.about, arguments: 0);
                    }),
                    _buildPillButton("Nos valeurs fondamentales", () {
                      Navigator.pushNamed(context, AppRoutes.about, arguments: 1);
                    }),
                    _buildPillButton("FAQ-COPPLUS", () {
                      Navigator.pushNamed(context, AppRoutes.about, arguments: 2);
                    }),
                    _buildPillButton("Politique et confidentialité", () {
                      Navigator.pushNamed(context, AppRoutes.about, arguments: 3);
                    }),
                  ],
                ),

                const SizedBox(height: 35),

                _buildSectionHeader("Autres informations"),
                _buildMenuTile(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: "Centre d'aide",
                  subtitle: "Contacter un conseiller en direct",
                  onTap: () => debugPrint("Lien WhatsApp ou Chat"),
                ),
                _buildMenuTile(
                  context,
                  icon: Icons.share_outlined,
                  title: "Partager l'application",
                  subtitle: "Recommander COP PLUS à vos proches",
                  onTap: () => debugPrint("Ouverture share sheet"),
                ),
              
                const SizedBox(height: 40),
                _buildLogoutButton(context),
                const SizedBox(height: 50),
                _buildSupportFooter(),
              ],
            ),
          ),

          // 3. TOP BAR FIXÉE
          Positioned(
            top: 0, left: 0, right: 0,
            child: CustomTopBar(
              imagePath: 'assets/images/logo.png',
              onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              onNotificationTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
              onMenuTap: () {}, // Déjà sur le menu
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 15),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11, 
          fontWeight: FontWeight.w900, 
          color: Colors.grey[400], 
          letterSpacing: 1.5
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, {
    required IconData icon, 
    required String title, 
    String? subtitle, 
    required VoidCallback onTap
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), 
        borderRadius: BorderRadius.circular(20)
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Icon(icon, color: const Color(0xFFBC7400), size: 24),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: subtitle != null 
          ? Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])) 
          : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
      ),
    );
  }

  Widget _buildPillButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), 
          border: Border.all(color: const Color(0xFFBC7400), width: 1.2)
        ),
        child: Text(
          label, 
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _confirmLogout(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05), 
          borderRadius: BorderRadius.circular(20), 
          border: Border.all(color: Colors.red.withOpacity(0.1))
        ),
        child: const Center(
          child: Text(
            "Se déconnecter", 
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800, fontSize: 14)
          )
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Déconnexion", style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()),
            child: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30), 
        color: const Color(0xFFBC7400)
      ),
      child: const Column(
        children: [
          Icon(Icons.headset_mic_rounded, color: Colors.white, size: 30),
          SizedBox(height: 10),
          Text("Contact support", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          SizedBox(height: 8),
          Text("support@copplus.org", style: TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}