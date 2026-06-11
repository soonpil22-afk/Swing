// 미니게임 "블록 퍼즐" — 떨어지는 블록을 좌우 이동·회전해 줄을 채우는 테트리스류 게임 (CustomPainter MVP) + 점수 랭킹 연동
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tokens.dart';
import 'driver_common.dart';
import 'glass_shine_button.dart';
import 'game_ranking_page.dart';

// 팔레트 별칭 (tokens.dart 단일 출처)
const _appBg    = kAppBg;
const _panel    = kPanel;
const _surface  = kSurface;
const _elevated = kElevated;
const _chip     = kChip;
const _text     = kText;
const _teal     = kTeal;
const _pink     = kPink;
const _amber    = kAmber;
const List<BoxShadow> _panelShadow = kPanelShadow;

const int _cols = 10;
const int _rows = 20;

// 블록 색 (index 1~7 = I,O,T,S,Z,J,L)
const List<Color> _pieceColor = [
  kSurface, kTeal, kAmber, kPurple, kGreen, kRed, kBlue, kPink,
];

// 블록 회전 형태 (4x4 문자열, X=칸)
const Map<int, List<List<String>>> _shapes = {
  1: [ // I
    ["....", "XXXX", "....", "...."],
    ["..X.", "..X.", "..X.", "..X."],
  ],
  2: [ // O
    [".XX.", ".XX.", "....", "...."],
  ],
  3: [ // T
    [".X..", "XXX.", "....", "...."],
    [".X..", ".XX.", ".X..", "...."],
    ["....", "XXX.", ".X..", "...."],
    [".X..", "XX..", ".X..", "...."],
  ],
  4: [ // S
    [".XX.", "XX..", "....", "...."],
    [".X..", ".XX.", "..X.", "...."],
  ],
  5: [ // Z
    ["XX..", ".XX.", "....", "...."],
    ["..X.", ".XX.", ".X..", "...."],
  ],
  6: [ // J
    ["X...", "XXX.", "....", "...."],
    [".XX.", ".X..", ".X..", "...."],
    ["....", "XXX.", "..X.", "...."],
    [".X..", ".X..", "XX..", "...."],
  ],
  7: [ // L
    ["..X.", "XXX.", "....", "...."],
    [".X..", ".X..", ".XX.", "...."],
    ["....", "XXX.", "X...", "...."],
    ["XX..", ".X..", ".X..", "...."],
  ],
};

// (x,y) 셀 목록으로 변환
List<Point<int>> _cells(int type, int rot) {
  final states = _shapes[type]!;
  final g = states[rot % states.length];
  final out = <Point<int>>[];
  for (var y = 0; y < 4; y++) {
    for (var x = 0; x < 4; x++) {
      if (g[y][x] == 'X') out.add(Point(x, y));
    }
  }
  return out;
}

class BlockPuzzleGame extends StatefulWidget {
  final String uid;
  const BlockPuzzleGame({super.key, required this.uid});
  @override
  State<BlockPuzzleGame> createState() => _BlockPuzzleGameState();
}

