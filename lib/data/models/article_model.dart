class ArticleModel {
  final int id;
  final String title;
  final String description;
  final String url;
  final String coverImage;
  final String publishedAt;
  final String authorName;
  final String authorProfileImage;
  final List<String> tags;

  ArticleModel({
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
}
