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

    // Fonction de formatage de date sécurisée
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
        centerTitle: false,
        title: const Text(
          "Compte",
          style: TextStyle(
            color: Colors.black, 
            fontSize: 28, 
            fontWeight: FontWeight.w800, 
            letterSpacing: -1.2
          ),
        
        ),
        leading: IconButton(
  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
  onPressed: () async {
    // maybePop vérifie s'il y a une page avant. 
    // Si non (canPop = false), on force le retour vers l'accueil.
    bool canPop = Navigator.of(context).canPop();
    if (canPop) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  },
),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFF5F5F5),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.black, size: 20),
                onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            
            // HEADER : Photo + Nom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: brandGold.withOpacity(0.3), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFFF0F0F0),
                      backgroundImage: user?.photo != null ? NetworkImage(user!.photo!) : null,
                      child: user?.photo == null 
                          ? const Icon(Icons.person_outline, size: 40, color: Colors.grey) 
                          : null,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? "Utilisateur",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user?.role?.toUpperCase() ?? "CLIENT",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            _sectionHeader("Informations personnelles"),
            _modernTile(Icons.email_outlined, "Email", user?.email ?? "-"),
            _modernTile(Icons.phone_iphone_outlined, "Téléphone", user?.tel ?? "-"),
            _modernTile(Icons.location_on_outlined, "Ville de résidence", user?.cityResidence ?? "-"),
            _modernTile(Icons.cake_outlined, "Date de naissance", formatDate(user?.birthdate)),
            _modernTile(
              user?.sex == 'M' ? Icons.male : Icons.female, 
              "Sexe", 
              user?.sex == 'M' ? 'Masculin' : (user?.sex == 'F' ? 'Féminin' : '-')
            ),

            if (user?.role == 'prestataire') ...[
              const SizedBox(height: 20),
              _sectionHeader("Détails professionnels"),
              _modernTile(Icons.work_outline, "Service proposé", user?.serviceOffered ?? "Non défini"),
              _modernTile(Icons.payments_outlined, "Tarif mensuel", "${user?.monthlyPrice ?? 0} \$"),
            ],
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 15),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w800, letterSpacing: 1.2),
      ),
    );
  }

  Widget _modernTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}