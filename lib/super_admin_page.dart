// 슈퍼관리자(운영자) 페이지 - 앱 전체 사용 on/off 등 운영 제어 화면
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'glass_shine_button.dart';
import 'tokens.dart';

// ═══════════════════════════════════════════════════════════════════════
// 공통 색 팔레트 (tokens.dart 단일 출처를 가리키는 별칭)
// ═══════════════════════════════════════════════════════════════════════
const _appBg    = kAppBg;    // 전체 배경
const _panel    = kPanel;    // 메인 배경 (inset 패널)
const _surface  = kSurface;  // 카드
const _elevated = kElevated; // 트랙 · 테두리
const _text  = kText;
const _text3 = kText3;
const _teal     = kTeal;     // 민트 (메인 액센트)
const _pink     = kPink;     // 핑크
const _purple   = kPurple;   // 보라
const _amber    = kAmber;    // 노랑

const List<BoxShadow> _cardShadow = kCardShadow;

// ═══════════════════════════════════════════════════════════════════════
// 1. 전체배경
// ═══════════════════════════════════════════════════════════════════════
const Color _bgScaffold = _appBg;   // 모든 화면 Scaffold 배경색

// ═══════════════════════════════════════════════════════════════════════
// 2. 메인배경 (안쪽 패널)
// ═══════════════════════════════════════════════════════════════════════
const Color  _panelColor       = _panel;     // 패널 배경색
const Color  _panelBorderColor = _elevated;  // 테두리 색
const double _panelBorderAlpha = 1.0;        // 테두리 투명도(0~1, 1.0=솔리드)
const double _panelOuterPad    = 10;  // 패널 바깥 여백
const double _panelRadius      = 24;  // 패널 모서리 둥글기
const double _panelBorderWidth = 1;   // 테두리 두께
const double _panelPadL = 12;  // 안쪽 여백 왼쪽
const double _panelPadT = 8;   // 안쪽 여백 위
const double _panelPadR = 12;  // 안쪽 여백 오른쪽
const double _panelPadB = 8;   // 안쪽 여백 아래
const List<BoxShadow> _panelShadow = kPanelShadow;

// ═══════════════════════════════════════════════════════════════════════
// 3. 안녕하세요 (인사)
// ═══════════════════════════════════════════════════════════════════════
const Color _greetIconOuterColor  = _teal;    // 바깥 원 색
const Color _greetIconInnerColor  = _pink;  // 안쪽 원 색
const Color _greetHelloColor      = _text;    // "안녕하세요," 글씨 색
const Color _greetNameColor       = _amber;   // 이름 글씨 색
const Color _greetSuffixColor     = _text;    // " 님" 글씨 색
const Color _greetLogoutIconColor = _pink;  // 로그아웃 아이콘 색
const double _greetHelloFontSize  = 18;  // "안녕하세요," 크기
const double _greetNameFontSize   = 18;  // 이름 크기
const double _greetSuffixFontSize = 18;  // " 님" 크기
const double _greetVPad           = 1;   // 인사줄 위아래 여백
const double _greetIconOuterSize  = 22;  // 바깥 원 지름
const double _greetIconInnerSize  = 12;  // 안쪽 원 지름
const double _greetIconGap        = 12;  // 원과 글씨 사이 간격
const double _greetLogoutBoxSize  = 38;  // 로그아웃 버튼 크기
const double _greetLogoutRadius   = 10;  // 로그아웃 버튼 모서리
const double _greetLogoutIconSize = 19;  // 로그아웃 아이콘 크기
const String _greetHelloText      = '안녕하세요!! ';
const String _greetSuffixText     = ' 님.';
const String _greetName           = '운영자';   // 이름 자리(고정)

// ═══════════════════════════════════════════════════════════════════════
// 4. 어플 사용 ON/OFF 카드
// ═══════════════════════════════════════════════════════════════════════
const Color  _appCardBg          = _surface;     // 카드 배경색
const Color  _appCardBorder      = _elevated;  // 카드 테두리 색
const double _appCardRadius      = 14;  // 카드 모서리
const double _appCardBorderWidth = 1;   // 카드 테두리 두께
const double _appCardPad         = 16;  // 카드 안쪽 여백
const Color  _appOnColor         = _teal; // 켜짐(사용가능) 강조색
const Color  _appOffColor        = _purple;  // 꺼짐(사용금지) 강조색
const double _appIconSize        = 26;  // 상태 아이콘 크기
const Color  _appTitleColor      = _text; // 제목 글씨 색
const double _appTitleFontSize   = 15;  // 제목 글씨 크기
const double _appDescFontSize    = 12;  // 상태 안내 글씨 크기
const double _appHeadGap         = 12;  // 아이콘-제목 간격
const String _appTitleText       = '어플 사용 ON/OFF';
const String _appOnDescText      = '어플 사용 가능.';
const String _appOffDescText     = '어플 사용중지';

