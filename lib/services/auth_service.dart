// lib/services/auth_service.dart
// 인증 관련 API 호출 및 토큰 로컬 저장/조회/삭제 담당

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_config.dart';

// 에러 응답 파싱 (detail이 String 또는 List 두 가지 형태)
String parseErrorDetail(dynamic body) {
  try {
    final decoded = jsonDecode(body is String ? body : utf8.decode(body));
    final detail = decoded['detail'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail[0];
      final msg = first['msg'] ?? '';
      return msg.toString().replaceFirst('Value error, ', '');
    }
  } catch (_) {}
  return '알 수 없는 오류가 발생했습니다.';
}

class AuthService {
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';

  // ── 토큰 저장 ──────────────────────────────────────────────
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }

  // ── 회원가입 ──────────────────────────────────────────────
  // 성공 시 null 반환, 실패 시 에러 메시지 반환
  static Future<String?> signup({
    required String username,
    required String password,
    required String nickname,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'nickname': nickname,
        }),
      );
      if (response.statusCode == 200) return null;
      return parseErrorDetail(response.body);
    } catch (_) {
      return '네트워크 연결을 확인해주세요.';
    }
  }

  // ── 로그인 ──────────────────────────────────────────────
  // 성공 시 null 반환 (토큰 자동 저장), 실패 시 에러 메시지 반환
  static Future<String?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        return null;
      }
      return parseErrorDetail(response.body);
    } catch (_) {
      return '네트워크 연결을 확인해주세요.';
    }
  }

  // ── 액세스 토큰 재발급 ──────────────────────────────────────
  // 성공 시 null 반환 (토큰 자동 갱신), 실패 시 에러 메시지 반환
  static Future<String?> refreshTokens() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return '로그인이 필요합니다.';
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        return null;
      }
      await clearTokens();
      return parseErrorDetail(response.body);
    } catch (_) {
      return '네트워크 연결을 확인해주세요.';
    }
  }

  // ── 로그아웃 ──────────────────────────────────────────────
  static Future<void> logout() async {
    final refreshToken = await getRefreshToken();
    try {
      await http.post(
        Uri.parse('${AppConfig.baseUrl}/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken ?? ''}),
      );
    } catch (_) {
      // 서버 응답 실패해도 로컬 토큰은 반드시 삭제
    }
    await clearTokens();
  }

  // ── 내 정보 조회 ──────────────────────────────────────────
  // 성공 시 사용자 정보 Map 반환, 실패 시 null 반환
  static Future<Map<String, dynamic>?> getMe() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/me'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      // 401이면 refresh 시도
      if (response.statusCode == 401) {
        final err = await refreshTokens();
        if (err != null) return null;
        return getMe(); // 재시도
      }
    } catch (_) {}
    return null;
  }
}
