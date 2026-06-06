// 관리자 라이더 정산내역 — 라이더별 정산내역/누적정산 탭 + 날짜별 상세
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _surface  = kSurface;
const _elevated = kElevated;
const _text     = kText;
const _text2    = kText2;
const _teal     = kTeal;
const _pink     = kPink;
const _amber    = kAmber;
const _borderDim = kBorderDim;
const _appBg    = kAppBg;
const _panel    = kPanel;
const List<BoxShadow> _panelShadow = kPanelShadow;

// 자체 스캐폴드·탭 레이아웃 (메인 허브와 동일 스타일)
const double _panelOuterPad = 10;
const double _panelRadius   = 24;
const Color  _subDivColor   = _elevated; // 헤더 경계선 색
const double _subDivMarginH = 15;        // 경계선 좌우 여백
const _tabTrackColor      = _surface;  // 탭 트랙 배경
const _tabIndicatorColor  = _surface;  // 선택탭 배경
const _tabIndicatorBorder = _elevated; // 선택탭 테두리
const _tabSelColor        = _teal;     // 선택탭 글씨
const _tabUnselColor      = _text2;    // 미선택탭 글씨
const double _tabFontSize        = 14; // 탭 글씨 크기
const double _tabTrackRadius     = 10; // 트랙 모서리
const double _tabIndicatorRadius = 7;  // 선택탭 모서리
const double _tabTrackPad        = 3;  // 트랙 안쪽 여백

// ═══════════════ 라이더 정산내역 카드 상수(_rh*) ═══════════════
// ── [8-3] 라이더 출금내역 (정산내역·누적정산 카드) ──
const double _rhCardBorderWidth = 1;   // 카드 테두리 두께
const _rhDateChipColor   = _teal;      // 날짜칩 글씨 색
const double _rhDateChipFontSize = 12; // 날짜칩 글씨 크기
const _rhDaysColor       = _amber;     // "N일" 색
const double _rhDaysFontSize = 11;     // "N일" 크기
const _rhHeadAmtColor    = _text;      // 헤더 금액 색
const double _rhHeadAmtFontSize = 13;  // 헤더 금액 크기
const _rhPaidBadgeColor  = _teal;      // "입금완료" 박스 색
const double _rhPaidFontSize = 10;     // "입금완료" 박스 글씨 크기
const _rhDividerColor    = _borderDim; // 헤더 ↔ 내용 구분선 색
// 상세 내역 행 (정산내역·누적정산 공통 헬퍼)
const _rhMainColor       = _text;      // "배달수수료(세전)" 등 메인 행 색
const double _rhMainFontSize = 12;     // 메인 행 글씨 크기
const _rhTogLabelColor   = _text;     // 토글 라벨 색
const double _rhTogFontSize  = 12;     // 토글 글씨 크기
const double _rhTogIconSize  = 14;     // 토글 아이콘 크기
const _rhSubColor        = _text2;     // 하위행 색
const double _rhSubFontSize  = 11;     // 하위행 글씨 크기
const _rhSubtotalColor   = _teal;      // 소계·총출금 색
const double _rhSubtotalLabelFontSize = 12; // 소계 라벨 크기
const double _rhSubtotalValueFontSize = 13; // 소계 값 크기
// 날짜별 상세 카드
const double _rhItemGap  = 6;          // 날짜 카드 사이 갭
const _rhItemChipColor   = _teal;      // 날짜칩 글씨 색
const double _rhItemChipFontSize = 11; // 날짜칩 글씨 크기
// 누적정산 시작일·마지막일 날짜 버튼
const _rhDateHintColor   = _text;     // 기본(미선택) 글씨 색
const _rhDateSelColor    = _teal;     // 선택 시 글씨 색
const double _rhDateFontSize = 11;    // 날짜 버튼 글씨 크기
const _rhDateBorderColor = _elevated; // 날짜 버튼 테두리 색
// 누적정산 카드 여백
const double _rhCumOuterL = 15; // 카드 바깥 여백 왼
const double _rhCumOuterT = 2; // 위 (탭 ↔ 카드)
const double _rhCumOuterR = 15; // 오른
const double _rhCumOuterB = 15; // 아래
const double _rhCumPadL = 16;   // 카드 안쪽 여백 왼
const double _rhCumPadT = 14;   // 위
const double _rhCumPadR = 10;   // 오른
const double _rhCumPadB = 16;   // 아래
// 정산내역 목록 여백·카드 갭
const double _rhSettleOuterL = 15; // 목록 바깥 여백 왼
const double _rhSettleOuterT = 2; // 위 (탭 ↔ 카드)
const double _rhSettleOuterR = 15; // 오른
const double _rhSettleOuterB = 15; // 아래
const double _rhLogCardGap   = 8;  // 정산내역 카드 사이 갭
// 정산내역 카드 안쪽 여백
const double _rhLogHeadPadH = 16; // 헤더 좌우 여백
const double _rhLogHeadPadV = 13; // 헤더 위아래 여백
const double _rhLogBodyPadL = 14; // 본문 여백 왼
const double _rhLogBodyPadT = 10; // 위
const double _rhLogBodyPadR = 14; // 오른
const double _rhLogBodyPadB = 14; // 아래
// 날짜카드(속) 안쪽 여백
const double _rhItemHeadPadH = 12; // 헤더 좌우 여백
const double _rhItemHeadPadV = 9;  // 헤더 위아래 여백
const double _rhItemBodyPadL = 12; // 본문 여백 왼
const double _rhItemBodyPadT = 8;  // 위
const double _rhItemBodyPadR = 12; // 오른
const double _rhItemBodyPadB = 10; // 아래

