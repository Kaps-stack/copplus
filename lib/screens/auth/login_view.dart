import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '/providers/auth_provider.dart';
import '/screens/auth/forgot_password_screen.dart';
import 'register_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- STYLE INPUT MODERNE AVEC ICÔNE ---
  InputDecoration _buildInstagramInput(String label, IconData prefixIcon) {
    return InputDecoration(
      hintText: label,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      // Ajout de l'icône à gauche
      prefixIcon: Icon(prefixIcon, color: Colors.grey[400], size: 20),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
        ), // Un peu plus arrondi pour le look moderne
        borderSide: BorderSide(color: Colors.grey[300]!, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFBC7400), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 0.8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  void _handleLogin() async {
    // 1. Validation du formulaire (champs vides, etc.)
    if (_formKey.currentState!.validate()) {
      // 2. FORCE LA FERMETURE DU CLAVIER
      // Crucial pour éviter les bugs d'affichage lors de la transition
      FocusScope.of(context).unfocus();

      final authProvider = context.read<AuthProvider>();

      try {
        // 3. Appel à la fonction login de ton Provider
        await authProvider.login(
          _loginController.text,
          _passwordController.text,
        );

        // 4. SÉCURITÉ DE REDIRECTION
        // Normalement, le Consumer dans main.dart détecte le changement.
        // Si toutefois l'écran reste bloqué, on force le retour à la racine '/'
        // qui exécutera la logique de _getHome(auth) dans MyApp.
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted && authProvider.isAuthenticated) {
              // On vide la pile de navigation et on revient à la racine
              // pour forcer le MaterialApp à re-évaluer 'home'
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            }
          });
        }
      } catch (e) {
        // 5. GESTION DES ERREURS
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.error ??
                    'Identifiants incorrects ou erreur réseau',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- LOGO CAPSULE REPRODUIT ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBC7400),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png', // Ton image de poignée de main
                        height: 35,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.handshake,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
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
                  'Connexion',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 30),

                // --- FORMULAIRE ---
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // CHAMP TÉLÉPHONE AVEC ICÔNE
                      TextFormField(
                        controller: _loginController,
                        keyboardType: TextInputType.phone,
                        decoration: _buildInstagramInput(
                          'Téléphone ou email',
                          Icons.person_outline,
                        ),
                        validator: (val) =>
                            (val == null || val.isEmpty) ? 'Requis' : null,
                      ),
                      const SizedBox(height: 16),
                      // CHAMP MOT DE PASSE AVEC ICÔNE
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration:
                            _buildInstagramInput(
                              'Mot de passe',
                              Icons.lock_outline,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                        validator: (val) =>
                            (val == null || val.isEmpty) ? 'Requis' : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          ),
                          child: const Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(
                              color: Color(0xFF0095F6),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBC7400),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading ? null : _handleLogin,
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
                                  'Se connecter',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        "OU",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 20),

                TextButton.icon(
                  onPressed: _showRoleSelectionDialog,
                  icon: Image.asset(
                    'assets/images/google.png',
                    height: 18,
                    errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata),
                  ),
                  label: const Text(
                    "Se connecter avec Google",
                    style: TextStyle(
                      color: Color(0xFF385185),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Pas encore de compte ?",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(
                          color: Color(0xFF0095F6),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRoleSelectionDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Continuer en tant que...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: const Text("CLIENT"),
              onTap: () => _handleGoogleLogin('client'),
            ),
            ListTile(
              leading: const Icon(Icons.handyman, color: Color(0xFFBC7400)),
              title: const Text("PRESTATAIRE"),
              onTap: () => _handleGoogleLogin('prestataire'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGoogleLogin(String role) async {
    final authProvider = context.read<AuthProvider>();
    final url = authProvider.getGoogleUrl(role);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
