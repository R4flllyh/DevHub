import 'package:equatable/equatable.dart';
import 'package:dev_news/domain/entities/article_entity.dart';

abstract class ArticleFeedState extends Equatable {
  const ArticleFeedState();

  @override
  List<Object?> get props => [];
}

class ArticleFeedInitial extends ArticleFeedState {}

class ArticleFeedLoading extends ArticleFeedState {}

class ArticleFeedLoaded extends ArticleFeedState {
  final List<ArticleEntity> articles;
  final bool hasReachedMax;
  final int currentPage;

  const ArticleFeedLoaded({
    required this.articles,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [articles, hasReachedMax, currentPage];

  // Helper
  ArticleFeedLoaded copyWith({
    List<ArticleEntity>? articles,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return ArticleFeedLoaded(
      articles: articles ?? this.articles,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ArticleFeedError extends ArticleFeedState {
  final String message;

  const ArticleFeedError(this.message);

  @override
  List<Object?> get props => [message];
}
