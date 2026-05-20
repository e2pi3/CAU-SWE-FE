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
  final double? alcoholVolume;
  final String? spiritType;
  final String? strength;
  final String? difficulty;
  final String? imageUrl;
  final List<Ingredient> ingredients;
  final List<String> steps;

  CocktailDetail({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.glassType,
    this.description,
    this.alcoholVolume,
    this.spiritType,
    this.strength,
    this.difficulty,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
  });

  factory CocktailDetail.fromJson(Map<String, dynamic> json) {
    return CocktailDetail(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      nameKo: json['name_ko'],
      glassType: json['glass_type'],
      description: json['description'],
      alcoholVolume: (json['alcohol_volume'] as num?)?.toDouble(),
      spiritType: json['spirit_type'],
      strength: json['strength'],
      difficulty: json['difficulty'],
      imageUrl: json['image_url'],
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => Ingredient.fromJson(e))
          .toList(),
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class Ingredient {
  final String name;
  final String nameKo;
  final String amount;
  final String? unit;

  Ingredient({
    required this.name,
    required this.nameKo,
    required this.amount,
    this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      nameKo: json['name_ko'] ?? json['name'],
      amount: json['amount']?.toString() ?? '',
      unit: json['unit'],
    );
  }

  String get displayAmount => unit != null ? '$amount$unit' : amount;
}

// ─────────────────────────────────────────────
// 상세 화면
// ─────────────────────────────────────────────
class CocktailDetailScreen extends StatefulWidget {
  final int cocktailId;
  final String cocktailNameKo; // 로딩 중 AppBar 제목에 사용

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
  bool _isFavorite = false; // TODO: 즐겨찾기 로컬 저장 연동

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
        _isLoading = false;
      });
    }
  }

  // ── 배지 색상 ──────────────────────────────
  Color _strengthColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'strong':
        return const Color(0xFFE53935);
      case 'medium':
        return const Color(0xFFFB8C00);
      case 'light':
        return const Color(0xFF43A047);
      default:
        return Colors.grey;
    }
  }

  Color _difficultyColor(String? d) {
    switch (d?.toLowerCase()) {
      case 'hard':
        return const Color(0xFFE53935);
      case 'medium':
        return const Color(0xFFFB8C00);
      case 'easy':
        return const Color(0xFF43A047);
      default:
        return Colors.grey;
    }
  }

  // ── 재료 아이콘 ────────────────────────────
  IconData _ingredientIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('rum') || n.contains('whiskey') || n.contains('vodka') ||
        n.contains('gin') || n.contains('tequila')) {
      return Icons.wine_bar;
    }
    if (n.contains('juice') || n.contains('lime') || n.contains('lemon')) {
      return Icons.emoji_food_beverage;
    }
    if (n.contains('syrup') || n.contains('sugar')) {
      return Icons.water_drop;
    }
    if (n.contains('mint') || n.contains('herb') || n.contains('leaf')) {
      return Icons.eco;
    }
    if (n.contains('soda') || n.contains('water') || n.contains('tonic')) {
      return Icons.bubble_chart;
    }
    if (n.contains('ice')) { return Icons.ac_unit; }
    if (n.contains('cream') || n.contains('milk')) { return Icons.local_cafe; }
    return Icons.local_bar;
  }

  // ── 빌드 ──────────────────────────────────
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
                  strengthColor: _strengthColor(_detail!.strength),
                  difficultyColor: _difficultyColor(_detail!.difficulty),
                  ingredientIcon: _ingredientIcon,
                ),
    );
  }
}

// ─────────────────────────────────────────────
// 로딩
// ─────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF69F0AE)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 에러
// ─────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
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
// 상세 본문 (CustomScrollView + SliverAppBar)
// ─────────────────────────────────────────────
class _DetailBody extends StatelessWidget {
  final CocktailDetail detail;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final Color strengthColor;
  final Color difficultyColor;
  final IconData Function(String) ingredientIcon;

  const _DetailBody({
    required this.detail,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.strengthColor,
    required this.difficultyColor,
    required this.ingredientIcon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Hero 이미지 + AppBar ──────────────
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
                // 이미지 or 플레이스홀더
                detail.imageUrl != null
                    ? Image.network(
                        detail.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const _ImagePlaceholder(),
                      )
                    : const _ImagePlaceholder(),
                // 아래로 갈수록 어두워지는 그라디언트
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xCC000000),
                        Color(0xFF121212),
                      ],
                      stops: [0.4, 0.8, 1.0],
                    ),
                  ),
                ),
                // 칵테일 이름
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        detail.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      if (detail.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          detail.description!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF69F0AE),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── 본문 콘텐츠 ──────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 메타 배지 행
                _MetaBadges(
                  detail: detail,
                  strengthColor: strengthColor,
                  difficultyColor: difficultyColor,
                ),
                const SizedBox(height: 24),

                // 재료 섹션
                _SectionHeader(title: 'INGREDIENTS'),
                const SizedBox(height: 12),
                ...detail.ingredients.map(
                  (ing) => _IngredientRow(
                    ingredient: ing,
                    icon: ingredientIcon(ing.name),
                  ),
                ),
                const SizedBox(height: 28),

                // 스텝 섹션
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

// ─────────────────────────────────────────────
// 이미지 플레이스홀더
// ─────────────────────────────────────────────
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: const Center(
        child: Icon(Icons.local_bar, size: 80, color: Color(0xFF3A3A3A)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 메타 배지 (알코올, 종류, 강도, 난이도)
// ─────────────────────────────────────────────
class _MetaBadges extends StatelessWidget {
  final CocktailDetail detail;
  final Color strengthColor;
  final Color difficultyColor;

  const _MetaBadges({
    required this.detail,
    required this.strengthColor,
    required this.difficultyColor,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (detail.alcoholVolume != null)
          _Badge(
            label: 'ALC. VOL: ${detail.alcoholVolume!.toStringAsFixed(0)}%',
            color: Colors.white24,
            textColor: Colors.white70,
          ),
        if (detail.spiritType != null)
          _Badge(
            label: 'TYPE: ${detail.spiritType!.toUpperCase()}',
            color: Colors.white24,
            textColor: Colors.white70,
          ),
        if (detail.strength != null)
          _Badge(
            label: 'STRENGTH: ${detail.strength!.toUpperCase()}',
            color: strengthColor.withValues(alpha: 0.2),
            textColor: strengthColor,
          ),
        if (detail.difficulty != null)
          _Badge(
            label: 'DIFFICULTY: ${detail.difficulty!.toUpperCase()}',
            color: difficultyColor.withValues(alpha: 0.2),
            textColor: difficultyColor,
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
  });

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
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 섹션 헤더
// ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 재료 한 행
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
            ingredient.displayAmount,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 스텝 한 행
// ─────────────────────────────────────────────
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
            decoration: const BoxDecoration(
              color: Color(0xFF69F0AE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Color(0xFF121212),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}