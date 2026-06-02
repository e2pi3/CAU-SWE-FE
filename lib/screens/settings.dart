import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../services/auth_service.dart';
import '../widgets/app_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AppDialog(
        title: '로그아웃 할까요?',
        actions: [
          AppDialogAction(
            label: '닫기',
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppDialogAction(
            label: '로그아웃',
            color: Colors.redAccent,
            onPressed: () async {
              Navigator.of(context).pop();
              await AuthService.logout();
              if (!context.mounted) return;
              // 설정 화면 닫기 (마이페이지로 복귀 → 마이페이지가 상태 갱신)
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('설정', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
