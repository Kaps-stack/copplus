import 'package:flutter/material.dart';
import '/routes/app_routes.dart';
import '/widgets/custom_bottom_nav.dart';
import '/widgets/custom_top_bar.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color brandGold = Color(0xFFBC7400);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Blanc cassé luxe
      bottomNavigationBar: const CustomBottomNav(currentRoute: AppRoutes.menu),
      body: Stack(
        children: [
          // CONTENU SCROLLABLE
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            // Padding ajusté pour CustomTopBar et CustomBottomNav
            padding: const EdgeInsets.fromLTRB(24, 120, 24, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Paramètres du compte"),
                _buildMenuTile(
                  context,
                  icon: Icons.person_outline_rounded,
                  title: "Informations du profil",
                  subtitle: "Nom, téléphone, adresse et documents",
                  onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                ),

                const SizedBox(height: 35),

                _buildSectionHeader("À propos de COP PLUS"),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildPillButton("Qui Sommes-nous ?", () => Navigator.pushNamed(context, AppRoutes.about, arguments: 0)),
                    _buildPillButton("Nos valeurs", () => Navigator.pushNamed(context, AppRoutes.about, arguments: 1)),
                    _buildPillButton("FAQ", () => Navigator.pushNamed(context, AppRoutes.about, arguments: 2)),
                    _buildPillButton("Confidentialité", () => Navigator.pushNamed(context, AppRoutes.about, arguments: 3)),
                  ],
                ),

                const SizedBox(height: 40),

                _buildSectionHeader("Assistance & Partage"),
                _buildMenuTile(
                  context,
                  icon: Icons.chat_bubble_outline_rounded,
                  title: "Centre d'aide",
                  subtitle: "Discuter avec un conseiller",
                  onTap: () => debugPrint("Lien WhatsApp"),
                ),
                _buildMenuTile(
                  context,
                  icon: Icons.ios_share_rounded,
                  title: "Recommander l'app",
                  subtitle: "Partager COP PLUS avec vos proches",
                  onTap: () => debugPrint("Share sheet"),
                ),

                const SizedBox(height: 40),
                _buildLogoutButton(context),
                const SizedBox(height: 40),
                _buildSupportCard(brandGold),
              ],
            ),
          ),

          // TOP BAR FIXÉE
          Positioned(
            top: 0, left: 0, right: 0,
            child: CustomTopBar(
              imagePath: 'assets/images/logo.png',
              onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              onNotificationTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
              onMenuTap: () {}, 
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.grey.shade500,
          letterSpacing: 1.8,
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
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.black, size: 22),
        ),
        title: Text(
          title, 
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.3)
        ),
        subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w400))
          : null,
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildPillButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEB), // Rouge très pâle
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => _confirmLogout(context),
        borderRadius: BorderRadius.circular(20),
        child: const Center(
          child: Text(
            "Se déconnecter",
            style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w900, fontSize: 15),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: const Text("Déconnexion", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -1)),
        content: const Text("Voulez-vous vraiment quitter l'application ?", style: TextStyle(fontSize: 16)),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Annuler", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700))
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(Color accentColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: accentColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: accentColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.headset_mic_rounded, color: accentColor, size: 28),
          ),
          const SizedBox(height: 16),
          const Text("Support Client", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(
            "Une question ? Nous sommes là pour vous aider.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Text(
            "support@copplus.org",
            style: TextStyle(color: accentColor, fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ],
      ),
    );
  }
}