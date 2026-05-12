import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/find_service_provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart'; // Pour les constantes de route
import '../widgets/custom_bottom_nav.dart'; // Import de ton menu custom

class MissionsView extends StatefulWidget {
  const MissionsView({super.key});

  @override
  State<MissionsView> createState() => _MissionsViewState();
}

class _MissionsViewState extends State<MissionsView> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final auth = context.read<AuthProvider>();
    debugPrint("DEBUG: Rafraîchissement des missions prestataire...");
    await context.read<FindServiceProvider>().fetchMissions(auth.token ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Permet au contenu de passer derrière le menu flottant arrondi
      appBar: AppBar(
        // Ajout de la flèche retour
        leading: IconButton(
  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
  onPressed: () async {
    // maybePop vérifie s'il y a une page avant. 
    // Si non (canPop = false), on force le retour vers l'accueil.
    bool canPop = Navigator.of(context).canPop();
    if (canPop) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  },
),
        title: const Text("Mes Missions", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          )
        ],
      ),
      // Intégration de ton CustomBottomNav
      bottomNavigationBar: const CustomBottomNav(currentRoute: AppRoutes.missions),
      
      body: Consumer<FindServiceProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) return const Center(child: CircularProgressIndicator());
          
          if (prov.myAppointments.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text("Aucune mission proposée")),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              // Padding bas important (100) pour ne pas être caché par le menu flottant
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), 
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: prov.myAppointments.length,
              itemBuilder: (context, index) {
                final mission = prov.myAppointments[index];

                debugPrint("DEBUG: Mission ID ${mission['id']} - Statut: ${mission['appointment_status']}");

                final Map<String, dynamic>? serviceRequest = mission['service_request'];
                final Map<String, dynamic>? client = serviceRequest?['user'];
                final String clientName = client?['name'] ?? "Client Inconnu";
                final String status = mission['appointment_status'] ?? 'pending';
                final String? location = mission['appointment_location'];
                final bool isConfirmed = status == 'confirmed';

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Client: $clientName", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: isConfirmed ? Colors.red : Colors.grey),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                isConfirmed 
                                    ? (location ?? "Lieu non précisé") 
                                    : "Adresse masquée (en attente d'acceptation)",
                                style: TextStyle(
                                  color: isConfirmed ? Colors.black87 : Colors.grey, 
                                  fontStyle: isConfirmed ? FontStyle.normal : FontStyle.italic
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _statusBadge(status),
                        if (status == 'pending_provider') ...[
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _handleAccept(mission['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green, 
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                              ),
                              child: const Text("Accepter la mission"),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String? status) {
    Color color = Colors.orange;
    String label = status ?? "INCONNU";
    if (status == 'pending_provider') label = "Nouvelle demande";
    if (status == 'pending_admin') { color = Colors.blue; label = "Attente Admin"; }
    if (status == 'confirmed') { color = Colors.green; label = "Confirmé"; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(10), 
        border: Border.all(color: color)
      ),
      child: Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _handleAccept(dynamic id) async {
    final auth = context.read<AuthProvider>();
    debugPrint("DEBUG: Action Accepter sur ID: $id");

    bool ok = await context.read<FindServiceProvider>().acceptMission(id, auth.token ?? "");
    
    if (ok && mounted) {
      await _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mission acceptée ! Liste mise à jour."))
      );
    }
  }
}