// 관리자 출금신청 페이지 — 기사 요청대기 카드 목록 + 상세 펼침 + 지급완료 처리
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';
import 'admin_common.dart';
import 'glass_shine_button.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _surface  = kSurface;
const _elevated = kElevated;
const _text     = kText;
const _text2    = kText2;
const _teal     = kTeal;
const _amber    = kAmber;
const _pink     = kPink;
const List<BoxShadow> _cardShadow = kCardShadow;

const double _wrTabToCardGap = 2; // 출금신청 탭 ↔ 카드 갭

// ═══════════════ 출금신청 카드 상수(_wr*) ═══════════════
// ── 출금신청 카드 ──
const _wrCardBg     = _surface;
const _wrCardBorder = _teal; // 출금신청(요청대기) 카드 강조 테두리
const double _wrCardRadius = 14;   // 카드 모서리
const double _wrCardGap    = kGapCard;   // 카드 사이 간격
const double _wrHeadPadH   = 16;   // 헤더 좌우 여백
const double _wrHeadPadV   = 13;   // 헤더 위아래 여백
const _wrNameColor  = _teal;     // 이름 글씨 색
const double _wrNameFontSize  = 17;// 이름 글씨 크기
const _wrTitleColor = _text;      // "님의 출금 신청" 글씨 색
const double _wrTitleFontSize = 15;// "님의 출금 신청" 글씨 크기
const _wrDateColor  = _text2;      // 날짜 글씨 색
const double _wrDateFontSize  = 11;// 날짜 글씨 크기
const _wrAmtColor   = _teal;     // 헤더 금액 숫자 색
const double _wrAmtFontSize    = 14;// 헤더 금액 숫자 크기
const _wrDaysColor  = _text2;      // "N일 합산" 글씨 색
const double _wrDaysFontSize   = 10;// "N일 합산" 글씨 크기
// 펼침: 계좌·최종출금금액 행
const _wrBankColor      = _amber;     // 은행명 글씨 색(박스 없음)
const double _wrBankFontSize     = 12; // 은행명 글씨 크기
const _wrAcctNumColor   = _text;       // 계좌번호 글씨 색(박스 안)
const double _wrAcctNumFontSize  = 13; // 계좌번호 글씨 크기
const _wrFinalLabelColor = _amber;    // "최종출금금액" 라벨 색
const double _wrFinalLabelFontSize = 12;// "최종출금금액" 라벨 크기
const _wrFinalAmtColor  = _text;       // 최종출금금액 숫자 색
const double _wrFinalAmtFontSize = 12; // 최종출금금액 숫자 크기
const _wrValBoxBg       = _surface;      // 값 박스 배경(블랙)
const _wrValBoxBorder   = _elevated;   // 값 박스 테두리
const double _wrValBoxRadius = 6;      // 값 박스 모서리
const double _wrValBoxPadH   = 8;      // 값 박스 좌우 여백
const double _wrValBoxPadV   = 4;      // 값 박스 위아래 여백
const _wrCopyBorder     = _elevated;   // 복사 버튼 테두리 색
const double _wrCopyBorderWidth = 1;   // 복사 버튼 테두리 두께
// 카드 테두리·헤더 줄 간격
const double _wrCardBorderWidth = 1;   // 카드 테두리 두께
const double _wrGapNameDate    = 2;    // 이름줄 ↔ 날짜 갭
const double _wrGapAmtChevron  = 8;    // 금액 ↔ 펼침아이콘 갭
const double _wrChevronSize    = 18;   // 펼침 아이콘 크기
const double _wrGapAcctFinal   = 8;    // 계좌행 ↔ 최종금액 갭
const double _wrGapFinalItems  = 10;   // 최종금액 ↔ 날짜상세 갭
// 날짜별 상세 내역 행
const double _wrItemGap        = kGapCard;    // 날짜 카드 사이 갭
const _wrItemChipColor         = _teal; // 날짜칩 글씨 색
const double _wrItemChipFontSize = 11; // 날짜칩 글씨 크기
const double _wrItemChevronSize  = 15; // 날짜 펼침 아이콘 크기
const _wrDtMainColor           = _text; // "배달수수료(세전)" 색
const double _wrDtMainFontSize   = 12; // "배달수수료(세전)" 크기
const _wrDtTogLabelColor       = _text; // 토글 라벨 색
const double _wrDtTogFontSize    = 12; // 토글 글씨 크기
const double _wrDtTogIconSize    = 14; // 토글 아이콘 크기
const _wrDtSubColor            = _text2; // 하위행(subRow) 색
const double _wrDtSubFontSize    = 11; // 하위행 글씨 크기
const _wrDtSubtotalColor       = _teal; // 소계 색
const double _wrDtSubtotalLabelFontSize = 12; // 소계 라벨 크기
const double _wrDtSubtotalValueFontSize = 13; // 소계 값 크기

