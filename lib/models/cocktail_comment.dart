// lib/models/cocktail_comment.dart

class CocktailComment {
  final int id;
  final String username;
  final String nickname;
  final String content;
  final bool isMine;

  CocktailComment({
    required this.id,
    required this.username,
    required this.nickname,
    required this.content,
    required this.isMine,
  });

  factory CocktailComment.fromJson(Map<String, dynamic> json) {
    return CocktailComment(
      id: json['id'] as int,
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      content: json['content'] as String,
      isMine: json['is_mine'] as bool? ?? false,
    );
  }
}
