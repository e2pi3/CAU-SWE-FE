// lib/screens/ingredient_info.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_config.dart';
import 'cocktail_info.dart';
import 'search.dart';
import '../utils/navigation_state.dart' show requestGoHome;

class IngredientCocktail {
  final String id;
  final String nameKo;
  final String imageUrl;

  IngredientCocktail({
    required this.id,
    required this.nameKo,
    required this.imageUrl,
  });

  factory IngredientCocktail.fromJson(Map<String, dynamic> json) {
    return IngredientCocktail(
      id: json['id'],
      nameKo: json['name_ko'],
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class IngredientDetail {
  final int id;
  final String name;
  final String nameKo;
  final String imageUrl;
  final String category;
  final List<IngredientCocktail> cocktails;

  IngredientDetail({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.imageUrl,
    required this.category,
    required this.cocktails,
  });

  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
      id: json['id'],
      name: json['name'],
      nameKo: json['name_ko'],
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
      cocktails: [],
    );
  }
}

class IngredientInfoScreen extends StatefulWidget {
  final String id;

  const IngredientInfoScreen({super.key, required this.id});

  @override
  State<IngredientInfoScreen> createState() => _IngredientInfoScreenState();
}

class _IngredientInfoScreenState extends State<IngredientInfoScreen> {
  IngredientDetail? _detail;
  List<IngredientCocktail> _cocktails = [];
  int _cocktailTotal = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final uri = Uri.parse(
        '${AppConfig.baseUrl}/ingredients/info?id=${widget.id}&limit=5&offset=0',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          _detail = IngredientDetail.fromJson(json);
          _cocktails = (json['cocktails'] as List)
              .map((e) => IngredientCocktail.fromJson(e))
              .toList();
          _cocktailTotal = json['cocktail_total'] ?? 0;
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

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final uri = Uri.parse(
        '${AppConfig.baseUrl}/ingredients/info?id=${widget.id}&limit=5&offset=${_cocktails.length}',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final more = (json['cocktails'] as List)
            .map((e) => IngredientCocktail.fromJson(e))
            .toList();
        setState(() {
          _cocktails.addAll(more);
          _isLoadingMore = false;
        });
      } else {
        setState(() => _isLoadingMore = false);
      }
    } catch (_) {
      setState(() => _isLoadingMore = false);
    }
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
            onPressed: () {
              requestGoHome();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
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
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이름 + 카테고리 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 영어 이름 (부제목 색상)
                Text(
                  d.name,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 4),

                // 한글 이름
                Text(
                  d.nameKo,
                  style: AppTextStyles.cocktailName,
                ),
                const SizedBox(height: 8),

                // 카테고리
                if (d.category.isNotEmpty)
                  Text(
                    '카테고리 > ${d.category}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 100, 100, 100),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(thickness: 1, height: 48, color: Color(0xFFE0E0E0)),

          // 재료 이미지
          if (d.imageUrl.isNotEmpty)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  d.imageUrl,
                  width: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.fitWidth,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded || frame != null) return child;
                    return SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 200,
                      child: Container(color: AppColors.inputFill),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),

          const Divider(thickness: 1, height: 48, color: Color(0xFFE0E0E0)),

          // 해당 재료가 들어간 칵테일 목록
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${d.nameKo}${_josaIGa(d.nameKo)} 들어간 칵테일',
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 16),

                if (_cocktails.isEmpty)
                  const Text('관련 칵테일이 없습니다.', style: AppTextStyles.caption)
                else ...[
                  ..._cocktails.map((c) => _buildCocktailItem(context, c)),

                  if (_cocktails.length < _cocktailTotal)
                    Center(
                      child: _isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: CircularProgressIndicator(),
                            )
                          : IconButton(
                              icon: const Icon(Icons.keyboard_arrow_down),
                              onPressed: _loadMore,
                            ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 마지막 글자 받침 유무에 따라 '이' 또는 '가' 반환
  String _josaIGa(String text) {
    if (text.isEmpty) return '이(가)';
    final last = text.codeUnitAt(text.length - 1);
    if (last < 0xAC00 || last > 0xD7A3) return '이(가)';
    return (last - 0xAC00) % 28 != 0 ? '이' : '가';
  }

  Widget _buildCocktailItem(BuildContext context, IngredientCocktail c) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CocktailInfoScreen(id: c.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // 칵테일 썸네일
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: c.imageUrl.isNotEmpty
                  ? Image.network(
                      c.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded || frame != null) return child;
                        return Container(
                          width: 60,
                          height: 60,
                          color: AppColors.inputFill,
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 60,
                        height: 60,
                        color: AppColors.inputFill,
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: AppColors.inputFill,
                    ),
            ),
            const SizedBox(width: 14),

            // 칵테일 이름
            Expanded(
              child: Text(
                c.nameKo,
                style: AppTextStyles.listTitle,
              ),
            ),

            const Icon(Icons.chevron_right, color: AppColors.subtitleText),
          ],
        ),
      ),
    );
  }
}
