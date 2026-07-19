import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dev_news/presentation/blocs/article_feed/article_feed_bloc.dart';
import 'package:dev_news/presentation/blocs/article_feed/article_feed_event.dart';
import 'package:dev_news/presentation/blocs/article_feed/article_feed_state.dart';
import 'article_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. deklarasi scrollController bawaan flutter
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    // 💡 TRICK BLOC: Pemicu pertama untuk mengambil data dari API saat halaman dibuka
    context.read<ArticleFeedBloc>().add(const FetchArticleFeed());

    // 2. pasang Listener untuk mendeteksi posisi scroll user
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    //3. wajib di dispose agar tidak memicu memory leak
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // cek apakah posisi scroll sudah mendekati atau sudah mentok di bawah layar
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // picu BLoC untuk mengambil halaman berikutnya
      context.read<ArticleFeedBloc>().add(FetchArticleFeed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'DevHub.',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      // 💡 BLOC BUILDER: Menggambar UI secara reaktif tergantung State mesin BLoC
      body: BlocBuilder<ArticleFeedBloc, ArticleFeedState>(
        builder: (context, state) {
          if (state is ArticleFeedLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1A1A1A),
                strokeWidth: 2,
              ),
            );
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
                          const FetchArticleFeed(),
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

            if (articles.isEmpty) {
              return const Center(child: Text('Tidak ada artikel saat ini.'));
            }

            return RefreshIndicator(
              color: const Color(0xFF1A1A1A),
              onRefresh: () async {
                context.read<ArticleFeedBloc>().add(const FetchArticleFeed());
              },
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(24.0),
                itemCount: state.hasReachedMax
                    ? articles.length
                    : articles.length + 1,
                separatorBuilder: (context, index) {
                  if (!state.hasReachedMax && index == articles.length + 1) {
                    return const SizedBox.shrink();
                  }
                  return const SizedBox(height: 24.0);
                },
                itemBuilder: (context, index) {
                  if (index >= articles.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
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
                        // Metadata Penulis
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

                        // Cover Image jika ada
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

                        // Judul Utama
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

                        // Render Tags Terbatas (Maksimal 3)
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
