import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final int id;
  final String bodyHtml;
  final String createdAt;
  final String userName;
  final String userProfileImage;

  const CommentEntity({
    required this.id,
    required this.bodyHtml,
    required this.createdAt,
    required this.userName,
    required this.userProfileImage,
  });

  @override
  List<Object?> get props => [
    id,
    bodyHtml,
    createdAt,
    userName,
    userProfileImage,
  ];
}
