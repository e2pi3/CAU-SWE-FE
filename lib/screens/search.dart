// lib/screens/search.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cocktail_detail.dart'; // ← 상세 화면 import

// ─────────────────────────────────────────────
// 검색 결과 모델 (id 필드 추가)
// ─────────────────────────────────────────────
class Cocktail {
  final int id; // ← 상세 화면 이동에 사용
  final String name;
  final String nameKo;
  final String glassType;

  Cocktail({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.glassType,
  });

  factory Cocktail.fromJson(Map<String, dynamic> json) {
    return Cocktail(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      nameKo: json['name_ko'],
      glassType: json['glass_type'],
    );
  }
}

// glass_type 문자열 → 아이콘 매핑
IconData _glassIcon(String glassType) {
  switch (glassType.toLowerCase()) {
    case 'cocktail glass':
    case 'martini glass':
      return Icons.wine_bar;
    case 'highball glass':
    case 'collins glass':
      return Icons.local_drink;
    case 'old fashioned glass':
    case 'rocks glass':
    case 'lowball glass':
      return Icons.sports_bar;
    case 'shot glass':
      return Icons.local_bar;
    case 'wine glass':
    case 'red wine glass':
    case 'white wine glass':
      return Icons.wine_bar;
    case 'champagne flute':
    case 'champagne glass':
      return Icons.celebration;
    case 'beer glass':
    case 'beer mug':
    case 'pint glass':
      return Icons.sports_bar;
    case 'copper mug':
    case 'mug':
      return Icons.coffee;
    case 'hurricane glass':
    case 'poco grande glass':
      return Icons.local_drink;
    default:
      return Icons.local_bar;
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Cocktail> _results = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  static const String _baseUrl = 'http://cau-swe-be-server.up.railway.app';
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
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('$_baseUrl/cocktails/search?q=$trimmed');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _results = data.map((e) => Cocktail.fromJson(e)).toList();
        });
      }
    } catch (e) {
      // 네트워크 에러시 기존 목록 유지
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── 상세 페이지로 이동 ──────────────────────
  void _navigateToDetail(Cocktail cocktail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CocktailDetailScreen(
          cocktailId: cocktail.id,
          cocktailNameKo: cocktail.nameKo,
        ),
      ),
    );
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
        title: const Text('Cocktail Search'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  color: Color.fromARGB(255, 119, 119, 119),
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
                fillColor: const Color.fromARGB(255, 230, 230, 230),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            // 얇은 로딩 인디케이터
            SizedBox(
              height: 4,
              child: _isLoading
                  ? const LinearProgressIndicator()
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: _results.isEmpty
                  ? const Center(
                      child: Text(
                        '검색어를 입력해보세요',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final cocktail = _results[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 0.1,
                          ),
                          leading: Icon(
                            _glassIcon(cocktail.glassType),
                            color: Colors.blueGrey,
                          ),
                          title: Text(
                            cocktail.nameKo,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            cocktail.name,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(255, 85, 84, 84),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                          // ← 탭 시 상세 페이지로 이동
                          onTap: () => _navigateToDetail(cocktail),
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