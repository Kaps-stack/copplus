import 'package:chewie/chewie.dart';
import 'package:copplus/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'login_view.dart';


class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final Color brandGold = const Color(0xFFBC7400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            _buildHeader(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // --- CARTE À PROPOS AVEC "VOIR PLUS" ---
                  _buildAboutCard(),

                  const SizedBox(height: 30),

                  // --- LE WIDGET VIDÉO RÉEL ---
                  const _VideoPlayerWidget(
                    videoUrl: 'assets/videos/videoPresentation.mp4',
                  ),

                  const SizedBox(height: 40),
                  _buildActionButtons(),

                  const SizedBox(height: 25),
                  _buildFooter(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        color: brandGold,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 90,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.handshake, size: 80, color: Colors.black),
            ),
            const SizedBox(height: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                children: [
                  TextSpan(
                    text: "COP",
                    style: TextStyle(color: Colors.red),
                  ),
                  TextSpan(
                    text: "PLUS",
                    style: TextStyle(color: Colors.yellow),
                  ),
                ],
              ),
            ),
            const Text(
              "Connecter, Trouver, Servir",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Qui Sommes-nous ?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.5,
                fontSize: 14,
              ),
              children: [
                const TextSpan(
                  text:
                      "Nous sommes bien plus qu’une plateforme : nous sommes un pont entre les besoins et les talents. Notre mission est de connecter les clients et les prestataires de services humains de manière transparente... ",
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: const Text(
                        "Voir plus",
                        style: TextStyle(
                          color: Color(0xFFBC7400),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () => _showRoleSelector(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: brandGold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 0,
            ),
            child: const Text(
              "S'inscrire",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _googleButton(),
      ],
    );
  }

  Widget _googleButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Image(image:  const AssetImage('assets/images/google.png'),
          height: 22,
          errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, size: 30),
        ),
        label: const Text(
          "Continuer avec Google",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[200]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  void _showRoleSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Choisissez votre profil",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _roleTile(context, "Client", "Je cherche un service",
                Icons.person_outline, "client"),
            const SizedBox(height: 12),
            _roleTile(context, "Prestataire", "Je propose mes services",
                Icons.handyman_outlined, "prestataire"),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _roleTile(BuildContext context, String title, String sub,
      IconData icon, String role) {
    return ListTile(
      onTap: () {
        Navigator.pop(context); // Ferme le modal
        Navigator.pushNamed(context, AppRoutes.register, arguments: role);
      },
      leading: CircleAvatar(
        backgroundColor: brandGold.withOpacity(0.1),
        child: Icon(icon, color: brandGold),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Vous avez un compte ? "),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginView()),
          ),
          child: const Text(
            "Se connecter",
            style: TextStyle(
              color: Color(0xFF0095F6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// --- WIDGET TECHNIQUE POUR LE LECTEUR VIDÉO ---
class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.asset(widget.videoUrl);
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
      autoPlay: false,
      looping: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFBC7400),
        handleColor: const Color(0xFFBC7400),
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white,
      ),
      placeholder: Container(
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}