// lib/models/cocktail_comment.dart

class CocktailComment {
  final int id;
  final String username;
  final String nickname;
  final String content;
  final bool isMine;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;

  CocktailComment({
    required this.id,
    required this.username,
    required this.nickname,
    required this.content,
    required this.isMine,
    required this.createdAt,
    required this.likeCount,
    required this.isLiked,
  });

  factory CocktailComment.fromJson(Map<String, dynamic> json) {
    return CocktailComment(
      id: json['id'] as int,
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      content: json['content'] as String,
      isMine: json['is_mine'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  CocktailComment copyWith({int? likeCount, bool? isLiked}) {
    return CocktailComment(
      id: id,
      username: username,
      nickname: nickname,
      content: content,
      isMine: isMine,
      createdAt: createdAt,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
