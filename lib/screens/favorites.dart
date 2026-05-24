import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('즐겨찾기', style: AppTextStyles.placeholder),
    );
  }
}
