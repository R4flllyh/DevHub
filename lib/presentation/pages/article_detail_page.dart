import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:dev_news/domain/entities/article_entity.dart';
import 'package:dev_news/presentation/blocs/article_detail/article_detail_bloc.dart';
import 'package:dev_news/presentation/blocs/article_detail/article_detail_event.dart';
import 'package:dev_news/presentation/blocs/article_detail/article_detail_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dev_news/presentation/blocs/article_comment/article_comment_bloc.dart';
import 'package:dev_news/presentation/blocs/article_comment/article_comment_event.dart';
import 'package:dev_news/presentation/blocs/article_comment/article_comment_state.dart';

class ArticleDetailPage extends StatefulWidget {
  // 💡 PERBAIKAN: Menggunakan ArticleEntity, bukan ArticleModel lagi
  final ArticleEntity article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class CommentItemWidget extends StatefulWidget {
  final String content;
  final String userName;
  final String userProfileImage;

  const CommentItemWidget({
    super.key,
    required this.content,
    required this.userName,
    required this.userProfileImage,
  });

  @override
  State<CommentItemWidget> createState() => _CommentItemWidgetState();
}

class _CommentItemWidgetState extends State<CommentItemWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // 💡 OPTIMASI: Trim teks untuk membuang spasi kosong atau enter tidak berguna di ujung data
    final String cleanedContent = widget.content.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profil
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[200],
                backgroundImage: NetworkImage(widget.userProfileImage),
              ),
              const SizedBox(width: 10),
              Text(
                widget.userName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Konten Komentar dengan Batasan Baris Dinamis
          LayoutBuilder(
            builder: (context, constraints) {
              // Mengukur secara presisi batas 3 baris berdasarkan lebar layout HP
              final textPainter = TextPainter(
                text: TextSpan(
                  text: cleanedContent,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[800],
                  ),
                ),
                maxLines: 3,
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth);

              // 💡 EVALUASI MUTLAK: true jika teks > 3 baris, false jika teks pendek
              final bool isTextOverflowing = textPainter.didExceedMaxLines;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isExpanded || !isTextOverflowing)
                    // Jika teksnya pendek (isTextOverflowing == false) atau user klik expand, tampilkan full Markdown
                    MarkdownBody(
                      data: cleanedContent,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    )
                  else
                    // Jika teks panjang dan belum di-expand, potong dengan Ellipsis (...)
                    Text(
                      cleanedContent,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),

                  // 💡 KUNCI JAWABAN: Tombol ini HANYA akan masuk ke dalam pohon widget jika isTextOverflowing bernilai TRUE
                  if (isTextOverflowing) ...[
                    const SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded ? 'Show less' : 'Read more',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  @override
  void initState() {
    super.initState();
    // 💡 TRICK BLOC: Memicu pengambilan detail konten Markdown via BLoC
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

            // 4. Area Konten Utama (Menggunakan BlocBuilder secara Reaktif)
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
                  // 1. Bersihkan Front Matter YAML
                  final RegExp frontMatterRegex = RegExp(
                    r'^---\s*[\s\S]*?---\s*',
                  );
                  String cleanedContent = state.content.replaceFirst(
                    frontMatterRegex,
                    '',
                  );

                  // 💡 PERBAIKAN LIQUID TAGS: Hapus baris teks penanda {% ... %} milik Dev.to agar tidak mengotori UI
                  final RegExp liquidTagsRegex = RegExp(r'{%\s*[\s\S]*?%}');
                  cleanedContent = cleanedContent.replaceAll(
                    liquidTagsRegex,
                    '',
                  );

                  return MarkdownBody(
                    data: cleanedContent,
                    selectable: true,
                    // 💡 PERBAIKAN LINK: Aktifkan fungsi klik untuk membuka browser bawaan HP
                    onTapLink: (text, href, title) async {
                      if (href != null) {
                        final Uri url = Uri.parse(href);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.inAppWebView);
                        }
                      }
                    },
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
                  );
                }

                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 40.0),
            const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 24.0),

            const Text(
              'Discussion',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),

            const SizedBox(height: 16),

            BlocBuilder<ArticleCommentBloc, ArticleCommentState>(
              builder: (context, commentState) {
                if (commentState is ArticleCommentLoading) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1A1A1A),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                if (commentState is ArticleCommentError) {
                  return Text(
                    'Gagal Memuat komentar: ${commentState.message}',
                    style: TextStyle(fontSize: 13, color: Colors.red),
                  );
                }

                if (commentState is ArticleCommentLoaded) {
                  if (commentState.comments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Belum ada komentar. Jadilah yang pertama berdiskusi!',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    );
                  }

                  final RegExp liquidTagsRegex = RegExp(r'{%\s*[\s\S]*?%}');

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: commentState.comments.length,
                    itemBuilder: (context, index) {
                      final comment = commentState.comments[index];

                      final RegExp liquidTagsRegex = RegExp(r'{%\s*[\s\S]*?%}');
                      final RegExp htmlTagsRegex = RegExp(r'<[^>]*>');

                      String cleanedCommentBody = comment.bodyHtml
                          .replaceAll(liquidTagsRegex, '')
                          .replaceAll(htmlTagsRegex, '');

                      return CommentItemWidget(
                        content: cleanedCommentBody,
                        userName: comment.userName,
                        userProfileImage: comment.userProfileImage,
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
