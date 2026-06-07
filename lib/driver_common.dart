// 기사 페이지 공용 — 서브페이지가 공유하는 헬퍼(포맷·안내창·헤더·배지)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'tokens.dart';
import 'glass_shine_button.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _surface = kSurface;
const _teal    = kTeal;
const _text    = kText;

// 절대값 천단위 콤마 포맷
String fmtAbs(double v) => NumberFormat('#,###').format(v.abs());

// 공통 안내 다이얼로그
void showInfoDialog(BuildContext context, String msg) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _teal, width: 1),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(msg,
              style: const TextStyle(
                  color: _teal, fontSize: 15, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: GlassShineButton(
              label: "확인",
              onPressed: () => Navigator.pop(ctx),
              accent: _teal,
              pill: true,
              height: 46,
              fontSize: 14,
            ),
          ),
        ]),
      ),
    ),
  );
}

// 서브 페이지 공통 헤더 (뒤로가기 + 제목)
Widget pageHeader(BuildContext context, String title) => Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 16, 0),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: _text, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        Text(title,
            style: const TextStyle(color: _text, fontSize: 19, fontWeight: FontWeight.w700)),
      ]),
    );

// 상태 배지 (출금가능 · 입금대기 등)
Widget statusBadge(String label, Color c) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c),
      ),
      child: Text(label,
          style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
    );
