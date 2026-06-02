// lib/screens/cocktail_info.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_config.dart';
import '../services/auth_service.dart';
import '../widgets/app_dialog.dart';
import '../widgets/login_dialog.dart';
import 'ingredient_info.dart';
import 'search.dart';
import '../models/cocktail_comment.dart';
import 'cocktail_comments.dart';

// 별 일부 채움에 사용하는 클리퍼 (예: 4.7점이면 5번째 별을 70%만 채움)
class _FractionClipper extends CustomClipper<Rect> {
  final double fraction;
  const _FractionClipper(this.fraction);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction.clamp(0.0, 1.0), size.height);

  @override
  bool shouldReclip(_FractionClipper old) => old.fraction != fraction;
}

Widget _buildPartialStar(double fill, double size) {
  return SizedBox(
    width: size,
    height: size,
    child: Stack(
      children: [
        Icon(Icons.star_border, color: AppColors.primary, size: size),
        ClipRect(
          clipper: _FractionClipper(fill),
          child: Icon(Icons.star, color: AppColors.primary, size: size),
        ),
      ],
    ),
  );
}

class CocktailIngredient {
  final String ingredient;
  final String amount;
  final String? ingredientId;

  CocktailIngredient({
    required this.ingredient,
    required this.amount,
    this.ingredientId,
  });

  factory CocktailIngredient.fromJson(Map<String, dynamic> json) {
    return CocktailIngredient(
      ingredient: json['ingredient'],
      amount: json['amount'],
      ingredientId: json['id']?.toString(),
    );
  }
}

class CocktailDetail {
  final String id;
  final String name;
  final String nameKo;
  final String recipe;
  final String glassType;
  final String imageUrl;
  final int? abv;
  final String? description;
  final List<CocktailIngredient> ingredients;

  CocktailDetail({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.recipe,
    required this.glassType,
    required this.imageUrl,
    this.abv,
    this.description,
    required this.ingredients,
  });

  factory CocktailDetail.fromJson(Map<String, dynamic> json) {
    return CocktailDetail(
      id: json['id'],
      name: json['name'],
      nameKo: json['name_ko'],
      recipe: json['recipe'],
      glassType: json['glass_type'],
      imageUrl: json['image_url'] ?? '',
      abv: json['abv'] != null ? (json['abv'] as num).toInt() : null,
      description: json['description'],
      ingredients: (json['ingredients'] as List)
          .map((e) => CocktailIngredient.fromJson(e))
          .toList(),
    );
  }
}

class CocktailInfoScreen extends StatefulWidget {
  final String id;
  const CocktailInfoScreen({super.key, required this.id});

  @override
  State<CocktailInfoScreen> createState() => _CocktailInfoScreenState();
}

class _CocktailInfoScreenState extends State<CocktailInfoScreen> {
  CocktailDetail? _detail;
  bool _isLoading = true;
  String? _error;

  // 평점 상태
  double _avgRating = 0.0;
  int _ratingCount = 0;
  int? _userRating; // 로그인 사용자의 내 평점 (없으면 null)
  bool _ratingLoading = true;

