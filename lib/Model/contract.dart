class Contract {
  final int id;
  final String status;
  final String clientName;
  final String providerName;
  final double salaryAmount;
  final String startDate;
  final String? endDate;
  final String? executionLocation;
  final String? workingDays;
  final String? startTime;
  final String? endTime;
  final String? tasks;
  final String? benefits;

  Contract({
    required this.id,
    required this.status,
    required this.clientName,
    required this.providerName,
    required this.salaryAmount,
    required this.startDate,
    this.endDate,
    this.executionLocation,
    this.workingDays,
    this.startTime,
    this.endTime,
    this.tasks,
    this.benefits,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    // --- FONCTION DE SÉCURITÉ ---
    // Cette fonction transforme n'importe quel type (List ou String) en String
    String? safeString(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.isEmpty ? "" : value.join(', ');
      }
      return value.toString();
    }

    return Contract(
      id: json['id'] ?? 0,
      status: json['status'] ?? 'active',
      
      // Relations
      clientName: json['client'] != null 
          ? (json['client']['name'] ?? 'Client sans nom') 
          : 'Client inconnu',
          
      providerName: json['provider'] != null 
          ? (json['provider']['name'] ?? 'Prestataire sans nom') 
          : 'Prestataire inconnu',

      // Parsing du salaire
      salaryAmount: double.tryParse(json['salary_amount'].toString()) ?? 0.0,
      
      startDate: json['start_date'] ?? '',
      
      // On applique safeString sur TOUS les champs susceptibles d'être des listes [] ou null
      endDate: safeString(json['end_date']),
      executionLocation: safeString(json['execution_location']),
      workingDays: safeString(json['working_days']),
      startTime: safeString(json['start_time']),
      endTime: safeString(json['end_time']),
      tasks: safeString(json['tasks']),
      benefits: safeString(json['benefits']),
    );
  }
}