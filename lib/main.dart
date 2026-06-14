import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'firebase_options.dart';
import 'tokens.dart';
import 'super_admin_page.dart';
import 'register_page.dart';
import 'admin_page.dart';
import 'driver_page.dart';
import 'glass_shine_button.dart';

// ═══════════════════════════════════════════════════════════════════════
// 공통 색 팔레트 (모든 섹션 공유)
// ═══════════════════════════════════════════════════════════════════════
const _surface  = kSurface;  // 카드·입력칸 배경
const _elevated = kElevated; // 테두리
const _text  = kText;
const _text2 = kText2;
const _teal     = kTeal;      // 민트 (메인 액센트)
const _amber    = kAmber;     // 노랑

// ═══════════════════════════════════════════════════════════════════════
// 1. 전체배경
// ═══════════════════════════════════════════════════════════════════════
const _appBg = kAppBg; // 전체 화면 Scaffold 배경색

// ═══════════════════════════════════════════════════════════════════════
// 2. 메인배경 (로그인 패널)
// ═══════════════════════════════════════════════════════════════════════
const _panel = kPanel; // 패널 배경색
const double _loginOuterPad         = 10;  // 패널 바깥 여백
const double _loginPanelRadius      = 24;  // 패널 모서리
const Color  _loginPanelBorderColor = _elevated; // 패널 테두리 색
const double _loginPanelBorderAlpha = 1.0; // 패널 테두리 투명도(1.0=솔리드)
const double _loginPanelBorderWidth = 1;   // 패널 테두리 두께
const double _loginInnerHPad        = 32;  // 내용 좌우 여백
const List<BoxShadow> _panelShadow = kPanelShadow;

// ═══════════════════════════════════════════════════════════════════════
// 3. 로고 / 브랜드
// ═══════════════════════════════════════════════════════════════════════
const double _gapLogoToField = 32; // 로고 ↔ 입력칸 갭
// 하단 브랜드 문구 (SWING TIGER / DELIVERY · PAYROLL)
const Color  _brandSwingColor   = _text;  // "SWING" 색
const Color  _brandTigerColor   = _amber; // "TIGER" 색
const double _brandFontSize     = 12;     // 브랜드 글씨 크기
const double _brandLetterSp     = 2.0;    // 브랜드 자간
const Color  _brandSubColor     = _text2; // "DELIVERY · PAYROLL" 색
const double _brandSubFontSize  = 8;      // 부제 글씨 크기
const double _brandSubLetterSp  = 3.0;    // 부제 자간
const double _gapSignupToBrand  = 40; // 회원가입 ↔ 브랜드 갭
const double _gapBrandToSub     = 4;  // 브랜드 ↔ 부제 갭
const double _gapBottom         = 40; // 부제 ↔ 하단 갭

// ═══════════════════════════════════════════════════════════════════════
// 4. 입력칸 (이메일 / 비밀번호)
// ═══════════════════════════════════════════════════════════════════════
const Color  _fieldLabelColor    = _text2;     // 라벨 색
const double _fieldLabelFontSize = 11;         // 라벨 글씨 크기
const double _fieldLabelLetterSp = 0.3;        // 라벨 자간
const double _fieldLabelGap      = 5;          // 라벨 ↔ 입력칸 갭
const Color  _fieldTextColor     = _text;      // 입력 글씨 색
const double _fieldTextFontSize  = 15;         // 입력 글씨 크기
const Color  _fieldHintColor     = _text2;     // 힌트 색
const double _fieldHintFontSize  = 13;         // 힌트 글씨 크기
const Color  _fieldFillColor     = _surface;   // 입력칸 배경
const Color  _fieldIconColor     = _teal;      // 아이콘 색
const double _fieldIconSize      = 22;         // 아이콘 크기
const Color  _fieldBorderColor   = _elevated; // 기본 테두리 색
const double _fieldBorderWidth   = 1;          // 기본 테두리 두께
const Color  _fieldFocusColor    = _teal;      // 포커스 테두리 색
const double _fieldFocusWidth    = 1;        // 포커스 테두리 두께
const double _fieldRadius        = 10;         // 입력칸 모서리
const double _fieldPadV          = 13;         // 안쪽 위아래 여백
const double _fieldPadH          = 14;         // 안쪽 좌우 여백
const double _gapFieldToField    = 12;         // 이메일 ↔ 비밀번호 갭

// ═══════════════════════════════════════════════════════════════════════
// 5. 로그인 정보 저장 + 비밀번호 찾기
// ═══════════════════════════════════════════════════════════════════════
const double _checkSize          = 20;       // 체크박스 크기
const Color  _checkActiveColor   = _teal;    // 체크 활성 색
const Color  _checkBorderColor   = _elevated;// 체크 테두리 색
const Color  _rememberColor      = _text2;   // "로그인 정보 저장" 색
const double _rememberFontSize   = 12;       // "로그인 정보 저장" 크기
const Color  _findPwColor        = _teal;    // "비밀번호 찾기" 색
const double _findPwFontSize     = 12;       // "비밀번호 찾기" 크기
const double _gapFieldToRemember = 8;        // 비번칸 ↔ 체크행 갭
const double _gapRememberToBtn   = 20;       // 체크행 ↔ 로그인 버튼 갭

