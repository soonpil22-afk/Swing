// 앱 전역 디자인 토큰(색·그림자) — 모든 페이지가 공유하는 단일 출처
import 'package:flutter/material.dart';

// ═══ 색 팔레트 ═══
const kAppBg      = Color(0xFF090E1A); // 전체 배경
const kPanel      = Color(0xFF070C18); // 메인 배경(패널)
const kSurface    = Color(0xFF0D1427); // 카드·입력칸 배경
const kElevated   = Color(0xFF303854); // 트랙·테두리
const kChip       = Color(0xFF18203A); // 칩·인풋·버튼 배경
const kText       = Color(0xFFFBFBFB);
const kText2      = Color(0xFF787C8D);
const kText3      = Color(0xFF515D6D);
const kTeal       = Color(0xFF4AE3ED); // 민트(메인 액센트)
const kPurple     = Color(0xFF9F66E6); // 보라
const kPink       = Color(0xFFE672BA); // 핑크
const kAmber      = Color(0xFFE6C97F); // 노랑
const kRed        = Color(0xFFE05252);
const kBorderDim  = Color(0x33303854); // 보조 테두리(옅은)
const kCardBorder = Color(0x4D303854);

// ═══ 그림자 ═══
const List<BoxShadow> kCardShadow = [
  BoxShadow(color: Color(0xD9000000), blurRadius: 11, offset: Offset(4, 6)),
];
const List<BoxShadow> kPanelShadow = [
  BoxShadow(color: Color(0xFF18203A), blurRadius: 11, offset: Offset(4, 6)),
];
