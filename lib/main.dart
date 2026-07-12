import 'package:dev_news/domain/usecases/get_article_comments.dart';
import 'package:dev_news/presentation/blocs/article_comment/article_comment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 1. Import Infrastruktur (Data Layer)
import 'package:dev_news/data/datasources/remote/news_remote_data_source.dart';
import 'package:dev_news/data/repositories/article_repository_impl.dart';

// 2. Import Aturan Bisnis (Domain Layer)
import 'package:dev_news/domain/usecases/get_latest_articles.dart';
import 'package:dev_news/domain/usecases/get_article_content.dart';

// 3. Import Manajemen State (Presentation Layer)
import 'package:dev_news/presentation/blocs/article_feed/article_feed_bloc.dart';
import 'package:dev_news/presentation/blocs/article_detail/article_detail_bloc.dart';
import 'package:dev_news/presentation/pages/home_page.dart';

void main() {
  // 💡 DEPENDENCY INJECTION MANUAL: Satukan instansiasi antar layer
  final NewsRemoteDataSource remoteDataSource = NewsRemoteDataSource();

  final ArticleRepositoryImpl articleRepository = ArticleRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );

  final GetLatestArticles getLatestArticles = GetLatestArticles(
    articleRepository,
  );
  final GetArticleContent getArticleContent = GetArticleContent(
    articleRepository,
  );

  final GetArticleComments getArticleComments = GetArticleComments(
    articleRepository,
  );

  runApp(
    MyApp(
      getLatestArticles: getLatestArticles,
      getArticleContent: getArticleContent,
      getArticleComments: getArticleComments,
    ),
  );
}

class MyApp extends StatelessWidget {
  final GetLatestArticles getLatestArticles;
  final GetArticleContent getArticleContent;
  final GetArticleComments getArticleComments;

  const MyApp({
    super.key,
    required this.getLatestArticles,
    required this.getArticleContent,
    required this.getArticleComments,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 SOLUSI: Bungkus MaterialApp dengan MultiBlocProvider agar BLoC bisa diakses secara global
    return MultiBlocProvider(
      providers: [
        BlocProvider<ArticleFeedBloc>(
          create: (context) =>
              ArticleFeedBloc(getLatestArticles: getLatestArticles),
        ),
        BlocProvider<ArticleDetailBloc>(
          create: (context) =>
              ArticleDetailBloc(getArticleContent: getArticleContent),
        ),
        BlocProvider<ArticleCommentBloc>(
          create: (context) =>
              ArticleCommentBloc(getArticleComments: getArticleComments),
        ),
      ],
      child: MaterialApp(
        title: 'DevHub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const HomePage(),
      ),
    );
  }
}
