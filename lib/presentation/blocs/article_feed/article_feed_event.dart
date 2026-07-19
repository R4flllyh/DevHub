import 'package:equatable/equatable.dart';

abstract class ArticleFeedEvent extends Equatable {
  const ArticleFeedEvent();

  @override
  List<Object?> get props => [];
}

// An event triggered when the main page is first opened or refreshed.
class FetchArticleFeed extends ArticleFeedEvent {
  final int page;

  const FetchArticleFeed({this.page = 1});

  @override
  List<Object?> get props => [page];
}
