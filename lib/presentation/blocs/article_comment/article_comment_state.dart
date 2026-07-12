import 'package:dev_news/domain/entities/comment_entity.dart';
import 'package:equatable/equatable.dart';

class ArticleCommentState extends Equatable {
  const ArticleCommentState();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class ArticleCommentInitial extends ArticleCommentState {}

class ArticleCommentLoading extends ArticleCommentState {}

class ArticleCommentLoaded extends ArticleCommentState {
  final List<CommentEntity> comments;

  const ArticleCommentLoaded(this.comments);

  @override
  // TODO: implement props
  List<Object?> get props => [comments];
}

class ArticleCommentError extends ArticleCommentState {
  final String message;

  const ArticleCommentError(this.message);

  @override
  // TODO: implement props
  List<Object?> get props => [message];
}
