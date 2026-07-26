import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dev_news/presentation/blocs/article_comment/article_comment_bloc.dart';
import 'package:dev_news/presentation/blocs/article_comment/article_comment_state.dart';
import 'package:dev_news/presentation/widgets/comment_item_widget.dart';
import 'package:shimmer/shimmer.dart';

class CommentBottomSheet extends StatefulWidget {
  const CommentBottomSheet({super.key});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  String? _replyingToUser;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  void _setReplyUser(String username) {
    setState(() {
      _replyingToUser = username;
    });
    // Auto focus ke textfield saat reply diklik
    FocusScope.of(context).requestFocus(_inputFocusNode);
  }

  void _clearReplyUser() {
    setState(() {
      _replyingToUser = null;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 MENGGUNAKAN DRAGGABLE SCROLLABLE SHEET AGAR HEIGHT BISA MENYESUAIKAN SCROLL
    return DraggableScrollableSheet(
      initialChildSize: 0.75, // Tinggi awal saat dibuka (75% layar)
      minChildSize:
          0.5, // Tinggi minimal saat ditarik ke bawah untuk menutup (50% layar)
      maxChildSize:
          0.95, // Tinggi maksimal saat di-scroll ke bawah (95% layar / hampir fullscreen)
      snap:
          true, // Membuat sheet otomatis "menempel" ke ukuran terdekat saat dilepas
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER AREA FIXED
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kapsul penanda drag minimalis
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12.0, bottom: 20.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E5E5),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),

                    // Judul Utama
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        bottom: 16.0,
                      ),
                      child: Text(
                        'Discussion',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    Container(
                      height: 1,
                      color: const Color(0xFF1A1A1A).withValues(alpha: 0.06),
                    ),
                  ],
                ),

                // KONTEN UTAMA SCROLLABLE
                Expanded(
                  child: BlocBuilder<ArticleCommentBloc, ArticleCommentState>(
                    builder: (context, commentState) {
                      if (commentState is ArticleCommentLoading) {
                        return const _CommentShimmerLoading();
                      }

                      if (commentState is ArticleCommentError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Gagal Memuat Komentar: ${commentState.message}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      }

                      if (commentState is ArticleCommentLoaded) {
                        if (commentState.comments.isEmpty) {
                          return _CommentEmptyState();
                        }

                        return ListView.separated(
                          // 💡 KUNCI UTAMA: Wajib pasang scrollController bawaan Draggable ke dalam ListView
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 20.0,
                          ),
                          itemCount: commentState.comments.length,
                          separatorBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: const Color(
                                0xFF1A1A1A,
                              ).withValues(alpha: 0.04),
                            ),
                          ),
                          itemBuilder: (context, index) {
                            final comment = commentState.comments[index];
                            return CommentItemWidget(
                              comment: comment,
                              onReply: (username) => _setReplyUser(username),
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),

                // 💡 AREA DUMMY INPUT TEXT BERBASIS STATE REPLY
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: const Color(
                            0xFF1A1A1A,
                          ).withValues(alpha: 0.06),
                          width: 1,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 💡 BANNER INDIKATOR REPLY
                          if (_replyingToUser != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 6.0,
                              ),
                              color: const Color(0xFFF7F7F7),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Replying to @$_replyingToUser',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _clearReplyUser,
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // INPUT ROW
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F7F7),
                                      borderRadius: BorderRadius.circular(24.0),
                                      border: Border.all(
                                        color: const Color(0xFFEAEAEA),
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: TextField(
                                      controller: _commentController,
                                      focusNode: _inputFocusNode,
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: _replyingToUser != null
                                            ? 'Write a reply...'
                                            : 'Add to the discussion...',
                                        hintStyle: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1A1A1A),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommentShimmerLoading extends StatelessWidget {
  const _CommentShimmerLoading();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer Header Profile
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Shimmer Text Lines
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemCount: 4,
      ),
    );
  }
}

class _CommentEmptyState extends StatelessWidget {
  const _CommentEmptyState();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF7F7F7),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_outlined,
                size: 28,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No discussions yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Be the first to share your thoughts and start the conversation below',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
