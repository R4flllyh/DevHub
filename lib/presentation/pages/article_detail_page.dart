import 'package:flutter/material.dart';
import '../../data/models/article_model.dart';

class ArticleDetailPage extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // Mengecek apakah artikel memiliki cover image yang valid
    final bool hasImage =
        article.coverImage.isNotEmpty &&
        article.coverImage != 'null' &&
        !article.coverImage.contains('placeholder');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1A1A1A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Metadata Penulis
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(article.authorProfileImage),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.authorName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      article.publishedAt,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Kondisional Rendering Gambar Utama
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  article.coverImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 24.0),
            ],

            // Judul Artikel Utama
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                height: 1.3,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 20),

            // Deskripsi Artikel
            Text(
              article.description,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                letterSpacing: 0.1,
                color: Colors.grey[800],
              ),
            ),

            const SizedBox(height: 40),

            // footer notes
            Center(
              child: Text(
                '•••',
                style: TextStyle(color: Colors.grey[400], fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
