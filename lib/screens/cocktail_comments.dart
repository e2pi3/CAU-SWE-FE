// lib/screens/cocktail_comments.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_config.dart';
import '../services/auth_service.dart';
import '../widgets/app_dialog.dart';
import '../widgets/login_dialog.dart';
import '../models/cocktail_comment.dart';
import 'cocktail_comment_write.dart';

class CocktailCommentsScreen extends StatefulWidget {
  final String cocktailId;
  final String cocktailName;
  final String cocktailNameKo;
  final String cocktailImageUrl;

  const CocktailCommentsScreen({
    super.key,
    required this.cocktailId,
    required this.cocktailName,
    required this.cocktailNameKo,
    required this.cocktailImageUrl,
  });

  @override
  State<CocktailCommentsScreen> createState() => _CocktailCommentsScreenState();
}

class _CocktailCommentsScreenState extends State<CocktailCommentsScreen> {
  final List<CocktailComment> _comments = [];
  int _totalCount = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  static const int _limit = 5;
  bool _isLoggedIn = false;
  bool _hasMineComment = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (mounted) setState(() => _isLoggedIn = loggedIn);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 80) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    try {
      final token = await AuthService.getAccessToken();
      final uri = Uri.parse(
        '${AppConfig.baseUrl}/cocktails/comments?id=${widget.cocktailId}&limit=$_limit&offset=$_offset',
      );
      final headers = <String, String>{};
      if (token != null) headers['Authorization'] = 'Bearer $token';
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newItems = (data['comments'] as List)
            .map((e) => CocktailComment.fromJson(e as Map<String, dynamic>))
            .toList();
        setState(() {
          _totalCount = data['count'] as int;
          _comments.addAll(newItems);
          _offset += newItems.length;
          _hasMore = _comments.length < _totalCount;
          _isLoading = false;
          if (!_hasMineComment) {
            _hasMineComment = newItems.any((c) => c.isMine);
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _comments.clear();
      _offset = 0;
      _hasMore = true;
      _hasMineComment = false;
    });
    await _loadMore();
  }

  Future<void> _deleteComment() async {
    final token = await AuthService.getAccessToken();
    try {
      final uri = Uri.parse(
        '${AppConfig.baseUrl}/cocktails/comments?id=${widget.cocktailId}',
      );
      final response = await http.delete(
        uri,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && mounted) {
        await _checkLoginStatus();
        await _refresh();
      }
    } catch (_) {}
  }

  void _showAlreadyCommentedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AppDialog(
        content: const Text(
          '이미 작성한 한줄평이 있습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          AppDialogAction(
            label: '확인',
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AppDialog(
        content: const Text(
          '댓글을 삭제할까요?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          AppDialogAction(
            label: '취소',
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          AppDialogAction(
            label: '삭제',
            color: Colors.red,
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteComment();
            },
          ),
        ],
      ),
    );
  }

  void _openWriteScreen({String? initialContent}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => CocktailCommentWriteScreen(
              cocktailId: widget.cocktailId,
              cocktailName: widget.cocktailName,
              cocktailNameKo: widget.cocktailNameKo,
              cocktailImageUrl: widget.cocktailImageUrl,
              initialContent: initialContent,
            ),
          ),
        )
        .then((_) async {
          await _checkLoginStatus();
          await _refresh();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        automaticallyImplyLeading: false,
        title: const Text('한줄평'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _comments.isEmpty && !_isLoading
              ? Center(
                  child: Text('아직 한줄평이 없습니다.', style: AppTextStyles.caption),
                )
              : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: _comments.length + (_isLoading ? 1 : 0),
                  separatorBuilder: (_, i) => const Divider(height: 24),
                  itemBuilder: (ctx, i) {
                    if (i == _comments.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    return _buildCommentItem(_comments[i]);
                  },
                ),

          // 하단 "한줄평 작성" 캡슐 버튼
          Positioned(
            bottom: 24 + MediaQuery.of(context).padding.bottom,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if (!_isLoggedIn) {
                    await showLoginRequiredDialog(
                      context,
                      onLoginSuccess: () async {
                        await _checkLoginStatus();
                        await _refresh(); // 로그인 후 isMine 반영을 위해 댓글 재조회
                      },
                    );
                    return;
                  }
                  if (_hasMineComment) {
                    _showAlreadyCommentedDialog();
                    return;
                  }
                  _openWriteScreen();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    '한줄평 작성',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CocktailComment c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: c.nickname,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: ' (${c.username})',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
              if (c.isMine)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _openWriteScreen(initialContent: c.content),
                      child: const Text(
                        '수정',
                        style: TextStyle(fontSize: 13, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _showDeleteDialog,
                      child: const Text(
                        '삭제',
                        style: TextStyle(fontSize: 13, color: Colors.red),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(c.content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
