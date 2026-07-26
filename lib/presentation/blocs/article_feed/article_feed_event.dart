import 'package:equatable/equatable.dart';

abstract class ArticleFeedEvent extends Equatable {
  const ArticleFeedEvent();

  @override
  List<Object?> get props => [];
}

// Event yang dipanggil saat load feed utama, search query, atau filter tag
class FetchArticleFeed extends ArticleFeedEvent {
  final int page;
  final String? query;
  final String? tag;

  const FetchArticleFeed({this.page = 1, this.query, this.tag});

  @override
  List<Object?> get props => [page, query, tag];
}
