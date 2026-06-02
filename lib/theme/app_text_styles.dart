// 앱에서 공통으로 사용되는 텍스트 스타일을 여기서 정의합니다!

import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // 제목
  static const appBarTitle  = TextStyle(fontSize: 20, fontWeight: FontWeight.bold); // 홈 상단 AppBar 탭 제목 (Cocktailer, 카테고리 등)
  static const sectionTitle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold); // 섹션 헤더 · 상세 화면 AppBar 제목 (재료, 제조법, 설명 등)
  static const cocktailName = TextStyle(fontSize: 28, fontWeight: FontWeight.bold); // 칵테일 상세 화면 한글 이름

  // 본문
  static const bodyText  = TextStyle(fontSize: 15, height: 1.7); // 레시피·설명 등 줄간격이 필요한 긴 텍스트
  static const listTitle = TextStyle(fontWeight: FontWeight.bold); // 검색 결과 ListTile 항목 이름

  // 보조 텍스트
  static const subtitle    = TextStyle(fontSize: 13, color: AppColors.subtitleText); // 검색 결과 카테고리 줄
  static const caption        = TextStyle(fontSize: 14, color: AppColors.subtitleText); // 재료 용량 · 미구현 placeholder 컨테이너
  static const cocktailNameEn = TextStyle(fontSize: 18, color: AppColors.subtitleText); // 칵테일 상세 화면 영문명
  static const placeholder = TextStyle(color: AppColors.emptyText);                  // 빈 화면 안내 문구 (미구현 탭 포함)

  // 뱃지
  static const abvBadge = TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600); // ABV % 뱃지 텍스트
}
