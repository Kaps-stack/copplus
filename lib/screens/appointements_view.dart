import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/find_service_provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart'; // Import pour les routes
import '../widgets/custom_bottom_nav.dart'; // Import de ton CustomBottomNav

class ClientAppointmentsView extends StatefulWidget {
  const ClientAppointmentsView({super.key});

  @override
  State<ClientAppointmentsView> createState() => _ClientAppointmentsViewState();
}

class _ClientAppointmentsViewState extends State<ClientAppointmentsView> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final auth = context.read<AuthProvider>();
    // Appel de la méthode fetch côté client
    await context.read<FindServiceProvider>().fetchClientAppointments(auth.token ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Ajout de la flèche retour manuelle (optionnel car Scaffold le fait auto si on vient d'un push)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Mes Rendez-vous", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData)
        ],
      ),
      // Intégration de ton CustomBottomNav
      bottomNavigationBar: const CustomBottomNav(currentRoute: AppRoutes.myAppointments),
      // On utilise extendBody pour que le contenu ne soit pas coupé par les marges du nav
      extendBody: true, 
      body: Consumer<FindServiceProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) return const Center(child: CircularProgressIndicator());
          
          if (prov.clientAppointments.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text("Aucun rendez-vous pour le moment")),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Padding bas pour ne pas cacher sous le nav
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: prov.clientAppointments.length,
              itemBuilder: (context, index) {
                final rdv = prov.clientAppointments[index];
                
                final Map<String, dynamic>? provider = rdv['provider'];
                final String providerName = provider?['name'] ?? "Prestataire inconnu";
                final String status = rdv['appointment_status'] ?? 'pending';
                final String? location = rdv['appointment_location'];
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Prestataire: $providerName", 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            _statusBadge(status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: isConfirmed ? Colors.red : Colors.grey),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                location ?? "Lieu en cours de validation",
                                style: TextStyle(color: isConfirmed ? Colors.black87 : Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 30),
                        if (status != 'cancelled' && status != 'completed')
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _showCancelDialog(rdv['id']),
                              icon: const Icon(Icons.cancel, size: 18),
                              label: const Text("Annuler le rendez-vous"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
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
    String label = status ?? "En attente";

    if (status == 'pending_provider') { label = "Attente Prestataire"; color = Colors.orange; }
    if (status == 'pending_admin') { label = "Validation Admin"; color = Colors.blue; }
    if (status == 'confirmed') { label = "Confirmé"; color = Colors.green; }
    if (status == 'cancelled') { label = "Annulé"; color = Colors.red; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 0.5)
      ),
      child: Text(label.toUpperCase(), 
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }

  void _showCancelDialog(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Annuler ?"),
        content: const Text("Voulez-vous vraiment annuler ce rendez-vous ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("NON", style: TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleCancel(id);
            }, 
            child: const Text("OUI, ANNULER", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  void _handleCancel(dynamic id) async {
    final auth = context.read<AuthProvider>();
    debugPrint("DEBUG: Annulation demandée pour l'ID: $id");
    
    // Une fois ton API prête, décommente la ligne ci-dessous :
    // await context.read<FindServiceProvider>().cancelAppointment(id, auth.token ?? "");
    
    await _refreshData();
  }
}