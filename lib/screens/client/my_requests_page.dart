import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/service_request_model.dart'; // <--- INDISPENSABLE : Import du modèle
import '../../providers/find_service_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_top_bar.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserRequests();
    });
  }

  Future<void> _fetchUserRequests() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await context.read<FindServiceProvider>().fetchUserRequests(context);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "Impossible de charger vos demandes. Vérifiez votre connexion.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<FindServiceProvider>().userRequests;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 110),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFBC7400),
                        ),
                      )
                    : _errorMessage != null
                    ? _buildErrorState()
                    : requests.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchUserRequests,
                        color: const Color(0xFFBC7400),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 10, bottom: 120),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            // On s'assure que chaque item est traité correctement
                            return _buildRequestCard(requests[index]);
                          },
                        ),
                      ),
              ),
            ],
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomTopBar(
              imagePath: 'assets/images/logo.png',
              onProfileTap: () =>
                  Navigator.pushNamed(context, AppRoutes.profile),
              onNotificationTap: () =>
                  Navigator.pushNamed(context, AppRoutes.notifications),
              onMenuTap: () => Navigator.pushNamed(context, AppRoutes.menu),
            ),
          ),

          const Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNav(currentRoute: AppRoutes.myRequests),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> data) {
    final String status = (data['status'] ?? 'en attente')
        .toString()
        .toLowerCase();
    Color statusColor = const Color(0xFFBC7400);

    if (status == 'confirmé' || status == 'accepted' || status == 'terminé')
      statusColor = Colors.green;
    if (status == 'annulé' || status == 'rejected') statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // --- CORRECTION CRUCIALE ICI ---
              // On convertit la Map en Objet ServiceRequest avant de l'envoyer
              final ServiceRequest requestObject = ServiceRequest.fromJson(
                data,
              );

              Navigator.pushNamed(
                context,
                AppRoutes.myRequestDetails,
                arguments: requestObject, // On envoie l'objet, plus la Map !
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: statusColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['service_name'] ?? "Service",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Réf: ${data['reference'] ?? 'COP-X'}",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Les autres widgets (_buildEmptyState, _buildErrorState) restent identiques...
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_motion_outlined,
            size: 80,
            color: Colors.grey[200],
          ),
          const SizedBox(height: 20),
          const Text(
            "Aucune demande active",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.findService),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBC7400),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: const Text(
              "Faire une demande",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 60,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 20),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          IconButton(
            onPressed: _fetchUserRequests,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 30,
              color: Color(0xFFBC7400),
            ),
          ),
        ],
      ),
    );
  }
}
