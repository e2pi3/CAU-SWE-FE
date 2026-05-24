// lib/screens/search.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/colors.dart';
import '../constants/app_config.dart';
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
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('검색'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '칵테일을 검색해보세요',
                hintStyle: const TextStyle(
                  color: AppColors.hintText,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    _onSearchChanged('');
                  },
                ),
                filled: true,
                fillColor: AppColors.inputFill,
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
                  ? const LinearProgressIndicator()
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        (_hasSearched && !_isLoading) ? '결과가 없습니다' : '검색어를 입력해보세요',
                        style: const TextStyle(color: AppColors.emptyText),
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
                          title: Text(
                            item.nameKo,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '카테고리 > ${item.category ?? ''}',
                            style: const TextStyle(fontSize: 13, color: AppColors.subtitleText),
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