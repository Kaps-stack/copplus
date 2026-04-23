import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/auth_provider.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final AppLinks _appLinks;
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) _parseUri(uri);
    } catch (e) {
      debugPrint('Erreur lien initial: $e');
    }

    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) _parseUri(uri);
    }, onError: (err) => debugPrint('Erreur stream liens: $err'));
  }

  void _parseUri(Uri uri) {
    final token = uri.queryParameters['token'];
    final email = uri.queryParameters['email'];
    setState(() {
      if (token != null) _tokenController.text = token;
      if (email != null) _emailController.text = email;
    });
  }

  void _resetPassword() async {
    final auth = context.read<AuthProvider>();

    if (_passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      await auth.resetPassword(
        _emailController.text.trim(),
        _tokenController.text.trim(),
        _passwordController.text.trim(),
        _passwordConfirmController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe réinitialisé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
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

  InputDecoration _buildInputDecoration(
    String label,
    IconData icon, {
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBC7400), width: 1.5),
      ),
    );
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
          icon: const Icon(Icons.close, color: Colors.black),
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
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.handshake,
                      color: Colors.black,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                      children: [
                        TextSpan(
                          text: "COP",
                          style: TextStyle(color: Colors.red),
                        ),
                        TextSpan(
                          text: "PLUS",
                          style: TextStyle(color: Colors.yellow),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            const Text(
              "Nouveau mot de passe",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Créez un mot de passe sécurisé que vous n'utilisez pas pour d'autres comptes.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 35),

            // Email (Lecture seule car vient du lien)
            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: _buildInputDecoration('Email', Icons.email_outlined),
            ),
            const SizedBox(height: 16),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: _buildInputDecoration(
                'Nouveau mot de passe',
                Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password
            TextField(
              controller: _passwordConfirmController,
              obscureText: _obscurePassword,
              decoration: _buildInputDecoration(
                'Confirmer le mot de passe',
                Icons.lock_reset,
              ),
            ),

            const SizedBox(height: 32),

            // Bouton de validation
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBC7400),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'RÉINITIALISER',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
