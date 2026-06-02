// lib/screens/cocktail_info.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_config.dart';
import '../services/auth_service.dart';
import 'ingredient_info.dart';
import 'login.dart';
import 'search.dart';

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

  @override
  void initState() {
    super.initState();
    _fetch();
    _fetchRating();
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
      _showLoginDialog();
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
        _showLoginDialog();
      }
    } catch (_) {}
  }

  // 로그인 안내 팝업
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그인 필요'),
        content: const Text('로그인이 필요합니다. 로그인 페이지로 이동하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('로그인하기'),
          ),
        ],
      ),
    );
  }

  // 평점 위젯: ★★★★☆ 4.0 (87) 형태
  Widget _buildRatingWidget() {
    if (_ratingLoading) {
      return const SizedBox(
        height: 32,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // 별 표시 기준: 내 평점이 있으면 내 평점, 없으면 평균(반올림)
    final displayScore = _userRating ?? _avgRating.round();

    return Row(
      children: [
        ...List.generate(5, (i) {
          final starValue = i + 1;
          return GestureDetector(
            onTap: () => _submitRating(starValue),
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                starValue <= displayScore ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 26,
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        Text(
          '${_avgRating.toStringAsFixed(1)} ($_ratingCount)',
          style: AppTextStyles.caption,
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
            style: AppTextStyles.caption,
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
