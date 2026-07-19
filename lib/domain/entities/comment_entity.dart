import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final int id;
  final String bodyHtml;
  final String createdAt;
  final String userName;
  final String userProfileImage;
  final List<CommentEntity> children;

  const CommentEntity({
    required this.id,
    required this.bodyHtml,
    required this.createdAt,
    required this.userName,
    required this.userProfileImage,
    required this.children,
  });

  @override
  List<Object?> get props => [
    id,
    bodyHtml,
    createdAt,
    userName,
    userProfileImage,
    children,
  ];
}