// ═══════════════ 출금신청 페이지 (로직) ═══════════════
class WithdrawalRequestPage extends StatefulWidget {
  final bool embedded; // 허브 탭 안에 들어갈 때 true (패널 생략)
  const WithdrawalRequestPage({super.key, this.embedded = false});
  @override
  State<WithdrawalRequestPage> createState() => _WithdrawalRequestPageState();
}

class _WithdrawalRequestPageState extends State<WithdrawalRequestPage> {

  final Map<String, Map<String, dynamic>> _cache       = {};
  final Map<String, bool>                 _cardExp     = {};
  // 3단계: 날짜별 펼치기
  final Map<String, Map<String, bool>>    _dateItemExp = {};
  bool _cacheReady = false;

  Future<void> _prefetch(List<QueryDocumentSnapshot> docs) async {
    final uids = docs
        .map((d) => (d.data() as Map<String, dynamic>)['uid'] as String?)
        .whereType<String>().toSet()
        .where((uid) => !_cache.containsKey(uid)).toList();
    if (uids.isEmpty) { if (mounted) setState(() => _cacheReady = true); return; }
    await Future.wait(uids.map((uid) async {
      try {
        final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (snap.exists) _cache[uid] = snap.data()!;
      } catch (_) {}
    }));
    if (mounted) setState(() => _cacheReady = true);
  }

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

