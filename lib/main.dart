// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'theme/colors.dart';

void main() {
  runApp(const Cocktailer());
}

class Cocktailer extends StatelessWidget {
  const Cocktailer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cocktailer',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),

      // 앱 시작 시 홈으로 진입, 로그인 여부는 HomeScreen에서 확인
      home: const HomeScreen(),
    );
  }
}
