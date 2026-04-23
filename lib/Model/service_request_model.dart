import 'dart:convert';

class ServiceRequest {
  final int id;
  final String reference;
  final String serviceName;
  final String status;
  final String salary;
  final String commune;
  final String? sexe;
  final String? ageRange;
  final String? educationLevel;
  final String? languages;
  final String? startTime;
  final String? endTime;
  final String? description;
  final List<String> tasks;
  final List<String> benefits;
  final List<String> days;

  ServiceRequest({
    required this.id, required this.reference, required this.serviceName,
    required this.status, required this.salary, required this.commune,
    this.sexe, this.ageRange, this.educationLevel, this.languages,
    this.startTime, this.endTime, this.description,
    this.tasks = const [], this.benefits = const [], this.days = const [],
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic data) {
      if (data == null) return [];
      if (data is List) return data.map((e) => e.toString()).toList();
      if (data is String) {
        try {
          final decoded = jsonDecode(data);
          return decoded is List ? decoded.map((e) => e.toString()).toList() : [];
        } catch (_) { return []; }
      }
      return [];
    }

    return ServiceRequest(
      id: json['id'] ?? 0,
      reference: json['reference'] ?? 'N/A',
      serviceName: json['service_name'] ?? 'Inconnu',
      status: json['status'] ?? 'En attente',
      salary: (json['salary_amount'] ?? '0').toString(),
      commune: json['commune'] ?? 'Non précisée',
      sexe: json['sexe'],
      ageRange: json['age_range'],
      educationLevel: json['education_level'],
      languages: json['languages'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      description: json['extra_notes'],
      tasks: parseList(json['tasks']),
      benefits: parseList(json['benefits']),
      days: parseList(json['working_days']),
    );
  }
}