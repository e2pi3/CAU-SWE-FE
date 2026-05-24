import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('마이페이지', style: AppTextStyles.placeholder),
    );
  }
}
