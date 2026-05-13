import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart'; // Pour les constantes de route

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    const Color brandGold = Color(0xFFBC7400);

    // Fonction de formatage de date sécurisée (Logique conservée)
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return "Non définie";
      try {
        DateTime dt = DateTime.parse(dateStr);
        return DateFormat('dd/MM/yyyy').format(dt);
      } catch (e) {
        return dateStr;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // Evite l'ombre au scroll sur les versions récentes
        centerTitle: false,
        title: const Text(
          "Profil",
          style: TextStyle(
            color: Colors.black,
            fontSize: 32, // Plus grand, style iOS
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.black),
          onPressed: () async {
            // Logique de retour conservée
            bool canPop = Navigator.of(context).canPop();
            if (canPop) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () {
              // Logique existante pour les réglages ou l'édition
              Navigator.pushNamed(context, '/edit-profile');
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 30),

            // HEADER : Photo + Nom + Rôle (Style Instagram)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      // --- PHOTO DE PROFIL CLICABLE ---
                      GestureDetector(
                        onTap: () {
                          if (user?.photo != null) {
                            _showLargeProfilePhoto(context, user!.photo!);
                          } else {
                            // Optionnel: Afficher un message si pas de photo
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Pas de photo de profil définie")));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 48, // Plus grand
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: user?.photo != null
                                ? NetworkImage(user!.photo!)
                                : null,
                            child: user?.photo == null
                                ? Icon(Icons.person_outline, size: 50, color: Colors.grey.shade400)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),

                      // NOM ET ROLE
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? "Utilisateur",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black, // Couleur du rôle
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                user?.role?.toUpperCase() ?? "CLIENT",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // BOUTONS D'ACTION (Style Instagram)
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          text: "Modifier le profil",
                          onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                          icon: Icons.edit_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _actionButton(
                          text: "Partager le profil",
                          onPressed: () {
                            // Action de partage (logique à ajouter si besoin)
                          },
                          icon: Icons.share_outlined,
                          isSecondary: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // SECTIONS D'INFORMATIONS
            _buildInfoSection(context, title: "Informations personnelles", tiles: [
              _modernTile(Icons.email_outlined, "Email", user?.email ?? "-"),
              _modernTile(Icons.phone_iphone_outlined, "Téléphone", user?.tel ?? "-"),
              _modernTile(Icons.location_on_outlined, "Ville", user?.cityResidence ?? "-"),
              _modernTile(Icons.cake_outlined, "Date de naissance", formatDate(user?.birthdate)),
              _modernTile(
                user?.sex == 'M' ? Icons.male : Icons.female,
                "Sexe",
                user?.sex == 'M' ? 'Masculin' : (user?.sex == 'F' ? 'Féminin' : '-'),
              ),
            ]),

            if (user?.role == 'prestataire') ...[
              const SizedBox(height: 25),
              _buildInfoSection(context, title: "Détails professionnels", tiles: [
                _modernTile(Icons.work_outline, "Service", user?.serviceOffered ?? "Non défini", brandGold),
                _modernTile(Icons.payments_outlined, "Tarif mensuel", "${user?.monthlyPrice ?? 0} \$", brandGold),
              ]),
            ],

            const SizedBox(height: 60), // Espace en bas pour le scroll
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUTION DE L'UI ---

  // Pour grouper les tuiles par section
  Widget _buildInfoSection(BuildContext context, {required String title, required List<Widget> tiles}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title),
        const SizedBox(height: 8),
        ...tiles,
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _modernTile(IconData icon, String title, String value, [Color accentColor = Colors.black]) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Fond très légèrement grisé pour les tuiles
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1), // Bordure fine
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08), // Fond de l'icône
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: accentColor),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  // Widget pour les boutons d'action (Modifier/Partager)
  Widget _actionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isSecondary = false,
  }) {
    final Color bgColor = isSecondary ? Colors.grey.shade100 : Colors.blue.shade600; // Couleur primaire bleue
    final Color textColor = isSecondary ? Colors.black : Colors.white;

    return SizedBox(
      height: 48,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 19),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: -0.2),
        ),
      ),
    );
  }

  // --- LOGIQUE POUR AFFICHER LA PHOTO EN GRAND ---
  void _showLargeProfilePhoto(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true, // Ferme en cliquant à côté
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Fond transparent autour de la dialog
          insetPadding: const EdgeInsets.all(20), // Espace par rapport aux bords de l'écran
          child: Column(
            mainAxisSize: MainAxisSize.min, // S'adapte à la taille du contenu
            children: [
              // Bouton fermer en haut à droite
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 10),
              // Conteneur de l'image
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.6, // 60% de la hauteur de l'écran max
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.contain, // Ajuste l'image pour qu'elle rentre sans être coupée
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}