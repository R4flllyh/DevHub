import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable {
  final int id;
  final String title;
  final String description;
  final String url;
  final String coverImage;
  final String publishedAt;
  final String authorName;
  final String authorProfileImage;
  final List<String> tags;

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.coverImage,
    required this.publishedAt,
    required this.authorName,
    required this.authorProfileImage,
    required this.tags,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    url,
    coverImage,
    publishedAt,
    authorName,
    authorProfileImage,
    tags,
  ];
}
