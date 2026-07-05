import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../data/models/article_model.dart';
import '../../data/providers/news_api_provider.dart';

class ArticleDetailPage extends StatefulWidget {
  final ArticleModel article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  final NewsApiProvider _apiProvider = NewsApiProvider();

  String _fullContent = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFullContent();
  }

  // Memicu pengambilan data body_markdown berdasarkan ID artikel
  Future<void> _fetchFullContent() async {
    try {
      final String content = await _apiProvider.getArticleContent(
        widget.article.id,
      );

      // 💡 FILTER REGEX: Menghapus blok Front Matter YAML (--- sampai ---) di awal dokumen
      // RegEx ini mendeteksi ^--- di awal, lalu mengambil seluruh teks hingga menemukan --- berikutnya
      final RegExp frontMatterRegex = RegExp(r'^---\s*[\s\S]*?---\s*');
      final String cleanedContent = content.replaceFirst(frontMatterRegex, '');

      setState(() {
        _fullContent = cleanedContent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Validasi cover image bawaan model Anda
    final bool hasImage =
        widget.article.coverImage.isNotEmpty &&
        widget.article.coverImage != 'null' &&
        !widget.article.coverImage.contains('placeholder');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
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
            // 1. Metadata Penulis & Tanggal (Tampil Instan tanpa nunggu API)
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: NetworkImage(
                    widget.article.authorProfileImage,
                  ),
                ),
                const SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.article.authorName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      widget.article.publishedAt,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24.0),

            // 2. Judul Artikel Utama (Tampil Instan)
            Text(
              widget.article.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                height: 1.3,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20.0),

            // 3. Kondisional Rendering Cover Image (Tampil Instan jika ada)
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  widget.article.coverImage,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 24.0),
            ],

            // 4. Area Konten Utama (Asynchronous Loading khusus teks body saja)
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1A1A1A),
                    strokeWidth: 2,
                  ),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    "Gagal memuat konten lengkap.\n$_errorMessage",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              )
            else
              // Render konten lengkap menggunakan format asli Markdown
              MarkdownBody(
                data: _fullContent,
                selectable:
                    true, // User bisa copy-paste baris kode atau teks artikel
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.6,
                    letterSpacing: 0.1,
                  ),
                  h1: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    height: 1.4,
                  ),
                  h2: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    height: 1.4,
                  ),
                  code: TextStyle(
                    color: Colors.red[800],
                    backgroundColor: Colors.grey[100],
                    fontSize: 14,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),

            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }
}
