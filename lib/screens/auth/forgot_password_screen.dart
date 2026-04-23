import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  void _sendResetEmail() async {
    final auth = context.read<AuthProvider>();

    try {
      await auth.forgotPassword(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email envoyé ! Vérifiez votre boîte mail.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${auth.error ?? e}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 10),
            
            // --- TON BADGE COPPLUS CAPSULE ---
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
                    'assets/images/logo.png',
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
            
            const SizedBox(height: 50),
            
            // Icône Verrou Instagram Style
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: const Icon(Icons.lock_outline, size: 60, color: Colors.black),
            ),
            
            const SizedBox(height: 24),
            const Text(
              "Problèmes de connexion ?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Entrez votre adresse e-mail et nous vous enverrons un lien pour retrouver l'accès à votre compte.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
            ),
            
            const SizedBox(height: 35),
            
            // Champ Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Adresse Email',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: const Color(0xFFFAFAFA),
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFBC7400), width: 1.5),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bouton Principal Envoyer
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _sendResetEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBC7400),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Envoyer le lien',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Séparateur "OU"
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text("OU", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // --- BOUTON RETOUR À LA CONNEXION ARRANGÉ ---
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 10),
                    Text(
                      "Retour à la connexion",
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}