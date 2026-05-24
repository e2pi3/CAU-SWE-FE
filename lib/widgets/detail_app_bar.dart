// 뒤로가기 버튼이 있는 상세 화면용 공통 AppBar
// 사용처: SearchScreen, IngredientInfoScreen

import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // AppBar에 표시할 제목
  const DetailAppBar(this.title, {super.key});

  @override
  Widget build(BuildContext context) => AppBar(
        leading: const BackButton(),
        title: Text(title, style: AppTextStyles.sectionTitle),
        centerTitle: true,
      );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
