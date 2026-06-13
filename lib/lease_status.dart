// 리스비/기타 납부 상태(칩) 판정과 기준일(anchor) 계산 — 카드·하단배지 공용 단일 출처
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;

// 종류별 상태: 'paid'(기사 입금신고) | 'overdue'(미납부) | 'today'(납부일) | null
// 매일=리포트 최신 날짜(anchor) / 주1회·매월=실제 오늘 날짜 기준
String? leaseStatusOf(List<Map<String, dynamic>> ps, String typeField, String anchor) {
  final unpaid = ps.where((p) => p['isPaid'] != true).toList();
  if (unpaid.isEmpty) return null;
  if (unpaid.any((p) => p['riderPaid'] == true)) return 'paid';
  final isDaily = ps.any((p) => (p[typeField] as String?) == 'daily');
  final base = isDaily ? anchor : DateFormat('yyyy-MM-dd').format(DateTime.now());
  if (base.isEmpty) return null;
  String dd(Map p) => p['dueDate'] as String? ?? '';
  if (unpaid.any((p) => dd(p).isNotEmpty && dd(p).compareTo(base) < 0)) return 'overdue';
  if (unpaid.any((p) => dd(p) == base)) return 'today';
  return null;
}

// 기사별 미납 강조 기준일(anchor) = 그 기사의 업로드된 리포트 최신 날짜.
// 출금요청대기 중이면 '' (미납 강조 끔). uid → anchor 맵을 돌려준다.
Future<Map<String, String>> loadLeaseAnchors(Iterable<String> uids) async {
  final result = <String, String>{};
  final list = uids.where((u) => u.isNotEmpty).toSet().toList();
  if (list.isEmpty) return result;
  Set<String> pendingUids = {};
  try {
    final pend = await FirebaseFirestore.instance
        .collection('withdrawal_requests')
        .where('status', isEqualTo: '요청대기')
        .get();
    pendingUids = pend.docs.map((d) => (d.data()['uid'] as String?) ?? '').toSet();
  } catch (_) {}
  await Future.wait(list.map((uid) async {
    if (pendingUids.contains(uid)) {
      result[uid] = '';
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('unpaid_balance')
          .doc(uid)
          .get();
      final items = (doc.data()?['items'] as List?) ?? [];
      var a = '';
      for (final it in items) {
        final d = (it as Map)['date'] as String? ?? '';
        if (d.compareTo(a) > 0) a = d;
      }
      result[uid] = a;
    } catch (_) {
      result[uid] = '';
    }
  }));
  return result;
}
