// 앱에서 공통으로 사용되는 색을 여기서 정의합니다!

import 'package:flutter/material.dart';

class AppColors {
  static const primary       = Color.fromARGB(255, 255, 149, 11); // 메인 컬러
  static const hintText      = Color(0xFF777777); // 칵테일을 검색해보세요
  static const inputFill     = Color.fromARGB(255, 240, 240, 240); // 검색창/스켈레톤 배경
  static const subtitleText  = Color.fromARGB(255, 145, 145, 145); // 부제목 색상
  static const emptyText     = Colors.grey; // 검색어를 입력해보세요

  // 하단 내비게이션 바
  static const tabSelected   = Colors.black87; // 선택된 탭 아이콘/라벨
  static const tabUnselected = Color.fromARGB(255, 197, 197, 197); // 비선택 탭
  static const navBorder     = Color(0xFFE0E0E0); // 내비게이션 바 상단 구분선
}
