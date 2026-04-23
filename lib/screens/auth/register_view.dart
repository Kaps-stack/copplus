import 'package:flutter/material.dart';
import 'register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- TON BADGE COPPLUS ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFBC7400),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png', // Ton image de logo
                    height: 30,
                    errorBuilder: (c, e, s) => const Icon(Icons.handshake, color: Colors.black, size: 25),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      children: [
                        TextSpan(text: "COP", style: TextStyle(color: Colors.red)),
                        TextSpan(text: "PLUS", style: TextStyle(color: Colors.yellow)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            const Text(
              "Bienvenue",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Choisissez votre profil pour continuer l'inscription",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 50),

            // Option Client
            _buildRoleButton(
              context,
              title: "S'inscrire comme Client",
              subtitle: "Je cherche des services de qualité",
              icon: Icons.person_outline,
              role: 'client',
              isPrimary: true,
            ),
            
            const SizedBox(height: 16),

            // Option Prestataire
            _buildRoleButton(
              context,
              title: "Devenir Prestataire",
              subtitle: "Je souhaite proposer mes services",
              icon: Icons.handyman_outlined,
              role: 'prestataire',
              isPrimary: false,
            ),
            
            const SizedBox(height: 40),
            
            // Footer style Insta
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Déjà un compte ?", style: TextStyle(color: Colors.grey[600])),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(color: Color(0xFFBC7400), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String role,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RegisterForm(role: role)),
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          side: BorderSide(
            color: isPrimary ? const Color(0xFFBC7400) : Colors.grey[300]!,
            width: 1.5,
          ),
          backgroundColor: isPrimary ? const Color(0xFFBC7400) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: isPrimary ? 2 : 0,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : Colors.black87,
              size: 28,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isPrimary ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isPrimary ? Colors.white.withOpacity(0.8) : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isPrimary ? Colors.white : Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}