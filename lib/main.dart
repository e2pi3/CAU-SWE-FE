// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'theme/colors.dart';
import 'services/auth_service.dart';

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

      home: const SplashRouter(),
    );
  }
}

// 앱 시작 시 토큰 유무 확인 후 홈 또는 로그인 화면으로 분기
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (loggedIn) {
      // 로그인 상태 → 홈으로
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // 비로그인 → 로그인 화면 (X 버튼으로 홈으로 이동 가능)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(canClose: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 라우팅 결정 전 잠깐 보이는 스플래시
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Cocktailer',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