  // 한줄평 미리보기 상태
  List<CocktailComment> _previewComments = [];
  int _totalCommentCount = 0;
  bool _commentsLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
    _fetchRating();
    _fetchPreviewComments();
  }

  Future<void> _fetch() async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/cocktails/info?id=${widget.id}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          _detail = CocktailDetail.fromJson(jsonDecode(response.body));
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '정보를 불러오지 못했습니다.';
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = '네트워크 오류가 발생했습니다.';
        _isLoading = false;
      });
    }
  }

  // 평점 정보 조회 (로그인 상태면 내 평점도 함께)
  Future<void> _fetchRating() async {
    try {
      final token = await AuthService.getAccessToken();
      final uri = Uri.parse('${AppConfig.baseUrl}/cocktails/rating?id=${widget.id}');
      final headers = <String, String>{};
      if (token != null) headers['Authorization'] = 'Bearer $token';
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _avgRating = (data['avg_rating'] as num).toDouble();
          _ratingCount = data['count'] as int;
          _userRating = data['user_rating'] as int?;
          _ratingLoading = false;
        });
      } else {
        setState(() => _ratingLoading = false);
      }
    } catch (_) {
      setState(() => _ratingLoading = false);
    }
  }

  // 평점 제출/수정 (로그인 필수)
  Future<void> _submitRating(int score) async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) {
      if (!mounted) return;
      await showLoginRequiredDialog(context, onLoginSuccess: _fetchRating);
      return;
    }
    final token = await AuthService.getAccessToken();
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/cocktails/rating?id=${widget.id}');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'rating': score}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          _avgRating = (data['avg_rating'] as num).toDouble();
          _ratingCount = data['count'] as int;
          _userRating = data['user_rating'] as int?;
        });
      } else if (response.statusCode == 401) {
        // 토큰 만료 등 인증 실패
        if (!mounted) return;
        await showLoginRequiredDialog(context, onLoginSuccess: _fetchRating);
      }
    } catch (_) {}
  }

  // 평점 팝업 (로그인 확인 후 표시)
  Future<void> _openRatingDialog() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!loggedIn) {
      if (!mounted) return;
      await showLoginRequiredDialog(context, onLoginSuccess: _fetchRating);
      return;
    }
    if (!mounted) return;

    int selectedRating = _userRating ?? 0;
    final initialRating = selectedRating; // 변경 여부 감지용

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AppDialog(
          title: '칵테일을 평가해주세요!',
          content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final starValue = i + 1;
                  return GestureDetector(
                    onTap: () {
                      // 별 탭 시 UI만 변경, API는 닫기 시 전송
                      setDialogState(() => selectedRating = starValue);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        starValue <= selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  );
                }),
          ),
          actions: [
            AppDialogAction(
              label: '닫기',
              onPressed: () {
                Navigator.of(ctx).pop();
                // 별점이 선택됐고 이전과 달라진 경우에만 API 전송
                if (selectedRating > 0 && selectedRating != initialRating) {
                  _submitRating(selectedRating);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // 한줄평 미리보기 조회 (상위 2개)
  Future<void> _fetchPreviewComments() async {
    try {
      final token = await AuthService.getAccessToken();
      final uri = Uri.parse('${AppConfig.baseUrl}/cocktails/comments?id=${widget.id}&limit=2&offset=0');
      final headers = <String, String>{};
      if (token != null) headers['Authorization'] = 'Bearer $token';
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _totalCommentCount = data['count'] as int;
          _previewComments = (data['comments'] as List)
              .map((e) => CocktailComment.fromJson(e as Map<String, dynamic>))
              .toList();
          _commentsLoading = false;
        });
      } else {
        setState(() => _commentsLoading = false);
      }
    } catch (_) {
      setState(() => _commentsLoading = false);
    }
  }

  // 한줄평 상세 화면으로 이동
  void _openCommentsScreen() {
    if (_detail == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CocktailCommentsScreen(
          cocktailId: widget.id,
          cocktailName: _detail!.name,
          cocktailNameKo: _detail!.nameKo,
          cocktailImageUrl: _detail!.imageUrl,
        ),
      ),
    ).then((_) {
      _fetchPreviewComments();
      _fetchRating(); // 댓글창에서 로그인했을 때 평점 상태도 갱신
    });
  }

  // 한줄평 섹션 (미리보기 2개)
  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더 행
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text('한줄평', style: AppTextStyles.sectionTitle),
            if (_totalCommentCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$_totalCommentCount',
                style: const TextStyle(fontSize: 15, color: AppColors.subtitleText),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (_commentsLoading)
          const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (_previewComments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('아직 한줄평이 없습니다.', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _openCommentsScreen,
                  child: const Text(
                    '첫 한줄평 남기기 ...',
                    style: TextStyle(fontSize: 14, color: AppColors.subtitleText),
                  ),
                ),
              ],
            ),
          )
        else ...[
          ..._previewComments.map((c) => _buildCommentPreviewItem(c)),
          GestureDetector(
            onTap: _openCommentsScreen,
            child: const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '댓글 더보기 ...',
                style: TextStyle(fontSize: 14, color: AppColors.subtitleText),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentPreviewItem(CocktailComment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: comment.nickname,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: ' (${comment.username})',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            comment.content,
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 평점 위젯: ★★★★☆ 4.0 (87) 형태 — 별은 항상 평균 평점 기준으로 표시
  Widget _buildRatingWidget() {
    if (_ratingLoading) {
      return const SizedBox(height: 26);
    }

    return Row(
      children: [
        ...List.generate(5, (i) {
          final fill = (_avgRating - i).clamp(0.0, 1.0);
          return GestureDetector(
            onTap: () => _openRatingDialog(),
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: _buildPartialStar(fill, 26),
            ),
          );
        }),
        const SizedBox(width: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: ' ($_ratingCount)',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    final d = _detail!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 영어 이름 (부제목 색상)
          Text(
            d.name,
            style: AppTextStyles.cocktailNameEn,
          ),
          const SizedBox(height: 4),

          // 한글 이름 + ABV 뱃지
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  d.nameKo,
                  style: AppTextStyles.cocktailName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (d.abv != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('ABV ${d.abv}%', style: AppTextStyles.abvBadge),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _buildRatingWidget(),
          const Divider(height: 48),

          // 한줄평
          _buildCommentsSection(),
          const Divider(height: 48),

          // 재료
          const Text('재료', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 10),
          ...d.ingredients.map(
            (e) => GestureDetector(
              onTap: e.ingredientId != null
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IngredientInfoScreen(id: e.ingredientId!),
                        ),
                      )
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.ingredient,
                      style: const TextStyle(fontSize: 15),
                    ),
                    Text(
                      e.amount,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 48),

          // 칵테일 사진 (스켈레톤 포함)
          if (d.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                d.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) return child;
                  return AspectRatio(
                    aspectRatio: 1,
                    child: Container(color: AppColors.inputFill),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('이미지 없음', style: AppTextStyles.caption),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // 제조법
          const Text('제조법', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 10),
          Text(d.recipe, style: AppTextStyles.bodyText),
          const Divider(height: 48),

          // 설명
          const Text('설명', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 10),
          Text(d.description ?? '', style: AppTextStyles.bodyText),
          const Divider(height: 48),

          // 구현 예정 영역
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '구현 예정',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
