// lib/screens/cocktail_comment_write.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_config.dart';
import '../services/auth_service.dart';

class CocktailCommentWriteScreen extends StatefulWidget {
  final String cocktailId;
  final String cocktailName;
  final String cocktailNameKo;
  final String cocktailImageUrl;
  final String? initialContent; // null이면 신규 작성, 값이 있으면 수정 모드

  const CocktailCommentWriteScreen({
    super.key,
    required this.cocktailId,
    required this.cocktailName,
    required this.cocktailNameKo,
    required this.cocktailImageUrl,
    this.initialContent,
  });

  @override
  State<CocktailCommentWriteScreen> createState() =>
      _CocktailCommentWriteScreenState();
}

class _CocktailCommentWriteScreenState
    extends State<CocktailCommentWriteScreen> {
  late final TextEditingController _controller;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final token = await AuthService.getAccessToken();
    setState(() => _submitting = true);
    try {
      final uri = Uri.parse(
        '${AppConfig.baseUrl}/cocktails/comments?id=${widget.cocktailId}',
      );
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'comment': content}),
      );
      if (response.statusCode == 200 && mounted) {
        Navigator.of(context).pop();
      } else {
        setState(() => _submitting = false);
      }
    } catch (_) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        automaticallyImplyLeading: false,
        title: const Text('한줄평 작성'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 칵테일 정보
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.cocktailImageUrl.isNotEmpty
                            ? Image.network(
                                widget.cocktailImageUrl,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  width: 72,
                                  height: 72,
                                  color: AppColors.inputFill,
                                ),
                              )
                            : Container(
                                width: 72,
                                height: 72,
                                color: AppColors.inputFill,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.cocktailName,
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.cocktailNameKo,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    '한줄평을 남겨주세요!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),

                  // 댓글 입력창
                  TextField(
                    controller: _controller,
                    maxLength: 100,
                    maxLines: 5,
                    minLines: 3,
                    buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                    decoration: InputDecoration(
                      hintText: '이 칵테일에 대한 솔직한 한줄평을 남겨주세요.',
                      hintStyle: AppTextStyles.caption,
                      filled: true,
                      fillColor: AppColors.inputFill,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 글자 수 카운터
                  Align(
                    alignment: Alignment.centerRight,
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _controller,
                      builder: (_, value, _) => Text(
                        '${value.text.length}/100',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 등록하기 버튼
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '등록하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
}
