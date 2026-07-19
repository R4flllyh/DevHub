import 'package:dev_news/domain/entities/comment_entity.dart';
import 'package:dev_news/domain/repositories/article_repository.dart';

class GetArticleComments {
  final ArticleRepository repository;

  GetArticleComments(this.repository);

  Future<List<CommentEntity>> execute(int articleId) async {
    return await repository.getArticleComments(articleId);
  }
}
