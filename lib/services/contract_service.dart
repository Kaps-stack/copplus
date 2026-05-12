import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/app_config.dart';

class ContractService {
  final String baseUrl = AppConfig.getBaseUrl();

  // --- HEADERS ---
  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // --- 1. RÉCUPÉRER LES CONTRATS DU CLIENT ---
  Future<List<dynamic>> getClientContracts(int clientId, String token) async {
    try {
      debugPrint("=== [API GET] Contrats Client ID: $clientId ===");
      final response = await http.get(
        Uri.parse('$baseUrl/my-contracts/client/$clientId'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : (data['data'] ?? []);
      }
    } catch (e) {
      debugPrint("!!! [ERREUR CRITIQUE] getClientContracts: $e");
    }
    return [];
  }

  // --- 2. RÉCUPÉRER LES CONTRATS DU PRESTATAIRE ---
  Future<List<dynamic>> getProviderContracts(int providerId, String token) async {
    try {
      debugPrint("=== [API GET] Contrats Prestataire ID: $providerId ===");
      final response = await http.get(
        Uri.parse('$baseUrl/my-contracts/provider/$providerId'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data : (data['data'] ?? []);
      }
    } catch (e) {
      debugPrint("!!! [ERREUR CRITIQUE] getProviderContracts: $e");
    }
    return [];
  }

  // --- 3. RÉCUPÉRER UN CONTRAT SPÉCIFIQUE (DETAILS) ---
  Future<dynamic> getContractDetails(int contractId, String token) async {
    try {
      debugPrint("=== [API GET] Détails Contrat ID: $contractId ===");
      final response = await http.get(
        Uri.parse('$baseUrl/contracts/$contractId'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      }
    } catch (e) {
      debugPrint("!!! [ERREUR CRITIQUE] getContractDetails: $e");
    }
    return null;
  }
}