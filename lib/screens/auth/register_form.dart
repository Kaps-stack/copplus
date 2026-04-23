import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// --- IMPORTS DES FICHIERS EXTERNES ---
import '/providers/auth_provider.dart';
import '/routes/app_routes.dart';
import '/utils/location_data.dart';
import '/utils/app_constants.dart'; // Assure-toi que le nom du fichier est correct

class RegisterForm extends StatefulWidget {
  final String role;
  const RegisterForm({super.key, required this.role});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _data = {};
  int _pageIndex = 0;
  late List<List<Map<String, dynamic>>> _steps;

  final TextEditingController _birthdateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _identityCardFile;

  String? selectedCommune;
  String? selectedQuartier;
  bool isOtherQuartier = false;
  bool isOtherService = false; // Pour gérer le service "Autre"

  @override
  void initState() {
    super.initState();
    _data['role'] = widget.role;
    _data['country'] = "RD Congo";
    _data['province'] = "Kinshasa";
    _data['city_residence'] = "Kinshasa";
    _initializeSteps();
  }

  void _initializeSteps() {
    List<Map<String, dynamic>> step1 = [
      {'name': 'name', 'label': 'Nom complet', 'icon': Icons.person_outline, 'type': TextInputType.text},
      {'name': 'email', 'label': 'Adresse Email', 'icon': Icons.alternate_email, 'type': TextInputType.emailAddress},
      {'name': 'tel', 'label': 'Numéro de téléphone', 'icon': Icons.phone_android, 'type': TextInputType.phone},
      {'name': 'sex', 'label': 'Sexe', 'icon': Icons.wc_outlined, 'type': 'dropdown'},
      {'name': 'birthdate', 'label': 'Date de naissance', 'icon': Icons.calendar_today_outlined, 'type': 'date'},
    ];

    List<Map<String, dynamic>> step2 = [
      {'name': 'country', 'label': 'Pays', 'icon': Icons.public},
      {'name': 'city_residence', 'label': 'Ville', 'icon': Icons.location_city},
      {'name': 'common', 'label': 'Commune', 'icon': Icons.map_outlined},
      {'name': 'neighborhood', 'label': 'Quartier', 'icon': Icons.near_me_outlined},
      {'name': 'street', 'label': 'Rue / Avenue', 'icon': Icons.streetview_outlined},
      {'name': 'streetnumber', 'label': 'Numéro', 'icon': Icons.format_list_numbered_outlined},
    ];

    List<Map<String, dynamic>> step3 = widget.role == 'prestataire'
        ? [
            {'name': 'occupation', 'label': 'Occupation actuelle', 'icon': Icons.work_outline},
            {'name': 'service_offered', 'label': 'Service proposé', 'icon': Icons.handyman_outlined, 'type': 'dropdown'},
            {'name': 'education_level', 'label': 'Niveau d\'étude', 'icon': Icons.school_outlined, 'type': 'dropdown'},
            {'name': 'study_domain', 'label': 'Domaine d\'étude', 'icon': Icons.history_edu_outlined},
            {'name': 'languages', 'label': 'Langues (Français, Lingala...)', 'icon': Icons.translate},
            {'name': 'province_origin', 'label': 'Province d\'origine', 'icon': Icons.explore_outlined, 'type': 'dropdown'},
          ]
        : [
            {'name': 'occupation', 'label': 'Votre profession', 'icon': Icons.work_outline},
          ];

    List<Map<String, dynamic>> step4 = [
      if (widget.role == 'prestataire') ...[
        {'name': 'salary_min', 'label': 'Salaire Minimum (CDF)', 'icon': Icons.payments_outlined, 'type': TextInputType.number},
        {'name': 'salary_max', 'label': 'Salaire Maximum (CDF)', 'icon': Icons.payments_outlined, 'type': TextInputType.number},
        {'name': 'identity_card', 'label': 'Pièce d\'identité', 'icon': Icons.badge_outlined, 'type': 'file'},
      ],
      {'name': 'password', 'label': 'Mot de passe', 'icon': Icons.lock_outline, 'type': TextInputType.visiblePassword},
      {'name': 'password_confirmation', 'label': 'Confirmer mot de passe', 'icon': Icons.lock_reset, 'type': TextInputType.visiblePassword},
    ];

    _steps = [step1, step2, step3, step4];
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
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

  Widget _buildSmartField(Map<String, dynamic> field) {
    final name = field['name'];

    // Champs en lecture seule
    if (['country', 'province', 'city_residence'].contains(name)) {
      return TextFormField(
        initialValue: _data[name],
        readOnly: true,
        decoration: _buildInputDecoration(field['label'], field['icon']),
      );
    }

    // --- GESTION DES DROPDOWNS VIA APPCONSTANTS ---
    if (name == 'sex' || name == 'education_level' || name == 'province_origin' || name == 'service_offered') {
      
      // Cas spécifique pour le service "Autre"
      if (name == 'service_offered' && isOtherService) {
        return TextFormField(
          decoration: _buildInputDecoration("Précisez votre service", Icons.edit_note).copyWith(
            suffixIcon: IconButton(icon: const Icon(Icons.cancel), onPressed: () => setState(() => isOtherService = false)),
          ),
          onChanged: (val) => _data[name] = val,
          validator: (val) => (val == null || val.isEmpty) ? 'Requis' : null,
        );
      }

      List<String> options;
      if (name == 'sex') options = AppConstants.sexes;
      else if (name == 'education_level') options = AppConstants.niveauxEtude;
      else if (name == 'service_offered') options = AppConstants.servicesBase;
      else options = ProvincesData.provinceList;
      
      return DropdownButtonFormField<String>(
        key: ValueKey("dropdown_$name"),
        value: options.contains(_data[name]) ? _data[name] : null,
        decoration: _buildInputDecoration(field['label'], field['icon']),
        items: options.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
        onChanged: (val) {
          if (name == 'service_offered' && val == 'Autre') {
            setState(() => isOtherService = true);
          } else {
            setState(() => _data[name] = val);
          }
        },
        validator: (val) => val == null ? 'Obligatoire' : null,
      );
    }

    // Commune
    if (name == 'common') {
      List<String> options = (LocationData.data['RD Congo']['Kinshasa'] as Map<String, dynamic>).keys.toList();
      return DropdownButtonFormField<String>(
        value: options.contains(selectedCommune) ? selectedCommune : null,
        decoration: _buildInputDecoration(field['label'], field['icon']),
        items: options.map<DropdownMenuItem<String>>((String c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
        onChanged: (val) => setState(() {
          selectedCommune = val;
          selectedQuartier = null;
          isOtherQuartier = false;
          _data[name] = val;
        }),
      );
    }

    // Quartier
    if (name == 'neighborhood') {
      if (isOtherQuartier) {
        return TextFormField(
          decoration: _buildInputDecoration("Précisez le quartier", Icons.edit_location).copyWith(
            suffixIcon: IconButton(icon: const Icon(Icons.cancel), onPressed: () => setState(() => isOtherQuartier = false)),
          ),
          onChanged: (val) => _data[name] = val,
        );
      }
      List<String> qOptions = selectedCommune != null 
          ? (LocationData.data['RD Congo']['Kinshasa'][selectedCommune] as List).cast<String>().toList() 
          : [];
      return DropdownButtonFormField<String>(
        value: qOptions.contains(selectedQuartier) ? selectedQuartier : null,
        decoration: _buildInputDecoration(field['label'], field['icon']),
        items: [
          ...qOptions.map<DropdownMenuItem<String>>((q) => DropdownMenuItem<String>(value: q, child: Text(q))),
          const DropdownMenuItem<String>(value: "AUTRE", child: Text("➕ Autre...", style: TextStyle(color: Colors.blue))),
        ],
        onChanged: (val) {
          if (val == "AUTRE") setState(() => isOtherQuartier = true);
          else setState(() { selectedQuartier = val; _data[name] = val; });
        },
      );
    }

    // Pièce d'identité
    if (name == 'identity_card') {
      return InkWell(
        onTap: () async {
          final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
          if (file != null) setState(() { _identityCardFile = File(file.path); _data['identity_card'] = file.path; });
        },
        child: Container(
          height: 100,
          decoration: BoxDecoration(color: const Color(0xFFFAFAFA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
          child: _identityCardFile == null 
            ? const Center(child: Icon(Icons.add_a_photo_outlined, color: Colors.grey)) 
            : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_identityCardFile!, fit: BoxFit.cover, width: double.infinity)),
        ),
      );
    }

    // Champs texte classiques
    return TextFormField(
      key: ValueKey("field_$name"),
      controller: name == 'birthdate' ? _birthdateController : null,
      readOnly: name == 'birthdate',
      onTap: name == 'birthdate' ? () => _selectDate(context) : null,
      obscureText: name.toString().contains('password'),
      keyboardType: field['type'] is TextInputType ? field['type'] : TextInputType.text,
      decoration: _buildInputDecoration(field['label'], field['icon']),
      onChanged: (val) => _data[name] = val,
      validator: (val) => (val == null || val.isEmpty) ? 'Requis' : null,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: DateTime(2000), 
      firstDate: DateTime(1950), 
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFBC7400)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() {
      _birthdateController.text = DateFormat('dd/MM/yyyy').format(picked);
      _data['birthdate'] = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await context.read<AuthProvider>().register(_data);
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0, backgroundColor: Colors.white, centerTitle: true,
        leading: IconButton(
          icon: Icon(_pageIndex > 0 ? Icons.arrow_back_ios : Icons.close, color: Colors.black, size: 20),
          onPressed: () => _pageIndex > 0 ? setState(() => _pageIndex--) : Navigator.pop(context),
        ),
        title: Text(widget.role == 'prestataire' ? "Inscription Prestataire" : "Inscription Client",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(value: (_pageIndex + 1) / _steps.length, backgroundColor: Colors.grey[100], color: const Color(0xFFBC7400)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // LOGO SECTION
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFFBC7400), borderRadius: BorderRadius.circular(50)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.handshake, color: Colors.black, size: 25),
                          const SizedBox(width: 10),
                          RichText(text: const TextSpan(style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900), children: [
                            TextSpan(text: "COP", style: TextStyle(color: Colors.red)),
                            TextSpan(text: "PLUS", style: TextStyle(color: Colors.yellow)),
                          ])),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Inscription', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("Étape ${_pageIndex + 1} sur ${_steps.length}", style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 30),
                    
                    // CHAMPS DYNAMIQUES
                    ...(_steps[_pageIndex].map((field) => Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _buildSmartField(field),
                    )).toList()),

                    const SizedBox(height: 20),
                    // BOUTON DE NAVIGATION
                    SizedBox(width: double.infinity, height: 52, child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBC7400), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_pageIndex < _steps.length - 1) setState(() => _pageIndex++);
                          else _submit();
                        }
                      },
                      child: Text(_pageIndex == _steps.length - 1 ? "TERMINER" : "CONTINUER", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}