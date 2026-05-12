import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/app_config.dart';

class AnnouncementsService {
  final String baseUrl = AppConfig.getBaseUrl();

  Future<List<dynamic>> getAnnouncements(String token) async {
    try {
      debugPrint("🚀 [DEBUG] URL d'appel : $baseUrl/announcements");
      
      final response = await http.get(
        Uri.parse("$baseUrl/announcements"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint("📡 [DEBUG] Statut HTTP : ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // On vérifie la structure brute du JSON
        debugPrint("📦 [DEBUG] JSON Brut reçu : ${response.body}");

        if (data is Map && data.containsKey('data')) {
          List<dynamic> list = data['data'];
          
          debugPrint("📋 [DEBUG] Nombre d'annonces trouvées : ${list.length}");

          // On transforme les URLs pour l'émulateur
          return list.map((item) {
            String? originalUrl = item['file_url'];
            
            debugPrint("🔗 [DEBUG] URL originale de l'annonce ID ${item['id']} : $originalUrl");

            if (originalUrl != null && originalUrl.contains('localhost')) {
              // On remplace pour l'émulateur
              String correctedUrl = originalUrl.replaceAll('localhost', '10.0.3.2');
              debugPrint("✅ [DEBUG] URL corrigée pour l'émulateur : $correctedUrl");
              item['file_url'] = correctedUrl;
            }
            
            return item;
          }).toList();
        } else {
          debugPrint("⚠️ [DEBUG] Le JSON ne contient pas de clé 'data' ou n'est pas une Map");
        }
      } else {
        debugPrint("❌ [DEBUG] Erreur API : ${response.body}");
      }
      return [];
    } catch (e) {
      debugPrint("💥 [DEBUG] Erreur Critique Service : $e");
      return [];
    }
  }
}