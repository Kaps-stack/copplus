import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contract_provider.dart';
import '../providers/auth_provider.dart';
import '../Model/contract.dart';
import '../routes/app_routes.dart'; // Import pour les routes
import '../widgets/custom_bottom_nav.dart'; // Ton menu custom importé ici
import 'contract_detail_screen.dart';

class ContractListScreen extends StatefulWidget {
  final bool isClient;
  const ContractListScreen({super.key, required this.isClient});

  @override
  State<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends State<ContractListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated && auth.user != null) {
      await context.read<ContractProvider>().fetchContracts(
          auth.user!.id, auth.token!,
          isClient: widget.isClient);
    }
  }

  @override
  Widget build(BuildContext context) {
    final contractProvider = context.watch<ContractProvider>();

    return Scaffold(
      extendBody: true, // Crucial pour le menu flottant arrondi
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        titleSpacing: 24,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          widget.isClient ? "Mes Emplois" : "Mes Missions",
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 28,
              letterSpacing: -1.2),
        ),
      ),
      // Intégration de ton CustomBottomNav
      bottomNavigationBar: CustomBottomNav(
        currentRoute: widget.isClient ? AppRoutes.contracts : AppRoutes.missions,
      ),
      body: contractProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.black,
              edgeOffset: 20,
              child: contractProvider.contracts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      // Padding bas de 120 pour ne pas être caché par le menu flottant
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 120),
                      physics: const BouncingScrollPhysics(),
                      itemCount: contractProvider.contracts.length,
                      itemBuilder: (context, index) {
                        final contract = contractProvider.contracts[index];
                        return _buildContractCard(contract);
                      },
                    ),
            ),
    );
  }

  Widget _buildContractCard(Contract contract) {
    final String displayName = widget.isClient ? contract.providerName : contract.clientName;
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 25,
              offset: const Offset(0, 12))
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ContractDetailScreen(
                    contract: contract, isClient: widget.isClient))),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Signature visuelle (Carré arrondi noir)
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(initial,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName,
                            style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6)),
                        const SizedBox(height: 2),
                        Text("Débuté le ${contract.startDate}",
                            style: TextStyle(
                                color: Colors.black38,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  _buildStatusBadge(contract.status),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Divider(color: Color(0xFFF5F5F5), height: 1, thickness: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("MONTANT DU CONTRAT",
                          style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text("${contract.salaryAmount.toInt()} FC",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: -1)),
                    ],
                  ),
                  if (widget.isClient)
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 8)
                          )
                        ]
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () => _handlePayment(contract),
                        child: const Text("Régler",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isActive = status.toLowerCase() == 'active' || status.toLowerCase() == 'actif';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isActive ? Colors.green.withOpacity(0.1) : Colors.transparent)
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: isActive ? const Color(0xFF2E7D32) : Colors.black26,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_motion_outlined, size: 70, color: Colors.grey.shade200),
          const SizedBox(height: 20),
          Text("Aucune activité trouvée",
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

 void _handlePayment(Contract contract) async {
  final auth = context.read<AuthProvider>();

  bool? confirm = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(35))),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 30),
          const Text("Paiement Sécurisé",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1)),
          const SizedBox(height: 12),
          Text(
              "Souhaitez-vous régler la facture de ${contract.salaryAmount.toInt()} FC pour la mission avec ${contract.providerName} ?",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 15, height: 1.5)),
          const SizedBox(height: 35),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Annuler",
                      style: TextStyle(
                          color: Colors.black45, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Confirmer",
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );

  if (confirm == true) {
    if (!mounted) return;

    // Navigation vers l'écran de paiement avec le montant en argument
    Navigator.pushNamed(
      context,
      AppRoutes.payment,
      arguments: contract.salaryAmount.toDouble(),
    );

    // Note : L'appel à payInvoice se fera normalement APRES 
    // la validation réussie sur l'écran PaymentView.
  }
}
}