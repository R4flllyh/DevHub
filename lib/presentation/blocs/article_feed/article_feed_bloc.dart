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
    final bool isFirstFetch =
        currentState is! ArticleFeedLoaded || event.page == 1;

    if (!isFirstFetch &&
        currentState is ArticleFeedLoaded &&
        currentState.hasReachedMax) {
      return;
    }

    try {
      if (isFirstFetch) {
        emit(ArticleFeedLoading());

        final articles = await getLatestArticles.execute(
          page: 1,
          query: event.query,
          tag: event.tag,
        );

        emit(
          ArticleFeedLoaded(
            articles: articles,
            // 💡 KUNCI FIX: Jika artikel kurang dari 20 (per_page), pasti sudah reached max!
            hasReachedMax: articles.length < 20,
            currentPage: 1,
          ),
        );
        return;
      }

      if (currentState is ArticleFeedLoaded) {
        final nextPage = currentState.currentPage + 1;
        final newArticles = await getLatestArticles.execute(
          page: nextPage,
          query: event.query,
          tag: event.tag,
        );

        if (newArticles.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(
            ArticleFeedLoaded(
              articles: List.of(currentState.articles)..addAll(newArticles),
              // 💡 JIKA HASIL DARI PAGE BERIKUTNYA KURANG DARI 20, JUGA SET TRUE
              hasReachedMax: newArticles.length < 20,
              currentPage: nextPage,
            ),
          );
        }
      }
    } catch (e) {
      emit(ArticleFeedError(e.toString()));
    }
  }
}
