import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/app_config.dart';

class FindService {
  final String baseUrl = AppConfig.getBaseUrl();

  // --- HEADERS ---
  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // --- 1. ENVOYER UNE DEMANDE (CLIENT) ---
  Future<dynamic> postServiceRequest(Map<String, dynamic> body, String token) async {
    try {
      debugPrint("=== [API POST] Envoi vers /service-requests ===");
      final response = await http.post(
        Uri.parse('$baseUrl/service-requests'),
        headers: _headers(token),
        body: jsonEncode(body),
      );
      
      debugPrint("=== [API RESPONSE] Status: ${response.statusCode} ===");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      }
    } catch (e) {
      debugPrint("!!! [ERREUR CRITIQUE] postServiceRequest: $e");
    }
    return null;
  }

  // --- 2. RÉCUPÉRER LES MATCHES (CLIENT) ---
  Future<List<dynamic>> getMatches(int requestId, String token) async {
    try {
      debugPrint("=== [API GET] Récupération des matches pour ID: $requestId ===");
      final response = await http.get(
        Uri.parse('$baseUrl/service-requests/$requestId/matches'),
        headers: _headers(token),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : (data['data'] ?? []);
      }
    } catch (e) {
      debugPrint("!!! [ERREUR CRITIQUE] getMatches: $e");
    }
    return [];
  }

  // --- 3. PROPOSER UN RDV (CLIENT) ---
  // Route Laravel : Route::post('/matches/{id}/appointment', ...)
  Future<bool> sendAppointmentProposal(int matchId, Map<String, dynamic> data, String token) async {
    try {
      debugPrint("=== [API POST] Proposer RDV sur Match ID: $matchId ===");
      final response = await http.post(
        Uri.parse('$baseUrl/matches/$matchId/appointment'), 
        headers: _headers(token),
        body: jsonEncode(data),
      );

      debugPrint("=== [API RESPONSE RDV] Status: ${response.statusCode} ===");
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("!!! [ERREUR CRITIQUE] sendAppointmentProposal: $e");
      return false;
    }
  }

  // --- 4. RÉCUPÉRER LES MISSIONS PROPOSÉES (PRESTATAIRE) ---
  // Route Laravel : Route::get('/my-missions', ...)
  Future<List<dynamic>> getMyMissions(String token) async {
    try {
      debugPrint("=== [API GET] Récupération /my-missions ===");
      final response = await http.get(
        Uri.parse('$baseUrl/my-missions'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : (data['data'] ?? []);
      }
    } catch (e) {
      debugPrint("!!! [ERREUR CRITIQUE] getMyMissions: $e");
    }
    return [];
  }

  Future<List<dynamic>> getMyAppointments(String token) async {
  try {
    debugPrint("=== [API GET] Récupération /my-appointments ===");
    
    final response = await http.get(
      Uri.parse('$baseUrl/my-appointments'), // Vérifie que l'URL correspond à ta route Laravel
      headers: _headers(token),
    );

    debugPrint("DEBUG: Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // On log la data brute pour vérifier la structure (provider, service_request, etc.)
      debugPrint("DEBUG: Data reçue: $data");

      // Gestion flexible du format de réponse (liste directe ou objet avec clé 'data')
      if (data is List) {
        return data;
      } else if (data is Map && data.containsKey('data')) {
        return data['data'] ?? [];
      }
      return [];
    } else {
      debugPrint("!!! [ERREUR API] Status: ${response.statusCode} - Body: ${response.body}");
    }
  } catch (e) {
    debugPrint("!!! [ERREUR CRITIQUE] getMyAppointments: $e");
  }
  return [];
}

  // --- 5. ACCEPTER UNE MISSION (PRESTATAIRE) ---
  // Route Laravel : Route::post('/matches/{id}/accept', ...)
  Future<bool> acceptMission(int matchId, String token) async {
    try {
      debugPrint("=== [API POST] Acceptation Match ID: $matchId ===");
      final response = await http.post(
        Uri.parse('$baseUrl/matches/$matchId/accept'),
        headers: _headers(token),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("!!! [ERREUR CRITIQUE] acceptMission: $e");
      return false;
    }
  }

  // --- 6. HISTORIQUE DES DEMANDES (CLIENT) ---
  Future<List<dynamic>> getMyRequests(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my-requests'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : (data['data'] ?? []);
      }
    } catch (e) {
      debugPrint("!!! [ERREUR CRITIQUE] getMyRequests: $e");
    }
    return [];
  }
}