// ═══════════════ 라이더 정산내역 페이지 (로직) ═══════════════
class RiderHistoryPage extends StatefulWidget {
  final String name, uid;
  const RiderHistoryPage({super.key, required this.name, required this.uid});
  @override
  State<RiderHistoryPage> createState() => _RiderHistoryPageState();
}

class _RiderHistoryPageState extends State<RiderHistoryPage>
    with SingleTickerProviderStateMixin {

  late TabController _tc;

  // 정산내역 탭
  List<Map<String, dynamic>> _logs       = [];
  bool                        _logsLoaded = false;
  final Map<String, bool>    _logExp     = {};  // 정산 배치 펼치기
  final Map<String, bool>    _dateExp    = {};  // 날짜별 펼치기

  // 누적정산 탭
  DateTime? _start, _end, _startApplied, _endApplied;
  bool   _cumLoaded  = false;
  bool   _cumLoading = false;
  bool   _taxExp = false, _promoExp = false, _deduExp = false, _commExp = false;
  double _gross = 0, _emp = 0, _acc = 0, _tax = 0;
  double _mission = 0, _perOrder = 0, _range = 0;
  double _ins = 0, _wdFee = 0, _comm = 0, _lease = 0, _total = 0;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 2, vsync: this);
    _loadLogs();
    _loadCumulative();
  }

  @override
  void dispose() { _tc.dispose(); super.dispose(); }

  // ── 데이터 로더 ──────────────────────────────────────────────────

  Future<void> _loadLogs() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('admin_settlement_logs')
          .where('uid',    isEqualTo: widget.uid)
          .where('status', isEqualTo: '지급완료')
          .orderBy('approvedAt', descending: true)
          .get();
      final list = snap.docs.map((doc) {
        final d = Map<String, dynamic>.from(doc.data());
        d['_docId'] = doc.id;
        return d;
      }).toList();
      if (mounted) setState(() { _logs = list; _logsLoaded = true; });
    } catch (e) {
      if (mounted) setState(() => _logsLoaded = true);
    }
  }

  Future<void> _loadCumulative() async {
    if (_cumLoading) return;
    setState(() { _cumLoading = true; _cumLoaded = false; });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('admin_settlement_logs')
          .where('uid',    isEqualTo: widget.uid)
          .where('status', isEqualTo: '지급완료')
          .get();
      double gross = 0, emp = 0, acc = 0, tax = 0;
      double mission = 0, perOrder = 0, range = 0, ins = 0, wdFee = 0, comm = 0, lease = 0, total = 0;

      final hasFilter = _startApplied != null || _endApplied != null;
      final endDay = _endApplied != null
          ? DateTime(_endApplied!.year, _endApplied!.month, _endApplied!.day, 23, 59, 59)
          : null;

      for (final doc in snap.docs) {
        final data = doc.data();
        final items = (data['items'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];

        if (!hasFilter) {
          total += (data['amount'] as num?)?.toDouble() ?? 0;
          if (items.isNotEmpty) {
            lease += (data['leaseDeduction'] as num?)?.toDouble() ?? 0;
            for (final item in items) {
              gross    += (item['deliveryFee']    as num?)?.toDouble() ?? 0;
              emp      += (item['employmentTax']  as num?)?.toDouble() ?? 0;
              acc      += (item['accidentTax']    as num?)?.toDouble() ?? 0;
              tax      += (item['incomeTax']      as num?)?.toDouble() ?? 0;
              mission  += (item['missionFee']     as num?)?.toDouble() ?? 0;
              perOrder += (item['perOrderAmount'] as num?)?.toDouble() ?? 0;
              range    += (item['rangeAmount']    as num?)?.toDouble() ?? 0;
              ins      += (item['insuranceFee']   as num?)?.toDouble() ?? 0;
              wdFee    += (item['withdrawalFee']  as num?)?.toDouble() ?? 0;
              comm     += (item['commissionAmt']  as num?)?.toDouble() ?? 0;
            }
          } else {
            final msg = data['message']?.toString() ?? '';
            gross    += _rx(msg, '배달수수료\\(세전\\)').abs();
            emp      += _rx(msg, '고용보험').abs();
            acc      += _rx(msg, '산재보험').abs();
            tax      += _rx(msg, '원천세').abs();
            mission  += _rx(msg, '미션금액').abs();
            perOrder += _rx(msg, '건당프로모션').abs();
            range    += _rx(msg, '구간프로모션').abs();
            ins      += _rx(msg, '시간제보험').abs();
            wdFee    += _rx(msg, '출금수수료').abs();
            comm     += _rxComm(msg);
            lease    += _rx(msg, '리스비\\(일\\)').abs();
          }
        } else {
          int matchedCount = 0;
          for (final item in items) {
            final itemDate = DateTime.tryParse(item['date'] as String? ?? '');
            if (itemDate == null) continue;
            if (_startApplied != null && itemDate.isBefore(_startApplied!)) continue;
            if (endDay != null && itemDate.isAfter(endDay)) continue;
            matchedCount++;
            gross    += (item['deliveryFee']    as num?)?.toDouble() ?? 0;
            emp      += (item['employmentTax']  as num?)?.toDouble() ?? 0;
            acc      += (item['accidentTax']    as num?)?.toDouble() ?? 0;
            tax      += (item['incomeTax']      as num?)?.toDouble() ?? 0;
            mission  += (item['missionFee']     as num?)?.toDouble() ?? 0;
            perOrder += (item['perOrderAmount'] as num?)?.toDouble() ?? 0;
            range    += (item['rangeAmount']    as num?)?.toDouble() ?? 0;
            ins      += (item['insuranceFee']   as num?)?.toDouble() ?? 0;
            wdFee    += (item['withdrawalFee']  as num?)?.toDouble() ?? 0;
            comm     += (item['commissionAmt']  as num?)?.toDouble() ?? 0;
          }
          if (matchedCount > 0 && items.isNotEmpty) {
            final fullLease = (data['leaseDeduction'] as num?)?.toDouble() ?? 0;
            lease += fullLease * matchedCount / items.length;
          }
        }
      }

      if (hasFilter) {
        total = gross + (mission + perOrder + range) - (emp + acc + tax) - (wdFee + comm) - ins - lease;
      }

      if (mounted) {
        setState(() {
          _gross = gross; _emp = emp; _acc = acc; _tax = tax;
          _mission = mission; _perOrder = perOrder; _range = range;
          _ins = ins; _wdFee = wdFee; _comm = comm; _total = total;
          _lease = lease;
          _cumLoaded = true; _cumLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _cumLoaded = true; _cumLoading = false; });
    }
  }

  // ── 헬퍼 ──────────────────────────────────────────────────

  double _rx(String msg, String key) {
    final m = RegExp('$key[^:：]*[：:][\\s]*([-\\d,]+)').firstMatch(msg);
    if (m == null) return 0;
    return double.tryParse(m.group(1)!.replaceAll(',', '')) ?? 0;
  }
  double _rxComm(String msg) {
    final m = RegExp(r'(?<![가-힣])협력사수수료\([^)]+\)\s*[：:]\s*([\d,]+)').firstMatch(msg);
    if (m == null) return 0;
    return double.tryParse(m.group(1)!.replaceAll(',', '')) ?? 0;
  }
  String _fmtC(double v) => NumberFormat('#,###').format(v);

  // ── BUILD ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_panelOuterPad),
          child: Container(
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(_panelRadius),
              border: Border.all(
                  color: _elevated, width: 1),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_panelRadius),
              child: Column(children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: _text, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                    RichText(
                        text: TextSpan(
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            children: [
                          TextSpan(text: widget.name,
                              style: const TextStyle(color: _teal, fontSize: 20)),
                          const TextSpan(text: " 님 출금 내역",
                              style: TextStyle(color: _text, fontSize: 19)),
                        ])),
                  ]),
                ),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: _subDivMarginH),
                  color: _subDivColor),
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 8),
                  padding: const EdgeInsets.all(_tabTrackPad),
                  decoration: BoxDecoration(
                      color: _tabTrackColor,
                      borderRadius: BorderRadius.circular(_tabTrackRadius)),
                  child: TabBar(
                    controller: _tc,
                    indicator: BoxDecoration(
                        color: _tabIndicatorColor,
                        borderRadius: BorderRadius.circular(_tabIndicatorRadius),
                        border: Border.all(color: _tabIndicatorBorder, width: 1)),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: _tabSelColor,
                    unselectedLabelColor: _tabUnselColor,
                    dividerColor: Colors.transparent,
                    labelStyle:
                        const TextStyle(fontWeight: FontWeight.w700, fontSize: _tabFontSize),
                    unselectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.w400, fontSize: _tabFontSize),
                    tabs: const [Tab(text: "정산 내역"), Tab(text: "누적 정산")],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tc,
                    children: [_settlementTab(), _cumulativeTab()],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ── 탭 1: 정산내역 ──────────────────────────────────────────────────

  Widget _settlementTab() {
    if (!_logsLoaded) return const Center(child: CircularProgressIndicator(color: _elevated));
    if (_logs.isEmpty) {
      return const Center(
          child: Text("출금 내역이 없습니다.", style: TextStyle(color: _text2, fontSize: 14)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(_rhSettleOuterL, _rhSettleOuterT, _rhSettleOuterR, _rhSettleOuterB),
      itemCount: _logs.length,
      itemBuilder: (_, i) => _logCard(_logs[i]),
    );
  }

  Widget _logCard(Map<String, dynamic> data) {
    final docId      = data['_docId'] as String? ?? '';
    final amount     = (data['amount'] as num?)?.toDouble() ?? 0;
    final items      = (data['items'] as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    final approvedAt = (data['approvedAt'] as Timestamp?)?.toDate();
    final dateStr    = approvedAt != null ? DateFormat('yyyy-MM-dd').format(approvedAt) : '';
    final logExp     = _logExp[docId] ?? false;

    // 날짜 범위 라벨
    String dateLabel;
    if (items.isNotEmpty) {
      final first = items.first['date'] as String? ?? '';
      final last  = items.last['date']  as String? ?? '';
      final fs = first.length >= 10 ? first.substring(5) : first;
      final ls = last.length  >= 10 ? last.substring(5)  : last;
      dateLabel = items.length == 1 ? fs : "$fs ~ $ls";
    } else {
      dateLabel = dateStr.length >= 10 ? dateStr.substring(5) : dateStr;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: _rhLogCardGap),
      decoration: BoxDecoration(
        color: _surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _elevated, width: _rhCardBorderWidth),
      ),
      child: Column(children: [

        // 카드 헤더
        GestureDetector(
          onTap: () => setState(() => _logExp[docId] = !logExp),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _rhLogHeadPadH, vertical: _rhLogHeadPadV),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _surface, borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: _elevated.withAlpha(150)),
                ),
                child: Text(dateLabel,
                    style: const TextStyle(color: _rhDateChipColor, fontSize: _rhDateChipFontSize, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              if (items.isNotEmpty)
                Text("  ${items.length}일", style: const TextStyle(color: _rhDaysColor, fontSize: _rhDaysFontSize)),
              const Spacer(),
              Text("${_fmtC(amount)} 원",
                  style: const TextStyle(color: _rhHeadAmtColor, fontSize: _rhHeadAmtFontSize, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),

        // 펼침 내용
        if (logExp) ...[
          Container(height: 1, color: _rhDividerColor),
          Padding(
            padding: const EdgeInsets.fromLTRB(_rhLogBodyPadL, _rhLogBodyPadT, _rhLogBodyPadR, _rhLogBodyPadB),
            child: Column(children: [
              if (items.isNotEmpty) ...[
                // 리스비를 날짜카드 안쪽(출금수수료 밑)으로 이동
                for (int i = 0; i < items.length; i++)
                  _dateItemCard(items[i], docId,
                      leasePerDay: (() {
                        final ld = (data['leaseDeduction'] as num?)?.toDouble() ?? 0;
                        return items.isNotEmpty ? ld / items.length : 0.0;
                      })()),
              ] else
                _oldMsgView(data),

            ]),
          ),
        ],
      ]),
    );
  }

  Widget _dateItemCard(Map<String, dynamic> item, String docId, {double leasePerDay = 0}) {
    final iDate   = item['date']            as String? ?? '';
    final iFinal  = (item['finalAmount']    as num?)?.toDouble() ?? 0;
    final key     = '${docId}_$iDate';
    final iExp    = _dateExp[key] ?? false;
    final iShort  = iDate.length >= 10 ? iDate.substring(5) : iDate;
    final actualFinal = iFinal - leasePerDay;

    final iDel    = (item['deliveryFee']    as num?)?.toDouble() ?? 0;
    final iPromo  = (item['promoTotal']     as num?)?.toDouble() ?? 0;
    final iTax    = (item['tax']            as num?)?.toDouble() ?? 0;
    final iComm   = (item['commissionAmt']  as num?)?.toDouble() ?? 0;
    final iWd     = (item['withdrawalFee']  as num?)?.toDouble() ?? 0;
    final iPOrd   = (item['perOrderAmount'] as num?)?.toDouble() ?? 0;
    final iRng    = (item['rangeAmount']    as num?)?.toDouble() ?? 0;
    final iETax   = (item['employmentTax']  as num?)?.toDouble() ?? 0;
    final iATax   = (item['accidentTax']    as num?)?.toDouble() ?? 0;
    final iITax   = (item['incomeTax']      as num?)?.toDouble() ?? 0;
    final iIns    = (item['insuranceFee']   as num?)?.toDouble() ?? 0;
    final iFee    = iWd + iComm;
    final iDedu   = iIns + leasePerDay;

    bool tog(String k) => _dateExp[k] ?? false;
    void togSet(String k) => setState(() => _dateExp[k] = !(_dateExp[k] ?? false));

    Widget subGroup(List<Widget> ch) => Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(color: _surface.withAlpha(180), borderRadius: BorderRadius.circular(6), border: Border.all(color: _elevated)),
      child: Column(children: ch),
    );
    Widget subRow(String label, String val, {Color lc = _rhSubColor, Color vc = _rhSubColor}) =>
        Padding(padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: TextStyle(color: lc, fontSize: _rhSubFontSize)),
            Text(val,   style: TextStyle(color: vc, fontSize: _rhSubFontSize)),
          ]));
    Widget togRow(String label, double v, Color vc, String k) =>
        GestureDetector(
          onTap: () => togSet(k),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Text(label, style: const TextStyle(color: _rhTogLabelColor, fontSize: _rhTogFontSize, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Icon(tog(k) ? Icons.expand_less : Icons.expand_more, color: _rhTogLabelColor, size: _rhTogIconSize),
              const Spacer(),
              Text("${_fmtC(v)} 원", style: TextStyle(color: vc, fontSize: _rhTogFontSize)),
            ]),
          ),
        );

    return Container(
      margin: const EdgeInsets.only(bottom: _rhItemGap),
      decoration: BoxDecoration(
        color: _surface, borderRadius: BorderRadius.circular(9),
        border: Border.all(color: iExp ? _teal.withAlpha(80) : _elevated),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _dateExp[key] = !iExp),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _rhItemHeadPadH, vertical: _rhItemHeadPadV),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(5), border: Border.all(color: _elevated)),
                child: Text(iShort, style: const TextStyle(color: _rhItemChipColor, fontSize: _rhItemChipFontSize, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _rhPaidBadgeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: _rhPaidBadgeColor.withAlpha(80)),
                ),
                child: const Text("입금완료",
                    style: TextStyle(color: _rhPaidBadgeColor, fontSize: _rhPaidFontSize, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ),
        if (iExp) ...[
          Container(height: 1, color: _borderDim),
          Padding(
            padding: const EdgeInsets.fromLTRB(_rhItemBodyPadL, _rhItemBodyPadT, _rhItemBodyPadR, _rhItemBodyPadB),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("배달수수료 (세전)", style: TextStyle(color: _rhMainColor, fontSize: _rhMainFontSize, fontWeight: FontWeight.w500)),
                  Text("${_fmtC(iDel)} 원", style: const TextStyle(color: _rhMainColor, fontSize: _rhMainFontSize)),
                ]),
              ),
              togRow("지원금합계", iPromo, _text, '${key}_promo'),
              if (tog('${key}_promo')) subGroup([
                subRow("건당프로모션", "${_fmtC(iPOrd)} 원"),
                subRow("구간프로모션", "${_fmtC(iRng)} 원"),
              ]),
              togRow("세금합계", iTax, _pink, '${key}_tax'),
              if (tog('${key}_tax')) subGroup([
                subRow("고용보험", "${_fmtC(iETax)} 원", vc: _text2),
                subRow("산재보험", "${_fmtC(iATax)} 원", vc: _text2),
                subRow("원천세",   "${_fmtC(iITax)} 원", vc: _text2),
              ]),
              togRow("수수료합계", iFee, _pink, '${key}_comm'),
              if (tog('${key}_comm')) subGroup([
                subRow("출금수수료",   "${_fmtC(iWd)} 원",   vc: _text2),
                subRow("협력사수수료", "${_fmtC(iComm)} 원", vc: _text2),
              ]),
              togRow("공제합계", iDedu, _pink, '${key}_dedu'),
              if (tog('${key}_dedu')) subGroup([
                subRow("시간제보험", "${_fmtC(iIns)} 원",        vc: _text2),
                subRow("리스비",     "${_fmtC(leasePerDay)} 원", vc: _text2),
              ]),
              Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(vertical: 5)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("소계", style: TextStyle(color: _rhSubtotalColor, fontSize: _rhSubtotalLabelFontSize, fontWeight: FontWeight.w700)),
                  Text("${_fmtC(leasePerDay > 0 ? actualFinal : iFinal)} 원",
                      style: const TextStyle(color: _rhSubtotalColor, fontSize: _rhSubtotalValueFontSize, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),
        ],
      ]),
    );
  }

  // 구형 메시지 파싱 뷰 (items 없는 기존 데이터용)
  Widget _oldMsgView(Map<String, dynamic> data) {
    final msg        = data['message']?.toString() ?? '';
    final deliveryFee  = _rx(msg, '배달수수료\\(세전\\)').abs();
    final tTax         = _rx(msg, '세금').abs();
    final eTax         = _rx(msg, '고용보험').abs();
    final aTax         = _rx(msg, '산재보험').abs();
    final iTax         = _rx(msg, '원천세').abs();
    final missionFee   = _rx(msg, '미션금액').abs();
    final perOrderAmt  = _rx(msg, '건당프로모션').abs();
    final rangeAmt     = _rx(msg, '구간프로모션').abs();
    final promoTotal   = missionFee + perOrderAmt + rangeAmt;
    final insuranceFee = _rx(msg, '시간제보험').abs();
    final withdrawFee  = _rx(msg, '출금수수료').abs();
    final leaseDailyAmt = _rx(msg, '리스비\\(일\\)').abs();
    final commAmt      = _rxComm(msg);
    final deductTotal  = insuranceFee + withdrawFee + leaseDailyAmt;
    final finalWd      = _rx(msg, '최종출금금액').abs();
    final docId        = data['_docId'] as String? ?? '';
    final taxExp       = _dateExp['${docId}_tax']   ?? false;
    final promoExp     = _dateExp['${docId}_promo'] ?? false;
    final deduExp      = _dateExp['${docId}_dedu']  ?? false;
    return Column(children: [
      _row("배달수수료 (세전)", "${_fmtC(deliveryFee)} 원"),
      _divider(),
      _toggle("지원금", "${_fmtC(promoTotal)} 원", _text2, promoExp,
          () => setState(() => _dateExp['${docId}_promo'] = !promoExp), [
        _sub("미션금",       "${_fmtC(missionFee)} 원"),
        _sub("건당프로모션", "${_fmtC(perOrderAmt)} 원"),
        _sub("구간프로모션", "${_fmtC(rangeAmt)} 원"),
      ]),
      _divider(),
      _toggle("세금", "${_fmtC(tTax)} 원", _pink, taxExp,
          () => setState(() => _dateExp['${docId}_tax'] = !taxExp), [
        _sub("고용보험", "${_fmtC(eTax)} 원"),
        _sub("산재보험", "${_fmtC(aTax)} 원"),
        _sub("원천세",   "${_fmtC(iTax)} 원"),
      ]),
      _divider(),
      _row("협력사수수료", "${_fmtC(commAmt)} 원", vc: _pink),
      _divider(),
      _toggle("공제", "${_fmtC(deductTotal)} 원", _pink, deduExp,
          () => setState(() => _dateExp['${docId}_dedu'] = !deduExp), [
        _sub("시간제보험", "${_fmtC(insuranceFee)} 원"),
        _sub("출금수수료", "${_fmtC(withdrawFee)} 원"),
        _sub("리스비(일)", "${_fmtC(leaseDailyAmt)} 원"),
      ]),
      Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(vertical: 8)),
      _row("최종출금금액", "${_fmtC(finalWd)} 원", lc: _teal, vc: _teal, bold: true, fs: 14),
    ]);
  }

  // ── 탭 2: 누적정산 ──────────────────────────────────────────────────

  Widget _cumulativeTab() {
    final totalTax   = _emp + _acc + _tax;
    final totalPromo = _mission + _perOrder + _range;
    final totalFee   = _wdFee + _comm;
    final totalDedu  = _ins + _lease;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(_rhCumOuterL, _rhCumOuterT, _rhCumOuterR, _rhCumOuterB),
      child: Container(
        padding: const EdgeInsets.fromLTRB(_rhCumPadL, _rhCumPadT, _rhCumPadR, _rhCumPadB),
        decoration: BoxDecoration(
          color: _surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _elevated, width: _rhCardBorderWidth),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 날짜 필터
          Row(children: [
            Flexible(child: _dateBtn(_start, "시작일",   (d) => setState(() => _start = d))),
            const Text(" ~ ", style: TextStyle(color: _text2, fontSize: 12)),
            Flexible(child: _dateBtn(_end,   "마지막일", (d) => setState(() => _end   = d))),
            const SizedBox(width: 6),
            _smallBtn("조회", () {
              setState(() { _startApplied = _start; _endApplied = _end; _cumLoaded = false; });
              _loadCumulative();
            }, filled: true),
            const SizedBox(width: 6),
            _smallBtn("초기화", () {
              if (_start == null && _end == null && _startApplied == null && _endApplied == null) return; // 기본 상태면 변화 없음
              setState(() { _start = _end = _startApplied = _endApplied = null; });
              _loadCumulative(); // 전체 다시 로드
            }),
          ]),
          Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(vertical: 12)),
          if (!_cumLoaded)
            const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: _teal),
            ))
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("배달수수료 (세전)", style: TextStyle(color: _rhMainColor, fontSize: _rhMainFontSize, fontWeight: FontWeight.w500)),
                Text("${_fmtC(_gross)} 원", style: const TextStyle(color: _rhMainColor, fontSize: _rhMainFontSize)),
              ]),
            ),
            _toggle("지원금합계", "${_fmtC(totalPromo)} 원", _text, _promoExp,
                () => setState(() => _promoExp = !_promoExp), [
              _subC("건당프로모션", "${_fmtC(_perOrder)} 원"),
              _sub("구간프로모션", "${_fmtC(_range)} 원"),
            ]),
            _toggle("세금합계", "${_fmtC(totalTax)} 원", _pink, _taxExp,
                () => setState(() => _taxExp = !_taxExp), [
              _subC("고용보험", "${_fmtC(_emp)} 원", vc: _text2),
              _subC("산재보험", "${_fmtC(_acc)} 원", vc: _text2),
              _subC("원천세",   "${_fmtC(_tax)} 원", vc: _text2),
            ]),
            _toggle("수수료합계", "${_fmtC(totalFee)} 원", _pink, _commExp,
                () => setState(() => _commExp = !_commExp), [
              _subC("출금수수료",   "${_fmtC(_wdFee)} 원", vc: _text2),
              _subC("협력사수수료", "${_fmtC(_comm)} 원",  vc: _text2),
            ]),
            _toggle("공제합계", "${_fmtC(totalDedu)} 원", _pink, _deduExp,
                () => setState(() => _deduExp = !_deduExp), [
              _subC("시간제보험", "${_fmtC(_ins)} 원",   vc: _text2),
              _subC("리스비",     "${_fmtC(_lease)} 원", vc: _text2),
            ]),
            Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(vertical: 10)),
            _row("총 출금금액", "${_fmtC(_total)} 원",
                lc: _teal, vc: _teal, bold: true, fs: 14),
          ],
        ]),
      ),
    );
  }

  // ── 공통 위젯 ──────────────────────────────────────────────────

  Widget _divider() => Container(height: 1, color: _borderDim, margin: const EdgeInsets.symmetric(vertical: 5));

  Widget _row(String label, String value,
      {Color lc = _text2, Color vc = _text2, bool bold = false, double fs = 12}) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: lc, fontSize: fs, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value, style: TextStyle(color: vc, fontSize: fs, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ]));

  Widget _sub(String label, String value) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: _rhSubColor, fontSize: _rhSubFontSize)),
          Text(value, style: const TextStyle(color: _rhSubColor, fontSize: _rhSubFontSize)),
        ]));

  Widget _subC(String label, String value, {Color lc = _rhSubColor, Color vc = _rhSubColor}) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: lc, fontSize: _rhSubFontSize)),
          Text(value, style: TextStyle(color: vc, fontSize: _rhSubFontSize)),
        ]));

  Widget _toggle(String label, String value, Color vc,
      bool expanded, VoidCallback onTap, List<Widget> children) =>
      Column(children: [
        GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              Text(label, style: const TextStyle(color: _rhTogLabelColor, fontSize: _rhTogFontSize, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Icon(expanded ? Icons.expand_less : Icons.expand_more,
                  color: _rhTogLabelColor, size: _rhTogIconSize),
              const Spacer(),
              Text(value, style: TextStyle(color: vc, fontSize: _rhTogFontSize)),
            ]))),
        if (expanded)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _elevated)),
            child: Column(children: children)),
      ]);

  Widget _dateBtn(DateTime? date, String hint, Function(DateTime) onPick) =>
      GestureDetector(
        onTap: () async {
          final p = await showDatePicker(context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2026), lastDate: DateTime(2030),
              builder: (ctx, child) => Theme(
                  data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: _teal)),
                  child: child!));
          if (p != null) onPick(p);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              border: Border.all(color: _rhDateBorderColor, width: 1),
              borderRadius: BorderRadius.circular(7)),
          child: Text(date != null ? DateFormat('MM-dd').format(date) : hint,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: date != null ? _rhDateSelColor : _rhDateHintColor, fontSize: _rhDateFontSize)),
        ),
      );

  Widget _smallBtn(String label, VoidCallback onTap, {bool filled = false}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          height: 28, padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: filled ? _teal : Colors.transparent,
            border: Border.all(color: filled ? _teal : _elevated, width: 1),
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(
              color: filled ? _surface : _teal,
              fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      );
}
