// 관리자 라이더 관리 — 라이더 목록/검색 + 은행·계좌·리스비 설정 편집
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';
import 'tokens.dart';
import 'admin_common.dart';
import 'glass_shine_button.dart';
import 'admin_rider_history_page.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _surface  = kSurface;
const _elevated = kElevated;
const _text     = kText;
const _text2    = kText2;
const _teal     = kTeal;
const _pink     = kPink;
const _amber    = kAmber;
const List<BoxShadow> _cardShadow = kCardShadow;

const double _rmTabToCardGap = 2; // 라이더 탭 ↔ 이름목록 카드 갭

// ═══════════════ 라이더 관리 카드 상수(_rm*) ═══════════════
// ── [8-1] 라이더탭 — 목록 카드 + 행 헤더 ──
const _rmCardBg     = _surface;    // 목록 카드 배경색
const _rmCardBorder = _elevated;     // 목록 카드 테두리 색
const double _rmCardBorderWidth = 1; // 목록 카드 테두리 두께
const double _rmCardRadius = 14;   // 목록 카드 모서리
const _rmSearchBg    = _surface;     // 검색창 배경
const _rmSearchHint  = _text2;     // 검색 힌트 색
const double _rmSearchFontSize = 13; // 검색 글씨 크기
const _rmDividerColor = _elevated; // 라이더 행 구분선 색
const _rmAvatarBg     = _surface; // 아바타 배경
const _rmAvatarBorder = _elevated;   // 아바타 테두리
const _rmAvatarText   = _teal;   // 아바타 글씨(이니셜) 색
const double _rmAvatarSize     = 34; // 아바타 크기
const double _rmAvatarFontSize = 14; // 아바타 글씨 크기
const _rmNameColor    = _text;    // 라이더 이름 색
const double _rmNameFontSize = 13; // 라이더 이름 크기
const _rmHistBtnColor = _teal;   // "출금내역" 버튼 글씨·아이콘 색
const _rmHistBtnBorder = _elevated;  // "출금내역" 버튼 테두리
const double _rmHistBtnFontSize = 13; // "출금내역" 버튼 글씨 크기
const _rmCallColor    = _pink;    // 전화 아이콘 색
const _rmSmsColor     = _amber;    // 문자 아이콘 색
// 라이더 카드 펼침 내용 (계좌·ID·리스비 폼)
const _rmFieldTextColor   = _text2; // 은행·계좌·ID 입력 글씨 색
const double _rmFieldFontSize = 13; // 은행·계좌·ID 입력 글씨 크기
const double _rmEditBtnFontSize = 12; // 수정/저장 버튼 글씨 크기
const double _rmGapRow      = 8;    // 폼 행 사이 갭(기본)
const double _rmGapRowSmall = 6;    // 폼 행 사이 갭(좁게)
const double _rmGapToLease  = 10;   // ID행 ↔ 리스비 섹션 갭
const _rmLeaseTitleColor    = _teal; // "리스비" 라벨 색
const double _rmLeaseTitleFontSize = 11; // "리스비" 라벨 크기
const _rmLeaseSmallBtnColor = _pink; // 초기화 등 작은 버튼 글씨 색
const double _rmLeaseBtnFontSize = 10;  // 리스비 작은 버튼·칩 글씨 크기
const double _rmLeaseInputFontSize = 11;// 리스비 입력칸 글씨 크기
const double _rmLeaseHintFontSize  = 10;// 리스비 입력 힌트 크기
const _rmLeaseUnitColor     = _text2; // 단위(일/회차/원) 색
const double _rmLeaseUnitFontSize = 10; // 단위 글씨 크기
const double _rmLeasePaidFontSize = 11; // 납부이력 글씨 크기

// ═══════════════ 라이더 관리 페이지 (로직) ═══════════════
class RiderManagePage extends StatefulWidget {
  final bool embedded;
  const RiderManagePage({super.key, this.embedded = false});
  @override
  State<RiderManagePage> createState() => _RiderManagePageState();
}

class _RiderManagePageState extends State<RiderManagePage> {

