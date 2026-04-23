import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Correction des imports pour correspondre à la casse de ton projet
import 'notification_provider.dart'; 
import 'auth_provider.dart';
import '../services/FindService.dart';

class FindServiceProvider with ChangeNotifier {
  final FindService _apiService = FindService();

  // États du formulaire
  String? selectedService;
  bool isOtherServiceSelected = false;
  final TextEditingController otherServiceController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  String? selectedSexe;
  String? selectedAge;
  String? selectedCommune;
  String? selectedLevel;
  String? languages;
  String? extraRequirements;

  RangeValues salaryRange = const RangeValues(100000, 1000000);

  List<String> selectedDays = [];
  final List<String> allDays = [
    'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim',
  ];

  TimeOfDay? startTime;
  TimeOfDay? endTime;

  List<String> benefitsList = [];
  List<String> tasksList = [];

  bool isLoading = false;
  List<dynamic> userRequests = [];

  // --- LOGIQUE ---

  void updateService(String s) {
    selectedService = s;
    isOtherServiceSelected = (s.toLowerCase() == "autre");
    notifyListeners();
  }

  void updateSalary(RangeValues v) {
    salaryRange = v;
    notifyListeners();
  }

  String formatMoney(String value) {
    if (value.isEmpty) return "";
    value = value.replaceAll(' ', '');
    final n = num.tryParse(value);
    if (n == null) return value;
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
  }

  void toggleDay(String day) {
    selectedDays.contains(day)
        ? selectedDays.remove(day)
        : selectedDays.add(day);
    notifyListeners();
  }

  void addItem(List<String> list, String val) {
    if (val.trim().isNotEmpty) {
      list.add(val.trim());
      notifyListeners();
    }
  }

  void removeItem(List<String> list, int idx) {
    list.removeAt(idx);
    notifyListeners();
  }

  // --- ENVOI AU BACKEND ---

  Future<void> submitSearch(BuildContext context) async {
    // On récupère les instances AVANT le chargement pour éviter les erreurs de contexte
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final notificationProv = Provider.of<NotificationProvider>(context, listen: false);
    
    if (auth.token == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> data = {
        'service': selectedService,
        'other_service': isOtherServiceSelected ? otherServiceController.text : null,
        'commune': selectedCommune,
        'sexe': selectedSexe,
        'age': selectedAge,
        'level': selectedLevel,
        'languages': languages,
        'salary': salaryController.text.replaceAll(' ', ''),
        'days': selectedDays,
        'start_time': startTime != null
            ? "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}"
            : null,
        'end_time': endTime != null
            ? "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}"
            : null,
        'benefits': benefitsList,
        'tasks': tasksList,
        'extra_requirements': extraRequirements,
      };

      // 1. Appel API
      await _apiService.postServiceRequest(data, auth.token!);

      // 2. Rafraîchir les notifications (pour la cloche)
      await notificationProv.fetchNotifications(auth.token!);

      // 3. UI Feedback (avec vérification si l'écran est toujours là)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Demande publiée avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
        reset();
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<dynamic>> fetchUserRequests(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return [];

    isLoading = true;
    notifyListeners();

    try {
      userRequests = await _apiService.getUserRequests(auth.token!);
      return userRequests;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    selectedService = null;
    isOtherServiceSelected = false;
    otherServiceController.clear();
    salaryController.clear();
    selectedDays = [];
    benefitsList = [];
    tasksList = [];
    startTime = null;
    endTime = null;
    notifyListeners();
  }

  // Setters basiques
  void updateSexe(String v) { selectedSexe = v; notifyListeners(); }
  void updateAge(String v) { selectedAge = v; notifyListeners(); }
  void updateCommune(String v) { selectedCommune = v; notifyListeners(); }
  void updateLevel(String v) { selectedLevel = v; notifyListeners(); }
  void updateTime(TimeOfDay t) { startTime = t; notifyListeners(); }
  void updateEndTime(TimeOfDay t) { endTime = t; notifyListeners(); }
}

// Extension pour éviter les erreurs de compilation si la méthode n'existe pas encore dans FindService
extension FindServiceCompat on FindService {
  Future<void> postServiceRequest(Map<String, dynamic> data, String token) async {
    // Si tu as déjà implémenté cette méthode dans ton service, supprime cette extension.
    return;
  }
}