import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../services/auth_service.dart';
import 'login.dart';
import 'settings.dart';

class MyPageScreen extends StatefulWidget {
  final ValueNotifier<int> tabNotifier;

  const MyPageScreen({super.key, required this.tabNotifier});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool _loginChecked = false; // 로컬 토큰 확인 완료 여부
  bool _isLoggedIn = false;
  bool _profileLoaded = false; // getMe() 완료 여부
  bool _mentLoaded = false;    // getTimeMent() 완료 여부
  String? _nickname;
  String? _username;
  String? _timeMent;
  int _loadGeneration = 0; // 탭 재진입 시 이전 요청 결과 무시용

  // MyPage 탭 인덱스 (home.dart의 _bodies 기준)
  static const _myPageTabIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    widget.tabNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    widget.tabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (widget.tabNotifier.value == _myPageTabIndex) {
      _loadUserInfo();
    }
  }

  Future<void> _loadUserInfo() async {
    final generation = ++_loadGeneration;

    // 상태 초기화
    setState(() {
      _loginChecked = false;
      _isLoggedIn = false;
      _profileLoaded = false;
      _mentLoaded = false;
      _nickname = null;
      _username = null;
      _timeMent = null;
    });

    // 1단계: 로컬 토큰 확인 (SharedPreferences - 빠름)
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted || generation != _loadGeneration) return;
    setState(() {
      _loginChecked = true;
      _isLoggedIn = loggedIn;
    });

    if (!loggedIn) return;

    // 2단계: API 호출 병렬 수행 (각각 완료되는 대로 즉시 표시)
    AuthService.getMe().then((me) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _profileLoaded = true;
        _nickname = me?['nickname'] as String?;
        _username = me?['username'] as String?;
        if (me == null) _isLoggedIn = false; // 토큰 만료
      });
    });

    AuthService.getTimeMent().then((ment) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _mentLoaded = true;
        _timeMent = ment;
      });
    });
  }

  void _goToLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const LoginScreen()))
        .then((_) => _loadUserInfo());
  }

  void _goToSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const SettingsScreen()))
        .then((_) => _loadUserInfo());
  }

  // 스켈레톤 바
  Widget _skeletonBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 상단 프로필 영역 ──────────────────────────────────
        if (!_loginChecked)
          const SizedBox(height: 126) // 로컬 토큰 확인 중 레이아웃 자리 확보
        else if (_isLoggedIn)
          _buildLoggedInHeader()
        else
          _buildLoggedOutHeader(),

        const SizedBox(height: 20),
        const Divider(
          thickness: 6,
          color: Color(0xFFEEEEEE),
          height: 6,
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text('구현예정', style: AppTextStyles.placeholder),
        ),
      ],
    );
  }

  // 로그인된 경우: 닉네임 + 아이디 + 설정 버튼
  Widget _buildLoggedInHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 멘트 + 닉네임 + 아이디
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 인사 멘트 (API 완료 전엔 스켈레톤)
                if (!_mentLoaded)
                  _skeletonBar(width: 120, height: 20)
                else if (_timeMent != null)
                  Text(
                    _timeMent!,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                const SizedBox(height: 6),
                // 닉네임 (API 완료 전엔 스켈레톤)
                if (!_profileLoaded)
                  _skeletonBar(width: 160, height: 28)
                else
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _nickname ?? '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const Text(
                        ' 님',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                // 아이디 (API 완료 전엔 스켈레톤)
                if (!_profileLoaded)
                  _skeletonBar(width: 100, height: 18)
                else
                  Row(
                    children: [
                      Text(
                        'id : ${_username ?? ''}',
                        style: const TextStyle(
                          fontSize: 17,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: _username ?? ''));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('아이디가 복사되었습니다.'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: const Icon(Icons.content_copy, size: 16, color: Colors.black45),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // 설정(톱니바퀴) 버튼 - API 관계없이 즉시 표시
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 26),
            color: Colors.black54,
            onPressed: _goToSettings,
          ),
        ],
      ),
    );
  }

  // 비로그인 경우: 로그인/회원가입 + 앱 소개
  Widget _buildLoggedOutHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 로그인/회원가입 버튼
        GestureDetector(
          onTap: _goToLogin,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(24, 36, 24, 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '로그인/회원가입',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // 앱 소개 문구
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '내 손안의 칵테일\nCocktailer',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
