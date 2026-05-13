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

  // --- LOGIQUE CONSERVÉE À L'IDENTIQUE ---
  void _update() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text,
        'tel': _telController.text,
        'city_residence': _cityController.text,
        'sex': _selectedSex,
        'birthdate': _selectedBirthDate?.toIso8601String(),
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
        scrolledUnderElevation: 0,
        leading: const CloseButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          "Modifier le profil",
          style: TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.w800, 
            fontSize: 18, 
            letterSpacing: -0.5
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 20),
                  
                  // AVATAR PICKER STYLE MODERNE
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, 
                            border: Border.all(color: Colors.grey.shade100, width: 2)
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: _newImage != null 
                              ? FileImage(_newImage!) 
                              : (auth.user?.photo != null ? NetworkImage(auth.user!.photo!) : null) as ImageProvider?,
                            child: (_newImage == null && auth.user?.photo == null) 
                              ? Icon(Icons.person_outline, size: 50, color: Colors.grey.shade400) 
                              : null,
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final XFile? img = await picker.pickImage(source: ImageSource.gallery);
                              if (img != null) setState(() => _newImage = File(img.path));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3)
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  _buildModernInput("Nom complet", _nameController, Icons.person_outline),
                  _buildModernInput("Téléphone", _telController, Icons.phone_iphone_outlined, keyboardType: TextInputType.phone),
                  _buildModernInput("Ville de résidence", _cityController, Icons.location_on_outlined),
                  
                  // DATE DE NAISSANCE
                  _buildClickableInput(
                    "Date de naissance", 
                    _selectedBirthDate == null 
                        ? "Définir ma date" 
                        : DateFormat('dd MMMM yyyy').format(_selectedBirthDate!),
                    Icons.cake_outlined,
                    () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedBirthDate ?? DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(primary: Colors.black),
                            ),
                            child: child!,
                          );
                        }
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
          ),

          // BOUTON ENREGISTRER EN BAS (FLOTTANT OU FIXE)
          Padding(
            padding: EdgeInsets.only(
              left: 24, 
              right: 24, 
              bottom: MediaQuery.of(context).padding.bottom + 10,
              top: 10
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: auth.isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Enregistrer les modifications", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInput(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.black, size: 22),
              filled: true,
              fillColor: const Color(0xFFF8F8F8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black12, width: 1)),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableInput(String label, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.black, size: 22),
                  const SizedBox(width: 12),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSexPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            const Text("Sexe", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 20),
            _sexOption("Masculin", 'M'),
            const SizedBox(height: 10),
            _sexOption("Féminin", 'F'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sexOption(String title, String code) {
    bool isSelected = _selectedSex == code;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedSex = code);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: isSelected ? Colors.white : Colors.black, fontSize: 16)),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}