  Map<String, bool> riderIdEditMode      = {};
  Map<String, bool> riderAccountEditMode = {};
  Map<String, bool> riderLeaseEditMode   = {};

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final Map<String, TextEditingController> _bankCtrlCache        = {};
  final Map<String, TextEditingController> _accountCtrlCache     = {};
  final Map<String, TextEditingController> _leaseCycleCtrlCache  = {};
  final Map<String, TextEditingController> _leaseAmountCtrlCache = {};
  final Map<String, String>                _leaseTypeCache       = {};
  final Map<String, DateTime?>             _leaseStartCache      = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    for (final c in _bankCtrlCache.values)        { c.dispose(); }
    for (final c in _accountCtrlCache.values)     { c.dispose(); }
    for (final c in _leaseCycleCtrlCache.values)  { c.dispose(); }
    for (final c in _leaseAmountCtrlCache.values) { c.dispose(); }
    super.dispose();
  }

  DateTime _calcMonthlyDate(DateTime from, int monthsToAdd, int day) {
    final totalMonths = (from.year * 12 + from.month - 1) + monthsToAdd;
    final year  = totalMonths ~/ 12;
    final month = (totalMonths % 12) + 1;
    final maxDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day.clamp(1, maxDay));
  }

  Future<void> _saveReportId(String uid, String id) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({'reportId': id});
    setState(() => riderIdEditMode[uid] = false);
    _showDialog("ID 저장완료!!");
  }

  Future<void> _saveAccountInfo(String uid, String bank, String account) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'bankName': bank.trim(), 'accountNumber': account.trim(),
    });
    setState(() => riderAccountEditMode[uid] = false);
    _showDialog("계좌정보 저장완료!!");
  }

  Future<void> _saveLease(String uid) async {
    final type      = _leaseTypeCache[uid] ?? 'weekly';
    final cycle     = int.tryParse((_leaseCycleCtrlCache[uid]?.text ?? '').replaceAll(',', '')) ?? 0;
    final amount    = double.tryParse((_leaseAmountCtrlCache[uid]?.text ?? '').replaceAll(',', ''))?.truncateToDouble() ?? 0;
    final startDate = _leaseStartCache[uid];
    final leaseDay  = startDate?.day ?? 1;

    if (startDate == null || amount <= 0) { _showDialog("시작일과 금액을 입력해주세요."); return; }
    if (cycle <= 0) { _showDialog(type == 'daily' ? "총 일수를 입력해주세요." : "회차를 입력해주세요."); return; }

    DateTime lastDate;
    if (type == 'daily') {
      lastDate = startDate.add(Duration(days: cycle));
    } else if (type == 'weekly') {
      lastDate = startDate.add(Duration(days: 7 * (cycle - 1)));
    } else {
      lastDate = _calcMonthlyDate(startDate, cycle - 1, leaseDay);
    }

    final updateData = <String, dynamic>{
      'leaseType':      type,
      'leaseCycle':     cycle,
      'leaseStartDate': DateFormat('yyyy-MM-dd').format(startDate),
      'leaseLastDate':  DateFormat('yyyy-MM-dd').format(lastDate),
      'leaseAmount':    amount.toInt(),
      'leaseNewAlert':  false,
    };
    await FirebaseFirestore.instance.collection('users').doc(uid).update(updateData);

    String riderName = '';
    try { final u = await FirebaseFirestore.instance.collection('users').doc(uid).get(); riderName = u.data()?['name'] as String? ?? ''; } catch (_) {}

    final oldSnap = await FirebaseFirestore.instance.collection('lease_payments').where('uid', isEqualTo: uid).get();
    final delBatch = FirebaseFirestore.instance.batch();
    for (final doc in oldSnap.docs) { delBatch.delete(doc.reference); }
    await delBatch.commit();

    // 매일 타입도 일별 납기일 생성 (미출금 추적용)
    final createBatch = FirebaseFirestore.instance.batch();
    for (int n = 0; n < cycle; n++) {
      final DateTime dueDate;
      if (type == 'daily') {
        dueDate = startDate.add(Duration(days: n));
      } else if (type == 'weekly') {
        dueDate = startDate.add(Duration(days: 7 * n));
      } else {
        dueDate = _calcMonthlyDate(startDate, n, leaseDay);
      }
      createBatch.set(FirebaseFirestore.instance.collection('lease_payments').doc(), {
        'uid': uid, 'riderName': riderName, 'cycle': n + 1, 'totalCycle': cycle,
        'dueDate': DateFormat('yyyy-MM-dd').format(dueDate),
        'amount': amount.toInt(), 'isPaid': false, 'paidAt': null,
        'leaseType': type, // 타입 저장
      });
    }
    await createBatch.commit();

    _leaseAmountCtrlCache[uid]?.text = NumberFormat('#,###').format(amount.toInt());
    setState(() => riderLeaseEditMode[uid] = false);
    _showDialog("리스비 저장완료!!\n총 $cycle회차 납기일이 생성되었습니다.");
  }

  Future<void> _resetLease(String uid) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _elevated, width: 1)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("초기화 확인", style: TextStyle(color: _teal, fontSize: 15, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          const Text("리스비 설정을 초기화하면\n모든 납기일이 삭제됩니다.", style: TextStyle(color: _text2, fontSize: 13, height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: GlassShineButton(
              label: "취소",
              onPressed: () => Navigator.pop(ctx, false),
              accent: _text2,
              textColor: _text2,
              pill: true,
              height: 46,
              fontSize: 14,
            )),
            const SizedBox(width: 10),
            Expanded(child: GlassShineButton(
              label: "초기화",
              onPressed: () => Navigator.pop(ctx, true),
              accent: _pink,
              textColor: _pink,
              pill: true,
              height: 46,
              fontSize: 14,
            )),
          ]),
        ]),
      ),
    ));
    if (confirm != true) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'leaseType': FieldValue.delete(), 'leaseCycle': FieldValue.delete(),
        'leaseStartDate': FieldValue.delete(), 'leaseLastDate': FieldValue.delete(),
        'leaseAmount': FieldValue.delete(), 'leaseNewAlert': FieldValue.delete(),
      });
      final snap = await FirebaseFirestore.instance.collection('lease_payments').where('uid', isEqualTo: uid).get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in snap.docs) { batch.delete(doc.reference); }
      await batch.commit();
      _leaseCycleCtrlCache[uid]?.text  = '';
      _leaseAmountCtrlCache[uid]?.text = '';
      _leaseTypeCache[uid]             = 'weekly';
      _leaseStartCache[uid]            = null;
      setState(() => riderLeaseEditMode[uid] = false);
      _showDialog("리스비 초기화 완료!");
    } catch (_) { _showDialog("초기화 실패. 다시 시도해주세요."); }
  }

  Future<void> _call(String phone) async { final u = Uri.parse('tel:$phone'); if (await canLaunchUrl(u)) await launchUrl(u); }
  Future<void> _sms(String phone)  async { final u = Uri.parse('sms:$phone'); if (await canLaunchUrl(u)) await launchUrl(u); }

  void _showDialog(String title) {
    showDialog(context: context, builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _elevated, width: 1)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: const TextStyle(color: _teal, fontSize: 15, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
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

  void _showBankPicker(String uid, TextEditingController bankCtrl) {
    const bankList = ['신한은행','국민은행','하나은행','우리은행','농협은행','기업은행','카카오뱅크','토스뱅크','케이뱅크','새마을금고','신협','우체국','씨티은행','SC제일은행','부산은행','대구은행','광주은행','전북은행','경남은행','제주은행'];
    showModalBottomSheet(context: context, backgroundColor: _surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 36, height: 4, decoration: BoxDecoration(color: _text2, borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text("은행 선택", style: TextStyle(color: _teal, fontSize: 14, fontWeight: FontWeight.w700))),
        Container(height: 1, color: _elevated),
        Flexible(child: ListView.builder(shrinkWrap: true, itemCount: bankList.length,
          itemBuilder: (ctx, i) => ListTile(dense: true,
            title: Text(bankList[i], style: const TextStyle(color: _text, fontSize: 13)),
            trailing: bankCtrl.text == bankList[i] ? const Icon(Icons.check_rounded, color: _teal, size: 16) : null,
            onTap: () { setState(() => bankCtrl.text = bankList[i]); Navigator.pop(ctx); }),
        )),
      ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.embedded
        ? _riderList()
        : adminPanelScaffold(context, "라이더 관리", _riderList());
  }

  Widget _riderList() => StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'driver').where('isApproved', isEqualTo: true).orderBy('name').snapshots(),
    builder: (_, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: _teal));
      final allDocs = snap.data!.docs;
      if (allDocs.isEmpty) return const Center(child: Text("등록된 라이더가 없습니다.", style: TextStyle(color: _text2)));
      final filtered = _searchQuery.isEmpty ? allDocs : allDocs.where((d) {
        final name = (d.data() as Map<String, dynamic>)['name']?.toString() ?? '';
        return name.contains(_searchQuery);
      }).toList();
      return Container(
        margin: const EdgeInsets.fromLTRB(15, _rmTabToCardGap, 15, 15),
        decoration: BoxDecoration(
            color: _rmCardBg,
            borderRadius: BorderRadius.circular(_rmCardRadius),
            border: Border.all(color: _rmCardBorder, width: _rmCardBorderWidth),
            boxShadow: _cardShadow),
        child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(12, 10, 12, 8), child: TextField(
            controller: _searchCtrl, onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(color: _text, fontSize: _rmSearchFontSize), cursorColor: _teal,
            decoration: InputDecoration(
              hintText: "이름 검색...", hintStyle: const TextStyle(color: _rmSearchHint, fontSize: _rmSearchFontSize),
              prefixIcon: const Icon(Icons.search_rounded, color: _text2, size: 18),
              suffixIcon: _searchQuery.isNotEmpty ? GestureDetector(
                onTap: () => setState(() { _searchCtrl.clear(); _searchQuery = ''; }),
                child: const Icon(Icons.close_rounded, color: _text2, size: 16)) : null,
              filled: true, fillColor: _rmSearchBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: BorderSide(color: _teal)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: _teal, width: 1)),
            ),
          )),
          filtered.isEmpty
              ? const Padding(padding: EdgeInsets.all(20), child: Text("검색 결과가 없습니다.", style: TextStyle(color: _text2, fontSize: 13)))
              : Expanded(child: ListView.separated(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Container(margin: const EdgeInsets.symmetric(horizontal: 14), height: 1, color: _rmDividerColor),
                  itemBuilder: (_, i) => _riderCard(filtered[i]))),
        ]),
      );
    },
  );

  Widget _riderCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final uid  = doc.id;
    final isEditingId      = riderIdEditMode[uid]      ?? false;
    final isEditingAccount = riderAccountEditMode[uid] ?? false;
    final isEditingLease   = riderLeaseEditMode[uid]   ?? false;
    final idCtrl = TextEditingController(text: data['reportId'] ?? "");
    _bankCtrlCache.putIfAbsent(uid, () => TextEditingController(text: data['bankName'] ?? ""));
    _accountCtrlCache.putIfAbsent(uid, () => TextEditingController(text: data['accountNumber'] ?? ""));
    final bankCtrl    = _bankCtrlCache[uid]!;
    final accountCtrl = _accountCtrlCache[uid]!;
    _leaseCycleCtrlCache.putIfAbsent(uid, () => TextEditingController(text: data['leaseCycle']?.toString() ?? ''));
    _leaseAmountCtrlCache.putIfAbsent(uid, () {
      final amt = data['leaseAmount'];
      if (amt == null) return TextEditingController(text: '');
      final intAmt = (amt is num) ? amt.toInt() : int.tryParse(amt.toString()) ?? 0;
      return TextEditingController(text: intAmt > 0 ? NumberFormat('#,###').format(intAmt) : '');
    });
    _leaseTypeCache.putIfAbsent(uid, () { final t = data['leaseType'] as String? ?? 'weekly'; return t == 'monthly' ? 'monthly_fixed' : t; });
    if (!_leaseStartCache.containsKey(uid)) { final s = data['leaseStartDate'] as String?; _leaseStartCache[uid] = s != null ? DateTime.tryParse(s) : null; }
    final cycleCtrl  = _leaseCycleCtrlCache[uid]!;
    final amountCtrl = _leaseAmountCtrlCache[uid]!;
    final leaseType  = _leaseTypeCache[uid] ?? 'weekly';
    final startDate  = _leaseStartCache[uid];
    final cycle      = int.tryParse(cycleCtrl.text) ?? 0;
    final amountRaw  = double.tryParse(amountCtrl.text.replaceAll(',', '')) ?? 0;
    DateTime? lastDate;
    if (startDate != null && cycle > 0) {
      if (leaseType == 'daily') { lastDate = startDate.add(Duration(days: cycle)); }
      else if (leaseType == 'weekly') { lastDate = startDate.add(Duration(days: 7 * (cycle - 1))); }
      else { lastDate = _calcMonthlyDate(startDate, cycle - 1, startDate.day); }
    }
    final totalAmount = amountRaw * cycle;
    final nameStr = data['name'] as String? ?? '?';
    final initial = nameStr.isNotEmpty ? nameStr.substring(0, 1) : '?';

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(14, 4, 14, 4), childrenPadding: EdgeInsets.zero, clipBehavior: Clip.none,
        iconColor: _teal, collapsedIconColor: _text2,
        leading: Container(width: _rmAvatarSize, height: _rmAvatarSize,
            decoration: BoxDecoration(color: _rmAvatarBg, border: Border.all(color: _rmAvatarBorder), borderRadius: BorderRadius.circular(9)),
            child: Center(child: Text(initial, style: const TextStyle(color: _rmAvatarText, fontSize: _rmAvatarFontSize, fontWeight: FontWeight.w700)))),
        title: Row(children: [
          Flexible(child: Text(data['name'] ?? "", overflow: TextOverflow.ellipsis, style: const TextStyle(color: _rmNameColor, fontWeight: FontWeight.w700, fontSize: _rmNameFontSize))),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RiderHistoryPage(name: data['name'] ?? "라이더", uid: uid))),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(border: Border.all(color: _rmHistBtnBorder), borderRadius: BorderRadius.circular(6)),
                child: const Text("출금내역", style: TextStyle(color: _rmHistBtnColor, fontSize: _rmHistBtnFontSize, fontWeight: FontWeight.w700)),
          ),
          ),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          GestureDetector(onTap: () => _call(data['phone'] ?? ""), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: _rmCallColor.withAlpha(20), border: Border.all(color: _rmCallColor), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.wifi_calling_3, color: _rmCallColor, size: 15))),
          const SizedBox(width: 6),
          GestureDetector(onTap: () => _sms(data['phone'] ?? ""),  child: Container(width: 32, height: 32, decoration: BoxDecoration(color: _rmSmsColor.withAlpha(20), border: Border.all(color: _rmSmsColor), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.sms, color: _rmSmsColor, size: 15))),
          const SizedBox(width: 6),
        ]),
        children: [Container(
          color: _surface.withAlpha(200), padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 은행 박스
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: isEditingAccount ? () => _showBankPicker(uid, bankCtrl) : null,
                child: Container(height: 38, padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: isEditingAccount ? _teal : _elevated)),
                  child: Row(children: [
                    Expanded(child: Text(bankCtrl.text.isNotEmpty ? bankCtrl.text : "은행 선택", style: const TextStyle(color: _rmFieldTextColor, fontSize: _rmFieldFontSize), overflow: TextOverflow.ellipsis)),
                    if (isEditingAccount) const Icon(Icons.arrow_drop_down, color: _teal, size: 18),
                  ]),
                ),
              )),
              const SizedBox(width: 8),
              SizedBox(width: 46, height: 38, child: GlassShineButton(
                label: isEditingAccount ? "저장" : "수정",
                onPressed: () { if (isEditingAccount) { _saveAccountInfo(uid, bankCtrl.text, accountCtrl.text); } else { setState(() => riderAccountEditMode[uid] = true); } },
                accent: _teal,
                width: 46,
                height: 38,
                radius: 8,
                fontSize: _rmEditBtnFontSize,
              )),
            ]),
            const SizedBox(height: _rmGapRowSmall),
            // 계좌번호 박스
            SizedBox(height: 38, child: TextField(
              controller: accountCtrl, enabled: isEditingAccount, keyboardType: TextInputType.number,
              style: const TextStyle(color: _rmFieldTextColor, fontSize: _rmFieldFontSize), cursorColor: _teal,
              decoration: InputDecoration(hintText: "계좌번호", hintStyle: const TextStyle(color: _rmFieldTextColor, fontSize: _rmFieldFontSize), filled: true, fillColor: _surface, contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _elevated)),
                enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _teal)),
                focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _teal, width: 1)),
              ),
            )),
            const SizedBox(height: _rmGapRow),
            // User ID
            Row(children: [
              Expanded(child: SizedBox(height: 38, child: TextField(
                controller: idCtrl, enabled: isEditingId,
                style: const TextStyle(color: _rmFieldTextColor, fontSize: _rmFieldFontSize), cursorColor: _teal,
                decoration: InputDecoration(hintText: "User ID", hintStyle: const TextStyle(color: _rmFieldTextColor, fontSize: _rmFieldFontSize), filled: true, fillColor: _surface, contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _elevated)),
                  enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _teal)),
                  focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _teal, width: 1)),
                ),
              ))),
              const SizedBox(width: 8),
              SizedBox(width: 46, height: 38, child: GlassShineButton(
                label: isEditingId ? "저장" : "수정",
                onPressed: () { if (isEditingId) { _saveReportId(uid, idCtrl.text); } else { setState(() => riderIdEditMode[uid] = true); } },
                accent: _teal,
                width: 46,
                height: 38,
                radius: 8,
                fontSize: _rmEditBtnFontSize,
              )),
            ]),
            const SizedBox(height: _rmGapToLease),
            // 리스비 섹션
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: _elevated)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  const Text("리스비", style: TextStyle(color: _rmLeaseTitleColor, fontSize: _rmLeaseTitleFontSize, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () { if (isEditingLease) { _saveLease(uid); } else { setState(() => riderLeaseEditMode[uid] = true); } },
                    child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(color: isEditingLease ? _teal : Colors.transparent, border: Border.all(color: _elevated), borderRadius: BorderRadius.circular(6)),
                      child: Text(isEditingLease ? "저장" : "수정", style: TextStyle(color: isEditingLease ? _surface : _teal, fontSize: _rmLeaseBtnFontSize, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(onTap: () => _resetLease(uid), child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(border: Border.all(color: _elevated), borderRadius: BorderRadius.circular(6)),
                    child: const Text("초기화", style: TextStyle(color: _rmLeaseSmallBtnColor, fontSize: _rmLeaseBtnFontSize)),
                  )),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  _leaseTypeBtn(uid, 'daily',  '매일',  isEditingLease),
                  const SizedBox(width: 4),
                  _leaseTypeBtn(uid, 'weekly', '주1회', isEditingLease),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: isEditingLease ? () => setState(() => _leaseTypeCache[uid] = 'monthly_fixed') : null,
                    child: AnimatedContainer(duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: leaseType == 'monthly_fixed' ? _teal : Colors.transparent, border: Border.all(color: leaseType == 'monthly_fixed' ? _teal : _elevated), borderRadius: BorderRadius.circular(5)),
                      child: Text("매월", style: TextStyle(color: leaseType == 'monthly_fixed' ? _surface : _text2, fontSize: _rmLeaseBtnFontSize, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 34, height: 26, child: TextField(
                    controller: cycleCtrl, enabled: isEditingLease, keyboardType: TextInputType.number, textAlign: TextAlign.center,
                    style: const TextStyle(color: _text, fontSize: _rmLeaseInputFontSize), cursorColor: _teal, onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(isDense: true, hintText: "0", hintStyle: const TextStyle(color: _text2, fontSize: _rmLeaseHintFontSize), filled: true, fillColor: _surface, contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: _teal)),
                      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: _elevated)),
                      focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: _teal))),
                  )),
                  Text(leaseType == 'daily' ? "  일" : "  회차", style: const TextStyle(color: _rmLeaseUnitColor, fontSize: _rmLeaseUnitFontSize)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: isEditingLease ? () async {
                      final p = await showDatePicker(context: context, initialDate: startDate ?? DateTime.now(), firstDate: DateTime(2026), lastDate: DateTime(2030), builder: (ctx, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: _teal)), child: child!));
                      if (p != null) setState(() => _leaseStartCache[uid] = p);
                    } : null,
                    child: Container(height: 32, decoration: BoxDecoration(color: _surface, border: Border.all(color: isEditingLease ? _teal : _elevated), borderRadius: BorderRadius.circular(7)), padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(children: [
                        Icon(Icons.calendar_today_rounded, color: isEditingLease ? _teal : _text2, size: 12), const SizedBox(width: 4),
                        Expanded(child: Text(startDate != null ? DateFormat('yyyy-MM-dd').format(startDate) : "시작일", textAlign: TextAlign.right, style: TextStyle(color: startDate != null ? _text : _text2, fontSize: _rmLeaseInputFontSize))),
                      ]),
                    ),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: Row(children: [
                    Expanded(child: Container(height: 32,
                      decoration: BoxDecoration(color: _surface, border: Border.all(color: isEditingLease ? _teal : _elevated), borderRadius: BorderRadius.circular(7)),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.centerRight,
                      child: TextField(
                        controller: amountCtrl, enabled: isEditingLease, keyboardType: TextInputType.number, textAlign: TextAlign.right,
                        style: const TextStyle(color: _text, fontSize: _rmLeaseInputFontSize), cursorColor: _teal,
                        onChanged: (v) { final raw = v.replaceAll(',', ''); final n = int.tryParse(raw); if (n != null) { final f = NumberFormat('#,###').format(n); if (f != v) amountCtrl.value = TextEditingValue(text: f, selection: TextSelection.collapsed(offset: f.length)); } setState(() {}); },
                        decoration: const InputDecoration(isCollapsed: true, border: InputBorder.none, hintText: "1회차금액", hintStyle: TextStyle(color: _text2, fontSize: _rmLeaseHintFontSize)),
                      ),
                    )),
                    const SizedBox(width: 4), const Text("원", style: TextStyle(color: _rmLeaseUnitColor, fontSize: _rmLeaseUnitFontSize)),
                  ])),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(child: Container(height: 32, decoration: BoxDecoration(color: _surface, border: Border.all(color: _elevated), borderRadius: BorderRadius.circular(7)), padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(children: [const Icon(Icons.event_rounded, color: _text2, size: 12), const SizedBox(width: 4), Expanded(child: Text(lastDate != null ? DateFormat('yyyy-MM-dd').format(lastDate) : "마지막일", textAlign: TextAlign.right, style: const TextStyle(color: _text2, fontSize: _rmLeaseInputFontSize)))]),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: Row(children: [
                    Expanded(child: Container(height: 32, decoration: BoxDecoration(color: _surface, border: Border.all(color: _elevated), borderRadius: BorderRadius.circular(7)), padding: const EdgeInsets.symmetric(horizontal: 8), alignment: Alignment.centerRight,
                      child: Text(totalAmount > 0 ? NumberFormat('#,###').format(totalAmount.truncate()) : "총금액", style: const TextStyle(color: _text2, fontSize: _rmLeaseInputFontSize)),
                    )),
                    const SizedBox(width: 4), const Text("원", style: TextStyle(color: _rmLeaseUnitColor, fontSize: _rmLeaseUnitFontSize)),
                  ])),
                ]),
                if (leaseType != 'daily')
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('lease_payments').where('uid', isEqualTo: uid).where('isPaid', isEqualTo: true).orderBy('cycle', descending: true).limit(1).snapshots(),
                    builder: (_, snap) {
                      if (!snap.hasData || snap.data!.docs.isEmpty) return const SizedBox.shrink();
                      final d = snap.data!.docs.first.data() as Map<String, dynamic>;
                      final pCycle = d['cycle'] as int? ?? 0; final pAmount = d['amount'] as int? ?? 0;
                      final paidAt = (d['paidAt'] as Timestamp?)?.toDate();
                      final dateStr = paidAt != null ? DateFormat('yyyy-MM-dd').format(paidAt) : '';
                      return Column(children: [
                        Container(height: 1, color: _elevated, margin: const EdgeInsets.symmetric(vertical: 6)),
                        Row(children: [
                          Text("$pCycle회차", style: const TextStyle(color: _text2, fontSize: _rmLeasePaidFontSize)), const SizedBox(width: 8),
                          Text(dateStr, style: const TextStyle(color: _text2, fontSize: _rmLeasePaidFontSize)), const Spacer(),
                          Text("${NumberFormat('#,###').format(pAmount)} 원", style: const TextStyle(color: _teal, fontSize: _rmLeasePaidFontSize, fontWeight: FontWeight.w700)),
                        ]),
                      ]);
                    },
                  ),
              ]),
            ),
          ]),
        )],
      ),
    );
  }

  Widget _leaseTypeBtn(String uid, String type, String label, bool isEditing) {
    final selected = (_leaseTypeCache[uid] ?? 'weekly') == type;
    return GestureDetector(
      onTap: isEditing ? () => setState(() => _leaseTypeCache[uid] = type) : null,
      child: AnimatedContainer(duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: selected ? _teal : Colors.transparent, border: Border.all(color: selected ? _teal : _elevated), borderRadius: BorderRadius.circular(5)),
        child: Text(label, style: TextStyle(color: selected ? _surface : _text2, fontSize: _rmLeaseBtnFontSize, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
