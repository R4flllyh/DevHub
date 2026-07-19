import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dev_news/presentation/blocs/article_comment/article_comment_bloc.dart';
import 'package:dev_news/presentation/blocs/article_comment/article_comment_state.dart';
import 'package:dev_news/presentation/widgets/comment_item_widget.dart';

class CommentBottomSheet extends StatelessWidget {
  const CommentBottomSheet({super.key});

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
        return Container(
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
                    color: const Color(0xFF1A1A1A).withOpacity(0.06),
                  ),
                ],
              ),

              // KONTEN UTAMA SCROLLABLE
              Expanded(
                child: BlocBuilder<ArticleCommentBloc, ArticleCommentState>(
                  builder: (context, commentState) {
                    if (commentState is ArticleCommentLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1A1A1A),
                          strokeWidth: 2,
                        ),
                      );
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
                        return Center(
                          child: Text(
                            "Belum Ada Komentar.",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        );
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
                            color: const Color(0xFF1A1A1A).withOpacity(0.04),
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final comment = commentState.comments[index];
                          return CommentItemWidget(comment: comment);
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFF1A1A1A).withOpacity(0.06),
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        // Avatar Dummy Pengguna Saat ini
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Input
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFEAEAEA),
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: const TextField(
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1A1A1A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Add to the discussion...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Tombol Send
                        GestureDetector(
                          onTap: () {
                            //
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              color: Color(
                                0xFF1A1A1A,
                              ), // Lingkaran hitam solid khas editorial kontras tinggi
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons
                                  .arrow_upward_rounded, // Ikon panah ke atas yang minimalis dan tajam
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
