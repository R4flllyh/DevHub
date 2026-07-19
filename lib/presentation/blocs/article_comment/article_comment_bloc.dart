import 'package:dev_news/domain/usecases/get_article_comments.dart';
import 'package:dev_news/presentation/blocs/article_comment/article_comment_event.dart';
import 'package:dev_news/presentation/blocs/article_comment/article_comment_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArticleCommentBloc
    extends Bloc<ArticleCommentEvent, ArticleCommentState> {
  final GetArticleComments getArticleComments;

  ArticleCommentBloc({required this.getArticleComments})
    : super(ArticleCommentInitial()) {
    on<FetchArticleComments>(_onFetchArticleComments);
  }

  Future<void> _onFetchArticleComments(
    FetchArticleComments event,
    Emitter<ArticleCommentState> emit,
  ) async {
    emit(ArticleCommentLoading());

    try {
      final comments = await getArticleComments.execute(event.articleId);

      // 💡 TAMBAHKAN LOG INI UNTUK INSPEKSI DATA
      for (var c in comments) {
        debugPrint("Komentar dari ${c.userName}: ${c.bodyHtml}");
      }
      emit(ArticleCommentLoaded(comments));
    } catch (e) {
      emit(ArticleCommentError(e.toString()));
    }
  }
}
