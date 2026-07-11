import 'package:dev_news/data/datasources/remote/news_remote_data_source.dart';
import 'package:dev_news/domain/entities/article_entity.dart';
import 'package:dev_news/domain/repositories/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsRemoteDataSource remoteDataSource;

  ArticleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ArticleEntity>> getLatestArticles({int page = 1}) async {
    try {
      // hit data source, automatically acknowledged ArticleModel as ArticleEntity
      return await remoteDataSource.getLatestArticles(page: page);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<String> getArticleContent(int id) async {
    try {
      return await remoteDataSource.getArticleContent(id);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
