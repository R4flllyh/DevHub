import 'package:equatable/equatable.dart';

abstract class ArticleDetailEvent extends Equatable {
  const ArticleDetailEvent();

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class FetchArticleDetail extends ArticleDetailEvent {
  final int id;

  const FetchArticleDetail(this.id);

  @override
  List<Object?> get props => [id];
}
