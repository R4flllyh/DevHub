import 'package:flutter/material.dart';
import '../../data/models/article_model.dart';
import '../../data/providers/news_api_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsApiProvider _newsApiProvider = NewsApiProvider();
  final ScrollController _scrollController = ScrollController();

  // State manajemen untuk infinite scroll
  final List<ArticleModel> _articles = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchArticles(); // Muat data pertama kali

    // Pasang listener pada ScrollController untuk mendeteksi posisi scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
        .dispose(); // Wajib di-dispose untuk menghindari kebocoran memori
    super.dispose();
  }

  // Fungsi untuk mengambil data berdasarkan halaman (page)
  Future<void> _fetchArticles() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // API Provider Anda harus mendukung parameter halaman, misalnya: getLatestArticles(page: _currentPage)
      // Jika API Anda belum mendukung, sesuaikan method getLatestArticles Anda terlebih dahulu.
      final List<ArticleModel> newArticles = await _newsApiProvider
          .getLatestArticles(page: _currentPage);

      setState(() {
        _isLoading = false;
        if (newArticles.isEmpty) {
          _hasMore = false; // Jika data kosong, berarti sudah habis
        } else {
          _currentPage++; // Naikkan halaman untuk fetch berikutnya
          _articles.addAll(newArticles); // Gabungkan data lama dengan data baru
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Deteksi jika user sudah scroll mendekati bawah (trigger 200 piksel sebelum mentok)
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchArticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DevHub.',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      // Mengganti FutureBuilder dengan kondisi State konvensional
      body: _articles.isEmpty && _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A1A1A)),
            )
          : _errorMessage != null && _articles.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Failed to load articles.\n$_errorMessage",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            )
          : ListView.builder(
              controller: _scrollController, // Pasang ScrollController di sini
              // Tambah item count + 1 jika masih ada data atau sedang loading untuk menampilkan indikator di bawah
              itemCount: _articles.length + (_hasMore ? 1 : 0),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              itemBuilder: (context, index) {
                // Jika index sama dengan panjang list artikel, berarti ini baris paling bawah
                if (index == _articles.length) {
                  if (_errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: TextButton(
                          onPressed: _fetchArticles,
                          child: const Text(
                            'Tap to retry',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }
                  // Tampilkan loading kecil di bawah saat memuat halaman berikutnya
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Color(0xFF1A1A1A),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                }

                final article = _articles[index];

                // UI Card Minimalis Anda tetap sama
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: InkWell(
                    onTap: () {},
                    splashColor: Colors.grey[100],
                    highlightColor: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: NetworkImage(
                                article.authorProfileImage,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              article.authorName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF555555),
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            const Text(
                              '•',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 6.0),
                            Text(
                              article.publishedAt,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            article.coverImage,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: const Color(0xFFF5F5F5),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.grey,
                                    size: 28,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          article.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                            height: 1.3,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          article.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
