import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Model/user.dart';
import '../services/auth_service.dart';

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
  bool get isProfileIncomplete => _user == null ? false : !_user!.isProfileComplete;
  bool get shouldShowCompleteProfileFlag => isAuthenticated && isProfileIncomplete;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final savedToken = await _storage.read(key: 'auth_token');
      final savedUserJson = await _storage.read(key: 'user_data');
      if (savedToken != null && savedUserJson != null) {
        _token = savedToken;
        _user = User.fromJson(jsonDecode(savedUserJson));
        debugPrint("🔐 [AUTH] Initialisé : ${_user?.name} (Complet: ${!isProfileIncomplete})");
      }
    } catch (e) {
      debugPrint("❌ [AUTH] Erreur Initialisation: $e");
      await logout();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> login(String login, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _authService.login(login, password);
      _user = result['user'];
      _token = result['token'];

      await _storage.write(key: 'auth_token', value: _token);
      await _storage.write(key: 'user_data', value: jsonEncode(_user!.toJson()));
      debugPrint("✅ [AUTH] Login réussi");
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ [AUTH] Erreur Login: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
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

      if (_token != null) {
        await _storage.write(key: 'auth_token', value: _token);
        await _storage.write(key: 'user_data', value: jsonEncode(_user!.toJson()));
      } else {
        await _storage.delete(key: 'auth_token');
        await _storage.delete(key: 'user_data');
      }
      debugPrint("✅ [AUTH] Inscription réussie");
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ [AUTH] Register Error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_token == null) {
      debugPrint("❌ [AUTH] UpdateProfile impossible: Token nul");
      return false;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    debugPrint("📡 [API] Envoi des données de mise à jour...");

    try {
      final updatedUser = await _authService.updateProfile(data, _token!);
      
      // Mise à jour de l'objet local avec les données fraîches du serveur
      _user = updatedUser;

      // Sauvegarde persistante
      await _storage.write(key: 'user_data', value: jsonEncode(_user!.toJson()));
      
      debugPrint("✅ [API] Profil mis à jour. Nouveau statut complet: ${!isProfileIncomplete}");
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint("❌ [API] Update Profile Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners(); // Déclenche la reconstruction de HomeView
    }
  }

  Future<void> updateLocation(double lat, double long) async {
    if (_token == null) return;
    try {
      debugPrint("📡 [API] Envoi GPS : $lat, $long");
      _user = await _authService.updateProfile({'latitude': lat, 'longitude': long}, _token!);
      await _storage.write(key: 'user_data', value: jsonEncode(_user!.toJson()));
      notifyListeners();
    } catch (e) {
      debugPrint("❌ [API] GPS Update Error: $e");
    }
  }

  Future<void> forgotPassword(String email) async => await _authService.forgotPassword(email);

  Future<void> resetPassword(String e, String t, String p, String pc) async =>
      await _authService.resetPassword(e, t, p, pc);

  Future<void> logout() async {
    try {
      if (_token != null) await _authService.logout(_token!);
    } catch (_) {}
    await _storage.deleteAll();
    _user = null;
    _token = null;
    _isInitialized = true;
    debugPrint("🚪 [AUTH] Déconnexion");
    notifyListeners();
  }

  String getGoogleUrl(String role) => _authService.getGoogleLoginUrl(role);
}