import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/providers/auth_provider.dart';
import '/routes/app_routes.dart';
import '/utils/location_data.dart';
import '/widgets/custom_bottom_nav.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _telController;
  late TextEditingController _birthdateController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _streetController;
  late TextEditingController _streetNumberController;
  late TextEditingController _occupationController;
  late TextEditingController _serviceOfferedController;
  late TextEditingController _salaryMinController;
  late TextEditingController _salaryMaxController;
  late TextEditingController _studyDomainController;
  late TextEditingController _languagesController;

  String? _selectedSex;
  String? _selectedCommune;
  String? _selectedQuartier;
  String? _selectedEducation;

  String? _newIdentityCardPath;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;

    _nameController = TextEditingController(text: user?.name ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
    _telController = TextEditingController(text: user?.tel ?? "");
    _birthdateController = TextEditingController(text: user?.birthdate ?? "");
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _streetController = TextEditingController(text: user?.street ?? "");
    _streetNumberController = TextEditingController(
      text: user?.streetNumber ?? "",
    );
    _occupationController = TextEditingController(text: user?.occupation ?? "");
    _serviceOfferedController = TextEditingController(
      text: user?.serviceOffered ?? "",
    );
    _salaryMinController = TextEditingController(
      text: user?.salaryMin?.toString() ?? "",
    );
    _salaryMaxController = TextEditingController(
      text: user?.salaryMax?.toString() ?? "",
    );
    _studyDomainController = TextEditingController(
      text: user?.studyDomain ?? "",
    );
    _languagesController = TextEditingController(text: user?.languages ?? "");

    _selectedSex = user?.sex;
    _selectedCommune = user?.common;
    _selectedQuartier = user?.neighborhood;
    _selectedEducation = user?.educationLevel;
  }

  Future<void> _pickIdCard() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _newIdentityCardPath = image.path);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _birthdateController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _streetController.dispose();
    _streetNumberController.dispose();
    _occupationController.dispose();
    _serviceOfferedController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _studyDomainController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  void _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      final user = context.read<AuthProvider>().user;
      final bool isPrestataire = user?.role.toLowerCase() == 'prestataire';

      final Map<String, dynamic> data = {
        'name': _nameController.text.trim(),
        'tel': _telController.text.trim(),
        'sex': _selectedSex ?? "",
        'birthdate': _birthdateController.text.trim(),
        'common': _selectedCommune ?? "",
        'neighborhood': _selectedQuartier ?? "",
        'street': _streetController.text.trim(),
        'streetnumber': _streetNumberController.text.trim(),
        'occupation': _occupationController.text.trim(),
        'identity_card': _newIdentityCardPath ?? user?.identityCard ?? "",
      };

      if (isPrestataire) {
        data.addAll({
          'education_level': _selectedEducation ?? "",
          'service_offered': _serviceOfferedController.text.trim(),
          'languages': _languagesController.text.trim(),
          'salary_min': _salaryMinController.text.trim(),
          'salary_max': _salaryMaxController.text.trim(),
          'study_domain': _studyDomainController.text.trim(),
        });
      }

      if (_newPasswordController.text.isNotEmpty) {
        data['old_password'] = _oldPasswordController.text;
        data['password'] = _newPasswordController.text;
      }

      setState(() => _isLoading = true);
      final success = await context.read<AuthProvider>().updateProfile(data);
      setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profil mis à jour !"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final bool isPrestataire = user.role.toLowerCase() == 'prestataire';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Modifier le profil",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(15),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              onPressed: _submitUpdate,
              icon: const Icon(
                Icons.check_circle,
                color: Color(0xFFBC7400),
                size: 28,
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // 1. LE FORMULAIRE SCROLLABLE
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              // Padding important pour laisser la place au menu flottant en bas
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
              child: Column(
                children: [
                  _buildSectionHeader("Sécurité"),
                  _buildTextField(
                    "Ancien mot de passe",
                    _oldPasswordController,
                    Icons.lock_person_outlined,
                    isPassword: true,
                    obscureVar: _obscureOldPassword,
                    onToggle: () => setState(
                      () => _obscureOldPassword = !_obscureOldPassword,
                    ),
                  ),
                  _buildTextField(
                    "Nouveau mot de passe",
                    _newPasswordController,
                    Icons.lock_reset,
                    isPassword: true,
                    obscureVar: _obscureNewPassword,
                    onToggle: () => setState(
                      () => _obscureNewPassword = !_obscureNewPassword,
                    ),
                  ),

                  _buildSectionHeader("Informations de base"),
                  _buildTextField(
                    "Nom complet",
                    _nameController,
                    Icons.person_outline,
                  ),
                  _buildTextField(
                    "Téléphone",
                    _telController,
                    Icons.phone_android_outlined,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          "Sexe",
                          Icons.wc,
                          ['M', 'F'],
                          _selectedSex,
                          (val) => setState(() => _selectedSex = val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDatePicker(
                          "Date de naissance",
                          _birthdateController,
                        ),
                      ),
                    ],
                  ),

                  _buildSectionHeader("Localisation"),
                  _buildDropdownField(
                    "Commune",
                    Icons.location_city,
                    LocationData.data['RD Congo']['Kinshasa'].keys
                        .cast<String>()
                        .toList(),
                    _selectedCommune,
                    (val) => setState(() {
                      _selectedCommune = val;
                      _selectedQuartier = null;
                    }),
                  ),
                  _buildDropdownField(
                    "Quartier",
                    Icons.near_me_outlined,
                    (_selectedCommune != null &&
                            LocationData
                                    .data['RD Congo']?['Kinshasa']?[_selectedCommune] !=
                                null)
                        ? List<String>.from(
                            LocationData
                                .data['RD Congo']['Kinshasa'][_selectedCommune],
                          )
                        : [],
                    _selectedQuartier,
                    (val) => setState(() => _selectedQuartier = val),
                  ),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          "Rue / Avenue",
                          _streetController,
                          Icons.streetview,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: _buildTextField(
                          "N°",
                          _streetNumberController,
                          Icons.numbers,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),

                  _buildSectionHeader("Document d'identité"),
                  _buildIdCardPicker(user.identityCard),

                  if (isPrestataire) ...[
                    _buildSectionHeader("Expertise Métier"),
                    _buildDropdownField(
                      "Niveau d'étude",
                      Icons.school_outlined,
                      [
                        'Primaire',
                        'Diplôme d\'Etat',
                        'Licence',
                        'Master',
                        'Doctorat',
                      ],
                      _selectedEducation,
                      (val) => setState(() => _selectedEducation = val),
                    ),
                    _buildTextField(
                      "Service proposé",
                      _serviceOfferedController,
                      Icons.handyman_outlined,
                    ),
                    _buildTextField(
                      "Langues parlées",
                      _languagesController,
                      Icons.translate,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "Tarif Min",
                            _salaryMinController,
                            Icons.remove_circle_outline,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            "Tarif Max",
                            _salaryMaxController,
                            Icons.add_circle_outline,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 2. BARRE DE NAVIGATION FIXÉE (en bas du Stack)
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNav(currentRoute: AppRoutes.profile),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS UI ---
  Widget _buildIdCardPicker(String? currentPath) {
    final String? pathToDisplay = _newIdentityCardPath ?? currentPath;
    return GestureDetector(
      onTap: _pickIdCard,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFBC7400).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: pathToDisplay != null && pathToDisplay.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: pathToDisplay.startsWith('http')
                    ? Image.network(
                        pathToDisplay,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.broken_image),
                      )
                    : Image.file(
                        File(pathToDisplay),
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.broken_image),
                      ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 40,
                    color: Color(0xFFBC7400),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Modifier la carte d'identité",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 25, bottom: 12, left: 5),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Color(0xFFBC7400),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    bool isPassword = false,
    bool? obscureVar,
    VoidCallback? onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? (obscureVar ?? true) : false,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFFBC7400)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (obscureVar ?? true)
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: onToggle,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    IconData icon,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<String>(
        value: (value != null && items.contains(value)) ? value : null,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFFBC7400)),
          border: InputBorder.none,
        ),
        items: items
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (picked != null)
          setState(
            () => controller.text = DateFormat('yyyy-MM-dd').format(picked),
          );
      },
      child: IgnorePointer(
        child: _buildTextField(
          label,
          controller,
          Icons.calendar_today_outlined,
        ),
      ),
    );
  }
}