class _BlockPuzzleGameState extends State<BlockPuzzleGame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(days: 1));
  final Random _rng = Random();

  late List<List<int>> _board;
  int _type = 1, _rot = 0, _px = 0, _py = 0;
  int _next = 1;
  int _score = 0, _lines = 0, _level = 1;
  bool _playing = false, _over = false, _saved = false;

  final AudioPlayer _bgm = AudioPlayer();
  bool _muted = false;

  double _acc = 0;
  Duration _last = Duration.zero;
  double get _dropInterval => max(0.08, 0.8 * pow(0.85, _level - 1));

  @override
  void initState() {
    super.initState();
    _board = List.generate(_rows, (_) => List.filled(_cols, 0));
    _bgm.setReleaseMode(ReleaseMode.loop); // 무한 반복
    _loadMuted();
    _ctrl.addListener(_tick);
    _ctrl.repeat();
  }

  @override
  void dispose() {
    _bgm.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  int _randType() => 1 + _rng.nextInt(7);

  // ── 배경음악 ──
  Future<void> _loadMuted() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _muted = p.getBool('game_muted') ?? false);
  }

  Future<void> _startBgm() async {
    if (_muted) return;
    try {
      await _bgm.play(AssetSource('Tetris_Bradinsky.mp3'));
    } catch (_) {}
  }

  Future<void> _stopBgm() async {
    try {
      await _bgm.stop();
    } catch (_) {}
  }

  Future<void> _toggleMute() async {
    setState(() => _muted = !_muted);
    final p = await SharedPreferences.getInstance();
    await p.setBool('game_muted', _muted);
    if (_muted) {
      _stopBgm();
    } else if (_playing) {
      _startBgm();
    }
  }

  void _start() {
    setState(() {
      _board = List.generate(_rows, (_) => List.filled(_cols, 0));
      _score = 0;
      _lines = 0;
      _level = 1;
      _over = false;
      _saved = false;
      _playing = true;
      _next = _randType();
      _last = _ctrl.lastElapsedDuration ?? Duration.zero;
      _acc = 0;
      _spawn();
    });
    _startBgm();
  }

  void _spawn() {
    _type = _next;
    _next = _randType();
    _rot = 0;
    _px = 3;
    _py = 0;
    if (_collide(_px, _py, _rot)) {
      // 스폰 자리 막힘 → 게임오버
      _playing = false;
      _over = true;
      _stopBgm();
      _submitScore();
    }
  }

  bool _collide(int px, int py, int rot) {
    for (final c in _cells(_type, rot)) {
      final x = px + c.x, y = py + c.y;
      if (x < 0 || x >= _cols || y >= _rows) return true;
      if (y >= 0 && _board[y][x] != 0) return true;
    }
    return false;
  }

  void _tick() {
    if (!_playing) return;
    final e = _ctrl.lastElapsedDuration ?? Duration.zero;
    final dt = ((e - _last).inMicroseconds / 1e6).clamp(0.0, 0.1);
    _last = e;
    _acc += dt;
    if (_acc >= _dropInterval) {
      _acc = 0;
      _step();
    }
  }

  // 한 칸 낙하 (못 내려가면 고정)
  void _step() {
    if (!_collide(_px, _py + 1, _rot)) {
      _py++;
    } else {
      _lock();
    }
  }

  void _lock() {
    for (final c in _cells(_type, _rot)) {
      final x = _px + c.x, y = _py + c.y;
      if (y >= 0 && y < _rows && x >= 0 && x < _cols) _board[y][x] = _type;
    }
    _clearLines();
    _spawn();
    setState(() {});
  }

  void _clearLines() {
    var cleared = 0;
    for (var y = _rows - 1; y >= 0; y--) {
      if (_board[y].every((v) => v != 0)) {
        _board.removeAt(y);
        _board.insert(0, List.filled(_cols, 0));
        cleared++;
        y++; // 같은 줄 다시 검사
      }
    }
    if (cleared > 0) {
      const pts = [0, 100, 300, 500, 800];
      _score += pts[cleared] * _level;
      _lines += cleared;
      _level = 1 + _lines ~/ 10;
    }
  }

  void _move(int dx) {
    if (!_playing) return;
    if (!_collide(_px + dx, _py, _rot)) setState(() => _px += dx);
  }

  void _rotate() {
    if (!_playing) return;
    final nr = (_rot + 1) % _shapes[_type]!.length;
    // 간단 벽킥: 제자리 → 좌1 → 우1 시도
    for (final k in [0, -1, 1, -2, 2]) {
      if (!_collide(_px + k, _py, nr)) {
        setState(() {
          _px += k;
          _rot = nr;
        });
        return;
      }
    }
  }

  void _hardDrop() {
    if (!_playing) return;
    while (!_collide(_px, _py + 1, _rot)) {
      _py++;
    }
    _lock();
  }

  // 게임오버 시 최고점 갱신하면 저장
  Future<void> _submitScore() async {
    if (_saved) return;
    _saved = true;
    try {
      final db = FirebaseFirestore.instance;
      final ref = db.collection('game_scores').doc(widget.uid);
      final cur = await ref.get();
      final prev = (cur.data()?['score'] as num?)?.toInt() ?? 0;
      if (_score > prev) {
        final user = await db.collection('users').doc(widget.uid).get();
        await ref.set({
          'uid': widget.uid,
          'name': (user.data()?['name'] as String?) ?? '',
          'score': _score,
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (_) {
      // 권한/네트워크 실패는 게임 진행에 영향 주지 않음
    }
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
                pageHeader(context, "블록 퍼즐"),
                const SizedBox(height: kGapInner),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  color: _elevated.withValues(alpha: 0.6),
                ),
                const SizedBox(height: kGapSection),
                _scoreBar(),
                const SizedBox(height: kGapCard),
                Expanded(child: _boardArea()),
                const SizedBox(height: kGapSection),
                _controls(),
                const SizedBox(height: 6),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          _stat("점수", "$_score"),
          const SizedBox(width: 18),
          _stat("줄", "$_lines"),
          const SizedBox(width: 18),
          _stat("레벨", "$_level"),
          const Spacer(),
          GestureDetector(
            onTap: _toggleMute,
            child: Icon(
                _muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: _pink,
                size: 20),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => GameRankingPage(uid: widget.uid))),
            child: const Row(children: [
              Icon(Icons.leaderboard_rounded, color: _teal, size: 18),
              SizedBox(width: 4),
              Text("랭킹",
                  style: TextStyle(
                      color: _teal, fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
      );

  Widget _stat(String label, String value) => Row(children: [
        Text("$label ",
            style: const TextStyle(color: _amber, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: _amber, fontSize: 15, fontWeight: FontWeight.w800)),
      ]);

  Widget _boardArea() => Center(
        child: AspectRatio(
          aspectRatio: _cols / _rows,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _elevated, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(children: [
                Positioned.fill(
                  child: CustomPaint(painter: _BoardPainter(this, _ctrl)),
                ),
                if (!_playing && !_over) _readyOverlay(),
                if (_over) _overOverlay(),
              ]),
            ),
          ),
        ),
      );

  Widget _readyOverlay() => _overlayBox([
        const Text("블록 퍼즐",
            style: TextStyle(
                color: _text, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text("줄을 채워 점수를 올리세요!",
            style: TextStyle(color: _amber, fontSize: 13)),
        const SizedBox(height: 18),
        GlassShineButton(
          label: "시작",
          icon: Icons.play_arrow_rounded,
          onPressed: _start,
          accent: _teal,
          textColor: _teal,
          width: 150,
          height: 46,
          fontSize: 15,
        ),
        const SizedBox(height: 14),
        const Text("플랫폼 알림루틴 설정필수!!",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _pink, fontSize: 12, fontWeight: FontWeight.w700)),
      ]);

  Widget _overOverlay() => _overlayBox([
        const Text("게임 오버",
            style: TextStyle(
                color: _pink, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text("점수  $_score",
            style: const TextStyle(
                color: _text, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 18),
        GlassShineButton(
          label: "다시하기",
          icon: Icons.refresh_rounded,
          onPressed: _start,
          accent: _amber,
          textColor: _amber,
          width: 160,
          height: 46,
          fontSize: 14,
        ),
        const SizedBox(height: kGapCard),
        GlassShineButton(
          label: "랭킹",
          icon: Icons.leaderboard_rounded,
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => GameRankingPage(uid: widget.uid))),
          accent: _teal,
          textColor: _teal,
          width: 160,
          height: 46,
          fontSize: 14,
        ),
      ]);

  Widget _overlayBox(List<Widget> children) => Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: BoxDecoration(
            color: _surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _elevated, width: 1),
            boxShadow: _panelShadow,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      );

  Widget _controls() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: [
          _btn(Icons.chevron_left_rounded, () => _move(-1)),
          const SizedBox(width: 8),
          _btn(Icons.chevron_right_rounded, () => _move(1)),
          const SizedBox(width: 8),
          _btn(Icons.keyboard_double_arrow_down_rounded, _hardDrop),
          const SizedBox(width: 8),
          _btn(Icons.rotate_right_rounded, _rotate),
        ]),
      );

  Widget _btn(IconData icon, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _chip,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _elevated, width: 1),
            ),
            child: Icon(icon, color: _teal, size: 28),
          ),
        ),
      );
}

