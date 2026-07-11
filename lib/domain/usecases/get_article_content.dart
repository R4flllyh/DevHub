import 'package:dev_news/domain/repositories/article_repository.dart';

class GetArticleContent {
  final ArticleRepository repository;

  GetArticleContent(this.repository);

  Future<String> execute(int id) async {
    return await repository.getArticleContent(id);
  }
}
