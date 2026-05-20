// lib/screens/cocktail_info.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/colors.dart';
import '../constants/app_config.dart';

class CocktailIngredient {
  final String ingredient;
  final String amount;

  CocktailIngredient({required this.ingredient, required this.amount});

  factory CocktailIngredient.fromJson(Map<String, dynamic> json) {
    return CocktailIngredient(
      ingredient: json['ingredient'],
      amount: json['amount'],
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

  @override
  void initState() {
    super.initState();
    _fetch();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
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
            style: const TextStyle(
              color: AppColors.subtitleText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),

          // 한글 이름 + ABV 뱃지
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                d.nameKo,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              if (d.abv != null) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ABV ${d.abv}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Divider(height: 48),

          // 재료
          const Text('재료', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...d.ingredients.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.ingredient, style: const TextStyle(fontSize: 15)),
                  Text(
                    e.amount,
                    style: const TextStyle(fontSize: 14, color: AppColors.subtitleText),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 48),

          // 제조법
          const Text('제조법', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(d.recipe, style: const TextStyle(fontSize: 15, height: 1.7)),
          const SizedBox(height: 24),

          // 칵테일 사진 (스켈레톤 포함, 제조법과 사이에 구분선 없음)
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
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          const Divider(height: 48),

          // 설명
          const Text('설명', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(d.description ?? '', style: const TextStyle(fontSize: 15, height: 1.7)),
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
              style: TextStyle(color: AppColors.subtitleText, fontSize: 14),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