// ── 보드 렌더링 ──
class _BoardPainter extends CustomPainter {
  final _BlockPuzzleGameState s;
  _BoardPainter(this.s, Listenable repaint) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / _cols, ch = size.height / _rows;

    void cell(int x, int y, Color col) {
      final r = RRect.fromRectAndRadius(
          Rect.fromLTWH(x * cw + 1, y * ch + 1, cw - 2, ch - 2),
          const Radius.circular(3));
      canvas.drawRRect(r, Paint()..color = col);
    }

    // 격자 배경선
    final grid = Paint()
      ..color = _elevated.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    for (var x = 1; x < _cols; x++) {
      canvas.drawLine(Offset(x * cw, 0), Offset(x * cw, size.height), grid);
    }
    for (var y = 1; y < _rows; y++) {
      canvas.drawLine(Offset(0, y * ch), Offset(size.width, y * ch), grid);
    }

    // 쌓인 블록
    for (var y = 0; y < _rows; y++) {
      for (var x = 0; x < _cols; x++) {
        if (s._board[y][x] != 0) cell(x, y, _pieceColor[s._board[y][x]]);
      }
    }

    // 현재 떨어지는 블록
    if (s._playing) {
      for (final c in _cells(s._type, s._rot)) {
        final x = s._px + c.x, y = s._py + c.y;
        if (y >= 0) cell(x, y, _pieceColor[s._type]);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) => false;
}
