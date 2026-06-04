import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'super_admin_page.dart';
import 'register_page.dart';
import 'admin_page.dart';
import 'driver_page.dart';
import 'glass_shine_button.dart';

// ─── Design Tokens ───────────────────────────────────────────────────
const _appBg    = Color(0xFF090E1A); // 전체 배경 (패널보다 살짝 밝게)
const _panel    = Color(0xFF070C18); // 메인 배경 (inset 패널)
const _surface  = Color(0xFF0D1427); // 카드
const _elevated = Color(0xFF303854); // 트랙 · 테두리

const _text  = Color(0xFFFBFBFB);
const _text2 = Color(0xFF787C8D);

const _teal     = Color(0xFF4AE3ED); // 민트 (메인 액센트)
const _amber    = Color(0xFFE6C97F); // 노랑

// ── 보조 테두리(옅은) ──
const _borderDim = Color(0x33303854);

// ── 로그인 패널(메인배경) ──
const double _loginOuterPad         = 10;   // 패널 바깥 여백
const double _loginPanelRadius      = 24;   // 패널 모서리
const double _loginPanelBorderAlpha = 0.3;  // 패널 테두리 투명도
const List<BoxShadow> _panelShadow = [
  BoxShadow(color: Color(0xFF18203A), blurRadius: 11, offset: Offset(4, 6)),
];
// ─────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    debugPrint("✅ Firebase 초기화 성공");
  } catch (e) {
    debugPrint("❌ Firebase 초기화 실패: $e");
  }
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'Pretendard'),
    home: const LoginPage(),
  ));
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRememberMe = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSavedData());
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isRememberMe = prefs.getBool('isRememberMe') ?? false;
        if (_isRememberMe) {
          _emailController.text    = prefs.getString('savedEmail')    ?? '';
          _passwordController.text = prefs.getString('savedPassword') ?? '';
        }
      });
    } catch (e) { debugPrint("데이터 로드 실패: $e"); }
  }

  Future<void> _saveLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_isRememberMe) {
        await prefs.setBool('isRememberMe', true);
        await prefs.setString('savedEmail',    _emailController.text.trim());
        await prefs.setString('savedPassword', _passwordController.text.trim());
      } else {
        await prefs.setBool('isRememberMe', false);
        await prefs.remove('savedEmail');
        await prefs.remove('savedPassword');
      }
    } catch (e) { debugPrint("데이터 저장 실패: $e"); }
  }

  Future<void> _recordVisit() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await FirebaseFirestore.instance
          .collection('visit_stats').doc(today)
          .set({'date': today, 'count': FieldValue.increment(1)}, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection('visit_stats').doc('total')
          .set({'count': FieldValue.increment(1)}, SetOptions(merge: true));
    } catch (e) { debugPrint("방문자 기록 실패: $e"); }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSimpleDialog("입력 확인", "정보를 모두 입력해 주세요.");
      return;
    }
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email:    _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await _saveLoginData();
      final String uid = userCredential.user!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final String role = userDoc.data()?['role'] ?? 'driver';
        if (!mounted) return;
        await _recordVisit();
        if (role == 'super_admin') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const SuperAdminPage()));
        } else if (role == 'admin') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const AdminPage()));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const DriverPage()));
        }
      } else {
        _showSimpleDialog("데이터 오류", "인증은 성공했으나 DB에 유저 정보가 없습니다.\nUID: $uid");
      }
    } on FirebaseAuthException catch (e) {
      String message = "이메일 또는 비밀번호를 다시 확인해 주세요.";
      if (e.code == 'user-not-found') message = "등록되지 않은 이메일입니다.";
      if (e.code == 'wrong-password')  message = "비밀번호가 틀렸습니다.";
      _showSimpleDialog("로그인 실패", message);
    } catch (e) {
      _showSimpleDialog("알 수 없는 오류", "상세 에러 내용:\n$e");
    }
  }

  // ── ✅ 추가된 비밀번호 찾기 함수 ────────────────────────────────────
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSimpleDialog("알림", "이메일을 먼저 입력한 후\n비밀번호 찾기를 눌러주세요.");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSimpleDialog("전송 완료", "$email\n\n메일함을 확인해주세요!\n링크주소로 비밀번호 재설정하세요!");
    } on FirebaseAuthException catch (_) {
      _showSimpleDialog("오류", "등록되지 않은 이메일입니다.");
    } catch (e) {
      _showSimpleDialog("오류", "오류가 발생했습니다.\n다시 시도해 주세요.");
    }
  }
  // ──────────────────────────────────────────────────────────────────

  void _showSimpleDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _elevated, width: 1),
        ),
        title: Text(title,
            style: const TextStyle(color: _teal, fontSize: 15, fontWeight: FontWeight.w700)),
        content: Text(msg,
            style: const TextStyle(color: _text, fontSize: 13, height: 1.6)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("확인",
                style: TextStyle(color: _teal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_loginOuterPad),
          child: Container(
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(_loginPanelRadius),
              border: Border.all(
                  color: _elevated.withValues(alpha: _loginPanelBorderAlpha),
                  width: 1),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_loginPanelRadius),
              child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              const _ShineLogo(),
              const SizedBox(height: 32),

              _buildField("이메일", Icons.mail_outline_rounded,
                  _emailController, false),
              const SizedBox(height: 12),

              _buildField("비밀번호", Icons.lock_outline_rounded,
                  _passwordController, true),
              const SizedBox(height: 8),

              // ── ✅ 체크박스 오른쪽에 비밀번호 찾기 추가 ──
              Row(children: [
                SizedBox(
                  width: 20, height: 20,
                  child: Checkbox(
                    value:       _isRememberMe,
                    onChanged:   (v) => setState(() => _isRememberMe = v!),
                    side:        const BorderSide(color: _elevated, width: 1.5),
                    activeColor: _teal,
                    checkColor:  _panel,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text("로그인 정보 저장",
                    style: TextStyle(color: _text2, fontSize: 12)),
                const Spacer(),
                GestureDetector(
                  onTap: _handleForgotPassword,
                  child: const Text(
                    "비밀번호 찾기",
                    style: TextStyle(
                      color: _teal,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      decorationColor: _teal,
                      decorationThickness: 1.0,
                    ),
                  ),
                ),
              ]),
              // ────────────────────────────────────────────────────

              const SizedBox(height: 20),

              GlassShineButton(label: "로그인", onPressed: _handleLogin),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "계정이 없으신가요?  ",
                    style: TextStyle(color: _text, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegisterPage())),
                    child: const Text(
                      "회원가입",
                      style: TextStyle(
                        color: _amber,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: _amber,
                        decorationThickness: 1.2,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
                    RichText(
              text: const TextSpan(
              style:TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2.0),
              children: [
                    TextSpan(text: "SWING ", style: TextStyle(color: _text)),
                    TextSpan(text: "TIGER", style: TextStyle(color: _amber)),
              ],
            ),
          ),
const SizedBox(height: 4),
const Text("DELIVERY · PAYROLL",
    style: TextStyle(color: _text2, fontSize: 8, letterSpacing: 3.0)),
const SizedBox(height: 40),
            ],
          ),
        ),
      ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon,
      TextEditingController ctrl, bool obscure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: _text2, fontSize: 11, letterSpacing: 0.3)),
        const SizedBox(height: 5),
        TextField(
          controller:  ctrl,
          obscureText: obscure,
          style: const TextStyle(color: _text, fontSize: 15),
          cursorColor: _teal,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _teal, size: 22),
            filled:    true,
            fillColor: _surface,
            hintText:  obscure ? '••••••••' : 'example@email.com',
            hintStyle: const TextStyle(color: _text2, fontSize: 13),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: _borderDim, width: 1),
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: _teal, width: 1.5),
                borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
          ),
        ),
      ],
    );
  }

}

