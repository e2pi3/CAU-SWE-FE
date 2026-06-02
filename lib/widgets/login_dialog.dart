// 로그인이 필요한 기능에서 공통으로 사용하는 로그인 안내 팝업
// onLoginSuccess: 로그인 후 실행할 콜백 (null이면 단순 이동만)

import 'package:flutter/material.dart';
import 'app_dialog.dart';
import '../screens/login.dart';
import '../theme/colors.dart';

Future<void> showLoginRequiredDialog(
  BuildContext context, {
  Future<void> Function()? onLoginSuccess,
}) async {
  await showDialog(
    context: context,
    builder: (ctx) => AppDialog(
      content: const Text(
        '로그인이 필요합니다.\n로그인 페이지로 이동할까요?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17,
          color: Color.fromARGB(255, 58, 58, 58),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        AppDialogAction(
          label: '닫기',
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        AppDialogAction(
          label: '로그인하기',
          color: AppColors.primary,
          onPressed: () async {
            Navigator.of(ctx).pop();
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
            if (context.mounted && onLoginSuccess != null) {
              await onLoginSuccess();
            }
          },
        ),
      ],
    ),
  );
}
