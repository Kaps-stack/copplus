import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../Model/user.dart';
import '../config/app_config.dart';

class AuthService {
  final String baseUrl = AppConfig.getBaseUrl();

  Map<String, String> _headers([String? token]) {
    final headers = {'Accept': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  /// LOGIN
  Future<Map<String, dynamic>> login(String login, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'login': login, 'password': password}),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return {
        'user': User.fromJson(json['user']), 
        'token': json['token']
      };
    }
    throw Exception(response.body);
  }

  /// REGISTER
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final json = await _sendMultipartRequest('/register', data);
    // On formate la réponse pour que le Provider reçoive un objet User typé
    return {
      'user': User.fromJson(json['user']),
      'token': json['token'], // Peut être null pour prestataire
      'message': json['message']
    };
  }

  /// UPDATE PROFILE
  Future<User> updateProfile(Map<String, dynamic> data, String token) async {
    final json = await _sendMultipartRequest('/profile/update', data, token: token);
    return User.fromJson(json['user']);
  }

  /// CORE MULTIPART METHOD
  Future<Map<String, dynamic>> _sendMultipartRequest(String path, Map<String, dynamic> data, {String? token, String method = 'POST'}) async {
    var request = http.MultipartRequest(method, Uri.parse('$baseUrl$path'));
    request.headers.addAll(_headers(token));

    for (var entry in data.entries) {
      if (entry.value == null) continue;
      if (entry.value is File) {
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value.path));
      } else {
        request.fields[entry.key] = entry.value.toString();
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      // Tente d'extraire le message d'erreur du JSON Laravel
      try {
        final errorJson = jsonDecode(response.body);
        throw Exception(errorJson['message'] ?? "Erreur serveur");
      } catch (_) {
        throw Exception("Erreur de connexion (${response.statusCode})");
      }
    }
  }

  Future<void> forgotPassword(String email) async {
    await http.post(Uri.parse('$baseUrl/forgot-password'), body: {'email': email});
  }

  Future<void> resetPassword(String email, String token, String pass, String passConf) async {
    await http.post(Uri.parse('$baseUrl/reset-password'), body: {
      'email': email, 'token': token, 'password': pass, 'password_confirmation': passConf
    });
  }

  Future<void> logout(String token) async {
    await http.post(Uri.parse('$baseUrl/logout'), headers: _headers(token));
  }

  String getGoogleLoginUrl(String role) => "$baseUrl/auth/google/url?role=$role";
}