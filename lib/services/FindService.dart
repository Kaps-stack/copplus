import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../Model/service_request_model.dart'; 

class FindService {
  final String baseUrl = AppConfig.getBaseUrl();

  // 1. Envoyer une demande
  Future<void> postServiceRequest(Map<String, dynamic> data, String token) async {
    final response = await http.post(
      Uri.parse("$baseUrl/service-requests"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw error['message'] ?? "Erreur lors de l'enregistrement";
    }
  }

  // 2. Liste des demandes
  Future<List<dynamic>> getUserRequests(String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/my-service-requests"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['data'] ?? result;
    }
    throw "Erreur serveur";
  }

  // 3. Détails d'une demande
  Future<ServiceRequest> getRequestById(String token, int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/service-requests/$id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return ServiceRequest.fromJson(result['data'] ?? result);
    }
    throw "Détails introuvables";
  }
}