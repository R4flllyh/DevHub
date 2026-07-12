import 'package:equatable/equatable.dart';

class ArticleCommentEvent extends Equatable {
  const ArticleCommentEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchArticleComments extends ArticleCommentEvent {
  final int articleId;

  const FetchArticleComments(this.articleId);

  @override
  // TODO: implement props
  List<Object?> get props => [articleId];
}
