// lib/screens/home.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'search.dart';
import 'category.dart';
import 'favorites.dart';
import 'mypage.dart';
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  }

  static const _tabs = [
    (icon: Icons.home_outlined, label: '홈'),
    (icon: Icons.list_alt, label: '카테고리'),
    (icon: Icons.favorite_outline, label: '즐겨찾기'),
    (icon: Icons.person_outline, label: '마이페이지'),
  ];

  static const _bodies = [
    Center(child: Text('홈 화면', style: AppTextStyles.placeholder)),
    CategoryScreen(),
    FavoritesScreen(),
    MyPageScreen(),
  ];

  static const _titles = ['Cocktailer', '카테고리', '즐겨찾기', '마이페이지'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex], style: AppTextStyles.appBarTitle),
      ),
      body: _bodies[_selectedIndex],
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _bottomBar() {
    final mq = MediaQuery.of(context);
    final screenHeight = mq.size.height;
    final bottomInset = mq.padding.bottom;
    final barHeight = (screenHeight * 0.070).clamp(56.0, 80.0);
    final fabSize = barHeight;
    final protrude = fabSize / 4;
    final iconSize = barHeight * 0.4;
    final fontSize = barHeight * 0.18;
    final searchIconSize = fabSize * 0.45;

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
