// 기사 설정 페이지 — 내 정보(이름·은행·계좌 등) 표시
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tokens.dart';
import 'driver_common.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg     = kAppBg;
const _panel     = kPanel;
const _surface   = kSurface;
const _elevated  = kElevated;
const _text      = kText;
const _text2     = kText2;
const _teal      = kTeal;
const Color _bgScaffold = _appBg;
const List<BoxShadow> _cardShadow  = kCardShadow;
const List<BoxShadow> _panelShadow = kPanelShadow;

// ═══════════════ 설정 페이지 상수(_sp* / _si*) ═══════════════
const Color  _spPanelColor       = _panel;     // 패널 배경색
const Color  _spPanelBorderColor = _elevated;  // 패널 테두리 색
const double _spPanelBorderAlpha = 1.0;        // 테두리 투명도 (1.0=솔리드)
const double _spOuterPad         = 10;  // 패널 바깥 여백
const double _spPanelRadius      = 24;  // 패널 모서리
// ── 헤더 아래 경계선 갭 ──
const double _spGapHeaderToDiv = kGapInner;  // 뒤로가기 ↔ 경계선 갭
const double _spGapDivToInfo   = kGapSection;  // 경계선 ↔ 내 정보 갭
const double _spDivMarginH     = 15; // 경계선 좌우 여백(끝까지 안 붙음)
const double _spListPadL = 10;  // 리스트 안쪽 여백 왼
const double _spListPadT = 0;   // 리스트 안쪽 위 여백(경계선↔내정보 갭은 _spGapDivToInfo로 조정)
const double _spListPadR = 10;  // 리스트 안쪽 여백 오른
const double _spListPadB = 10;  // 리스트 안쪽 여백 아래
const Color  _spHeadIconColor   = _teal;   // 사람 아이콘 색
const double _spHeadIconSize    = 20;      // 아이콘 크기
const Color  _spHeadTitleColor  = _text;   // "내 정보" 글씨 색
const double _spHeadTitleFontSize = 15;    // "내 정보" 글씨 크기

const Color  _siCardBg          = _surface;    // 카드 배경색
const Color  _siCardBorder      = _elevated; // 카드 테두리 색
const double _siCardRadius      = 14;  // 카드 모서리
const double _siCardPadH        = 10;  // 카드 좌우 안쪽 여백
const Color  _siLabelColor      = _text;  // 라벨(왼쪽) 글씨 색
const double _siLabelFontSize   = 13;      // 라벨 글씨 크기
const Color  _siValueColor      = _text2;   // 값(오른쪽) 글씨 색
const double _siValueFontSize   = 13;      // 값 글씨 크기
const double _siRowPadV         = 6;      // 행 위아래 여백
const Color  _siDividerColor    = _elevated; // 행 구분선 색
const double _siLabelGap        = 12;      // 라벨-값 사이 간격
// ── 값 표시 배경박스 (각 값을 감싸는 칸) ──
const Color  _siBoxBg           = _appBg;     // 값 박스 배경색
const Color  _siBoxBorder       = _elevated; // 값 박스 테두리 색
const double _siBoxRadius       = 8;          // 값 박스 모서리
const double _siBoxPadH         = 10;         // 값 박스 좌우 여백
const double _siBoxPadV         = 6;          // 값 박스 위아래 여백
const double _siAccountIndent   = 64;         // 계좌번호(둘째 줄) 들여쓰기
const Color  _siSoonColor       = _text2;     // "준비중" 글씨 색
const String _siSoonText        = '준비중';    // 미구현 항목 표시 문구

