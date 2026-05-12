import 'package:flutter/material.dart';
import '../../Model/service_request_model.dart';

class RequestDetailsPage extends StatelessWidget {
  final ServiceRequest r;
  const RequestDetailsPage({super.key, required this.r});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Détails ${r.reference}")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildInfoTile("Service", r.serviceName),
          _buildInfoTile("Commune", r.commune),
          _buildInfoTile("Budget", "${r.salaryAmount} CFA"), // Corrigé
          _buildInfoTile("Jours", r.days?.join(', ') ?? 'Non spécifié'), // Corrigé (null-check)
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
    );
  }
}