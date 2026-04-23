import 'package:flutter/material.dart';

class CopplusHeader extends StatelessWidget implements PreferredSizeWidget {
  const CopplusHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFBC7400),
      elevation: 4,
      shadowColor: Colors.black26,
      centerTitle: false,
      title: Row(
        children: [
          // REMPLACEMENT DE L'ICÔNE PAR TON IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png', // <-- Vérifie bien le nom de ton fichier ici
              height: 35,               // Taille ajustée pour l'AppBar
              width: 35,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // En cas d'erreur de chargement, on affiche un petit carré vide ou une icône de secours
                return const Icon(Icons.broken_image, color: Colors.black26);
              },
            ),
          ),
          const SizedBox(width: 12),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 0.5,
                fontFamily: 'Roboto', // Ou ta police personnalisée
              ),
              children: [
                TextSpan(text: "COP", style: TextStyle(color: Colors.red)),
                TextSpan(text: "PLUS", style: TextStyle(color: Colors.yellow)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 30),
          onPressed: () {
            // Logique pour ouvrir le drawer si tu en as un
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}