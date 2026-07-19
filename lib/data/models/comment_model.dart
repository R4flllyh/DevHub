import 'package:dev_news/domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.bodyHtml,
    required super.createdAt,
    required super.userName,
    required super.userProfileImage,
    required super.children,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // API dev.to menyimpan di dalam nested object 'user'
    final userJson = json['user'] ?? {};

    // parsing children json jadi list
    final List<dynamic> rawChildren = json['children'] ?? [];
    final List<CommentModel> parsedChildren = rawChildren
        .map((childJson) => CommentModel.fromJson(childJson))
        .toList();
    return CommentModel(
      id: json['id'] ?? 0,
      bodyHtml: json['body_html'] ?? '',
      createdAt: json['created_at'] ?? '',
      userName: userJson['username'] ?? 'Anonymous',
      userProfileImage:
          userJson['profile_image_90'] ??
          'https://dev-to-uploads.s3.amazonaws.com/uploads/user/profile_image/placeholder.png',
      children: parsedChildren,
    );
  }
}