// ═══════════════════════════════════════════════════════════════════════
// 6. 로그인 버튼 (GlassShineButton — 스타일은 위젯 내부)
// ═══════════════════════════════════════════════════════════════════════
const double _gapBtnToSignup = 16; // 로그인 버튼 ↔ 회원가입 갭

// ═══════════════════════════════════════════════════════════════════════
// 7. 회원가입 링크
// ═══════════════════════════════════════════════════════════════════════
const Color  _signupQColor       = _text;  // "계정이 없으신가요?" 색
const double _signupQFontSize    = 13;     // 안내 글씨 크기
const Color  _signupLinkColor    = _amber; // "회원가입" 색
const double _signupLinkFontSize = 13;     // "회원가입" 글씨 크기

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint("✅ Firebase 초기화 성공");
  } catch (e) {
    debugPrint("❌ Firebase 초기화 실패: $e");
  }
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'DoHyeon'),
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
            style: const TextStyle(color: _teal, fontSize: 15, fontWeight: FontWeight.w400)),
        content: Text(msg,
            style: const TextStyle(color: _text, fontSize: 13, height: 1.6)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("확인",
                style: TextStyle(color: _teal, fontWeight: FontWeight.w400)),
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
                  color: _loginPanelBorderColor.withValues(alpha: _loginPanelBorderAlpha),
                  width: _loginPanelBorderWidth),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_loginPanelRadius),
              child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: _loginInnerHPad),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // ── 3. 로고 ──
              const _ShineLogo(),
              const SizedBox(height: _gapLogoToField),

              // ── 4. 입력칸 ──
              _buildField("이메일", Icons.mail_outline_rounded,
                  _emailController, false),
              const SizedBox(height: _gapFieldToField),
              _buildField("비밀번호", Icons.lock_outline_rounded,
                  _passwordController, true),
              const SizedBox(height: _gapFieldToRemember),

              // ── 5. 로그인 정보 저장 + 비밀번호 찾기 ──
              Row(children: [
                SizedBox(
                  width: _checkSize, height: _checkSize,
                  child: Checkbox(
                    value:       _isRememberMe,
                    onChanged:   (v) => setState(() => _isRememberMe = v!),
                    side:        const BorderSide(color: _checkBorderColor, width: 1),
                    activeColor: _checkActiveColor,
                    checkColor:  _panel,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),
                const Text("로그인 정보 저장",
                    style: TextStyle(color: _rememberColor, fontSize: _rememberFontSize)),
                const Spacer(),
                GestureDetector(
                  onTap: _handleForgotPassword,
                  child: const Text(
                    "비밀번호 찾기",
                    style: TextStyle(
                      color: _findPwColor,
                      fontSize: _findPwFontSize,
                      decoration: TextDecoration.underline,
                      decorationColor: _findPwColor,
                      decorationThickness: 1.0,
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: _gapRememberToBtn),

              // ── 6. 로그인 버튼 ──
              GlassShineButton(label: "로그인", onPressed: _handleLogin),
              const SizedBox(height: _gapBtnToSignup),

              // ── 7. 회원가입 링크 ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "계정이 없으신가요?  ",
                    style: TextStyle(color: _signupQColor, fontSize: _signupQFontSize),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegisterPage())),
                    child: const Text(
                      "회원가입",
                      style: TextStyle(
                        color: _signupLinkColor,
                        fontSize: _signupLinkFontSize,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                        decorationColor: _signupLinkColor,
                        decorationThickness: 1.2,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: _gapSignupToBrand),
              // ── 3. 브랜드 문구 ──
              Text.rich(
                const TextSpan(
                  style: TextStyle(fontSize: _brandFontSize, fontWeight: FontWeight.w400, letterSpacing: _brandLetterSp),
                  children: [
                    TextSpan(text: "SWING ", style: TextStyle(color: _brandSwingColor)),
                    TextSpan(text: "TIGER", style: TextStyle(color: _brandTigerColor)),
                  ],
                ),
              ),
              const SizedBox(height: _gapBrandToSub),
              const Text("DELIVERY · PAYROLL",
                  style: TextStyle(color: _brandSubColor, fontSize: _brandSubFontSize, letterSpacing: _brandSubLetterSp)),
              const SizedBox(height: _gapBottom),
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
            style: const TextStyle(color: _fieldLabelColor, fontSize: _fieldLabelFontSize, letterSpacing: _fieldLabelLetterSp)),
        const SizedBox(height: _fieldLabelGap),
        TextField(
          controller:  ctrl,
          obscureText: obscure,
          style: const TextStyle(color: _fieldTextColor, fontSize: _fieldTextFontSize),
          cursorColor: _teal,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _fieldIconColor, size: _fieldIconSize),
            filled:    true,
            fillColor: _fieldFillColor,
            hintText:  obscure ? '••••••••' : 'example@email.com',
            hintStyle: const TextStyle(color: _fieldHintColor, fontSize: _fieldHintFontSize),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: _fieldBorderColor, width: _fieldBorderWidth),
                borderRadius: BorderRadius.circular(_fieldRadius)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: _fieldFocusColor, width: _fieldFocusWidth),
                borderRadius: BorderRadius.circular(_fieldRadius)),
            contentPadding: const EdgeInsets.symmetric(vertical: _fieldPadV, horizontal: _fieldPadH),
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
