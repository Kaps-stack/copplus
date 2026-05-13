import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Imports de vos services et widgets
import '../../providers/auth_provider.dart';
import '../../providers/find_service_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_constants.dart';
import '../../widgets/action_card.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/custom_top_bar.dart';
import '../../services/announcements_service.dart';
import 'announcements_widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _priceController = TextEditingController();
  
  // Stocker le futur pour éviter les rebuilds inutiles
  Future<List<dynamic>>? _announcementsFuture;

  @override
  void initState() {
    super.initState();
    // On initialise le chargement dès le départ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.token != null) {
        setState(() {
          _announcementsFuture = AnnouncementsService().getAnnouncements(auth.token!);
        });
      }
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  // --- 1. BANNIÈRE AIDE ---
  Widget _buildSupportBanner(bool isClient) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Besoin d'aide ?",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                Text(
                  isClient ? "Un souci avec un pro ?" : "Un souci client ?",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text("Aide"),
          ),
        ],
      ),
    );
  }

  // --- 2. DIALOGUE DE RDV ---
  void _showAppointmentDialog(BuildContext context, int matchId) {
    DateTime selDate = DateTime.now();
    TimeOfDay selTime = TimeOfDay.now();
    final cCommune = TextEditingController();
    final cQuartier = TextEditingController();
    final cAvenue = TextEditingController();
    final cNumero = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDiagState) => AlertDialog(
          title: const Text("Détails du RDV",
              style: TextStyle(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.event, color: Color(0xFFBC7400)),
                  title: Text(DateFormat('dd/MM/yyyy').format(selDate)),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: selDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (d != null) setDiagState(() => selDate = d);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time, color: Color(0xFFBC7400)),
                  title: Text(selTime.format(ctx)),
                  onTap: () async {
                    final t = await showTimePicker(context: ctx, initialTime: selTime);
                    if (t != null) setDiagState(() => selTime = t);
                  },
                ),
                const Divider(),
                TextField(controller: cCommune, decoration: const InputDecoration(labelText: "Commune")),
                TextField(controller: cQuartier, decoration: const InputDecoration(labelText: "Quartier")),
                Row(
                  children: [
                    Expanded(child: TextField(controller: cAvenue, decoration: const InputDecoration(labelText: "Avenue"))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: cNumero, decoration: const InputDecoration(labelText: "N°"), keyboardType: TextInputType.number)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
              onPressed: () async {
                final auth = context.read<AuthProvider>();
                final findProv = context.read<FindServiceProvider>();

                String adresse = "C/${cCommune.text}, Q/${cQuartier.text}, Av/${cAvenue.text}, N°${cNumero.text}";
                String dateStr = DateFormat('yyyy-MM-dd').format(selDate);
                String timeStr = "${selTime.hour.toString().padLeft(2, '0')}:${selTime.minute.toString().padLeft(2, '0')}:00";

                bool success = await findProv.proposeAppointment(
                  matchId: matchId,
                  date: "$dateStr $timeStr",
                  location: adresse,
                  token: auth.token ?? "",
                );

                if (success && context.mounted) {
                  Navigator.pop(ctx);
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Demande envoyée !"), backgroundColor: Colors.green),
                  );
                }
              },
              child: const Text("Confirmer"),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. PANNEAU DE RECHERCHE ---
  void _openSearchPanel(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final findProv = context.read<FindServiceProvider>();
    _priceController.text = findProv.salaryAmount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF4F7F6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) => ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 40, height: 5,
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const Text("Trouver un pro", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                const Text("Service requis", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: AppConstants.servicesBase.map((s) {
                    final isSelected = findProv.serviceName == s;
                    return ChoiceChip(
                      label: Text(s),
                      selected: isSelected,
                      onSelected: (val) => setModalState(() => findProv.serviceName = val ? s : ""),
                      selectedColor: Colors.black,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text("Budget (FC)", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildQuickPrice("15000", findProv, setModalState),
                    const SizedBox(width: 8),
                    _buildQuickPrice("30000", findProv, setModalState),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        onChanged: (v) => findProv.salaryAmount = v,
                        decoration: InputDecoration(
                          hintText: "Autre",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBC7400),
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: findProv.isLoading ? null : () async {
                    await findProv.runSearch(auth.token ?? "");
                    setModalState(() {}); 
                  },
                  child: findProv.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("RECHERCHER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 40),
                if (!findProv.isLoading)
                  ...findProv.providersMatched.map((m) => _buildProviderCard(context, m)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPrice(String amt, FindServiceProvider prov, StateSetter setState) {
    bool isSel = prov.salaryAmount == amt;
    return InkWell(
      onTap: () => setState(() {
        prov.salaryAmount = amt;
        _priceController.text = amt;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: isSel ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(amt, style: TextStyle(color: isSel ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, Map match) {
  final provider = match['provider'] ?? {};
  final String photo = provider['photo'] ?? "";
  final String name = provider['name'] ?? "Prestataire";
  final String service = provider['service_offered'] ?? 'Service';

  return Container(
    margin: const EdgeInsets.only(bottom: 16),
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
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // AVATAR AVEC BORDURE FINE
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade100, width: 1),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFFF5F5F5),
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty
                  ? const Icon(Icons.person_outline, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          // INFOS PRESTATAIRE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  service,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                
                // BADGE KINSHASA
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.blueAccent),
                      SizedBox(width: 4),
                      Text(
                        "Kinshasa",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // BOUTON CHOISIR CHIC
          ElevatedButton(
            onPressed: () => _showAppointmentDialog(context, match['id']),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Choisir",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // --- 4. LE BUILD PRINCIPAL ---
  @override
 @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    
    // Protection si l'utilisateur n'est pas encore chargé
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    // Détection dynamique du rôle
    final bool isClient = user.role.toLowerCase() == 'client';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 140, 24, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(user.name),
                const SizedBox(height: 35),
                
                // CARTE : TROUVER / MISSIONS
                ActionCard(
                  index: 0,
                  label: isClient ? "Trouver un prestataire" : "Mes missions",
                  icon: isClient ? Icons.search : Icons.work_history,
                  onTap: () {
                    if (isClient) { 
                      _openSearchPanel(context); 
                    } else { 
                      Navigator.pushNamed(context, AppRoutes.missions); 
                    }
                  },
                ),
                
                const SizedBox(height: 15),

                // CARTE : MES CONTRATS (CORRIGÉE)
                ActionCard(
                  index: 1,
                  label: "Mes contrats",
                  icon: Icons.description,
                  onTap: () {
                    Navigator.pushNamed(
                      context, 
                      AppRoutes.contracts, 
                      arguments: isClient, // On passe dynamiquement le rôle détecté
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // BANNIÈRE AIDE
                _buildSupportBanner(isClient),
                
                const SizedBox(height: 40),

                // SECTION ANNONCES / CARROUSEL
                const Text(
                  "À LA UNE",
                  style: TextStyle(
                    fontSize: 11, 
                    color: Colors.grey, 
                    letterSpacing: 1.5, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 15),

                // GESTION DU CARROUSEL
                _announcementsFuture == null 
                  ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: Colors.black)))
                  : FutureBuilder<List<dynamic>>(
                      future: _announcementsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: Colors.black)));
                        }
                        
                        if (snapshot.hasError) {
                          debugPrint("Erreur Carrousel: ${snapshot.error}");
                          return const SizedBox.shrink();
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          debugPrint("Carrousel : Aucune donnée");
                          return const SizedBox.shrink(); 
                        }

                        return AnnouncementCarousel(announcements: snapshot.data!);
                      },
                    ),
              ],
            ),
          ),

          // BARRES FIXES (TOP & BOTTOM)
          Positioned(
            top: 0, left: 0, right: 0,
            child: CustomTopBar(
              imagePath: 'assets/images/logo.png',
              onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              onNotificationTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
              onMenuTap: () => Navigator.pushNamed(context, AppRoutes.menu), // Ajouté pour le menu
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNav(currentRoute: AppRoutes.home),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("TABLEAU DE BORD",
            style: TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
        
      ],
    );
  }
}