// ═══════════════════════════════════════════════════════════════════════
// 로고 - 미세한 후광 + 좌상단→우하단 대각선 광택 sweep 애니메이션
// ═══════════════════════════════════════════════════════════════════════
// 조정값
const double _logoSize        = 220;   // 로고 크기
const double _glowAlpha        = 0.03;  // 후광 세기(0~1, 작을수록 미세)
const double _glowRadius       = 0.3;   // 후광 반경(작을수록 가운데만, 모서리는 사라짐)
const int    _shineDurationMs  = 20000;  // 한 사이클 시간(스치고+쉬고)
const double _shineSweepRatio  = 0.45;  // 한 사이클 중 빛이 지나가는 구간 비율
const double _shineAlpha       = 0.3;   // 광택 밝기(0~1)

class _ShineLogo extends StatefulWidget {
  const _ShineLogo();
  @override
  State<_ShineLogo> createState() => _ShineLogoState();
}

class _ShineLogoState extends State<_ShineLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _shineDurationMs),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _logoSize,
      height: _logoSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 방사형 후광: 가운데만 은은하고 가장자리·모서리는 완전히 사라짐
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: _glowRadius,
                colors: [
                  _teal.withValues(alpha: _glowAlpha),
                  Colors.transparent,
                ],
              ),
            ),
            child: const SizedBox(width: _logoSize, height: _logoSize),
          ),
          AnimatedBuilder(
            animation: _c,
        builder: (_, child) {
          // 사이클 앞부분(_shineSweepRatio)에만 빛이 좌상→우하로 지나가고 나머진 쉼
          final sweep = (_c.value / _shineSweepRatio).clamp(0.0, 1.0);
          final p = -0.25 + sweep * 1.5; // 광택 띠 중심: -0.25(좌상 밖) → 1.25(우하 밖)
          double cl(double v) => v.clamp(0.0, 1.0);
          return ShaderMask(
            blendMode: BlendMode.srcATop, // 로고 픽셀 위에서만 광택 표시
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.white.withValues(alpha: _shineAlpha),
                Colors.transparent,
                Colors.transparent,
              ],
              stops: [cl(p - 0.25), cl(p - 0.10), cl(p), cl(p + 0.10), cl(p + 0.25)],
            ).createShader(rect),
            child: child,
          );
        },
        child: Image.asset(
          'assets/swingtiger_logo_01.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.moped, color: _teal, size: 80),
        ),
          ),
        ],
      ),
    );
  }
}
