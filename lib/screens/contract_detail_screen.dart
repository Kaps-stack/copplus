import 'package:flutter/material.dart';
import '../Model/contract.dart';
import '../routes/app_routes.dart';
import '../routes/app_pages.dart';

class ContractDetailScreen extends StatelessWidget {
  final Contract contract;
  final bool isClient;
  const ContractDetailScreen({super.key, required this.contract, required this.isClient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Gris très clair moderne
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Contrat de\nMission", 
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1)),
            const SizedBox(height: 25),
            
            _buildInfoCard(),
            const SizedBox(height: 30),
            
            // Section Organisation dans une Card
            _buildMainCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Plannification"),
                  const SizedBox(height: 10),
                  const Text("Jours de travail", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 8),
                  // SOLUTION AU DEBORDEMENT : Wrap au lieu de Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buildWorkDayChips(contract.workingDays),
                  ),
                  const SizedBox(height: 20),
                  _detailRow(Icons.access_time_filled_rounded, "Horaires", "${contract.startTime} - ${contract.endTime}"),
                  _detailRow(Icons.location_on_rounded, "Lieu d'exécution", contract.executionLocation ?? "À définir"),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            _buildMainCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Missions & Tâches"),
                  const SizedBox(height: 10),
                  Text(contract.tasks ?? "Aucune description", 
                      style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildMainCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Rémunération & Avantages"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Salaire convenu", style: TextStyle(color: Colors.black54)),
                      Text("${contract.salaryAmount.toInt()} FC", 
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.blueAccent)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(),
                  ),
                  Text(contract.benefits ?? "Avantages standards inclus", 
                      style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
                ],
              ),
            ),

            const SizedBox(height: 40),
            
            
          ],
        ),
      ),
    );
  }

  // Widget pour créer les badges des jours sans dépasser
  List<Widget> _buildWorkDayChips(String? days) {
    if (days == null || days.isEmpty) return [const Text("Non définis")];
    
    // On sépare la chaîne (ex: "Lundi, Mardi") en liste
    List<String> daysList = days.split(RegExp(r'[,\s]+')).where((s) => s.isNotEmpty).toList();
    
    return daysList.map((day) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Text(day, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 12)),
    )).toList();
  }

  Widget _buildMainCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF333333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 28, 
              backgroundColor: Colors.white, 
              child: Text(isClient ? contract.providerName[0] : contract.clientName[0], 
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isClient ? "PRESTATAIRE" : "CLIENT", 
                    style: TextStyle(color: Colors.blueAccent[100], fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                Text(isClient ? contract.providerName : contract.clientName, 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.verified, color: Colors.blueAccent, size: 20),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title.toUpperCase(), 
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.blueAccent));
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: Colors.blueAccent),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Ajoute "BuildContext context" entre les parenthèses ici

}