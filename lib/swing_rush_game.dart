// 미니게임 "스윙 러시" — 하단 스포너를 좌우로 드래그해 게이트(×2/+N/−N)를 골라 군중을 키우고 보스와 수치 대결 (CustomPainter MVP)
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tokens.dart';
import 'driver_common.dart';
import 'glass_shine_button.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg    = kAppBg;
const _panel    = kPanel;
const _surface  = kSurface;
const _elevated = kElevated;
const _text     = kText;
const _text2    = kText2;
const _teal     = kTeal;
const _purple   = kPurple;
const _pink     = kPink;
const _amber    = kAmber;
const _red      = kRed;
const List<BoxShadow> _panelShadow = kPanelShadow;

enum _Op { mul, add, sub }
enum _Phase { ready, playing, win, lose }

class _Gate {
  final _Op op;
  final int v;
  const _Gate(this.op, this.v);
  String get label => op == _Op.mul ? '×2' : (op == _Op.add ? '+$v' : '−$v');
  Color get color => op == _Op.mul ? _purple : (op == _Op.add ? _teal : _pink);
}

class _Row {
  final _Gate left;
  final _Gate right;
  final double pos; // 시작점에서의 진행 거리(px)
  bool done = false;
  _Row(this.left, this.right, this.pos);
}

class SwingRushGame extends StatefulWidget {
  const SwingRushGame({super.key});
  @override
  State<SwingRushGame> createState() => _SwingRushGameState();
}

