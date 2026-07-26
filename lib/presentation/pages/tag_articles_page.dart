import 'package:dev_news/presentation/blocs/article_feed/article_feed_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dev_news/presentation/blocs/article_feed/article_feed_bloc.dart';
import 'package:dev_news/presentation/blocs/article_feed/article_feed_event.dart';
import 'package:dev_news/presentation/pages/article_detail_page.dart';

class TagArticlesPage extends StatefulWidget {
  final String tagName;

  const TagArticlesPage({super.key, required this.tagName});

  @override
  State<TagArticlesPage> createState() => _TagArticlesPageState();
}

class _TagArticlesPageState extends State<TagArticlesPage> {
  @override
  void initState() {
    super.initState();
    // Fetch artikel khusus untuk tag ini
    context.read<ArticleFeedBloc>().add(
      FetchArticleFeed(page: 1, tag: widget.tagName),
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1A1A1A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '#${widget.tagName}',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<ArticleFeedBloc, ArticleFeedState>(
        builder: (context, state) {
          if (state is ArticleFeedLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A1A1A)),
            );
          }

          if (state is ArticleFeedLoaded) {
            if (state.articles.isEmpty) {
              return Center(
                child: Text(
                  'Tidak ada artikel dengan tag #${widget.tagName}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: state.articles.length,
              itemBuilder: (context, index) {
                final article = state.articles[index];
                return ListTile(
                  title: Text(
                    article.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(article.authorName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ArticleDetailPage(article: article),
                      ),
                    );
                  },
                );
              },
            );
          }

          if (state is ArticleFeedError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
