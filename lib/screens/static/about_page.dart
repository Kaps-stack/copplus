import 'package:flutter/material.dart';
import '/widgets/custom_top_bar.dart';
import '/widgets/custom_bottom_nav.dart';
import '/routes/app_routes.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _valuesKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _privacyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final int? sectionIndex = ModalRoute.of(context)?.settings.arguments as int?;
      if (sectionIndex != null) {
        _scrollToSection(sectionIndex);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 300 && !_showBackToTop) {
      setState(() => _showBackToTop = true);
    } else if (_scrollController.offset < 300 && _showBackToTop) {
      setState(() => _showBackToTop = false);
    }
  }

  void _scrollToSection(int index) {
    GlobalKey? targetKey;
    switch (index) {
      case 0: targetKey = _heroKey; break;
      case 1: targetKey = _valuesKey; break;
      case 2: targetKey = _faqKey; break;
      case 3: targetKey = _privacyKey; break;
    }
    if (targetKey != null && targetKey.currentContext != null) {
      Scrollable.ensureVisible(
        targetKey.currentContext!,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  void _backToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;

    return Scaffold(
      backgroundColor: Colors.white,
      // Le bouton flottant est ajusté pour ne pas gêner la barre de navigation
      floatingActionButton: _showBackToTop 
        ? Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: FloatingActionButton(
              onPressed: _backToTop,
              backgroundColor: const Color(0xFF1A1A1A),
              mini: true,
              child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
            ),
          )
        : null,

      body: Stack(
        children: [
          // 1. CONTENU SCROLLABLE
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            // Padding top pour la TopBar et bottom pour la Nav
            padding: const EdgeInsets.fromLTRB(0, 100, 0, 140),
            child: Column(
              children: [
                Container(key: _heroKey, child: _buildHeroSection()),
                
                Container(key: _valuesKey, child: _buildSectionDivider("Nos valeurs")),
                _buildValueRow(
                  title: "Confiance", 
                  desc: "Nous sélectionnons et vérifions chaque prestataire pour garantir votre sécurité totale.", 
                  icon: Icons.verified_user_rounded, 
                  iconColor: Colors.blue, 
                  isLeft: true
                ),
                _buildValueRow(
                  title: "Respect et dignité", 
                  desc: "Prestataires et clients sont traités comme des membres de la famille Copplus.", 
                  icon: Icons.volunteer_activism, 
                  iconColor: Colors.red, 
                  isLeft: false
                ),
                _buildValueRow(
                  title: "Innovation humaine", 
                  desc: "La technologie rapproche les hommes et simplifie le quotidien à Kinshasa.", 
                  icon: Icons.lightbulb, 
                  iconColor: Colors.amber, 
                  isLeft: true
                ),

                const SizedBox(height: 20),
                
                Container(
                  key: _faqKey, 
                  child: Column(
                    children: [
                      _buildSectionDivider("FAQ - COPPLUS"),
                      
                      _buildFaqCategory("POUR LES CLIENTS", [
                        {"q": "1. Qu'est-ce que COPPLUS ?", "a": "CopPlus est une application qui met en relation des clients avec des prestataires de services humains fiables : femmes de ménage, chauffeurs, baby-sitters, gardiens, pharmaciens pour vos magasins ou boutiques, garçons de course et bien d’autres."},
                        {"q": "2. Comment réserver un service ?", "a": "Télécharge l’application, crée ton compte client, sélectionne le service souhaité, décris les tâches (horaires, conditions, exigences, salaire selon ton budget, date de paiement, frais de transport et avantages), soumets ta requête, reçois une notification du service client avec les meilleurs profils selon tes critères, consulte les prestataires disponibles dans ton quartier, puis le prestataire accepte la mission et vous êtes notifiés pour le premier rendez-vous, la signature du contrat et le début du service."},
                        {"q": "3. Quelles sont les responsabilités de COPPLUS ?", "a": "Veiller au respect du contrat entre les deux parties, intervenir comme intermédiaire en cas de plainte ou de conflit, sécuriser les paiements via la plateforme (hors frais annexes comme le transport, le salaire étant payé directement en ligne), garantir après signature du contrat le paiement mensuel du prestataire par Copplus avant la mise à disposition des fonds par le client, dans une limite de 3 mois pour assurer la continuité du service, appliquer des frais de 10 % sur le premier salaire puis 5 % à chaque paiement suivant, verser le reste directement au prestataire, et assurer une totale impartialité en garantissant un traitement équitable entre employeur et employé."},
                        {"q": "4. Puis-je annuler une mission ?", "a": "Les annulations sont possibles ; toutefois, si le prestataire a déjà commencé la mission, le paiement sera calculé au prorata des jours travaillés, et les frais de la plateforme resteront dus conformément au contrat."},
                        {"q": "5. Comment évaluer un prestataire ?", "a": "À l’issue de chaque mission, tu peux laisser un avis et une note afin d’aider la communauté à identifier les prestataires les plus fiables."},
                        {"q": "6. Que faire si j’ai un problème avec un prestataire ?", "a": "Contacte notre support Copplus directement via l’application."},
                      ]),

                      _buildFaqCategory("POUR LES PRESTATAIRES", [
                        {"q": "1. Comment devenir prestataire sur COPPLUS ?", "a": "Crée ton profil dans l’application en renseignant ton service, ton quartier, tes disponibilités et tes coordonnées, puis fais-le valider afin de pouvoir commencer à recevoir des missions."},
                        {"q": "2. Quels sont les frais pour les prestataires ?", "a": "Une commission mensuelle de 5 % est prélevée sur ton salaire pour rester actif et visible auprès des clients."},
                        {"q": "3. Comment recevoir mes paiements ?", "a": "Les paiements s’effectuent via Mobile Money ou d’autres méthodes intégrées à l’application, et tu reçois ton salaire net après déduction de la commission."},
                        {"q": "4. Puis-je choisir mes missions ?", "a": "Oui, tu es libre d’accepter ou de refuser les missions proposées en fonction de ta disponibilité et de tes exigences."},
                        {"q": "5. Comment rester visible sur l’application ?", "a": "Assure-toi que ton profil est complet et actif, car le prélèvement mensuel de 5 % sur ton salaire te permet de rester visible et de continuer à recevoir des missions."},
                        {"q": "6. Que faire si j’ai un problème avec un client ?", "a": "Contacte le support Copplus directement via l’application ou adresse-toi à ton Vigil Zone, l’agent terrain de Copplus responsable d’une zone spécifique."},
                      ]),

                      _buildFaqCategory("QUESTIONS GENERALES", [
                        {"q": "1. CopPlus est-il sécurisé ?", "a": "Oui, tous les paiements et profils sont sécurisés et vérifiés afin d’assurer la fiabilité de la plateforme."},
                        {"q": "2. Où puis-je contacter le support ?", "a": "Via l’application, par email ou WhatsApp."},
                        {"q": "3. Puis-je utiliser CopPlus dans d’autres villes ?", "a": "Actuellement disponible à Kinshasa, l’extension vers d’autres villes est en cours."},
                      ]),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Container(key: _privacyKey, child: _buildPrivacyCard()),

                const SizedBox(height: 50),
                _buildSupportFooter(),
              ],
            ),
          ),

          // 2. TOP BAR FIXÉE
          Positioned(
            top: 0, left: 0, right: 0,
            child: Stack(
              children: [
                CustomTopBar(
                  imagePath: 'assets/images/logo.png',
                  onProfileTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  onNotificationTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
                  onMenuTap: () => Navigator.pushNamed(context, AppRoutes.menu),
                ),
                Positioned(
                  left: 10,
                  top: MediaQuery.of(context).padding.top + 5,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFBC7400), size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
          
          // 3. BARRE DE NAVIGATION FIXÉE
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNav(currentRoute: currentRoute),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE COMPOSANTS ---

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 40, 30, 20),
      child: Column(
        children: [
          const Text("Qui Sommes-nous ?", 
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 15),
          Text(
            "Chez CopPlus, nous croyons que chaque individu mérite un accès simple et fiable aux services essentiels de la vie quotidienne, tout en offrant aux prestataires un moyen digne et équitable de gagner leur vie. Nous sommes bien plus qu’une plateforme : nous sommes un pont entre les besoins et les talents. Notre mission est de connecter les clients et les prestataires de services humains de manière transparente, humaine et professionnelle, afin de bâtir une communauté basée sur la confiance, la fiabilité et la qualité.",
            textAlign: TextAlign.justify,
            style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[200], indent: 20)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(text.toUpperCase(), 
              style: const TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w900, fontSize: 11, color: Colors.grey)),
          ),
          Expanded(child: Divider(color: Colors.grey[200], endIndent: 20)),
        ],
      ),
    );
  }

  Widget _buildValueRow({required String title, required String desc, required IconData icon, required Color iconColor, required bool isLeft}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      color: isLeft ? Colors.white : const Color(0xFFF9FAFB),
      child: Row(
        children: [
          if (isLeft) _iconBox(icon, iconColor),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: isLeft ? 20 : 0, right: isLeft ? 0 : 20),
              child: Column(
                crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  const SizedBox(height: 6),
                  Text(desc, 
                    textAlign: isLeft ? TextAlign.left : TextAlign.right, 
                    style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
                ],
              ),
            ),
          ),
          if (!isLeft) _iconBox(icon, iconColor),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color color) => Container(
    height: 50, width: 50, 
    decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), 
    child: Icon(icon, color: color, size: 24)
  );

  Widget _buildFaqCategory(String title, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 20, 25, 10), 
          child: Text(title, style: const TextStyle(color: Color(0xFFBC7400), fontWeight: FontWeight.w900, fontSize: 13))
        ),
        ...items.map((item) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(15)),
          child: ExpansionTile(
            shape: const RoundedRectangleBorder(side: BorderSide.none),
            iconColor: const Color(0xFFBC7400),
            title: Text(item['q']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), 
                child: Text(
                  item['a']!,
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 13),
                )
              )
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: const Column(
        children: [
          Icon(Icons.privacy_tip_outlined, color: Color(0xFFBC7400), size: 30),
          SizedBox(height: 10),
          Text("Politique et confidentialité", style: TextStyle(fontWeight: FontWeight.w800)),
          Text("Cliquer pour consulter", style: TextStyle(color: Color(0xFFBC7400), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSupportFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      color: const Color(0xFFBC7400),
      child: const Column(
        children: [
          Text("Besoin d'aide ?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
          SizedBox(height: 5),
          Text("support@copplus.org", style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}