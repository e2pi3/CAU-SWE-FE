// 앱 전반에서 사용하는 공통 다이얼로그 위젯
// 흰색 배경, 구분선 버튼, 검정 버튼 텍스트 디자인

import 'package:flutter/material.dart';

/// 다이얼로그 하단 버튼 정의
class AppDialogAction {
  final String label;
  final VoidCallback onPressed;

  const AppDialogAction({required this.label, required this.onPressed});
}

/// iOS 스타일 공통 다이얼로그
/// - 흰색 배경, 구분선으로 버튼 구분
class AppDialog extends StatelessWidget {
  final String? title;
  final Widget? content;
  final List<AppDialogAction> actions;

  const AppDialog({
    super.key,
    this.title,
    this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (content != null) ...[
                  if (title != null) const SizedBox(height: 12),
                  content!,
                ],
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
          IntrinsicHeight(
            child: Row(
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  if (i > 0)
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Color(0xFFE0E0E0),
                    ),
                  Expanded(
                    child: TextButton(
                      onPressed: actions[i].onPressed,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: i == 0
                                ? const Radius.circular(14)
                                : Radius.zero,
                            bottomRight: i == actions.length - 1
                                ? const Radius.circular(14)
                                : Radius.zero,
                          ),
                        ),
                      ),
                      child: Text(
                        actions[i].label,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
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
}
