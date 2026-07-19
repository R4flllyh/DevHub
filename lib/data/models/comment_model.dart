import 'package:dev_news/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.bodyHtml,
    required super.createdAt,
    required super.userName,
    required super.userProfileImage,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // API dev.to menyimpan di dalam nested object 'user'
    final userJson = json['user'] ?? {};
    return CommentModel(
      id: json['id'] ?? 0,
      bodyHtml: json['body_html'] ?? '',
      createdAt: json['created_at'] ?? '',
      userName: userJson['username'] ?? 'Anonymous',
      userProfileImage:
          userJson['profile_image_90'] ??
          'https://dev-to-uploads.s3.amazonaws.com/uploads/user/profile_image/placeholder.png',
    );
  }
}
