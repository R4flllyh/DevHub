import 'package:dev_news/data/datasources/remote/news_remote_data_source.dart';
import 'package:dev_news/domain/entities/article_entity.dart';
import 'package:dev_news/domain/entities/comment_entity.dart';
import 'package:dev_news/data/models/comment_model.dart';
import 'package:dev_news/domain/repositories/article_repository.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsRemoteDataSource remoteDataSource;

  ArticleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ArticleEntity>> getLatestArticles({
    int page = 1,
    String? query,
    String? tag,
  }) async {
    try {
      // hit data source, automatically acknowledged ArticleModel as ArticleEntity
      return await remoteDataSource.getLatestArticles(
        page: page,
        query: query,
        tag: tag,
      );
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

  @override
  Future<List<CommentEntity>> getArticleComments(int articleId) async {
    try {
      final rawComment = await remoteDataSource.getArticleComments(articleId);

      return rawComment.map((json) => CommentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
