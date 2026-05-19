// lib/screens/search.dart
// 칵테일 검색하면 나오는 조회 목록에 대한 코드
// 변수 앞에 _가 붙는건 dart언어에서 private 변수선언 같은거라네요



import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class Cocktail {        // 칵테일 목록만 조회하기위해 이름과 잔 종류만 가져옴
  final String name;
  final String nameKo;
  final String glassType;

  Cocktail({
    required this.name,
    required this.nameKo,
    required this.glassType,
  });

  // json 응답 구조 관련
  factory Cocktail.fromJson(Map<String, dynamic> json) {
    return Cocktail(
      name: json['name'],
      nameKo: json['name_ko'],
      glassType: json['glass_type'],
    );
  }
}

// 검색창 선언한거고 Stateful은 상태가 변화하는 창으로 선언했다는 뜻
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

// 여기가 검색창이 될 메인 클래스
class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Cocktail> _results = [];
  bool _isLoading = false;

  static const String _baseUrl = 'http://cau-swe-be-server.up.railway.app';

  Future<void> _search(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse('$_baseUrl/cocktails/search?q=$trimmed'); // 검색 API 호출
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _results = data.map((e) => Cocktail.fromJson(e)).toList();
        });
      } else {
        // TODO: 에러 처리 고도화 필요
        setState(() => _results = []);
      }
    } catch (e) {
      // TODO: 네트워크 에러 UI 처리 필요
      setState(() => _results = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {   // 화면 UI 담당 함수
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
              onChanged: _search,
              decoration: InputDecoration(
                hintText: '칵테일 이름을 입력하세요',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    _search('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
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
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cocktail.nameKo),
                                    Text(cocktail.glassType,
                                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
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