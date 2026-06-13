// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home.dart';
import 'theme/colors.dart';

// 뒤로가기 등으로 HomeScreen이 다시 활성화될 때를 감지하기 위한 전역 옵저버
final routeObserver = RouteObserver<PageRoute<dynamic>>();

// 웹에서 마우스 드래그로 스크롤 가능하도록 허용
class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch,
    PointerDeviceKind.trackpad,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Cocktailer());
}

class Cocktailer extends StatelessWidget {
  const Cocktailer({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '칵테일러',

      scrollBehavior: _AppScrollBehavior(),

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

      navigatorObservers: [routeObserver],

      // 앱 시작 시 홈으로 진입, 로그인 여부는 HomeScreen에서 확인
      home: const HomeScreen(),
    );
  }
}
