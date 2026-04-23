import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/auth_provider.dart';
import '/routes/app_routes.dart';
import '/widgets/custom_bottom_nav.dart'; // Import de ton nouveau widget unique
import '/widgets/custom_top_bar.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  // ProfileView.dart - Extrait corrigé du build
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFBC7400)),
        ),
      );
    }

    final bool isPrestataire = user.role.toLowerCase() == 'prestataire';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),

      // On retire l'appBar ici pour la mettre dans le Stack
      body: Stack(
        children: [
          // 1. CONTENU SCROLLABLE
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            // Padding top (110) pour la TopBar et bottom (130) pour la BottomNav
            padding: const EdgeInsets.fromLTRB(16, 110, 16, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(context, user, isPrestataire),
                const SizedBox(height: 25),
                _buildSectionTitle("Informations de base"),
                _buildInfoGrid([
                  _infoTile(Icons.alternate_email_rounded, "Email", user.email),
                  _infoTile(Icons.phone_iphone_rounded, "Téléphone", user.tel),
                  _infoTile(
                    Icons.face_retouching_natural_rounded,
                    "Sexe",
                    user.sex,
                  ),
                  _infoTile(
                    Icons.event_available_rounded,
                    "Naissance",
                    user.birthdate,
                  ),
                ]),
                const SizedBox(height: 25),
                _buildSectionTitle("Adresse & Résidence"),
                _buildModernCard(
                  child: Column(
                    children: [
                      _infoRow(
                        Icons.public_rounded,
                        "Pays / Province",
                        "${user.country} • ${user.province}",
                      ),
                      const Divider(height: 30, indent: 40),
                      _infoRow(
                        Icons.location_city_rounded,
                        "Ville / Commune",
                        "${user.cityResidence} • ${user.common}",
                      ),
                      const Divider(height: 30, indent: 40),
                      _infoRow(
                        Icons.map_rounded,
                        "Quartier",
                        user.neighborhood,
                      ),
                      const Divider(height: 30, indent: 40),
                      _infoRow(
                        Icons.home_rounded,
                        "Adresse précise",
                        "${user.street}, n°${user.streetNumber}",
                      ),
                    ],
                  ),
                ),
                if (isPrestataire) ...[
                  const SizedBox(height: 25),
                  _buildSectionTitle("Compétences & Expertise"),
                  _buildModernCard(
                    child: Column(
                      children: [
                        _infoRow(
                          Icons.verified_user_rounded,
                          "Service offert",
                          user.serviceOffered ?? "Non défini",
                          isBold: true,
                        ),
                        const Divider(height: 30, indent: 40),
                        _infoRow(
                          Icons.school_rounded,
                          "Formation",
                          "${user.educationLevel} (${user.studyDomain ?? 'N/A'})",
                        ),
                        const Divider(height: 30, indent: 40),
                        _infoRow(
                          Icons.translate_rounded,
                          "Langues parlées",
                          user.languages ?? "N/A",
                        ),
                        const Divider(height: 30, indent: 40),
                        _infoRow(
                          Icons.monetization_on_rounded,
                          "Tarif souhaité",
                          "${user.salaryMin} - ${user.salaryMax} \$ / h",
                          color: const Color(0xFFBC7400),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Vérification d'identité"),
                  _buildIdentitySection(user.identityCard),
                ],
              ],
            ),
          ),

          // 2. TOP BAR FIXÉE
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomTopBar(
              imagePath: 'assets/images/logo.png',
              onProfileTap: () {},
              onNotificationTap: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
              onMenuTap: () => Navigator.pushNamed(context, AppRoutes.menu),
            ),
          ),

          // 3. BARRE DE NAVIGATION COMMUNE
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNav(currentRoute: AppRoutes.profile),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---

  Widget _buildHeaderCard(
    BuildContext context,
    dynamic user,
    bool isPrestataire,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBC7400).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFBC7400),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  isPrestataire ? "Service : ${user.occupation}" : "Client",
                  style: const TextStyle(
                    color: Color(0xFFBC7400),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.editProfile),
            icon: const Icon(
              Icons.settings_suggest_rounded,
              color: Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF4A4A4A),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildModernCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoGrid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: children,
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFBC7400)),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF1A1A1A)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
                  color: color ?? const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdentitySection(String? path) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "DOCUMENTS VÉRIFIÉS",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: (path != null && path.isNotEmpty)
                ? (path.startsWith('http')
                      ? Image.network(
                          path,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _emptyDoc(),
                        )
                      : Image.file(
                          File(path),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _emptyDoc(),
                        ))
                : _emptyDoc(),
          ),
        ],
      ),
    );
  }

  Widget _emptyDoc() => Container(
    height: 150,
    width: double.infinity,
    color: Colors.white10,
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.qr_code_scanner_rounded, color: Colors.white24, size: 40),
        SizedBox(height: 8),
        Text(
          "Image non disponible",
          style: TextStyle(color: Colors.white24, fontSize: 12),
        ),
      ],
    ),
  );
}
