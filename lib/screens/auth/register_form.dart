import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:copplus/routes/app_routes.dart';
import 'package:copplus/providers/auth_provider.dart';
import '../../utils/app_constants.dart';

class RegisterForm extends StatefulWidget {
  final String role;
  const RegisterForm({super.key, required this.role});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Design System
  final Color brandGold = const Color(0xFFBC7400);
  final Color softGrey = const Color(0xFFF8F9FA);

  // Contrôleurs
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _serviceController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController(text: "Kinshasa"); // Ville figée

  File? _identityImage;
  final ImagePicker _picker = ImagePicker();
  final List<String> _quickPrices = ["5000", "15000", "25000", "50000"];

  int get _totalSteps => widget.role == 'prestataire' ? 4 : 2;

  // --- ACTIONS ---

  Future<void> _nextStep() async {
    if (_currentStep == 2 && widget.role == 'prestataire' && _identityImage == null) {
      _showSnackBar("Veuillez charger votre pièce d'identité", Colors.orange);
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() => _currentStep++);
      } else {
        _submitForm();
      }
    }
  }

  Future<void> _submitForm() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Map<String, dynamic> data = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'tel': _telController.text.trim(),
      'password': _passController.text,
      'password_confirmation': _confirmPassController.text,
      'role': widget.role,
    };

    if (widget.role == 'prestataire') {
      data.addAll({
        'service_offered': _serviceController.text,
        'monthly_price': _priceController.text,
        'city_residence': _cityController.text, // Kinshasa par défaut
        'identity_card': _identityImage,
      });
    }

    try {
      await authProvider.register(data);
      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) _showSnackBar(e.toString().replaceAll('Exception:', ''), Colors.redAccent);
    }
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),
                      _buildStepContent(),
                      const SizedBox(height: 40),
                      auth.isLoading 
                        ? const Center(child: CircularProgressIndicator()) 
                        : _buildActionButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  Widget _buildAppBar() => SliverAppBar(
    expandedHeight: 100, backgroundColor: Colors.white, elevation: 0, pinned: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
      onPressed: () => _currentStep > 0 ? setState(() => _currentStep--) : Navigator.pop(context),
    ),
    flexibleSpace: FlexibleSpaceBar(centerTitle: true, title: _badgeMini()),
  );

  Widget _buildHeader() {
    List<String> titles = widget.role == 'prestataire' 
        ? ["Infos personnelles", "Votre Expertise", "Vérification ID", "Sécurité"]
        : ["Créer un compte", "Sécurité"];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildStepIndicator(),
      const SizedBox(height: 20),
      Text(titles[_currentStep], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildStepContent() {
    if (widget.role == 'prestataire') {
      if (_currentStep == 0) return _buildPersoFields();
      if (_currentStep == 1) return _buildServiceFields();
      if (_currentStep == 2) return _buildIdentityFields();
      return _buildSecurityFields();
    } else {
      return _currentStep == 0 ? _buildPersoFields() : _buildSecurityFields();
    }
  }

  Widget _buildPersoFields() => Column(children: [
    _input(_nameController, "Nom Complet", Icons.person_outline),
    _input(_emailController, "Email", Icons.alternate_email, type: TextInputType.emailAddress),
    _input(_telController, "Téléphone", Icons.phone_android, type: TextInputType.phone),
  ]);

  Widget _buildServiceFields() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text("Quel service proposez-vous ?", style: TextStyle(fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    Wrap(spacing: 8, runSpacing: 8, children: AppConstants.servicesBase.map((s) {
      bool isSel = _serviceController.text == s;
      return ChoiceChip(
        label: Text(s), selected: isSel,
        onSelected: (v) => setState(() => _serviceController.text = v ? s : ""),
        selectedColor: brandGold.withOpacity(0.2), backgroundColor: softGrey,
        labelStyle: TextStyle(color: isSel ? brandGold : Colors.black, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
    }).toList()),
    const SizedBox(height: 25),
    const Text("Votre tarif (FC)", style: TextStyle(fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    Row(children: _quickPrices.map((p) => Expanded(child: GestureDetector(
      onTap: () => setState(() => _priceController.text = p),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: _priceController.text == p ? brandGold : softGrey, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(p, style: TextStyle(color: _priceController.text == p ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
      ),
    ))).toList()),
    _input(_priceController, "Prix personnalisé", Icons.payments_outlined, type: TextInputType.number),
    const SizedBox(height: 15),
    // VILLE FIGÉE ICI
    _input(_cityController, "Ville", Icons.location_city, readOnly: true, suffix: const Icon(Icons.lock_outline, size: 16, color: Colors.orange)),
  ]);

  Widget _buildIdentityFields() => Column(children: [
    const Text("Preuve d'identité (Carte d'électeur / Passeport)", textAlign: TextAlign.center),
    const SizedBox(height: 20),
    GestureDetector(
      onTap: () => _pickImage(ImageSource.gallery),
      child: Container(
        height: 200, width: double.infinity,
        decoration: BoxDecoration(color: softGrey, borderRadius: BorderRadius.circular(20), border: Border.all(color: brandGold.withOpacity(0.1))),
        child: _identityImage == null 
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, color: brandGold, size: 40), const Text("Ajouter la photo")])
          : ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(_identityImage!, fit: BoxFit.cover)),
      ),
    ),
  ]);

  Widget _buildSecurityFields() => Column(children: [
    _input(_passController, "Mot de passe", Icons.lock_outline, obscure: true),
    _input(_confirmPassController, "Confirmation", Icons.lock_reset, obscure: true),
  ]);

  // --- ATOMES UI ---

  Widget _input(TextEditingController c, String h, IconData i, {bool obscure = false, TextInputType type = TextInputType.text, bool readOnly = false, Widget? suffix}) => Padding(
    padding: const EdgeInsets.only(top: 15),
    child: TextFormField(
      controller: c, obscureText: obscure, keyboardType: type, readOnly: readOnly,
      validator: (v) => v!.isEmpty ? "Requis" : null,
      decoration: InputDecoration(
        filled: true, fillColor: softGrey, prefixIcon: Icon(i, color: brandGold, size: 20),
        suffixIcon: suffix, hintText: h,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _buildActionButton() => SizedBox(
    width: double.infinity, height: 58,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: brandGold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      onPressed: _nextStep,
      child: Text(_currentStep == _totalSteps - 1 ? "VALIDER" : "SUIVANT", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildStepIndicator() => Row(children: List.generate(_totalSteps, (i) => Expanded(child: Container(
    height: 4, margin: const EdgeInsets.symmetric(horizontal: 2),
    decoration: BoxDecoration(color: i <= _currentStep ? brandGold : softGrey, borderRadius: BorderRadius.circular(10)),
  ))));

  Widget _badgeMini() => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: brandGold, borderRadius: BorderRadius.circular(20)), child: const Text("COPPLUS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)));

  void _showSnackBar(String m, Color c) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c, behavior: SnackBarBehavior.floating));

  Future<void> _pickImage(ImageSource s) async {
    final p = await _picker.pickImage(source: s, imageQuality: 40);
    if (p != null) setState(() => _identityImage = File(p.path));
  }

 void _showSuccessDialog() {
  final bool isPrestataire = widget.role == 'prestataire';
  
  showDialog(
    context: context, 
    barrierDismissible: false, 
    builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Icon(isPrestataire ? Icons.access_time : Icons.check_circle_outline, 
               color: isPrestataire ? Colors.orange : Colors.green, size: 70),
          const SizedBox(height: 20),
          Text(isPrestataire ? "Demande en attente" : "Compte créé !", 
               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          Text(
            isPrestataire 
              ? "Votre profil de prestataire est en cours de vérification. Nous reviendrons vers vous par email." 
              : "Bienvenue chez COPPLUS ! Vous pouvez maintenant vous connecter.", 
            textAlign: TextAlign.center
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity, 
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: brandGold),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false),
              child: const Text("RETOUR À LA CONNEXION", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    ),
  );
}
}