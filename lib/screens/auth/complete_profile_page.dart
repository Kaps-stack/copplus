import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final Color brandGold = const Color(0xFFBC7400);

  String? _city;
  String? _sex;
  double? _latitude;
  double? _longitude;
  DateTime? _birthDate;
  File? _imageFile;
  bool _isLocating = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<void> _selectDate() async {
    try {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime(2000),
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: brandGold, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        ),
      );
      if (picked != null) setState(() => _birthDate = picked);
    } catch (e) {
      debugPrint("❌ [UI] Erreur DatePicker: $e");
      _showSnackBar("Erreur calendrier.", Colors.red);
    }
  }

  Future<void> _getCurrentLocation() async {
    debugPrint("🛰️ [GPS] Démarrage de la localisation...");
    setState(() => _isLocating = true);
    
    try {
      // 1. Service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint("🛰️ [GPS] Service activé: $serviceEnabled");
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        throw "Le GPS est désactivé.";
      }

      // 2. Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint("🛰️ [GPS] Statut Permission: $permission");
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw "Permission refusée.";
      }

      // 3. Acquisition
      debugPrint("🛰️ [GPS] Tentative de lecture des coordonnées...");
      Position? position = await Geolocator.getLastKnownPosition();
      
      if (position != null) {
        debugPrint("🛰️ [GPS] Dernière position connue trouvée");
      } else {
        debugPrint("🛰️ [GPS] Aucune position en cache, appel au capteur (10s max)...");
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );
      }

      setState(() {
        _latitude = position!.latitude;
        _longitude = position.longitude;
      });
      
      debugPrint("🛰️ [GPS] Succès: Lat=$_latitude, Long=$_longitude");
      _showSnackBar("Position capturée !", Colors.green);

    } catch (e) {
      debugPrint("❌ [GPS] ERREUR FATALE: $e");
      _showSnackBar("Erreur GPS: $e", Colors.orange);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bool isClient = auth.user?.role.toLowerCase() == 'client';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, centerTitle: true,
        title: Text("Finalisation", style: TextStyle(color: brandGold, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildAvatar(),
                const SizedBox(height: 40),
                if (isClient) ...[
                  _modernInput(hint: "Ville de résidence", icon: Icons.location_city, onSaved: (v) => _city = v),
                  const SizedBox(height: 15),
                  _modernSelect(
                    hint: "Sexe", icon: Icons.wc_outlined,
                    items: const [
                      DropdownMenuItem(value: "M", child: Text("Homme")),
                      DropdownMenuItem(value: "F", child: Text("Femme")),
                    ],
                    onChanged: (val) => setState(() => _sex = val),
                  ),
                  const SizedBox(height: 15),
                ],
                _inkField(
                  onTap: _selectDate,
                  icon: Icons.cake_outlined,
                  text: _birthDate == null ? "Date de naissance" : DateFormat('dd MMMM yyyy').format(_birthDate!),
                ),
                const SizedBox(height: 25),
                _buildLocationCard(),
                const SizedBox(height: 40),
                _buildSubmitButton(auth, isClient),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 65, backgroundColor: const Color(0xFFF5F5F5),
            backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
            child: _imageFile == null ? Icon(Icons.camera_alt_outlined, size: 40, color: brandGold) : null,
          ),
          CircleAvatar(backgroundColor: brandGold, radius: 20, child: const Icon(Icons.add, color: Colors.white, size: 18)),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return GestureDetector(
      onTap: _getCurrentLocation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _latitude != null ? Colors.green.withOpacity(0.08) : brandGold.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _latitude != null ? Colors.green : brandGold.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(_latitude != null ? Icons.check_circle : Icons.location_on, 
                 color: _latitude != null ? Colors.green : brandGold),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                _latitude != null ? "Position capturée (${_latitude!.toStringAsFixed(3)})" : "Activer la géolocalisation",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            if (_isLocating) const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFBC7400))),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AuthProvider auth, bool isClient) {
    return SizedBox(
      width: double.infinity, height: 58,
      child: ElevatedButton(
        onPressed: (auth.isLoading || _isLocating) ? null : () async {
          debugPrint("🚀 [UI] Tentative de soumission finale...");
          if (_imageFile == null) { _showSnackBar("Photo requise", Colors.orange); return; }
          if (_latitude == null) { _showSnackBar("Position GPS manquante", Colors.orange); return; }
          if (_birthDate == null) { _showSnackBar("Date de naissance manquante", Colors.orange); return; }
          
          _formKey.currentState!.save();
          
          final Map<String, dynamic> data = {
            'latitude': _latitude,
            'longitude': _longitude,
            'birthdate': _birthDate?.toIso8601String(),
            'photo': _imageFile,
          };

          if (isClient) {
            data['city_residence'] = _city;
            data['sex'] = _sex;
          }

          debugPrint("🚀 [UI] Appel updateProfile Provider...");
          bool success = await auth.updateProfile(data);
          if (success && mounted) {
            debugPrint("✅ [UI] Succès total, redirection Home");
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
          } else {
            debugPrint("❌ [UI] Échec de la mise à jour profil");
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: brandGold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        child: auth.isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text("TERMINER L'INSCRIPTION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() => Column(children: [
    const Text("Profil Complet", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
    const SizedBox(height: 8),
    const Text("Dernière étape pour finaliser", style: TextStyle(color: Colors.grey)),
  ]);

  Widget _modernInput({required String hint, required IconData icon, required Function(String?) onSaved}) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(15)),
    child: TextFormField(onSaved: onSaved, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: brandGold), border: InputBorder.none)),
  );

  Widget _inkField({required VoidCallback onTap, required IconData icon, required String text}) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
      decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(15)),
      child: Row(children: [Icon(icon, color: brandGold), const SizedBox(width: 15), Text(text, style: const TextStyle(fontSize: 15))]),
    ),
  );

  Widget _modernSelect({required String hint, required IconData icon, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(color: const Color(0xFFF8F8F8), borderRadius: BorderRadius.circular(15)),
    child: DropdownButtonFormField<String>(items: items, onChanged: onChanged, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: brandGold), border: InputBorder.none)),
  );

  void _showSnackBar(String msg, Color color) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
}