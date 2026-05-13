import 'package:flutter/material.dart';
import '/routes/app_routes.dart';
import '/widgets/custom_bottom_nav.dart';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  String selectedMethod = 'mpesa';

  @override
  Widget build(BuildContext context) {
    const Color brandGold = Color(0xFFBC7400);

    // --- RÉCUPÉRATION DU MONTANT DYNAMIQUE ---
    // On récupère l'argument passé (le salaire du contrat)
    final double? amountToPay = ModalRoute.of(context)?.settings.arguments as double?;
    // Si aucun montant n'est passé (accès direct), on met 0 par défaut
    final String displayAmount = amountToPay?.toStringAsFixed(2) ?? "0.00";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      bottomNavigationBar: const CustomBottomNav(currentRoute: AppRoutes.home),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "RÈGLEMENT",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CARTE DE FACTURE DYNAMIQUE ---
            _buildInvoiceCard(displayAmount, brandGold),
            
            const SizedBox(height: 40),
            _buildSectionTitle("MOYENS DE PAIEMENT"),
            const SizedBox(height: 15),

            Row(
  children: [
    _buildPaymentMethod(
      id: 'mpesa',
      name: 'M-Pesa',
      image: Image.asset('assets/images/mpesa.jpeg', fit: BoxFit.contain),
      color: Colors.red.shade700,
    ),
    const SizedBox(width: 12),
    _buildPaymentMethod(
      id: 'orange',
      name: 'Orange',
      image: Image.asset('assets/images/orangemoney.png', fit: BoxFit.contain),
      color: Colors.orange.shade800,
    ),
    const SizedBox(width: 12),
    _buildPaymentMethod(
      id: 'visa',
      name: 'Visa/Card',
      image: Image.asset('assets/images/visa.png', fit: BoxFit.contain),
      color: const Color(0xFF1A1F71),
    ),
  ],
),

            const SizedBox(height: 35),
            
            // --- BOUTON DE PAIEMENT FINAL ---
            _buildConfirmButton(displayAmount),

            const SizedBox(height: 40),
            _buildSectionTitle("HISTORIQUE RÉCENT"),
            const SizedBox(height: 15),
            
            _buildTransactionItem("Dernier contrat", "Aujourd'hui", "- $displayAmount FC", true),
            _buildTransactionItem("Dépôt via M-Pesa", "Hier", "+ 150.00 \$", false),
          ],
        ),
      ),
    );
  }

  // Affiche le montant récupéré du contrat
  Widget _buildInvoiceCard(String amount, Color accent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: accent.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 15))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Montant à régler", 
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 1)),
          const SizedBox(height: 10),
          Text("$amount FC", 
            style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Text("Paiement sécurisé COP PLUS", 
              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildConfirmButton(String amount) {
    return ElevatedButton(
      onPressed: () {
        // Simulation de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Traitement du paiement..."), backgroundColor: Colors.black)
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        elevation: 0,
      ),
      child: Text("PAYER $amount FC", 
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5));
  }

 Widget _buildPaymentMethod({
  required String id,
  required String name,
  Widget? image, // Changé en Widget? pour accepter Image.asset
  required Color color,
}) {
  bool isSelected = selectedMethod == id;
  return Expanded(
    child: GestureDetector(
      onTap: () => setState(() => selectedMethod = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? color : Colors.transparent, 
            width: 2,
          ),
          boxShadow: isSelected 
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))] 
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 45,
              width: 45,
              padding: const EdgeInsets.all(8), // Petit padding pour que le logo ne touche pas les bords
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.05) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: image ?? Icon(Icons.payment, color: color),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTransactionItem(String title, String date, String amount, bool isNegative) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          Icon(isNegative ? Icons.arrow_downward : Icons.arrow_upward, 
            color: isNegative ? Colors.red : Colors.green, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                Text(date, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        ],
      ),
    );
  }
}