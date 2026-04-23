import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Model/User.dart';
import '../services/AuthService.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  bool get initialized => _isInitialized;
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  // Utilitaire pour la redirection
  bool get isProfileIncomplete {
    if (_user == null) return false;
    return (_user!.tel.isEmpty) || (_user!.common.isEmpty);
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    final savedToken = await _storage.read(key: 'auth_token');
    final savedUserJson = await _storage.read(key: 'user_data');
    if (savedToken != null && savedUserJson != null) {
      _token = savedToken;
      _user = User.fromJson(jsonDecode(savedUserJson));
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login(String login, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(login, password);

      // 1. Mise à jour des données
      _token = result['token'];
      _user = result['user'];

      // 2. Sauvegarde locale
      await _storage.write(key: 'auth_token', value: _token);
      await _storage.write(
        key: 'user_data',
        value: jsonEncode(_user!.toJson()),
      );

      // --- FORCE LA NOTIFICATION ICI ---
      _isLoading = false;
      notifyListeners();
      print("✅ Login réussi, notifyListeners appelé");
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _authService.register(data);
      _user = result['user'];
      _token = result['token'];
      await _storage.write(key: 'auth_token', value: _token);
      await _storage.write(
        key: 'user_data',
        value: jsonEncode(_user!.toJson()),
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- RESTAURATION : TES MÉTHODES D'ORIGINE ---
  Future<void> forgotPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.forgotPassword(email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(
    String email,
    String token,
    String pass,
    String passConf,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.resetPassword(email, token, pass, passConf);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// MISE À JOUR DU PROFIL
  /// Envoie les données au AuthService, met à jour l'utilisateur local
  /// et rafraîchit l'interface utilisateur.
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_token == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Appel au service (Laravel)
      final updatedUser = await _authService.updateProfile(data, _token!);

      // 2. Mise à jour de l'état local
      _user = updatedUser;

      // 3. Persistance dans le stockage sécurisé
      await _storage.write(
        key: 'user_data',
        value: jsonEncode(_user!.toJson()),
      );

      print("✅ Profil mis à jour et synchronisé");
      return true;
    } catch (e) {
      _error = e.toString();
      print("❌ Erreur lors de l'update : $_error");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) await _authService.logout(_token!);
    } finally {
      await _storage.deleteAll();
      _user = null;
      _token = null;
      notifyListeners();
    }
  }

  String getGoogleUrl(String role) => _authService.getGoogleLoginUrl(role);
}
