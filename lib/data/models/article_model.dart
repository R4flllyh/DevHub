class ArticleModel {
  final int id;
  final String title;
  final String description;
  final String url;
  final String coverImage;
  final String publishedAt;
  final String authorName;
  final String authorProfileImage;

  ArticleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.coverImage,
    required this.publishedAt,
    required this.authorName,
    required this.authorProfileImage,
  });

  // Factory constructor to create an ArticleModel from JSON data
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
