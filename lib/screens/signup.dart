// lib/screens/signup.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/app_text_styles.dart';
import '../services/auth_service.dart';

// 클라이언트 사이드 유효성 검사 패턴
// username: 4~20자, 첫 글자 영문 소문자, 이후 영문 소문자/숫자/언더스코어
final _usernameRegex = RegExp(r'^[a-z][a-z0-9_]{3,19}$');
// nickname: 2~12자, 한글/영문/숫자만
final _nicknameRegex = RegExp(r'^[가-힣a-zA-Z0-9]{2,12}$');

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nicknameController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  String? _validate() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final passwordConfirm = _passwordConfirmController.text;
    final nickname = _nicknameController.text.trim();

    if (username.isEmpty || password.isEmpty || passwordConfirm.isEmpty || nickname.isEmpty) {
      return '모든 항목을 입력해주세요.';
    }
    if (!_usernameRegex.hasMatch(username)) {
      return '아이디: 4~20자, 첫 글자는 영문 소문자,\n이후 영문 소문자/숫자/언더스코어(_)만 사용 가능합니다.';
    }
    if (password.length < 8 || password.length > 32) {
      return '비밀번호는 8~32자여야 합니다.';
    }
    if (password != passwordConfirm) {
      return '비밀번호가 일치하지 않습니다.';
    }
    if (!_nicknameRegex.hasMatch(nickname)) {
      return '닉네임: 2~12자, 한글/영문/숫자만 사용 가능합니다.';
    }
    return null;
  }

  Future<void> _signup() async {
    final validationError = _validate();
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await AuthService.signup(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      nickname: _nicknameController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      return;
    }

    // 회원가입 성공 → 로그인 화면으로 돌아가기
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인해주세요.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('회원가입', style: AppTextStyles.appBarTitle),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // 아이디
              _buildLabel('아이디'),
              const SizedBox(height: 6),
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                decoration: _inputDecoration('영문 소문자로 시작, 4~20자'),
              ),
              const SizedBox(height: 4),
              const Text(
                '영문 소문자/숫자/언더스코어(_) 사용 가능',
                style: TextStyle(fontSize: 12, color: AppColors.subtitleText),
              ),

              const SizedBox(height: 16),

              // 비밀번호
              _buildLabel('비밀번호'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('8~32자').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.subtitleText,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 비밀번호 확인
              _buildLabel('비밀번호 확인'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordConfirmController,
                obscureText: _obscurePasswordConfirm,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('비밀번호 재입력').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePasswordConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.subtitleText,
                      size: 20,
                    ),
                    onPressed: () => setState(
                        () => _obscurePasswordConfirm = !_obscurePasswordConfirm),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 닉네임
              _buildLabel('닉네임'),
              const SizedBox(height: 6),
              TextField(
                controller: _nicknameController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _signup(),
                decoration: _inputDecoration('2~12자, 한글/영문/숫자'),
              ),

              // 에러 메시지
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 13, color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),

              // 회원가입 버튼
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // 로그인으로 돌아가기
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '이미 계정이 있으신가요?',
                    style: AppTextStyles.caption,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.hintText, fontSize: 14),
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
