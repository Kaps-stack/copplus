import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AnnouncementCarousel extends StatelessWidget {
  final List<dynamic> announcements;

  const AnnouncementCarousel({super.key, required this.announcements});

  @override
  Widget build(BuildContext context) {
    if (announcements.isEmpty) return const SizedBox.shrink();

    return CarouselSlider(
      options: CarouselOptions(
        height: 250.0, // Un peu plus grand pour le visuel
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        enlargeCenterPage: true,
        viewportFraction: 0.85,
      ),
      items: announcements.map((item) {
        final String type = item['type'] ?? 'image';
        // Assure-toi que ton API renvoie l'URL complète générée par Laravel
        final String url = item['file_url'] ?? ''; 

        return ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            color: Colors.black12,
            child: type == 'image'
                ? Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.broken_image, size: 50),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                : _VideoPlaceholder(url: url), // Un petit widget pour les vidéos
          ),
        );
      }).toList(),
    );
  }
}

// Petit widget simple pour représenter une vidéo avant lecture
class _VideoPlaceholder extends StatelessWidget {
  final String url;
  const _VideoPlaceholder({required this.url});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(color: Colors.black87),
        const Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
        const Positioned(
          bottom: 10,
          child: Text("Annonce Vidéo", style: TextStyle(color: Colors.white)),
        )
      ],
    );
  }
}