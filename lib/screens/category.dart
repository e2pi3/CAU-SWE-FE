import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('카테고리', style: AppTextStyles.placeholder),
    );
  }
}
