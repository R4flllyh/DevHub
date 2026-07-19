import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dev_news/domain/usecases/get_latest_articles.dart';
import 'article_feed_event.dart';
import 'article_feed_state.dart';

class ArticleFeedBloc extends Bloc<ArticleFeedEvent, ArticleFeedState> {
  final GetLatestArticles getLatestArticles;

  ArticleFeedBloc({required this.getLatestArticles})
    : super(ArticleFeedInitial()) {
    on<FetchArticleFeed>(_onFetchArticleFeed);
  }

  Future<void> _onFetchArticleFeed(
    FetchArticleFeed event,
    Emitter<ArticleFeedState> emit,
  ) async {
    final currentState = state;

    // 1. jika sudah mencapai halaman maksimal, maka jangan lakukan apa-apa
    if (currentState is ArticleFeedLoaded && currentState.hasReachedMax) return;

    try {
      // 2. Jika baru pertama kali load (initial)
      if (currentState is! ArticleFeedLoaded) {
        emit(ArticleFeedLoading());
        final articles = await getLatestArticles.execute(page: 1);

        emit(
          ArticleFeedLoaded(
            articles: articles,
            hasReachedMax: articles.isEmpty,
            currentPage: 1,
          ),
        );
        return;
      }

      // 3. jika ini adalah request halaman berikut nya (lazy load)
      final nextPage = currentState.currentPage + 1;
      final newArticles = await getLatestArticles.execute(page: nextPage);

      if (newArticles.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true));
      } else {
        // Kunci pagination: gabungkan list lama dengan yang baru
        emit(
          ArticleFeedLoaded(
            articles: List.of(currentState.articles)..addAll(newArticles),
            hasReachedMax: false,
            currentPage: nextPage,
          ),
        );
      }
    } catch (e) {
      emit(ArticleFeedError(e.toString()));
    }
  }
}