// ═══════════════ 설정 페이지 (로직) ═══════════════
class SettingsPage extends StatefulWidget {
  final String uid;
  const SettingsPage({super.key, required this.uid});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic>? _data;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      if (mounted) setState(() {
        _data = doc.data();
        _loaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  // ── 8-2. 라벨 ──
  Widget _siLabel(String t) => Text(t,
      style: const TextStyle(color: _siLabelColor, fontSize: _siLabelFontSize));

  // 값 표시 배경박스(_appBg) — 표시되는 부분만 감쌈
  Widget _siValueBox(String value, {Color? valueColor}) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: _siBoxPadH, vertical: _siBoxPadV),
        decoration: BoxDecoration(
          color: _siBoxBg,
          borderRadius: BorderRadius.circular(_siBoxRadius),
          border: Border.all(color: _siBoxBorder, width: 1),
        ),
        child: Text(value,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: valueColor ?? _siValueColor,
                fontSize: _siValueFontSize,
                fontWeight: FontWeight.w400)),
      );

  // 라벨 + 값박스 (전체폭: 값박스가 남는 폭만큼 늘어남)
  Widget _siField(String label, String value, {Color? valueColor}) => Row(
        children: [
          _siLabel(label),
          const SizedBox(width: _siLabelGap),
          Flexible(child: _siValueBox(value, valueColor: valueColor)),
        ],
      );

  // 행 위아래 여백 래퍼
  Widget _siRow(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: _siRowPadV),
        child: child,
      );

  Widget _siDivider() => Container(height: 1, color: _siDividerColor);

  // 불러온 정보 표시 (값마다 _appBg 배경박스)
  Widget _siInfoBox() {
    final name    = (_data?['name']          as String?)?.trim();
    final id      = (_data?['reportId']       as String?)?.trim();
    final email   = (_data?['email']          as String?)?.trim();
    final phone   = (_data?['phone']          as String?)?.trim();
    final bank    = (_data?['bankName']       as String?)?.trim();
    final account = (_data?['accountNumber']  as String?)?.trim();
    final vehicle   = (_data?['vehicleType']   as String?)?.trim();
    final insurance = (_data?['paidInsurance'] as String?)?.trim();
    String orDash(String? v) => (v == null || v.isEmpty) ? '-' : v;
    // 값이 있으면 실제 값, 없으면(구 계정) "준비중" 회색 표시
    Widget infoOrSoon(String label, String? v) =>
        (v == null || v.isEmpty)
            ? _siField(label, _siSoonText, valueColor: _siSoonColor)
            : _siField(label, v);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // 이름
      _siRow(_siField("이름", orDash(name))),
      _siDivider(),
      // ID (이름 밑 줄)
      _siRow(_siField("ID", orDash(id))),
      _siDivider(),
      _siRow(_siField("E.MAIL", orDash(email))),
      _siDivider(),
      _siRow(_siField("전화번호", orDash(phone))),
      _siDivider(),
      // 계좌번호: 은행명 박스 + 아래 줄에 계좌번호 박스
      _siRow(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _siField("계좌번호", orDash(bank)),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: _siAccountIndent),
          child: _siValueBox(orDash(account)),
        ),
      ])),
      _siDivider(),
      _siRow(infoOrSoon("운송수단", vehicle)),
      _siDivider(),
      _siRow(infoOrSoon("유상운송보험 가입유무", insurance)),
    ]);
  }

  // ── 8-1. 메인배경 + 내 정보 ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_spOuterPad),
          child: Container(
            decoration: BoxDecoration(
              color: _spPanelColor,
              borderRadius: BorderRadius.circular(_spPanelRadius),
              border: Border.all(
                  color: _spPanelBorderColor.withValues(alpha: _spPanelBorderAlpha)),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_spPanelRadius),
              child: Column(children: [
                const SizedBox(height: 8),
                pageHeader(context, "설정"),
                const SizedBox(height: _spGapHeaderToDiv),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: _spDivMarginH),
                  color: _elevated.withValues(alpha: 0.6),
                ),
                const SizedBox(height: _spGapDivToInfo),
                Expanded(
                    child: !_loaded
                        ? const Center(child: CircularProgressIndicator(color: _teal))
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(
                                _spListPadL, _spListPadT, _spListPadR, _spListPadB),
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Row(children: [
                                  Icon(Icons.person_outline_rounded,
                                      color: _spHeadIconColor, size: _spHeadIconSize),
                                  SizedBox(width: 8),
                                  Text("내 정보",
                                      style: TextStyle(
                                          color: _spHeadTitleColor,
                                          fontSize: _spHeadTitleFontSize,
                                          fontWeight: FontWeight.w400)),
                                ]),
                              ),
                              Container(
                                padding: const EdgeInsets.all(_siCardPadH),
                                decoration: BoxDecoration(
                                  color: _siCardBg,
                                  borderRadius: BorderRadius.circular(_siCardRadius),
                                  border: Border.all(color: _siCardBorder, width: 1),
                                  boxShadow: _cardShadow,
                                ),
                                child: _siInfoBox(),
                              ),
                            ],
                          ),
                  ),
                ]),
              ),
            ),
          ),
      ),
    );
  }
}