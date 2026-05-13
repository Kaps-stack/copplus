import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/find_service_provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_bottom_nav.dart';

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
    await context.read<FindServiceProvider>().fetchMissions(auth.token ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF4F7F6), // Couleur crème/soie très chic
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          "Missions",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 30,
            letterSpacing: -1.5,
          ),
        ),
        centerTitle: false,
      ),
      bottomNavigationBar: const CustomBottomNav(currentRoute: AppRoutes.missions),
      body: Consumer<FindServiceProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2));

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: Colors.black,
            edgeOffset: 20,
            child: prov.myAppointments.isEmpty 
              ? _buildEmptyState() 
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  physics: const BouncingScrollPhysics(),
                  itemCount: prov.myAppointments.length,
                  itemBuilder: (context, index) {
                    final mission = prov.myAppointments[index];
                    final client = mission['service_request']?['user'];
                    final String status = mission['appointment_status'] ?? 'pending';
                    
                    return _buildMissionItem(
                      id: mission['id'],
                      name: client?['name'] ?? "Client",
                      location: mission['appointment_location'],
                      status: status,
                    );
                  },
                ),
          );
        },
      ),
    );
  }

  Widget _buildMissionItem({required dynamic id, required String name, String? location, required String status}) {
    bool isPending = status == 'pending_provider';
    bool isConfirmed = status == 'confirmed';

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Initiale stylisée au lieu d'une icône banale
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isConfirmed ? (location ?? "Lieu défini") : "Localisation masquée",
                        style: TextStyle(
                          color: isConfirmed ? Colors.black54 : Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildMiniBadge(status),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isPending)
            GestureDetector(
              onTap: () => _handleAccept(id),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A), // Noir profond
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "ACCEPTER MAINTENANT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String status) {
    Color dotColor = status == 'confirmed' ? Colors.green : (status == 'pending_provider' ? Colors.orange : Colors.blue);
    String text = status == 'pending_provider' ? "Nouveau" : (status == 'confirmed' ? "Confirmé" : "En cours");

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black45),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 50, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            "Tout est calme ici",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black26),
          ),
        ],
      ),
    );
  }

  void _handleAccept(dynamic id) async {
    final auth = context.read<AuthProvider>();
    bool ok = await context.read<FindServiceProvider>().acceptMission(id, auth.token ?? "");
    if (ok && mounted) {
      _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Mission acceptée", style: TextStyle(fontWeight: FontWeight.bold)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
    }
  }
}