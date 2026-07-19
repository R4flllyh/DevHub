import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dev_news/domain/usecases/get_article_content.dart';
import 'article_detail_event.dart';
import 'article_detail_state.dart';

class ArticleDetailBloc extends Bloc<ArticleDetailEvent, ArticleDetailState> {
  final GetArticleContent getArticleContent;

  ArticleDetailBloc({required this.getArticleContent})
    : super(ArticleDetailInitial()) {
    on<FetchArticleDetail>((event, emit) async {
      emit(ArticleDetailLoading());

      try {
        final content = await getArticleContent.execute(event.id);
        emit(ArticleDetailLoaded(content));
      } catch (e) {
        emit(ArticleDetailError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
