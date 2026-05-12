import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/find_service.dart';

class FindServiceProvider extends ChangeNotifier {
  final FindService _findService = FindService();

  // --- CHAMPS ---
  String serviceName = '';
  String salaryAmount = '';
  String selectedCommune = 'Kinshasa';

  // --- ÉTATS ---
  bool isLoading = false;

  // --- DONNÉES ---
  List<dynamic> providersMatched = []; 
  List<dynamic> userRequests = [];      
  List<dynamic> myAppointments = [];   
  List<dynamic> _clientAppointments = []; // Nouvelle liste pour les RDV du client
  List<dynamic> get clientAppointments => _clientAppointments; 

  /// 1. RECHERCHE DE PRESTATAIRES
  Future<void> runSearch(String token) async {
    if (serviceName.isEmpty) return;

    isLoading = true;
    providersMatched = []; 
    notifyListeners();

    try {
      final int salaryInt = int.tryParse(salaryAmount.replaceAll(' ', '')) ?? 0;

      final Map<String, dynamic> body = {
        'service': serviceName,
        'salary': salaryInt,
        'commune': selectedCommune,
      };

      final dynamic responseData = await _findService.postServiceRequest(body, token);
      
      if (responseData != null) {
        if (responseData['matches'] != null) {
          providersMatched = responseData['matches'];
        } 
        else if (responseData['data'] != null && responseData['data']['matches'] != null) {
          providersMatched = responseData['data']['matches'];
        }
        else {
          final int? requestId = responseData['id'] ?? responseData['data']?['id'];
          if (requestId != null) {
            providersMatched = await _findService.getMatches(requestId, token);
          }
        }
      }
    } catch (e) {
      debugPrint("Error runSearch: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 2. PROPOSER UN RDV (Côté Client)
  Future<bool> proposeAppointment({
  required int matchId,
  required String date,
  required String location,
  required String token,
}) async {
  isLoading = true;
  notifyListeners();

  // 1. Log des données d'entrée
  debugPrint("--- [DEBUG PROVIDER] Tentative de RDV ---");
  debugPrint("ID du Match : $matchId");
  debugPrint("Date envoyée : $date");
  debugPrint("Lieu envoyé : $location");

  try {
    final Map<String, dynamic> data = {
      'appointment_date': date,
      'appointment_location': location,
    };

    // 2. Log de l'objet JSON final
    debugPrint("Payload JSON : ${jsonEncode(data)}");

    final bool success = await _findService.sendAppointmentProposal(matchId, data, token);

    // 3. Log du résultat final
    debugPrint("Résultat de l'appel Service : $success");
    
    return success;
  } catch (e, stacktrace) {
    // 4. Log détaillé de l'erreur
    debugPrint("!!! [ERREUR PROVIDER] !!!");
    debugPrint("Erreur : $e");
    debugPrint("Stacktrace : $stacktrace");
    return false;
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

  /// 3. CHARGER LES MISSIONS (Côté Prestataire)
  Future<void> fetchMissions(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      // On utilise la méthode du service qui pointe vers /my-missions
      myAppointments = await _findService.getMyMissions(token);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchClientAppointments(String token) async {
    isLoading = true;
    notifyListeners(); // Affiche le loader sur l'interface client

    try {
      debugPrint("=== [PROVIDER] fetchClientAppointments lancé ===");
      
      // On utilise la nouvelle méthode getMyAppointments du service
      _clientAppointments = await _findService.getMyAppointments(token);
      
      debugPrint("=== [PROVIDER] ${_clientAppointments.length} rendez-vous récupérés ===");
    } catch (e) {
      debugPrint("!!! [PROVIDER ERROR] fetchClientAppointments: $e");
    } finally {
      isLoading = false;
      notifyListeners(); // Cache le loader et rafraîchit l'UI
    }
  }

  /// 4. ACCEPTER UNE MISSION (Côté Prestataire)
  Future<bool> acceptMission(int matchId, String token) async {
    isLoading = true;
    notifyListeners();
    try {
      final bool success = await _findService.acceptMission(matchId, token);
      if (success) {
        await fetchMissions(token);
      }
      return success;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void resetFilters() {
    serviceName = '';
    salaryAmount = '';
    selectedCommune = 'Kinshasa';
    providersMatched = [];
    notifyListeners();
  }
}