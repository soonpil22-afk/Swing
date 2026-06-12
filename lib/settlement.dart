// 정산 계산 단일 출처 — 리스비/기타 날짜별 공제와 순 출금액을 한 곳에서 계산.
// 기사 프레임·출금신청·정산내역 미출금이 전부 이 모듈을 쓴다 → 화면 간 금액이 항상 일치한다.

// 리스비/기타 일할 공제 — 리포트 날짜(yyyy-MM-dd)가 적용기간[start,last] 안이면 일일액, 밖이면 0.
// (익일 출금 시스템: "오늘"이 아니라 각 리포트 날짜로 가른다)
double dayDeduction(String? reportDate, DateTime? start, DateTime? last, double dailyAmt) {
  if (dailyAmt <= 0 || start == null || last == null || reportDate == null) return 0;
  final d = DateTime.tryParse(reportDate);
  if (d == null) return 0;
  final day = DateTime(d.year, d.month, d.day);
  if (day.isBefore(DateTime(start.year, start.month, start.day))) return 0;
  if (day.isAfter(DateTime(last.year, last.month, last.day))) return 0;
  return dailyAmt;
}

// 공제 설정 — 일일액 + 적용기간(리포트 날짜 기준)
class DeductionConfig {
  final double dailyAmt;
  final DateTime? start;
  final DateTime? last;
  const DeductionConfig(this.dailyAmt, this.start, this.last);

  // 한 리포트(하루)에 적용되는 공제액
  double forItem(Map<String, dynamic> item) =>
      dayDeduction(item['date'] as String?, start, last, dailyAmt);
}

// 정산 결과 — 누적(공제 전) / 리스비 합 / 기타 합 / 순 출금액(net)
class SettlementResult {
  final double gross;      // 미출금 누적(공제 전) = Σ finalAmount
  final double leaseTotal; // 리스비 합 (날짜 기준)
  final double etcTotal;   // 기타 합 (날짜 기준)
  const SettlementResult(this.gross, this.leaseTotal, this.etcTotal);
  double get net => gross - leaseTotal - etcTotal; // 순 출금액 = 누적 − 리스비 − 기타
}

// 미출금 아이템 목록 + 리스비/기타 설정 → 정산 결과.
// grossOverride: unpaid_balance.totalAmount를 직접 줄 때(없으면 items의 finalAmount 합산).
// 단건·누적·개인 모두 이 함수를 "무엇을 넣느냐"만 다르게 호출한다.
SettlementResult computeSettlement(
  List<Map<String, dynamic>> items,
  DeductionConfig lease,
  DeductionConfig etc, {
  double? grossOverride,
}) {
  final double gross = grossOverride ??
      items.fold<double>(0.0, (s, it) => s + ((it['finalAmount'] as num?)?.toDouble() ?? 0.0));
  final leaseTotal = items.fold<double>(0.0, (s, it) => s + lease.forItem(it));
  final etcTotal = items.fold<double>(0.0, (s, it) => s + etc.forItem(it));
  return SettlementResult(gross, leaseTotal, etcTotal);
}
