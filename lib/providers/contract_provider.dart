import 'package:flutter/material.dart';
import '../Model/contract.dart';
import '../services/contract_service.dart';

class ContractProvider with ChangeNotifier {
  final ContractService _service = ContractService();
  
  List<Contract> _contracts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Contract> get contracts => _contracts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchContracts(int userId, String token, {bool isClient = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint("🔍 [FETCH] Début récupération - Mode Client: $isClient");

      final data = isClient 
          ? await _service.getClientContracts(userId, token)
          : await _service.getProviderContracts(userId, token);
      
      // --- DEBUG DES DONNÉES BRUTES ---
      debugPrint("📦 [DATA BRUTE] Nombre d'éléments reçus: ${data.length}");
      if (data.isNotEmpty) {
        debugPrint("📄 [JSON PREMIER ÉLÉMENT]: ${data.first}");
      }

      _contracts = data.map((json) {
        // Debug pour voir si l'objet 'provider' ou 'client' existe dans chaque ligne
        debugPrint("🛠️ [PARSING] ID Contrat: ${json['id']}");
        debugPrint("   - Provider ID en JSON: ${json['provider_id']}");
        debugPrint("   - Objet Provider présent ? ${json['provider'] != null}");
        if (json['provider'] != null) {
          debugPrint("   - Nom du Provider trouvé: ${json['provider']['name']}");
        }
        
        return Contract.fromJson(json);
      }).toList();

    } catch (e) {
      debugPrint("❌ [ERREUR PROVIDER]: $e");
      _errorMessage = "Impossible de récupérer les contrats.";
    } finally {
      _isLoading = false;
      _notifySafety();
    }
  }

  // Pour éviter les erreurs notifyListeners() pendant le build
  void _notifySafety() {
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  Future<bool> payInvoice(int contractId, String token) async {
    await Future.delayed(const Duration(seconds: 2)); 
    return true;
  }
}