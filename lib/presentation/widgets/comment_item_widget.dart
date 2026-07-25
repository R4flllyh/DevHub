import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:dev_news/domain/entities/comment_entity.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentItemWidget extends StatefulWidget {
  final CommentEntity comment;
  final bool isReply;
  final ValueChanged<String>? onReply;

  const CommentItemWidget({
    super.key,
    required this.comment,
    this.isReply = false,
    this.onReply,
  });

  @override
  State<CommentItemWidget> createState() => _CommentItemWidgetState();
}

class _CommentItemWidgetState extends State<CommentItemWidget> {
  bool _isExpanded = false;
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final String cleanedContent = widget.comment.bodyHtml
        .replaceAll(RegExp(r'{%\s*[\s\S]*?%}'), '')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();

    final int repliesCount = widget.comment.children.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kiri: Garis pandu vertikal tipis untuk komentar balasan bersarang
            if (widget.isReply) ...[
              const SizedBox(width: 8.0),
              Container(
                width: 1.5,
                margin: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                color: const Color(0xFF1A1A1A).withOpacity(0.08),
              ),
            ],

            // Kanan: Konten Utama Komentar
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Profil: Nama Pengguna saja
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: NetworkImage(
                            widget.comment.userProfileImage,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.comment.userName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Isi Konten Komentar Utama
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final textPainter = TextPainter(
                          text: TextSpan(
                            text: cleanedContent,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Color(0xFF333333),
                            ),
                          ),
                          maxLines: 3,
                          textDirection: TextDirection.ltr,
                        )..layout(maxWidth: constraints.maxWidth);

                        final bool isTextOverflowing =
                            textPainter.didExceedMaxLines;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Render Teks Utama
                            if (_isExpanded || !isTextOverflowing)
                              MarkdownBody(
                                data: cleanedContent,
                                onTapLink: (text, href, title) async {
                                  if (href != null) {
                                    final Uri url = Uri.parse(href);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  }
                                },
                                imageBuilder: (uri, title, alt) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxHeight: 250,
                                        ),
                                        child: Image.network(
                                          uri.toString(),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const SizedBox.shrink();
                                              },
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Shimmer.fromColors(
                                                  child: Container(
                                                    height: 150,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  baseColor: Colors.grey[500]!,
                                                  highlightColor:
                                                      Colors.grey[50]!,
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF333333),
                                    height: 1.5,
                                  ),
                                ),
                              )
                            else
                              Text(
                                cleanedContent,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF333333),
                                  height: 1.5,
                                ),
                              ),

                            const SizedBox(height: 8.0),

                            // 💡 EDITORIAL ACTION ROW: Baris Horizontal Aksi di Bawah Teks
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // 1. Read More / Show Less (Hanya muncul jika teks panjang)
                                    if (isTextOverflowing) ...[
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => _isExpanded = !_isExpanded,
                                        ),
                                        child: Text(
                                          _isExpanded
                                              ? 'Show less'
                                              : 'Read more',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1A1A1A),
                                            letterSpacing: -0.1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12.0,
                                      ), // Spasi antara Read More dan Reply
                                    ],

                                    // 2. Tombol Reply (Selalu muncul di setiap komentar)
                                    GestureDetector(
                                      onTap: () {
                                        if (widget.onReply != null) {
                                          widget.onReply!(
                                            widget.comment.userName,
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Reply',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF666666),
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Pojok Kanan Bawah: Tombol Replies
                                if (repliesCount > 0)
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => _showReplies = !_showReplies,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 5.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _showReplies
                                            ? const Color(0xFF1A1A1A)
                                            : const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(
                                          6.0,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _showReplies
                                                ? Icons
                                                      .keyboard_arrow_up_rounded
                                                : Icons
                                                      .keyboard_arrow_down_rounded,
                                            size: 14,
                                            color: _showReplies
                                                ? Colors.white
                                                : const Color(0xFF666666),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _showReplies
                                                ? 'Hide'
                                                : '$repliesCount ${repliesCount == 1 ? 'reply' : 'replies'}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: _showReplies
                                                  ? Colors.white
                                                  : const Color(0xFF666666),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Panggilan Rekursif Bersarang untuk Balasan Komentar Anak
        if (repliesCount > 0 && _showReplies)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              children: widget.comment.children.map((childComment) {
                return CommentItemWidget(comment: childComment, isReply: true);
              }).toList(),
            ),
          ),
      ],
    );
  }
}