// ═══════════════════════════════════════════════════════════════════════
// SuperAdminPage – 메인
// ═══════════════════════════════════════════════════════════════════════
class SuperAdminPage extends StatefulWidget {
  const SuperAdminPage({super.key});
  @override
  State<SuperAdminPage> createState() => _SuperAdminPageState();
}

class _SuperAdminPageState extends State<SuperAdminPage> {
  // 앱 on/off 상태 문서 (기사페이지가 이 값을 읽어 점검화면 표시)
  final DocumentReference _appStatusRef =
      FirebaseFirestore.instance.collection('system_settings').doc('app_status');

  Future<void> _setAppOn(bool on) async {
    await _appStatusRef.set({'isAppOn': on}, SetOptions(merge: true));
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false);
  }

  // ── 1·2. 전체배경 + 메인배경 (로직) ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_panelOuterPad),
          child: Container(
            decoration: BoxDecoration(
              color: _panelColor,
              borderRadius: BorderRadius.circular(_panelRadius),
              border: Border.all(
                  color: _panelBorderColor.withValues(alpha: _panelBorderAlpha),
                  width: _panelBorderWidth),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_panelRadius),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    _panelPadL, _panelPadT, _panelPadR, _panelPadB),
                children: [
                  _greeting(),
                  const SizedBox(height: 20),
                  _appToggleCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── 3. 안녕하세요 (로직) ──
  Widget _greeting() => Padding(
        padding: const EdgeInsets.symmetric(vertical: _greetVPad),
        child: Row(children: [
          Container(
            width: _greetIconOuterSize,
            height: _greetIconOuterSize,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: _greetIconOuterColor),
            child: Center(
              child: Container(
                width: _greetIconInnerSize,
                height: _greetIconInnerSize,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: _greetIconInnerColor),
              ),
            ),
          ),
          const SizedBox(width: _greetIconGap),
          const Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: _greetHelloText,
                    style: TextStyle(
                        color: _greetHelloColor,
                        fontSize: _greetHelloFontSize,
                        fontWeight: FontWeight.w700)),
                TextSpan(
                    text: _greetName,
                    style: TextStyle(
                        color: _greetNameColor,
                        fontSize: _greetNameFontSize,
                        fontWeight: FontWeight.w700)),
                TextSpan(
                    text: _greetSuffixText,
                    style: TextStyle(
                        color: _greetSuffixColor,
                        fontSize: _greetSuffixFontSize,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
          GlassShineButton(
            onPressed: _handleLogout,
            icon: Icons.logout_rounded,
            accent: _greetLogoutIconColor,
            textColor: _greetLogoutIconColor,
            width: _greetLogoutBoxSize,
            height: _greetLogoutBoxSize,
            radius: _greetLogoutRadius,
            fontSize: _greetLogoutIconSize - 3,
          ),
        ]),
      );

  // ── 4. 어플 사용 ON/OFF 카드 (로직) ──
  Widget _appToggleCard() => StreamBuilder<DocumentSnapshot>(
        stream: _appStatusRef.snapshots(),
        builder: (_, snap) {
          final isOn =
              (snap.data?.data() as Map<String, dynamic>?)?['isAppOn'] as bool? ??
                  true;
          final accent = isOn ? _appOnColor : _appOffColor;
          return Container(
            padding: const EdgeInsets.all(_appCardPad),
            decoration: BoxDecoration(
              color: _appCardBg,
              borderRadius: BorderRadius.circular(_appCardRadius),
              border: Border.all(color: _appCardBorder, width: _appCardBorderWidth),
              boxShadow: _cardShadow,
            ),
            child: Row(children: [
              Icon(isOn ? Icons.power_settings_new_rounded : Icons.power_off_rounded,
                  color: accent, size: _appIconSize),
              const SizedBox(width: _appHeadGap),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(_appTitleText,
                          style: TextStyle(
                              color: _appTitleColor,
                              fontSize: _appTitleFontSize,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(isOn ? _appOnDescText : _appOffDescText,
                          style: TextStyle(
                              color: accent, fontSize: _appDescFontSize)),
                    ]),
              ),
              Switch(
                value: isOn,
                onChanged: _setAppOn,
                activeThumbColor: _appOnColor,
                inactiveThumbColor: _text3,
                inactiveTrackColor: _elevated,
              ),
            ]),
          );
        },
      );
}
