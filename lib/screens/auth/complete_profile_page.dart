import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _data = {};
  File? _idFile;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text("Finaliser le profil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Complétez vos informations pour accéder à l'application.",
              ),
              const SizedBox(height: 20),

              if (user?.tel == null || user!.tel.isEmpty)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Téléphone",
                    prefixIcon: Icon(Icons.phone),
                  ),
                  onSaved: (v) => _data['tel'] = v,
                ),

              if (user?.common == null)
                const Text("Ici vos dropdowns de Commune/Quartier..."),

              if (user?.role == 'prestataire' && user?.identityCard == null)
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text("Photo Carte d'Identité"),
                  subtitle: Text(
                    _idFile == null ? "Aucun fichier" : "Fichier prêt",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                      );
                      if (picked != null)
                        setState(() => _idFile = File(picked.path));
                    },
                  ),
                ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          _formKey.currentState!.save();
                          if (_idFile != null)
                            _data['identity_card'] = _idFile!.path;
                          await auth.updateProfile(_data);
                        },
                  child: auth.isLoading
                      ? const CircularProgressIndicator()
                      : const Text("TERMINER"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
