import 'package:equatable/equatable.dart';

abstract class ArticleDetailState extends Equatable {
  const ArticleDetailState();

  @override
  List<Object?> get props => [];
}

class ArticleDetailInitial extends ArticleDetailState {}

class ArticleDetailLoading extends ArticleDetailState {}

class ArticleDetailLoaded extends ArticleDetailState {
  final String content;

  const ArticleDetailLoaded(this.content);

  @override
  // TODO: implement props
  List<Object?> get props => [content];
}

class ArticleDetailError extends ArticleDetailState {
  final String message;

  const ArticleDetailError(this.message);

  @override
  // TODO: implement props
  List<Object?> get props => [message];
}
