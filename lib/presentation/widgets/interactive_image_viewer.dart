import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class InteractiveImageViewer extends StatelessWidget {
  final String imageUrl;

  const InteractiveImageViewer({super.key, required this.imageUrl});

  // 💡 Helper static method untuk memanggil dialog dengan mudah
  static void show(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => InteractiveImageViewer(imageUrl: imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark backdrop ala gallery
      body: Stack(
        children: [
          // 💡 1. AREA ZOOMABLE PHOTO VIEW
          PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3.0, // Maksimal zoom 3x
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),

          // 💡 2. TOMBOL CLOSE DI POJOK KANAN ATAS
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
