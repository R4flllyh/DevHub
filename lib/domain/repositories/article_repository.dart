import 'package:dev_news/domain/entities/article_entity.dart';
import 'package:dev_news/domain/entities/comment_entity.dart';

abstract class ArticleRepository {
  Future<List<ArticleEntity>> getLatestArticles({int page = 1});
  Future<String> getArticleContent(int id);

  Future<List<CommentEntity>> getArticleComments(int articleId);
}
