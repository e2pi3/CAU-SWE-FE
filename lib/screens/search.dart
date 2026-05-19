// lib/screens/search.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Cocktail {
  final String name;
  final String nameKo;
  final String glassType;

  Cocktail({
    required this.name,
    required this.nameKo,
    required this.glassType,
  });

  factory Cocktail.fromJson(Map<String, dynamic> json) {
    return Cocktail(
      name: json['name'],
      nameKo: json['name_ko'],
      glassType: json['glass_type'],
    );
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
        _isLoading = false; // 빈 검색어면 로딩도 끄기
      });
      return;
    }

    setState(() => _isLoading = true); // 로딩 시작 (목록은 그대로 유지)

    try {
      final uri = Uri.parse('$_baseUrl/cocktails/search?q=$trimmed');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _results = data.map((e) => Cocktail.fromJson(e)).toList(); // 프론트 변경: API 완료되면 그때 목록 교체
        });
      } else {
        // 에러시 기존 목록 유지 (선택), 혹은 초기화하려면 _results = [] 로 변경
      }
    } catch (e) {
      // 네트워크 에러시도 기존 목록 유지
    } finally {
      setState(() => _isLoading = false); // 로딩 종료
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
        title: const Text('🍹 Cocktail Search'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: '칵테일 이름을 입력하세요',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    _onSearchChanged('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // 프론트 변경: CircularProgressIndicator 대신 얇은 LinearProgressIndicator
            // 로딩 중엔 진행바 표시, 아니면 투명한 SizedBox로 자리만 유지 (레이아웃 흔들림 방지)
            SizedBox(
              height: 4,
              child: _isLoading
                  ? const LinearProgressIndicator()
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 12),

            Expanded(
              // 프론트 변경: _isLoading 여부와 관계없이 항상 목록을 보여줌
              child: _results.isEmpty
                  ? const Center(
                      child: Text('검색어를 입력해보세요',
                          style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final cocktail = _results[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.local_bar,
                                color: Colors.deepPurple),
                            title: Text(cocktail.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cocktail.nameKo),
                                Text(cocktail.glassType,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
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