class _SwingRushGameState extends State<SwingRushGame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(days: 1));
  final Random _rng = Random();

  // 게임 파라미터
  static const int _nRows = 8;
  static const double _rowGap = 160;
  static const double _startGap = 260;
  static const double _speed = 150; // px/초

  // 군중 점 흩뿌림 패턴(필로택시스) — 한 번만 생성
  late final List<Offset> _dots = List.generate(80, (i) {
    final a = i * 2.399963; // 황금각
    final r = 4.5 * sqrt(i);
    return Offset(cos(a) * r, sin(a) * r);
  });

  _Phase _phase = _Phase.ready;
  int _crowd = 1;
  double _px = 0.5; // 스포너 가로 위치(0~1)
  double _scroll = 0;
  Duration _last = Duration.zero;
  List<_Row> _rows = [];
  int _enemy = 0;
  double _bossPos = 0;
  bool _bossDone = false;
  int _score = 0;
  int _best = 0;

  @override
  void initState() {
    super.initState();
    _loadBest();
    _ctrl.addListener(_tick);
    _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadBest() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _best = p.getInt('swing_rush_best') ?? 0);
  }

  Future<void> _saveBest() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('swing_rush_best', _best);
  }

  // 게이트 1개 무작위 생성
  _Gate _gate() {
    final t = _rng.nextInt(10);
    if (t < 3) return const _Gate(_Op.mul, 2);
    if (t < 7) return _Gate(_Op.add, 3 + _rng.nextInt(8)); // +3~+10
    return _Gate(_Op.sub, 2 + _rng.nextInt(6)); // −2~−7
  }

  int _apply(int c, _Gate g) {
    switch (g.op) {
      case _Op.mul:
        return min(c * 2, 999999);
      case _Op.add:
        return c + g.v;
      case _Op.sub:
        return max(1, c - g.v);
    }
  }

  void _start() {
    // 게이트 행 생성 (양쪽 다 감점이면 한쪽을 가점으로)
    final rows = <_Row>[];
    for (var i = 0; i < _nRows; i++) {
      var a = _gate();
      var b = _gate();
      if (a.op == _Op.sub && b.op == _Op.sub) {
        b = _Gate(_Op.add, 3 + _rng.nextInt(8));
      }
      rows.add(_Row(a, b, _startGap + i * _rowGap));
    }
    // 보스 수치 = "한 줄씩 더 큰 쪽" 경로 결과의 55% (이기기 가능하되 만만치 않게)
    var opt = 1;
    for (final r in rows) {
      opt = max(_apply(opt, r.left), _apply(opt, r.right));
    }
    setState(() {
      _rows = rows;
      _enemy = max(5, (opt * 0.55).round());
      _bossPos = _startGap + _nRows * _rowGap;
      _bossDone = false;
      _crowd = 1;
      _scroll = 0;
      _px = 0.5;
      _last = _ctrl.lastElapsedDuration ?? Duration.zero;
      _phase = _Phase.playing;
    });
  }

  void _tick() {
    if (_phase != _Phase.playing) return;
    final e = _ctrl.lastElapsedDuration ?? Duration.zero;
    final dt = ((e - _last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _last = e;
    _scroll += _speed * dt;

    final lane = _px < 0.5 ? 0 : 1; // 0=왼쪽, 1=오른쪽
    for (final r in _rows) {
      if (!r.done && _scroll >= r.pos) {
        r.done = true;
        _crowd = _apply(_crowd, lane == 0 ? r.left : r.right);
      }
    }
    if (!_bossDone && _scroll >= _bossPos) {
      _bossDone = true;
      _finish();
    }
  }

  void _finish() {
    _score = _crowd;
    final win = _crowd >= _enemy;
    if (_score > _best) {
      _best = _score;
      _saveBest();
    }
    setState(() => _phase = win ? _Phase.win : _Phase.lose);
  }

  void _drag(double dx, double width) {
    if (_phase != _Phase.playing) return;
    _px = (dx / width).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _elevated),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(children: [
                const SizedBox(height: 8),
                pageHeader(context, "미니게임"),
                const SizedBox(height: kGapInner),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  color: _elevated.withValues(alpha: 0.6),
                ),
                Expanded(child: _field()),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field() => LayoutBuilder(builder: (_, c) {
        final w = c.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (d) => _drag(d.localPosition.dx, w),
          onPanUpdate: (d) => _drag(d.localPosition.dx, w),
          child: Stack(children: [
            Positioned.fill(
              child: CustomPaint(painter: _GamePainter(this, _ctrl)),
            ),
            if (_phase == _Phase.ready) _readyOverlay(),
            if (_phase == _Phase.win || _phase == _Phase.lose) _resultOverlay(),
          ]),
        );
      });

  Widget _readyOverlay() => Center(
        child: _panelBox(children: [
          const Text("스윙 러시",
              style: TextStyle(
                  color: _text, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text("좌우로 드래그해 더 좋은 게이트를 지나며\n군중을 키워 보스를 이기세요!",
              textAlign: TextAlign.center,
              style: TextStyle(color: _text2, fontSize: 13, height: 1.4)),
          const SizedBox(height: 18),
          GlassShineButton(
            label: "시작",
            icon: Icons.play_arrow_rounded,
            onPressed: _start,
            accent: _teal,
            textColor: _teal,
            width: 160,
            height: 48,
            fontSize: 15,
          ),
          if (_best > 0) ...[
            const SizedBox(height: 12),
            Text("최고 점수  $_best",
                style: const TextStyle(color: _text2, fontSize: 12)),
          ],
        ]),
      );

  Widget _resultOverlay() {
    final win = _phase == _Phase.win;
    return Center(
      child: _panelBox(children: [
        Text(win ? "성공!" : "아쉽네요",
            style: TextStyle(
                color: win ? _teal : _pink,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text("내 군중 $_score  vs  적 $_enemy",
            style: const TextStyle(
                color: _text, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text("최고 점수  $_best",
            style: const TextStyle(color: _text2, fontSize: 12)),
        const SizedBox(height: 18),
        GlassShineButton(
          label: "다시하기",
          icon: Icons.refresh_rounded,
          onPressed: _start,
          accent: _teal,
          textColor: _teal,
          width: 160,
          height: 48,
          fontSize: 15,
        ),
      ]),
    );
  }

  Widget _panelBox({required List<Widget> children}) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _elevated, width: 1),
          boxShadow: _panelShadow,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      );
}

// ── 게임 렌더링 ──
class _GamePainter extends CustomPainter {
  final _SwingRushGameState s;
  _GamePainter(this.s, Listenable repaint) : super(repaint: repaint);

  void _txt(Canvas c, String t, Offset center, Color col, double size,
      {FontWeight w = FontWeight.w800}) {
    final tp = TextPainter(
      text: TextSpan(
          text: t, style: TextStyle(color: col, fontSize: size, fontWeight: w)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _gate(Canvas c, _Gate g, double cx, double y, double w, bool done) {
    final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, y), width: w, height: 52),
        const Radius.circular(10));
    final col = g.color;
    c.drawRRect(rect,
        Paint()..color = col.withValues(alpha: done ? 0.12 : 0.22));
    c.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = col.withValues(alpha: done ? 0.3 : 1));
    _txt(c, g.label, Offset(cx, y), done ? _text2 : col, 20);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final bottomY = h - 110;
    final lx = w * 0.25, rx = w * 0.75, gw = w * 0.42;

    // 레인 배경 + 가운데 구분선
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = _appBg);
    canvas.drawRect(Rect.fromLTWH(0, 0, w / 2, h),
        Paint()..color = _surface.withValues(alpha: 0.35));
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h),
        Paint()..color = _elevated..strokeWidth = 1);

    // 트리거 라인
    canvas.drawLine(Offset(0, bottomY), Offset(w, bottomY),
        Paint()..color = _elevated..strokeWidth = 1);

    if (s._phase == _Phase.playing ||
        s._phase == _Phase.win ||
        s._phase == _Phase.lose) {
      // 게이트 행
      for (final row in s._rows) {
        final y = bottomY - (row.pos - s._scroll);
        if (y < -60 || y > h + 60) continue;
        _gate(canvas, row.left, lx, y, gw, row.done);
        _gate(canvas, row.right, rx, y, gw, row.done);
      }
      // 보스
      final by = bottomY - (s._bossPos - s._scroll);
      if (by > -80 && by < h + 80) {
        final rect = RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(w / 2, by), width: w * 0.9, height: 60),
            const Radius.circular(12));
        canvas.drawRRect(rect, Paint()..color = _red.withValues(alpha: 0.2));
        canvas.drawRRect(
            rect,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = _red);
        _txt(canvas, "적  ${s._enemy}", Offset(w / 2, by), _red, 22);
      }

      // 스포너 군중
      final sx = w * s._px;
      final n = min(s._crowd, 80);
      final dotPaint = Paint()..color = _teal;
      for (var i = 0; i < n; i++) {
        canvas.drawCircle(Offset(sx, bottomY - 18) + s._dots[i], 2.4, dotPaint);
      }
      // 스포너 베이스 + 군중 수
      canvas.drawCircle(Offset(sx, bottomY), 6, Paint()..color = _amber);
      _txt(canvas, "${s._crowd}", Offset(sx, bottomY + 28), _text, 24);
    }
  }

  @override
  bool shouldRepaint(covariant _GamePainter old) => false;
}
