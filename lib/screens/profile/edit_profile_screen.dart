import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _telController;
  late TextEditingController _cityController;
  String? _selectedSex;
  DateTime? _selectedBirthDate;
  File? _newImage;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _telController = TextEditingController(text: user?.tel);
    _cityController = TextEditingController(text: user?.cityResidence);
    _selectedSex = user?.sex;
    if (user?.birthdate != null) {
      _selectedBirthDate = DateTime.tryParse(user!.birthdate!);
    }
  }

  void _update() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text,
        'tel': _telController.text,
        'city_residence': _cityController.text,
        'sex': _selectedSex,
        'birthdate': _selectedBirthDate?.toIso8601String(), // Format technique pour l'API
        'photo': _newImage,
      };
      bool success = await context.read<AuthProvider>().updateProfile(data);
      if (success && mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    const Color brandGold = Color(0xFFBC7400);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const CloseButton(color: Colors.black),
        title: const Text("Modifier le profil", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
        actions: [
          TextButton(
            onPressed: auth.isLoading ? null : _update,
            child: auth.isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: brandGold))
              : const Text("Enregistrer", style: TextStyle(color: brandGold, fontWeight: FontWeight.w900, fontSize: 16)),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 20),
            
            // AVATAR PICKER
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[100]),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _newImage != null 
                        ? FileImage(_newImage!) 
                        : (auth.user?.photo != null ? NetworkImage(auth.user!.photo!) : null) as ImageProvider?,
                      child: (_newImage == null && auth.user?.photo == null) ? const Icon(Icons.person, size: 45, color: Colors.grey) : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final XFile? img = await picker.pickImage(source: ImageSource.gallery);
                        if (img != null) setState(() => _newImage = File(img.path));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2)
                        ),
                        child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            _buildModernInput("Nom complet", _nameController, Icons.person_outline),
            _buildModernInput("Téléphone", _telController, Icons.phone_android_outlined),
            _buildModernInput("Ville de résidence", _cityController, Icons.location_on_outlined),
            
            // DATE DE NAISSANCE (dd/MM/yyyy)
            _buildClickableInput(
              "Date de naissance", 
              _selectedBirthDate == null 
                  ? "Définir ma date" 
                  : DateFormat('dd/MM/yyyy').format(_selectedBirthDate!),
              Icons.cake_outlined,
              () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedBirthDate ?? DateTime(2000),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _selectedBirthDate = date);
              }
            ),

            // SEXE
            _buildClickableInput(
              "Sexe", 
              _selectedSex == 'M' ? "Masculin" : (_selectedSex == 'F' ? "Féminin" : "Choisir"),
              Icons.wc_outlined,
              () => _showSexPicker(context)
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInput(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black, size: 20),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: const Color(0xFFF6F6F6),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildClickableInput(String label, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }

  void _showSexPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("Sélectionnez votre sexe", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            _sexOption("Masculin", 'M'),
            _sexOption("Féminin", 'F'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sexOption(String title, String code) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: _selectedSex == code ? const Icon(Icons.check_circle, color: Colors.black) : null,
      onTap: () {
        setState(() => _selectedSex = code);
        Navigator.pop(context);
      },
    );
  }
}