import '../../domain/entities/article_entity.dart';

class ArticleModel extends ArticleEntity {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.description,
    required super.url,
    required super.coverImage,
    required super.publishedAt,
    required super.authorName,
    required super.authorProfileImage,
    required super.tags,
  });

  // Factory constructor to create an ArticleModel from JSON data
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    // Parsing tag_list menjadi List<String> yang aman dari null
    final List<dynamic> tagList = json['tag_list'] ?? [];
    final List<String> parsedTags = tagList
        .map((tag) => tag.toString())
        .toList();

    return ArticleModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      coverImage: json['cover_image'] ?? '',
      publishedAt: json['readable_publish_date'] ?? '',
      authorName: json['user']?['name'] ?? 'Anonymous',
      authorProfileImage:
          json['user']?['profile_image_90'] ??
          'https://placehold.co/100x100/png?text=User',

      tags: parsedTags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'cover_image': coverImage,
      'readable_publish_date': publishedAt,
      'user': {'name': authorName, 'profile_image_90': authorProfileImage},
      'tag_list': tags,
    };
  }
}
