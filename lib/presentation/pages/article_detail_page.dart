import 'package:dev_news/domain/entities/comment_entity.dart';
import 'package:dev_news/presentation/widgets/comment_bottom_sheet.dart';
import 'package:dev_news/presentation/widgets/comment_item_widget.dart';
import 'package:dev_news/presentation/widgets/interactive_image_viewer.dart';
import 'package:dev_news/presentation/widgets/vscode_code_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:dev_news/domain/entities/article_entity.dart';
import 'package:dev_news/presentation/blocs/article_detail/article_detail_bloc.dart';
import 'package:dev_news/presentation/blocs/article_detail/article_detail_event.dart';
import 'package:dev_news/presentation/blocs/article_detail/article_detail_state.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dev_news/presentation/blocs/article_comment/article_comment_bloc.dart';
import 'package:dev_news/presentation/blocs/article_comment/article_comment_event.dart';
import 'package:dev_news/presentation/blocs/article_comment/article_comment_state.dart';

class ArticleDetailPage extends StatefulWidget {
  final ArticleEntity article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ArticleDetailBloc>().add(
      FetchArticleDetail(widget.article.id),
    );
    context.read<ArticleCommentBloc>().add(
      FetchArticleComments(widget.article.id),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          //Button Share Article
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: Color(0xFF1A1A1A),
              size: 22,
            ),
            onPressed: () {
              final String articleUrl = widget.article.url.isNotEmpty
                  ? widget.article.url
                  : 'https://dev.to';

              Share.share(
                'Check out this article: "${widget.article.title}"\n\n$articleUrl',
                subject: widget.article.title,
              );
            },
          ),
          // Button comments
          BlocBuilder<ArticleCommentBloc, ArticleCommentState>(
            builder: (context, commentState) {
              int commentCount = 0;
              if (commentState is ArticleCommentLoaded) {
                commentCount = commentState.comments.length;
              }
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (modalContext) {
                          return BlocProvider.value(
                            value: context.read<ArticleCommentBloc>(),
                            child: const CommentBottomSheet(),
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.mode_comment_outlined,
                      color: Color(0xFF1A1A1A),
                      size: 22,
                    ),
                  ),

                  // Badge Counter
                  if (commentCount > 0)
                    Positioned(
                      top: 10,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A1A1A),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '$commentCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Metadata Penulis & Tanggal
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

            // 2. Judul Artikel Utama
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
            const SizedBox(height: 16.0),

            // Render Tags Terstruktur dari Entity
            if (widget.article.tags.isNotEmpty) ...[
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: widget.article.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20.0),
            ],

            // 3. Kondisional Rendering Cover Image (Interactive Zoom)
            if (hasImage) ...[
              GestureDetector(
                onTap: () => InteractiveImageViewer.show(
                  context,
                  widget.article.coverImage,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Image.network(
                        widget.article.coverImage,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[200]!,
                            highlightColor: Colors.grey[50]!,
                            child: Container(
                              height: 200.0,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      // Indikator Zoom
                      Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: const Icon(
                          Icons.zoom_in_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
            ],

            // 4. Area Konten Utama
            BlocBuilder<ArticleDetailBloc, ArticleDetailState>(
              builder: (context, state) {
                if (state is ArticleDetailLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1A1A1A),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                if (state is ArticleDetailError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          Text(
                            "Gagal memuat konten lengkap.\n${state.message}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1A1A),
                            ),
                            onPressed: () {
                              context.read<ArticleDetailBloc>().add(
                                FetchArticleDetail(widget.article.id),
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

                if (state is ArticleDetailLoaded) {
                  final RegExp frontMatterRegex = RegExp(
                    r'^---\s*[\s\S]*?---\s*',
                  );
                  String cleanedContent = state.content.replaceFirst(
                    frontMatterRegex,
                    '',
                  );

                  final RegExp liquidTagsRegex = RegExp(r'{%\s*[\s\S]*?%}');
                  cleanedContent = cleanedContent.replaceAll(
                    liquidTagsRegex,
                    '',
                  );

                  return MarkdownBody(
                    data: cleanedContent,
                    selectable: true,
                    builders: {'pre': VsCodeCodeBlockBuilder()},
                    // handle link on the body
                    onTapLink: (text, href, title) async {
                      if (href != null) {
                        final Uri url = Uri.parse(href);
                        try {
                          // 💡 Gunakan externalApplication agar pasti membuka Chrome / Browser default
                          bool launched = await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );

                          // Fallback jika externalApplication gagal
                          if (!launched) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.platformDefault,
                            );
                          }
                        } catch (e) {
                          debugPrint('Error launching url: $e');
                        }
                      }
                    },
                    // 💡 HANDLER RENDERING GAMBAR DENGAN FITUR POPUP ZOOM
                    imageBuilder: (uri, title, alt) {
                      final String imageUrl = uri.toString();

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: GestureDetector(
                          // 💡 TAP GAMBAR UNTUK BUKA POPUP INTERAKTIF
                          onTap: () =>
                              InteractiveImageViewer.show(context, imageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight:
                                    300.0, // Batas tinggi normal saat berada di dalam artikel
                              ),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  // Render Gambar
                                  Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const SizedBox.shrink(),
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Shimmer.fromColors(
                                            baseColor: Colors.grey[200]!,
                                            highlightColor: Colors.grey[50]!,
                                            child: Container(
                                              height: 180.0,
                                              width: double.infinity,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                  ),

                                  // 💡 INDIKATOR VISUAL BAHWA GAMBAR BISA DI-TAP/ZOOM
                                  Container(
                                    margin: const EdgeInsets.all(8.0),
                                    padding: const EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: const Icon(
                                      Icons.zoom_in_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    styleSheet: MarkdownStyleSheet(
                      // 💡 1. MATIKAN DEKORASI BONGKAH KODE BAWAAN
                      codeblockDecoration: const BoxDecoration(
                        color:
                            Colors.transparent, // Hilangkan background bawaan
                      ),
                      codeblockPadding:
                          EdgeInsets.zero, // Hilangkan padding luar ganda
                      // 💡 2. MATIKAN BACKGROUND CODE BAWAAN
                      code: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13.0,
                        backgroundColor: Colors
                            .transparent, // Pastikan tidak ada highlight pink/abu bawaan
                      ),

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
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }
}
