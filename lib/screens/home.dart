// lib/screens/home.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'search.dart';
import 'category.dart';
import 'favorites.dart';
import 'mypage.dart';
import 'home_tab.dart';
import 'login.dart';
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../services/auth_service.dart';
import '../main.dart' show routeObserver;
import '../utils/navigation_state.dart' show consumeGoHomeRequest;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  int _selectedIndex = 0;
  final _tabNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    _checkLogin();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    // 위에 쌓인 라우트가 팝되어 HomeScreen이 다시 활성화될 때
    if (consumeGoHomeRequest()) {
      // 홈 버튼으로 복귀 시 홈 탭(index 0)으로 이동
      setState(() => _selectedIndex = 0);
      _tabNotifier.value = 0;
    } else {
      // ValueNotifier는 동일값 재할당 시 발동 안 하므로 -1을 거쳐 재발화
      _tabNotifier.value = -1;
      _tabNotifier.value = _selectedIndex;
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tabNotifier.dispose();
    super.dispose();
  }

  Future<void> _checkLogin() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;
    if (!loggedIn) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  static const _tabs = [
    (icon: Icons.home_outlined, label: '홈'),
    (icon: Icons.list_alt, label: '카테고리'),
    (icon: Icons.favorite_outline, label: '즐겨찾기'),
    (icon: Icons.person_outline, label: '마이페이지'),
  ];

  late final _bodies = [
    HomeTabScreen(tabNotifier: _tabNotifier),
    const CategoryScreen(),
    const FavoritesScreen(),
    MyPageScreen(tabNotifier: _tabNotifier),
  ];

  static const _titles = ['홈', '카테고리', '즐겨찾기', '마이페이지'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex], style: AppTextStyles.appBarTitle),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _bodies,
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _bottomBar() {
    final mq = MediaQuery.of(context);
    final screenHeight = mq.size.height;
    final bottomInset = mq.padding.bottom;
    final barHeight = (screenHeight * 0.070).clamp(56.0, 80.0); // 하단바 높이
    final fabSize = barHeight+8; // 돋보기 버튼사이즈
    final searchIconSize = fabSize * 0.45; // 돋보기 아이콘 크기
    final protrude = fabSize / 4; // 위로 튀어나온 정도
    final iconSize = barHeight * 0.4; // 하단바 아이콘 크기
    final fontSize = barHeight * 0.18; // 하단바 글자 크기

    return SizedBox(
      height: barHeight + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.only(bottom: bottomInset),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.navBorder, width: 1),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _tabItem(0, iconSize: iconSize, fontSize: fontSize),
                    _tabItem(1, iconSize: iconSize, fontSize: fontSize),
                    SizedBox(width: fabSize),
                    _tabItem(2, iconSize: iconSize, fontSize: fontSize),
                    _tabItem(3, iconSize: iconSize, fontSize: fontSize),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -protrude,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                color: AppColors.primary,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                shadowColor: Colors.black26,
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  splashFactory: InkRipple.splashFactory,
                  splashColor: Colors.white.withValues(alpha: 0.25),
                  highlightColor: Colors.transparent,
                  child: SizedBox(
                    width: fabSize,
                    height: fabSize,
                    child: Icon(Icons.search, color: Colors.white, size: searchIconSize),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem(int index, {required double iconSize, required double fontSize}) {
    final selected = _selectedIndex == index;
    final color = selected ? AppColors.tabSelected : AppColors.tabUnselected;
    final tab = _tabs[index];

    return Expanded(
      child: InkResponse(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedIndex = index);
          _tabNotifier.value = index;
        },
        radius: iconSize + fontSize + 8,
        highlightShape: BoxShape.circle,
        splashFactory: InkRipple.splashFactory,
        splashColor: Colors.black.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tab.icon, color: color, size: iconSize),
              SizedBox(height: fontSize * 0.3),
              Text(
                tab.label,
                style: TextStyle(
                  color: color,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
