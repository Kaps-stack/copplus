import 'package:flutter/material.dart';
import '../../Model/service_request_model.dart';

class RequestDetailsPage extends StatelessWidget {
  final ServiceRequest r;
  const RequestDetailsPage({super.key, required this.r});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFBC7400);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Détails ${r.reference}", 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBadge(r.status, gold),
            const SizedBox(height: 20),
            _sectionHeader("SERVICE & LIEU"),
            _infoTile("Métier", r.serviceName, Icons.work_outline, gold),
            _infoTile("Commune", r.commune, Icons.location_on_outlined, gold),
            
            const Divider(height: 40),
            _sectionHeader("PROFIL RECHERCHÉ"),
            Row(
              children: [
                Expanded(child: _infoTile("Sexe", r.sexe ?? "N/A", Icons.person_outline, gold)),
                Expanded(child: _infoTile("Âge", r.ageRange != null ? "${r.ageRange} ans" : "N/A", Icons.cake_outlined, gold)),
              ],
            ),
            _infoTile("Niveau d'études", r.educationLevel ?? "N/A", Icons.school_outlined, gold),
            _infoTile("Langues", r.languages ?? "Non spécifié", Icons.translate, gold),

            const Divider(height: 40),
            _sectionHeader("BUDGET & TEMPS"),
            _infoTile("Salaire", "${r.salary} CDF / mois", Icons.payments_outlined, gold),
            _infoTile("Jours", r.days.join(", "), Icons.calendar_today_outlined, gold),
            _infoTile("Horaire", "${r.startTime ?? '--:--'} - ${r.endTime ?? '--:--'}", Icons.access_time, gold),

            const Divider(height: 40),
            _sectionHeader("MISSIONS & TÂCHES"),
            _buildChipsList(r.tasks, "Tâches journalières", gold),
            const SizedBox(height: 20),
            _buildChipsList(r.benefits, "Avantages inclus", gold),

            if (r.description != null && r.description!.isNotEmpty) ...[
              const Divider(height: 40),
              _sectionHeader("AUTRES EXIGENCES"),
              Text(r.description!, style: const TextStyle(color: Colors.black54, height: 1.5)),
            ],
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
  );

  Widget _infoTile(String label, String val, IconData icon, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _buildChipsList(List<String> items, String title, Color color) {
    if (items.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: items.map((i) => Chip(
            label: Text(i, style: const TextStyle(fontSize: 11)),
            backgroundColor: color.withOpacity(0.05),
            side: BorderSide.none,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}