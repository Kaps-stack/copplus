import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/find_service_provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_bottom_nav.dart';

class ClientAppointmentsView extends StatefulWidget {
  const ClientAppointmentsView({super.key});

  @override
  State<ClientAppointmentsView> createState() => _ClientAppointmentsViewState();
}

class _ClientAppointmentsViewState extends State<ClientAppointmentsView> {
  final Color brandGold = const Color(0xFFBC7400);

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final auth = context.read<AuthProvider>();
    await context.read<FindServiceProvider>().fetchClientAppointments(auth.token ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // --- BOUTON RETOUR SÉCURISÉ ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          onPressed: () async {
            bool canPop = await Navigator.of(context).maybePop();
            if (!canPop && mounted) {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
            }
          },
        ),
        title: const Text(
          "Mes Rendez-vous",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: brandGold),
            onPressed: _refreshData,
          )
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentRoute: AppRoutes.myAppointments),
      body: Consumer<FindServiceProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) {
            return Center(child: CircularProgressIndicator(color: brandGold, strokeWidth: 2));
          }

          if (prov.clientAppointments.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              color: brandGold,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  _buildEmptyState(),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: brandGold,
            onRefresh: _refreshData,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              itemCount: prov.clientAppointments.length,
              itemBuilder: (context, index) {
                final rdv = prov.clientAppointments[index];
                return _buildAppointmentCard(rdv);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> rdv) {
    final Map<String, dynamic>? provider = rdv['provider'];
    final String providerName = provider?['name'] ?? "Prestataire inconnu";
    final String status = rdv['appointment_status'] ?? 'pending';
    final String? location = rdv['appointment_location'];
    final String date = rdv['appointment_date'] ?? "Date à confirmer";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusBadge(status),
                    const Icon(Icons.more_horiz, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  providerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.calendar_today_outlined, date),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_outlined, location ?? "Lieu non défini"),
              ],
            ),
          ),
          if (status != 'cancelled' && status != 'completed')
            InkWell(
              onTap: () => _showCancelDialog(rdv['id']),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  border: Border(top: BorderSide(color: Colors.red.withOpacity(0.08))),
                ),
                child: const Center(
                  child: Text(
                    "Annuler le rendez-vous",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'confirmed':
        color = Colors.green;
        label = "Confirmé";
        break;
      case 'cancelled':
        color = Colors.red;
        label = "Annulé";
        break;
      case 'pending_admin':
        color = Colors.blue;
        label = "Validation Admin";
        break;
      default:
        color = brandGold;
        label = "En attente";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.event_busy_outlined, size: 80, color: Colors.grey.shade200),
        const SizedBox(height: 20),
        const Text(
          "Aucun rendez-vous",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(
          "Vos demandes apparaîtront ici.",
          style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _showCancelDialog(dynamic id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Annuler ?", style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text("Cette action annulera votre demande de service."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("RETOUR", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _handleCancel(id);
            },
            child: const Text("CONFIRMER", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleCancel(dynamic id) async {
    // Logique d'annulation ici
    await _refreshData();
  }
}