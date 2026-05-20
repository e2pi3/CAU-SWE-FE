// lib/screens/cocktail_detail.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────
// 데이터 모델
// ─────────────────────────────────────────────
class CocktailDetail {
  final int id;
  final String name;
  final String nameKo;
  final String glassType;
  final String? description;
  final double? abv; // alcohol_volume 대신 abv로 변경
  final String? recipe; // steps 대신 recipe 사용
  final String? imageUrl;
  final List<Ingredient> ingredients;
  final List<String> steps; // recipe를 가공해서 담을 리스트

  CocktailDetail({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.glassType,
    this.description,
    this.abv,
    this.recipe,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
  });

  factory CocktailDetail.fromJson(Map<String, dynamic> json) {
    // recipe 문자열을 문장별로 쪼개어 리스트로 변환 (온점 기준)
    final String rawRecipe = json['recipe'] ?? '';
    final List<String> parsedSteps = rawRecipe
        .split('.')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => '$e.') // 잘려나간 온점 다시 붙여주기
        .toList();

    return CocktailDetail(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      nameKo: json['name_ko'] ?? '',
      glassType: json['glass_type'] ?? '',
      description: json['description'],
      abv: (json['abv'] as num?)?.toDouble(), // 'abv' 키 대응
      recipe: rawRecipe,
      imageUrl: json['image_url'],
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => Ingredient.fromJson(e))
          .toList(),
      steps: parsedSteps, // 가공된 스텝 리스트 주입
    );
  }
}

class Ingredient {
  final String nameKo;
  final String amount;

  Ingredient({
    required this.nameKo,
    required this.amount,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      // JSON의 'ingredient' 키가 한글 이름이므로 nameKo에 매핑
      nameKo: json['ingredient'] ?? '',
      amount: json['amount']?.toString() ?? '',
    );
  }
}

// ─────────────────────────────────────────────
// 상세 화면
// ─────────────────────────────────────────────
class CocktailDetailScreen extends StatefulWidget {
  final int cocktailId;
  final String cocktailNameKo;

  const CocktailDetailScreen({
    super.key,
    required this.cocktailId,
    required this.cocktailNameKo,
  });

  @override
  State<CocktailDetailScreen> createState() => _CocktailDetailScreenState();
}

class _CocktailDetailScreenState extends State<CocktailDetailScreen> {
  static const String _baseUrl = 'http://cau-swe-be-server.up.railway.app';

  CocktailDetail? _detail;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final uri = Uri.parse('$_baseUrl/cocktails/info?id=${widget.cocktailId}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _detail = CocktailDetail.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = '데이터를 불러오지 못했어요 (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '네트워크 오류가 발생했어요';
        debugPrint('에러 발생: $e');
        _isLoading = false;
      });
    }
  }

  // ── 재료 아이콘 (한글 매핑으로 수정) ────────────────────────────
  IconData _ingredientIcon(String nameKo) {
    if (nameKo.contains('보드카') || nameKo.contains('럼') || 
        nameKo.contains('진') || nameKo.contains('데킬라') || nameKo.contains('위스키')) {
      return Icons.wine_bar;
    }
    if (nameKo.contains('즙') || nameKo.contains('주스') || nameKo.contains('레몬') || nameKo.contains('라임')) {
      return Icons.emoji_food_beverage;
    }
    if (nameKo.contains('시럽') || nameKo.contains('설탕')) {
      return Icons.water_drop;
    }
    if (nameKo.contains('민트') || nameKo.contains('애플민트') || nameKo.contains('허브')) {
      return Icons.eco;
    }
    if (nameKo.contains('콜라') || nameKo.contains('소다') || nameKo.contains('토닉')) {
      return Icons.bubble_chart;
    }
    if (nameKo.contains('얼음')) {
      return Icons.ac_unit;
    }
    return Icons.local_bar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _isLoading
          ? const _LoadingView()
          : _error != null
              ? _ErrorView(message: _error!, onRetry: _fetchDetail)
              : _DetailBody(
                  detail: _detail!,
                  isFavorite: _isFavorite,
                  onFavoriteToggle: () =>
                      setState(() => _isFavorite = !_isFavorite),
                  ingredientIcon: _ingredientIcon,
                ),
    );
  }
}

// ─────────────────────────────────────────────
// 로딩 & 에러 뷰 (기존 코드와 동일)
// ─────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF69F0AE))),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text('다시 시도', style: TextStyle(color: Color(0xFF69F0AE))),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 상세 본문
// ─────────────────────────────────────────────
class _DetailBody extends StatelessWidget {
  final CocktailDetail detail;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final IconData Function(String) ingredientIcon;

  const _DetailBody({
    required this.detail,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.ingredientIcon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: const Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.redAccent : Colors.white,
              ),
              onPressed: onFavoriteToggle,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                detail.imageUrl != null
                    ? Image.network(
                        detail.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
                      )
                    : const _ImagePlaceholder(),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xCC000000), Color(0xFF121212)],
                      stops: [0.4, 0.8, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        detail.nameKo, // 기본 타이틀을 한글 이름으로 변경
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail.name.toUpperCase(), // 부타이틀로 영문 이름 배치
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white54,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MetaBadges(detail: detail),
                const SizedBox(height: 24),

                _SectionHeader(title: 'INGREDIENTS'),
                const SizedBox(height: 12),
                ...detail.ingredients.map(
                  (ing) => _IngredientRow(
                    ingredient: ing,
                    icon: ingredientIcon(ing.nameKo),
                  ),
                ),
                const SizedBox(height: 28),

                if (detail.steps.isNotEmpty) ...[
                  _SectionHeader(title: 'STEPS'),
                  const SizedBox(height: 12),
                  ...detail.steps.asMap().entries.map(
                        (entry) => _StepRow(index: entry.key + 1, text: entry.value),
                      ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: const Center(child: Icon(Icons.local_bar, size: 80, color: Color(0xFF3A3A3A))),
    );
  }
}

// ─────────────────────────────────────────────
// 메타 배지 (JSON 데이터에 맞게 축소)
// ─────────────────────────────────────────────
class _MetaBadges extends StatelessWidget {
  final CocktailDetail detail;
  const _MetaBadges({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (detail.abv != null)
          _Badge(
            label: 'ALC. VOL: ${detail.abv!.toStringAsFixed(0)}%',
            color: Colors.white24,
            textColor: Colors.white70,
          ),
        if (detail.glassType.isNotEmpty)
          _Badge(
            label: 'GLASS: ${detail.glassType.replaceAll('_', ' ').toUpperCase()}',
            color: Colors.white24,
            textColor: Colors.white70,
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Badge({required this.label, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: textColor, letterSpacing: 0.6),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
    );
  }
}

// ─────────────────────────────────────────────
// 재료 및 스텝 로우 (데이터 구조에 맞춰 수정)
// ─────────────────────────────────────────────
class _IngredientRow extends StatelessWidget {
  final Ingredient ingredient;
  final IconData icon;

  const _IngredientRow({required this.ingredient, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF69F0AE)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient.nameKo,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Text(
            ingredient.amount, // 기존 displayAmount 대신 바로 amount 출력
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int index;
  final String text;

  const _StepRow({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(color: Color(0xFF69F0AE), shape: BoxShape.circle),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(color: Color(0xFF121212), fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}