  void _showDone(String msg) {
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _teal, width: 1)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(msg, style: const TextStyle(color: _teal, fontSize: 15, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: GlassShineButton(
            label: "확인",
            onPressed: () => Navigator.pop(ctx),
            accent: _teal,
            pill: true,
            height: 46,
            fontSize: 14,
          )),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final body = StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('withdrawal_requests')
            .where('status', isEqualTo: '요청대기')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: _teal));
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("출금 요청이 없습니다.", style: TextStyle(color: _text2, fontSize: 14)));
          if (!_cacheReady) { _prefetch(docs); return const Center(child: CircularProgressIndicator(color: _teal)); }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(15, _wrTabToCardGap, 15, 15),
            itemCount: docs.length,
            itemBuilder: (_, i) => _card(docs[i]),
          );
        },
      );
    return widget.embedded ? body : adminPanelScaffold(context, "출금 신청", body);
  }

  // 3단계: items 배열 기반 카드 (하위 호환 유지)
  Widget _card(QueryDocumentSnapshot doc) {
    final data      = doc.data() as Map<String, dynamic>;
    final docId     = doc.id;
    final fixedData = Map<String, dynamic>.from(data);
    final fixedUid  = data['uid'] as String?;
    final cardExp   = _cardExp[docId] ?? false;

    // 신규: items 배열
    final items = (data['items'] as List<dynamic>?)
        ?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    final hasItems        = items.isNotEmpty;
    final totalAmount     = (data['amount'] as num?)?.toDouble() ?? 0;
    final leaseDeduction  = (data['leaseDeduction'] as num?)?.toDouble() ?? 0;
    final etcDeduction    = (data['etcDeduction'] as num?)?.toDouble() ?? 0;
    final riderName       = data['riderName'] as String? ?? '';

    // 날짜 범위 라벨
    String dateLabel;
    if (hasItems) {
      final first = (items.first['date'] as String? ?? '');
      final last  = (items.last['date']  as String? ?? '');
      final fs = first.length >= 10 ? first.substring(5) : first;
      final ls = last.length  >= 10 ? last.substring(5)  : last;
      dateLabel = items.length == 1 ? fs : "$fs ~ $ls";
    } else {
      final d = data['date'] as String? ?? '';
      dateLabel = d.length >= 10 ? d.substring(5) : d;
    }

    final cached  = fixedUid != null ? _cache[fixedUid] : null;
    final bank    = cached?['bankName']      as String? ?? '';
    final account = cached?['accountNumber'] as String? ?? '';

    _dateItemExp.putIfAbsent(docId, () => {});

    return Container(
      margin: const EdgeInsets.only(bottom: _wrCardGap),
      decoration: BoxDecoration(
          color: _wrCardBg,
          borderRadius: BorderRadius.circular(_wrCardRadius),
          border: Border.all(color: _wrCardBorder, width: _wrCardBorderWidth),
          boxShadow: _cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── 카드 헤더 ──
        GestureDetector(
          onTap: () => setState(() => _cardExp[docId] = !cardExp),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: _wrHeadPadH, vertical: _wrHeadPadV),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                RichText(text: TextSpan(style: const TextStyle(fontWeight: FontWeight.w700), children: [
                  TextSpan(text: riderName, style: const TextStyle(color: _wrNameColor, fontSize: _wrNameFontSize)),
                  const TextSpan(text: " 님의 출금 신청!!", style: TextStyle(color: _wrTitleColor, fontSize: _wrTitleFontSize)),
                ])),
                const SizedBox(height: _wrGapNameDate),
                Text(dateLabel, style: const TextStyle(color: _wrDateColor, fontSize: _wrDateFontSize)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text("${NumberFormat('#,###').format(totalAmount)} 원",
                    style: const TextStyle(color: _wrAmtColor, fontWeight: FontWeight.w700, fontSize: _wrAmtFontSize)),
                if (hasItems)
                  Text("${items.length}일 합산", style: const TextStyle(color: _wrDaysColor, fontSize: _wrDaysFontSize)),
              ]),
              const SizedBox(width: _wrGapAmtChevron),
              Icon(cardExp ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: cardExp ? _text2 : _teal, size: _wrChevronSize),
            ]),
          ),
        ),

        // ── 펼침 내용 ──
        if (cardExp) ...[
          Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(horizontal: 12)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // 계좌 정보 (은행명=텍스트 / 계좌번호=블랙 박스)
              if (bank.isNotEmpty || account.isNotEmpty) ...[
                Row(children: [
                  Text(bank, style: const TextStyle(color: _wrBankColor, fontSize: _wrBankFontSize)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: _wrValBoxPadH, vertical: _wrValBoxPadV),
                    decoration: BoxDecoration(
                        color: _wrValBoxBg,
                        borderRadius: BorderRadius.circular(_wrValBoxRadius),
                        border: Border.all(color: _wrValBoxBorder)),
                    child: Text(account,
                        style: const TextStyle(
                            color: _wrAcctNumColor, fontSize: _wrAcctNumFontSize)),
                  ),
                  const SizedBox(width: 6),
                  _copyBtn(() => Clipboard.setData(ClipboardData(
                      text: account.replaceAll('-', '').replaceAll(' ', '')))),
                ]),
                const SizedBox(height: _wrGapAcctFinal),
              ],

              // 최종출금금액 (숫자=블랙 박스) + 복사
              Row(children: [
                const Text("최종출금금액", style: TextStyle(color: _wrFinalLabelColor, fontSize: _wrFinalLabelFontSize)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: _wrValBoxPadH, vertical: _wrValBoxPadV),
                  decoration: BoxDecoration(
                      color: _wrValBoxBg,
                      borderRadius: BorderRadius.circular(_wrValBoxRadius),
                      border: Border.all(color: _wrValBoxBorder)),
                  child: Text("${_fmtC(totalAmount)} 원",
                      style: const TextStyle(
                          color: _wrFinalAmtColor,
                          fontWeight: FontWeight.w700,
                          fontSize: _wrFinalAmtFontSize)),
                ),
                const SizedBox(width: 8),
                _copyBtn(() => Clipboard.setData(ClipboardData(
                    text: totalAmount.toInt().toString()))),
              ]),

              // 날짜별 상세 (items 있을 때)
              if (hasItems) ...[
                const SizedBox(height: _wrGapFinalItems),
                ...List.generate(items.length, (i) {
                  final item    = items[i];
                  final iDate   = item['date'] as String? ?? '';
                  final iShort  = iDate.length >= 10 ? iDate.substring(5) : iDate;
                  final iFinal  = (item['finalAmount']    as num?)?.toDouble() ?? 0;
                  final iDel    = (item['deliveryFee']    as num?)?.toDouble() ?? 0;
                  final iPromo  = (item['promoTotal']     as num?)?.toDouble() ?? 0;
                  final iTax    = (item['tax']            as num?)?.toDouble() ?? 0;
                  final iComm   = (item['commissionAmt']  as num?)?.toDouble() ?? 0;
                  final iWd     = (item['withdrawalFee']  as num?)?.toDouble() ?? 0;
                  final iPOrder = (item['perOrderAmount'] as num?)?.toDouble() ?? 0;
                  final iRange  = (item['rangeAmount']    as num?)?.toDouble() ?? 0;
                  // 프로모 건수 라벨 (평일=당일건수 / 화요일=당일·주간누적)
                  final iPmApplied = item['promoApplied'] == true;
                  final iPmDaily   = (item['deliveryCount'] as num?)?.toInt() ?? 0;
                  final iPmWeekly  = (item['promoCount']    as num?)?.toInt() ?? iPmDaily;
                  final iPmCnt = iPmApplied ? "당일$iPmDaily·주간$iPmWeekly건" : "$iPmDaily건";
                  final iETax   = (item['employmentTax']  as num?)?.toDouble() ?? 0;
                  final iATax   = (item['accidentTax']    as num?)?.toDouble() ?? 0;
                  final iITax   = (item['incomeTax']      as num?)?.toDouble() ?? 0;
                  final iIns    = (item['insuranceFee']   as num?)?.toDouble() ?? 0;
                  final iLease  = items.isNotEmpty ? leaseDeduction / items.length : 0.0;
                  final iEtc    = items.isNotEmpty ? etcDeduction / items.length : 0.0;
                  final iFee    = iWd + iComm;
                  final iDedu   = iIns + iLease + iEtc;
                  final iExp    = _dateItemExp[docId]?[iDate] ?? false;

                  bool tog(String k) => _dateItemExp[docId]?[k] ?? false;
                  void togSet(String k) => setState(() =>
                      _dateItemExp[docId]![k] = !(_dateItemExp[docId]![k] ?? false));

                  Widget subGroup(List<Widget> ch) => Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                    decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: _elevated)),
                    child: Column(children: ch),
                  );

                  Widget subRow(String label, String val, {Color lc = _wrDtSubColor, Color vc = _wrDtSubColor}) =>
                      Padding(padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(label, style: TextStyle(color: lc, fontSize: _wrDtSubFontSize)),
                          Text(val,   style: TextStyle(color: vc, fontSize: _wrDtSubFontSize)),
                        ]));

                  Widget togRow(String label, double v, Color vc, String k) =>
                      GestureDetector(
                        onTap: () => togSet(k),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(children: [
                            Text(label, style: const TextStyle(color: _wrDtTogLabelColor, fontSize: _wrDtTogFontSize, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 4),
                            Icon(tog(k) ? Icons.expand_less : Icons.expand_more, color: tog(k) ? _text2 : _teal, size: _wrDtTogIconSize),
                            const Spacer(),
                            Text.rich(TextSpan(children: [
                              TextSpan(text: _fmtC(v), style: TextStyle(color: vc, fontSize: _wrDtTogFontSize)),
                              const TextSpan(text: ' 원', style: TextStyle(color: _text, fontSize: _wrDtTogFontSize)),
                            ])),
                          ]),
                        ),
                      );

                  return Container(
                    margin: const EdgeInsets.only(bottom: _wrItemGap),
                    decoration: BoxDecoration(
                      color: _surface, borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: iExp ? _teal : _elevated),
                    ),
                    child: Column(children: [
                      GestureDetector(
                        onTap: () => setState(() => _dateItemExp[docId]![iDate] = !iExp),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(5), border: Border.all(color: _elevated)),
                              child: Text(iShort, style: const TextStyle(color: _wrItemChipColor, fontSize: _wrItemChipFontSize, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 4),
                            Icon(iExp ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: iExp ? _text2 : _teal, size: _wrItemChevronSize),
                          ]),
                        ),
                      ),
                      if (iExp) ...[
                        Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(horizontal: 10)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const Text("배달수수료 (세전)", style: TextStyle(color: _wrDtMainColor, fontSize: _wrDtMainFontSize, fontWeight: FontWeight.w500)),
                                Text("${_fmtC(iDel)} 원", style: const TextStyle(color: _wrDtMainColor, fontSize: _wrDtMainFontSize)),
                              ]),
                            ),
                            togRow("지원금합계", iPromo, _text, '${iDate}_promo'),
                            if (tog('${iDate}_promo')) subGroup([
                              subRow("건당프로모션 ($iPmCnt)", "${_fmtC(iPOrder)} 원"),
                              subRow("구간프로모션 ($iPmCnt)", "${_fmtC(iRange)} 원"),
                            ]),
                            togRow("세금합계", iTax, _pink, '${iDate}_tax'),
                            if (tog('${iDate}_tax')) subGroup([
                              subRow("고용보험", "${_fmtC(iETax)} 원", vc: _text2),
                              subRow("산재보험", "${_fmtC(iATax)} 원", vc: _text2),
                              subRow("원천세",   "${_fmtC(iITax)} 원", vc: _text2),
                            ]),
                            togRow("수수료합계", iFee, _pink, '${iDate}_comm'),
                            if (tog('${iDate}_comm')) subGroup([
                              subRow("출금수수료",   "${_fmtC(iWd)} 원",   vc: _text2),
                              subRow("협력사수수료", "${_fmtC(iComm)} 원", vc: _text2),
                            ]),
                            togRow("공제합계", iDedu, _pink, '${iDate}_dedu'),
                            if (tog('${iDate}_dedu')) subGroup([
                              subRow("시간제보험", "${_fmtC(iIns)} 원",   vc: _text2),
                              subRow("리스비",     "${_fmtC(iLease)} 원", vc: _text2),
                              subRow("기타",       "${_fmtC(iEtc)} 원",   vc: _text2),
                            ]),
                            Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                const Text("소계", style: TextStyle(color: _wrDtSubtotalColor, fontSize: _wrDtSubtotalLabelFontSize, fontWeight: FontWeight.w700)),
                                Text("${_fmtC(iFinal - iDedu)} 원", style: const TextStyle(color: _wrDtSubtotalColor, fontSize: _wrDtSubtotalValueFontSize, fontWeight: FontWeight.w700)),
                              ]),
                            ),
                          ]),
                        ),
                      ],
                    ]),
                  );
                }),
              ]

              // 구형 호환: items 없으면 message 파싱
              else ...[
                _divider(),
                () {
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
                  final etcDailyAmt   = _rx(msg, '기타\\(일\\)').abs();
                  final commAmt      = _rxComm(msg);
                  final deductTotal  = insuranceFee + withdrawFee + leaseDailyAmt + etcDailyAmt;
                  final finalWd      = _rx(msg, '최종출금금액').abs();
                  final oldTaxExp    = _dateItemExp[docId]?['_tax']   ?? false;
                  final oldPromoExp  = _dateItemExp[docId]?['_promo'] ?? false;
                  final oldDeduExp   = _dateItemExp[docId]?['_dedu']  ?? false;
                  return Column(children: [
                    _row("배달수수료 (세전)", "${_fmtC(deliveryFee)} 원"),
                    _divider(),
                    _toggle("지원금", "${_fmtC(promoTotal)} 원", _text, oldPromoExp,
                        () => setState(() => _dateItemExp[docId]!['_promo'] = !oldPromoExp), [
                      _sub("미션금", "${_fmtC(missionFee)} 원"),
                      _sub("건당프로모션", "${_fmtC(perOrderAmt)} 원"),
                      _sub("구간프로모션", "${_fmtC(rangeAmt)} 원"),
                    ]),
                    _divider(),
                    _toggle("세금", "${_fmtC(tTax)} 원", _pink, oldTaxExp,
                        () => setState(() => _dateItemExp[docId]!['_tax'] = !oldTaxExp), [
                      _sub("고용보험", "${_fmtC(eTax)} 원"),
                      _sub("산재보험", "${_fmtC(aTax)} 원"),
                      _sub("원천세",   "${_fmtC(iTax)} 원"),
                    ]),
                    _divider(),
                    _row("협력사수수료", "${_fmtC(commAmt)} 원", vc: _pink),
                    _divider(),
                    _toggle("공제", "${_fmtC(deductTotal)} 원", _pink, oldDeduExp,
                        () => setState(() => _dateItemExp[docId]!['_dedu'] = !oldDeduExp), [
                      _sub("시간제보험", "${_fmtC(insuranceFee)} 원"),
                      _sub("출금수수료", "${_fmtC(withdrawFee)} 원"),
                      _sub("리스비(일)", "${_fmtC(leaseDailyAmt)} 원"),
                      _sub("기타(일)",   "${_fmtC(etcDailyAmt)} 원"),
                    ]),
                    Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(vertical: 8)),
                    _row("최종출금금액", "${_fmtC(finalWd)} 원", lc: _teal, vc: _teal, bold: true, fs: 14),
                  ]);
                }(),
              ],

              const SizedBox(height: 14),

              // ── 4단계: 입금완료 버튼 (unpaid_balance 삭제 포함) ──
              Center(child: SizedBox(width: 180, height: 44, child: GlassShineButton(
                label: "입 금 완 료",
                accent: _teal,
                height: 44,
                fontSize: 14,
                onPressed: () async {
                  final batch = FirebaseFirestore.instance.batch();
                  batch.update(
                      FirebaseFirestore.instance.collection('withdrawal_requests').doc(docId),
                      {'status': '지급완료'});
                  batch.set(
                      FirebaseFirestore.instance.collection('admin_settlement_logs').doc(), {
                    ...fixedData,
                    'uid':        fixedUid,
                    'status':     '지급완료',
                    'approvedAt': FieldValue.serverTimestamp(),
                  });
                  await batch.commit();

                  // 4단계: unpaid_balance 초기화
                  if (fixedUid != null) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('unpaid_balance').doc(fixedUid).delete();
                    } catch (e) { debugPrint('unpaid_balance 삭제 실패: $e'); }
                  }

                  // 매일 타입 리스비: 이번 출금에서 실제 공제된 리스비 금액 ÷ 1일치 = 완납할 일수
                  if (fixedUid != null) {
                    try {
                      final uLease = await FirebaseFirestore.instance
                          .collection('users').doc(fixedUid).get();
                      final bool isDailyLease =
                          (uLease.data()?['leaseType'] as String?) == 'daily';
                      final double dailyAmt =
                          (uLease.data()?['leaseAmount'] as num?)?.toDouble() ?? 0;
                      final int payDays = (isDailyLease && dailyAmt > 0)
                          ? (leaseDeduction / dailyAmt).round()
                          : 0;
                      if (payDays > 0) {
                        final leaseSnap = await FirebaseFirestore.instance
                            .collection('lease_payments')
                            .where('uid',       isEqualTo: fixedUid)
                            .where('leaseType', isEqualTo: 'daily')
                            .where('isPaid',    isEqualTo: false)
                            .get();
                        if (leaseSnap.docs.isNotEmpty) {
                          // 회차(cycle) 오름차순으로 앞에서부터 payDays개 완납 처리
                          final docs = leaseSnap.docs.toList()
                            ..sort((a, b) =>
                                ((a.data()['cycle'] as num?) ?? 0)
                                    .compareTo((b.data()['cycle'] as num?) ?? 0));
                          final lBatch = FirebaseFirestore.instance.batch();
                          for (final ld in docs.take(payDays)) {
                            lBatch.update(ld.reference, {
                              'isPaid': true,
                              'paidAt': FieldValue.serverTimestamp(),
                              'seenByRider': false,
                            });
                          }
                          await lBatch.commit();
                          // 기사 하단바 리스비 배지 자동 활성화
                          await FirebaseFirestore.instance
                              .collection('users').doc(fixedUid)
                              .update({'leaseNewAlert': true});
                        }
                      }
                    } catch (e) { debugPrint('매일 리스비 완납 처리 실패: $e'); }
                  }

                  // 매일 타입 기타: 이번 출금에서 실제 공제된 기타 금액 ÷ 1일치 = 완납할 일수
                  if (fixedUid != null) {
                    try {
                      final uEtc = await FirebaseFirestore.instance
                          .collection('users').doc(fixedUid).get();
                      final bool isDailyEtc =
                          (uEtc.data()?['etcType'] as String?) == 'daily';
                      final double dailyEtc =
                          (uEtc.data()?['etcAmount'] as num?)?.toDouble() ?? 0;
                      final int payDaysEtc = (isDailyEtc && dailyEtc > 0)
                          ? (etcDeduction / dailyEtc).round()
                          : 0;
                      if (payDaysEtc > 0) {
                        final etcSnap = await FirebaseFirestore.instance
                            .collection('etc_payments')
                            .where('uid',     isEqualTo: fixedUid)
                            .where('etcType', isEqualTo: 'daily')
                            .where('isPaid',  isEqualTo: false)
                            .get();
                        if (etcSnap.docs.isNotEmpty) {
                          final docs = etcSnap.docs.toList()
                            ..sort((a, b) =>
                                ((a.data()['cycle'] as num?) ?? 0)
                                    .compareTo((b.data()['cycle'] as num?) ?? 0));
                          final eBatch = FirebaseFirestore.instance.batch();
                          for (final ed in docs.take(payDaysEtc)) {
                            eBatch.update(ed.reference, {
                              'isPaid': true,
                              'paidAt': FieldValue.serverTimestamp(),
                              'seenByRider': false,
                            });
                          }
                          await eBatch.commit();
                          await FirebaseFirestore.instance
                              .collection('users').doc(fixedUid)
                              .update({'etcNewAlert': true});
                        }
                      }
                    } catch (e) { debugPrint('매일 기타 완납 처리 실패: $e'); }
                  }

                  if (mounted) _showDone("입금 처리 완료");
                },
              ))),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _copyBtn(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: _wrCopyBorder, width: _wrCopyBorderWidth), borderRadius: BorderRadius.circular(6)),
      child: const Text("복사", style: TextStyle(color: _teal, fontSize: 11)),
    ),
  );

  Widget _divider() => Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(vertical: 5));

  Widget _row(String label, String value, {Color lc = _text2, Color vc = _text2, bool bold = false, double fs = 12}) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(color: lc, fontSize: fs, fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value, style: TextStyle(color: vc, fontSize: fs, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ]));

  Widget _sub(String label, String value) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: _text2, fontSize: 11)),
          Text(value, style: const TextStyle(color: _text2, fontSize: 11)),
        ]));

  Widget _toggle(String label, String value, Color vc, bool expanded, VoidCallback onTap, List<Widget> children) =>
      Column(children: [
        GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque,
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              Text(label, style: const TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: expanded ? _text2 : _teal, size: 16),
              const Spacer(),
              Text.rich(TextSpan(children: [
                TextSpan(text: value.endsWith(' 원') ? value.substring(0, value.length - 2) : value,
                    style: TextStyle(color: vc, fontSize: 12, fontWeight: FontWeight.w600)),
                if (value.endsWith(' 원'))
                  const TextSpan(text: ' 원', style: TextStyle(color: _text, fontSize: 12, fontWeight: FontWeight.w600)),
              ])),
            ]))),
        if (expanded)
          Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _elevated, width: 1)),
              child: Column(children: children)),
      ]);
}
