import 'package:flutter/material.dart';
import '../../data/models/article_model.dart';
import '../../data/providers/news_api_provider.dart';
import '../widgets/loading_shimmer.dart';
import 'article_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsApiProvider _newsApiProvider = NewsApiProvider();
  final ScrollController _scrollController = ScrollController();

  final List<ArticleModel> _articles = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper untuk mengecek apakah artikel memiliki cover image yang valid
  bool _hasValidCover(String? url) {
    if (url == null || url.isEmpty || url == 'null') return false;
    // Mengantisipasi jika API mengirimkan aset gambar placeholder kosong
    if (url.contains('no-image') || url.contains('placeholder')) return false;
    return true;
  }

  Future<void> _fetchArticles() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<ArticleModel> newArticles = await _newsApiProvider
          .getLatestArticles(page: _currentPage);

      setState(() {
        _isLoading = false;
        if (newArticles.isEmpty) {
          _hasMore = false;
        } else {
          _currentPage++;
          _articles.addAll(
            newArticles,
          ); // Kita simpan semua data, filternya di tingkat UI
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

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
      body: _articles.isEmpty && _isLoading
          ? const LoadingShimmer()
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
          : RefreshIndicator(
              color: const Color(0xFF1A1A1A),
              backgroundColor: Colors.white,
              onRefresh: () async {
                _currentPage = 1;
                _hasMore = true;

                try {
                  final List<ArticleModel> refreshedArticles =
                      await _newsApiProvider.getLatestArticles(
                        page: _currentPage,
                      );

                  setState(() {
                    _articles.clear();
                    _articles.addAll(refreshedArticles);
                    _currentPage++;
                  });
                } catch (e) {
                  setState(() {
                    _errorMessage = e.toString();
                  });
                }
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _articles.length + (_hasMore ? 1 : 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 12.0,
                ),
                itemBuilder: (context, index) {
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
                  final bool dynamicHasImage = _hasValidCover(
                    article.coverImage,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ArticleDetailPage(article: article),
                          ),
                        );
                      },
                      splashColor: Colors.grey[100],
                      highlightColor: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Metadata Penulis
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

                          // 2. Kondisional Rendering Gambar Utama
                          if (dynamicHasImage) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                article.coverImage,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox.shrink(); // Sembunyikan jika network gagal
                                },
                              ),
                            ),
                            const SizedBox(height: 12.0),
                          ],

                          // 💡 SINKRONISASI TAGS: Pasang Wrap ini agar tags muncul di Home Page
                          if (article.tags.isNotEmpty) ...[
                            Wrap(
                              spacing: 6.0, // Jarak horizontal antar chip tag
                              runSpacing:
                                  4.0, // Jarak vertikal jika tag melipat ke baris baru
                              children: article.tags.take(3).map((tag) {
                                // 💡 Trik: .take(3) agar kartu tidak kepenuhan jika tag terlalu banyak
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8.0),
                          ],

                          // 3. Judul Artikel (Langsung merapat ke atas jika tidak ada gambar)
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

                          // 4. Deskripsi Artikel
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
            ),
    );
  }
}
