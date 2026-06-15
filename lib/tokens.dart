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
const kBlue       = Color(0xFF5B8DEF); // 미니게임 블록용
const kGreen      = Color(0xFF5BD08B); // 미니게임 블록용

// ═══ 시맨틱(역할) 토큰 — 원시색에 "역할" 이름을 부여 ═══
const kBorderActive = kTeal; // 강조/활성 테두리 (안읽음·출금요청·납부 박스 등)

// 랭킹 메달 — 1·2·3등 금·은·동 (출금랭킹·미니게임랭킹 공용)
const kRankGold   = Color.fromARGB(255, 241, 201, 97);  // 1등 금
const kRankSilver = Color.fromARGB(255, 200, 207, 216); // 2등 은
const kRankBronze = Color.fromARGB(255, 177, 118, 79);  // 3등 동

// ═══ 갭(여백) — 안쪽 8 / 카드사이 8 / 큰구역 10 ═══
const double kGapInner   = 8;  // 카드 속 헤더↔경계선, 경계선↔내용
const double kGapCard    = 8;  // 카드 ↔ 카드 사이
const double kGapSection = 10; // 헤더↔카드/경계선, 경계선↔탭/카드

// ═══ 그림자 ═══
const List<BoxShadow> kCardShadow = [
  BoxShadow(color: Color(0xD9000000), blurRadius: 11, offset: Offset(4, 6)),
];
const List<BoxShadow> kPanelShadow = [
  BoxShadow(color: Color(0xFF18203A), blurRadius: 11, offset: Offset(4, 6)),
];
