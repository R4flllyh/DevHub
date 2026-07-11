import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dev_news/domain/usecases/get_latest_articles.dart';
import 'article_feed_event.dart';
import 'article_feed_state.dart';

class ArticleFeedBloc extends Bloc<ArticleFeedEvent, ArticleFeedState> {
  final GetLatestArticles getLatestArticles;

  ArticleFeedBloc({required this.getLatestArticles})
    : super(ArticleFeedInitial()) {
    // Registrasi handler untuk FetchArticleFeed event
    on<FetchArticleFeed>((event, emit) async {
      emit(ArticleFeedLoading());
      try {
        final articles = await getLatestArticles.execute(page: event.page);
        emit(ArticleFeedLoaded(articles));
      } catch (e) {
        emit(ArticleFeedError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
