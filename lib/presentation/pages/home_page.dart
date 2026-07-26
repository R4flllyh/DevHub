import 'dart:async';

import 'package:dev_news/presentation/blocs/article_feed/article_feed_state.dart';
import 'package:dev_news/presentation/widgets/article_feed_shimmer.dart';
import 'package:dev_news/presentation/widgets/devhub_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dev_news/presentation/blocs/article_feed/article_feed_bloc.dart';
import 'package:dev_news/presentation/blocs/article_feed/article_feed_event.dart';
import 'article_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // State untuk toggle mode search dan menyimpan query aktif
  bool _isSearching = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ArticleFeedBloc>().add(const FetchArticleFeed());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Jeda 700ms agar tidak over-trigger API saat user belum selesai mengetik
    _debounce = Timer(const Duration(milliseconds: 700), () {
      setState(() {
        _currentQuery = query.trim();
      });

      context.read<ArticleFeedBloc>().add(
        FetchArticleFeed(page: 1, query: _currentQuery),
      );
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final state = context.read<ArticleFeedBloc>().state;

    if (state is ArticleFeedLoaded && state.hasReachedMax) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // 💡 PERBAIKAN: Kirim page sebagai -1 atau angka > 1 agar BLoC tahu ini BUKAN first fetch
      if (state is ArticleFeedLoaded) {
        context.read<ArticleFeedBloc>().add(
          FetchArticleFeed(
            page: state.currentPage + 1, // Explicitly pass next page
            query: _currentQuery,
          ),
        );
      }
    }
  }

  // 💡 Widget Custom Empty State (Di dalam State class agar bisa akses Controller)
  Widget _buildSearchEmptyState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              query.isEmpty
                  ? 'Belum ada artikel saat ini'
                  : 'Tidak ada hasil untuk "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              query.isEmpty
                  ? 'Tarik layar ke bawah untuk memperbarui feed artikel terbaru.'
                  : 'Coba periksa kembali ejaan kamu atau gunakan kata kunci topik yang lebih umum.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            if (query.isNotEmpty) ...[
              const SizedBox(height: 24.0),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1A1A1A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                ),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
                child: const Text(
                  'Hapus Pencarian',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _isSearching
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Cari artikel, topik, atau keyword...',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    border: InputBorder.none,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 18,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
              )
            : const Text(
                'DevHub.',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: const Color(0xFF1A1A1A),
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _currentQuery = '';
                  context.read<ArticleFeedBloc>().add(
                    const FetchArticleFeed(page: 1),
                  );
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: BlocBuilder<ArticleFeedBloc, ArticleFeedState>(
        builder: (context, state) {
          if (state is ArticleFeedLoading) {
            return const ArticleFeedShimmer();
          }

          if (state is ArticleFeedError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Gagal memuat artikel:\n${state.message}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A1A),
                      ),
                      onPressed: () {
                        context.read<ArticleFeedBloc>().add(
                          FetchArticleFeed(page: 1, query: _currentQuery),
                        );
                      },
                      child: const Text(
                        'Coba Lagi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ArticleFeedLoaded) {
            final articles = state.articles;

            // 💡 PANGGIL EMPTY STATE DISINI
            if (articles.isEmpty) {
              return _buildSearchEmptyState(_currentQuery);
            }

            return DevHubRefreshIndicator(
              onRefresh: () async {
                context.read<ArticleFeedBloc>().add(
                  FetchArticleFeed(page: 1, query: _currentQuery),
                );
              },
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(24.0),
                itemCount: state.hasReachedMax
                    ? articles.length
                    : articles.length + 1,
                separatorBuilder: (context, index) {
                  if (!state.hasReachedMax && index == articles.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return const SizedBox(height: 24.0);
                },
                itemBuilder: (context, index) {
                  if (index >= articles.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1A1A1A),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }
                  final article = articles[index];

                  final bool hasImage =
                      article.coverImage.isNotEmpty &&
                      article.coverImage != 'null' &&
                      !article.coverImage.contains('placeholder');

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ArticleDetailPage(article: article),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
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
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            Text(
                              '  •  ${article.publishedAt}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        if (hasImage) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(
                              article.coverImage,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                        ],
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        if (article.tags.isNotEmpty) ...[
                          Wrap(
                            spacing: 6.0,
                            runSpacing: 4.0,
                            children: article.tags.take(3).map((tag) {
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
                        ],
                      ],
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
