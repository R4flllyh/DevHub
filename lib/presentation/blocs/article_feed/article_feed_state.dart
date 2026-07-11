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

  const ArticleFeedLoaded(this.articles);

  @override
  List<Object?> get props => [articles];
}

class ArticleFeedError extends ArticleFeedState {
  final String message;

  const ArticleFeedError(this.message);

  @override
  List<Object?> get props => [message];
}
