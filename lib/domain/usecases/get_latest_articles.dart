import 'package:dev_news/domain/entities/article_entity.dart';
import 'package:dev_news/domain/repositories/article_repository.dart';

class GetLatestArticles {
  final ArticleRepository repository;

  GetLatestArticles(this.repository);

  Future<List<ArticleEntity>> execute({
    int page = 1,
    String? query,
    String? tag,
  }) async {
    return await repository.getLatestArticles(
      page: page,
      query: query,
      tag: tag,
    );
  }
}
