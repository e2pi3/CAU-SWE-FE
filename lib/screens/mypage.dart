import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import 'login.dart';
import 'settings.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool _loading = true;
  bool _isLoggedIn = false;
  String? _nickname;
  String? _username;
  String? _timeMent;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;
    if (!loggedIn) {
      setState(() {
        _loading = false;
        _isLoggedIn = false;
        _nickname = null;
        _username = null;
      });
      return;
    }
    final results = await Future.wait([
      AuthService.getMe(),
      AuthService.getTimeMent(),
    ]);
    if (!mounted) return;
    final me = results[0] as Map<String, dynamic>?;
    final ment = results[1] as String?;
    setState(() {
      _loading = false;
      _isLoggedIn = me != null;
      _nickname = me?['nickname'] as String?;
      _username = me?['username'] as String?;
      _timeMent = ment;
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 상단 프로필 영역 ──────────────────────────────────
        if (_loading)
          const SizedBox(height: 126) // 로드 전 레이아웃 자리 확보
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
                if (_timeMent != null) ...[
                  Text(
                    _timeMent!,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _nickname ?? '',
                        style: const TextStyle(
                          fontSize: 26,
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
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'id : ${_username ?? ''}',
                      style: const TextStyle(
                        fontSize: 18,
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
          // 설정(톱니바퀴) 버튼
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
                    fontSize: 26,
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
              fontSize: 20,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
