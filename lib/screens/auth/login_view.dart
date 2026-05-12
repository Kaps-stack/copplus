import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart'; 
import 'package:copplus/routes/app_routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Color brandGold = const Color(0xFFBC7400);

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint("⚠️ Validation locale échouée");
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    debugPrint("🚀 Tentative de connexion...");
    debugPrint("📧 Login: ${_loginController.text.trim()}");

    try {
      await authProvider.login(
        _loginController.text.trim(),
        _passwordController.text,
      );

      debugPrint("✅ Connexion réussie !");

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      }
    } catch (e) {
      debugPrint("❌ Erreur de connexion : $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black)
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildBadgeHeader(brandGold),
                  const SizedBox(height: 50),
                  const Text("Bon retour !", 
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  const Text("Connectez-vous pour continuer", 
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 40),
                  
                  _modernInput(
                    "Email ou Téléphone", 
                    Icons.alternate_email, 
                    controller: _loginController,
                    validator: (v) => v!.isEmpty ? "Identifiant requis" : null,
                  ),
                  
                  _modernInput(
                    "Mot de passe", 
                    Icons.lock_outline, 
                    obscure: true, 
                    controller: _passwordController,
                    validator: (v) => v!.isEmpty ? "Mot de passe requis" : null,
                  ),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        debugPrint("🔗 Clic sur Mot de passe oublié");
                      }, 
                      child: const Text("Mot de passe oublié ?", 
                          style: TextStyle(color: Color(0xFF0095F6), fontWeight: FontWeight.bold))
                    ),
                  ),
                  const SizedBox(height: 10),

                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return auth.isLoading 
                        ? const CircularProgressIndicator()
                        : _mainButton("SE CONNECTER", brandGold, onPressed: _handleLogin);
                    }
                  ),

                  const SizedBox(height: 30),
                  _buildDivider(),
                  const SizedBox(height: 30),
                  _googleButton(),
                  const SizedBox(height: 50),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeHeader(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(50)),
      child: const Text("COPPLUS", 
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
    );
  }

  Widget _modernInput(String hint, IconData icon, 
      {bool obscure = false, TextEditingController? controller, String? Function(String?)? validator}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA), 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: Colors.grey[200]!)
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20), 
          hintText: hint, 
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10)
        ),
      ),
    );
  }

  Widget _mainButton(String text, Color color, {required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, 
          elevation: 0, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
        ),
        child: Text(text, 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10), 
          child: Text("OU", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }

  Widget _googleButton() {
    return SizedBox(
      width: double.infinity, height: 55,
      child: OutlinedButton.icon(
        onPressed: () => debugPrint("🚀 Google Login Pressed"),
        style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey[200]!), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        icon: const Image(image: AssetImage('assets/images/google.png'), height: 24),
        label: const Text("Continuer avec Google", 
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- NOUVELLE MÉTHODE POUR LE SÉLECTEUR DE RÔLE (COMME DANS WELCOME) ---
  void _showRoleSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Choisissez votre profil",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _roleTile(context, "Client", "Je cherche un service",
                Icons.person_outline, "client"),
            const SizedBox(height: 12),
            _roleTile(context, "Prestataire", "Je propose mes services",
                Icons.handyman_outlined, "prestataire"),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET POUR LES OPTIONS DU MODAL ---
  Widget _roleTile(BuildContext context, String title, String sub,
      IconData icon, String role) {
    return ListTile(
      onTap: () {
        Navigator.pop(context); // Ferme le modal
        Navigator.pushNamed(context, AppRoutes.register, arguments: role);
      },
      leading: CircleAvatar(
        backgroundColor: brandGold.withOpacity(0.1),
        child: Icon(icon, color: brandGold),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Vous n'avez pas de compte ? "),
        GestureDetector(
          onTap: () {
            _showRoleSelector(context); // Ouvre maintenant le sélecteur de rôle
          },
          child: const Text("S'inscrire", 
              style: TextStyle(color: Color(0xFF0095F6), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}