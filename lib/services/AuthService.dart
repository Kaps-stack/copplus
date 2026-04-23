import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Model/User.dart';
import '../config/app_config.dart';

class AuthService {
  final String baseUrl = AppConfig.getBaseUrl();

  Map<String, String> _headers([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // --- TON CODE D'ORIGINE POUR REGISTER ---
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _headers(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return {'user': User.fromJson(json['user']), 'token': json['token']};
    } else {
      throw Exception(response.body);
    }
  }

  // --- TON CODE D'ORIGINE POUR LOGIN ---
  Future<Map<String, dynamic>> login(String login, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers(),
      body: jsonEncode({'login': login, 'password': password}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return {'user': User.fromJson(json['user']), 'token': json['token']};
    } else {
      throw Exception(response.body);
    }
  }

  // --- AJOUT : UPDATE PROFILE (POUR GOOGLE) ---
  Future<User> updateProfile(Map<String, dynamic> data, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/update'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)['user']);
    } else {
      throw Exception(response.body);
    }
  }

  // --- TON CODE D'ORIGINE POUR LE RESTE ---
  Future<void> logout(String token) async {
    await http.post(Uri.parse('$baseUrl/logout'), headers: _headers(token));
  }

  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: _headers(),
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) throw Exception(response.body);
  }

  Future<void> resetPassword(
    String email,
    String token,
    String pass,
    String passConf,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'token': token,
        'password': pass,
        'password_confirmation': passConf,
      }),
    );
    if (response.statusCode != 200) throw Exception(response.body);
  }

  String getGoogleLoginUrl(String role) => '$baseUrl/login/google?role=$role';
}
