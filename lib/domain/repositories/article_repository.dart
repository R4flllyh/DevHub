import '../entities/article_entity.dart';

abstract class ArticleRepository {
  Future<List<ArticleEntity>> getLatestArticles({int page = 1});
  Future<String> getArticleContent(int id);
}
