// lib/screens/search.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_config.dart';
import '../widgets/detail_app_bar.dart';
import 'cocktail_info.dart';
import 'ingredient_info.dart';


// 검색 API에서 호출시 받는 정보 클래스 정의
class Item {
  final String id;
  final String nameKo;
  final String? category;

  Item({
    required this.id,
    required this.nameKo,
    this.category,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'].toString(),
      nameKo: json['name_ko'],
      category: json['category'],
    );
  }
}
 // 아이콘 출력 case 문
IconData _categoryIcon(String? category) {
  switch (category) {
    case '칵테일':
      return Icons.local_bar;
    default:
      return Icons.liquor;
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Item> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _hasText = false;
  Timer? _debounceTimer;

  // 치는동안에는 검색안되게 API호출전까지의 딜레이
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(_debounceDuration, () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/search?q=$trimmed');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _results = data.map((e) => Item.fromJson(e)).toList();
        });
      }
    } catch (e) {
      // 네트워크 에러시 기존 목록 유지
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DetailAppBar(
        '검색',
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              cursorColor: AppColors.primary,
              onChanged: (value) {
                setState(() => _hasText = value.isNotEmpty);
                _onSearchChanged(value);
              },
              decoration: InputDecoration(
                hintText: '칵테일을 검색해보세요',
                hintStyle: const TextStyle(color: AppColors.hintText),
                prefixIcon: const Icon(Icons.search, size: 24),
                suffixIcon: _hasText
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _hasText = false);
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.inputFill,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // 얇은 로딩 인디케이터 (레이아웃 흔들림 방지용 고정 높이)
            SizedBox(
              height: 4,
              child: _isLoading
                  ? const LinearProgressIndicator(color: AppColors.primary)
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        (_hasSearched && !_isLoading) ? '결과가 없습니다' : '검색어를 입력해보세요',
                        style: AppTextStyles.placeholder,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 0.1,
                          ),
                          leading: Icon(
                            _categoryIcon(item.category),
                            color: AppColors.primary,
                          ),
                          title: Text(item.nameKo, style: AppTextStyles.listTitle),
                          subtitle: Text(
                            '카테고리 > ${item.category ?? ''}',
                            style: AppTextStyles.subtitle,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => item.category == '칵테일'
                                  ? CocktailInfoScreen(id: item.id)
                                  : IngredientInfoScreen(id: item.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}