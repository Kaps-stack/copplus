import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contract_provider.dart';
import '../providers/auth_provider.dart'; // Import crucial pour l'auth
import '../Model/contract.dart';   // Assure-toi du nom du fichier
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
    // Appel initial sécurisé via les deux Providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  // Méthode pour rafraîchir les données proprement
  Future<void> _refreshData() async {
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated && auth.user != null) {
      await context.read<ContractProvider>().fetchContracts(
        auth.user!.id, 
        auth.token!, 
        isClient: widget.isClient
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // On écoute le ContractProvider pour l'état de la liste
    final contractProvider = context.watch<ContractProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        title: Text(
          widget.isClient ? "Mes Emplois" : "Mes Missions", 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: contractProvider.isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.black))
        : RefreshIndicator(
            onRefresh: _refreshData,
            child: contractProvider.contracts.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: contractProvider.contracts.length,
                  itemBuilder: (context, index) {
                    final contract = contractProvider.contracts[index];
                    return _buildContractCard(contract);
                  },
                ),
          ),
    );
  }

  Widget _buildContractCard(Contract contract) { // Utilisation du type Contract
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => ContractDetailScreen(contract: contract, isClient: widget.isClient))
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isClient ? contract.providerName : contract.clientName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Débuté le ${contract.startDate}", 
                          style: TextStyle(color: Colors.grey[500], fontSize: 13)
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(contract.status),
                ],
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${contract.salaryAmount.toInt()} FC", 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.blueAccent)
                  ),
                  
                  if (widget.isClient) 
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      onPressed: () => _handlePayment(contract.id),
                      child: const Text("Régler la facture", style: TextStyle(fontSize: 12)),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.toUpperCase(), 
        style: TextStyle(
          color: isActive ? Colors.green[700] : Colors.grey, 
          fontSize: 10, 
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text("Aucun contrat trouvé", style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  void _handlePayment(int id) async {
    final auth = context.read<AuthProvider>();
    
    // Affichage d'une confirmation ultra simple avant paiement
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Règlement"),
        content: const Text("Voulez-vous procéder au paiement de cette facture ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirmer")),
        ],
      ),
    );

    if (confirm == true) {
      // Afficher un loader
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Traitement du paiement...")));
      
      // Ici tu appelles ton provider pour le paiement
      bool success = await context.read<ContractProvider>().payInvoice(id, auth.token!);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Paiement réussi !"), backgroundColor: Colors.green)
        );
      }
    }
  }
}