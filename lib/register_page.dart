import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'glass_shine_button.dart';

// ─── 기사페이지와 동일 팔레트 (네이비 + 민트) ───────────────────────
const _appBg    = Color(0xFF090E1A); // 전체 배경 (패널보다 살짝 밝게)
const _panel    = Color(0xFF070C18); // 메인 배경 (inset 패널)
const _surface  = Color(0xFF0D1427); // 카드
const _elevated = Color(0xFF303854); // 트랙 · 테두리

const _text  = Color(0xFFFBFBFB);
const _text2 = Color(0xFF787C8D);

const _teal     = Color(0xFF4AE3ED); // 민트 (메인 액센트)
const _pink     = Color(0xFFE672BA); // 핑크
const _amber    = Color(0xFFE6C97F); // 노랑

// ── 보조 테두리(옅은) ──
const _borderDim = Color(0x33303854);

// ── 회원가입 패널(메인배경) ──
const double _regOuterPad         = 10;   // 패널 바깥 여백
const double _regPanelRadius      = 24;   // 패널 모서리
const double _regPanelBorderAlpha = 0.3;  // 패널 테두리 투명도
const List<BoxShadow> _panelShadow = [
  BoxShadow(color: Color(0xFF18203A), blurRadius: 11, offset: Offset(4, 6)),
];
// ─────────────────────────────────────────────────────────────────

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final TextEditingController _nameController            = TextEditingController();
  final TextEditingController _phoneController           = TextEditingController();
  final TextEditingController _emailController           = TextEditingController();
  final TextEditingController _passwordController        = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;

  String? _vehicleType;    // 운송수단: '오토바이' | '자동차'
  String? _paidInsurance;  // 유상운송보험 가입유무: '가입' | '미가입'

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── 회원가입 처리 (기존 로직 그대로) ─────────────────────────────

  Future<void> _handleRegisterRequest() async {
    final name     = _nameController.text.trim();
    final phone    = _phoneController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      _showDialog("알림", "모든 필수 항목을 입력해 주세요.");
      return;
    }
    if (password != _confirmPasswordController.text.trim()) {
      _showDialog("알림", "비밀번호가 일치하지 않습니다.");
      return;
    }
    if (password.length < 6) {
      _showDialog("알림", "비밀번호는 최소 6자리 이상이어야 합니다.");
      return;
    }
    if (_vehicleType == null || _paidInsurance == null) {
      _showDialog("알림", "운송수단과 유상운송보험 가입유무를 선택해 주세요.");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: _teal)),
    );

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'uid':        credential.user!.uid,
        'name':          name,
        'phone':         phone,
        'email':         email,
        'vehicleType':   _vehicleType,
        'paidInsurance': _paidInsurance,
        'role':          'driver',
        'isApproved':    false,
        'createdAt':     FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context);
      _showDialog("요청 완료", "회원가입 요청이 전송되었습니다.\n관리자 승인 후 이용 가능합니다.");
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      String msg = "회원가입 중 오류가 발생했습니다.";
      if (e.code == 'email-already-in-use') msg = "이미 사용 중인 이메일입니다.";
      if (e.code == 'invalid-email')        msg = "유효하지 않은 이메일 형식입니다.";
      _showDialog("오류", msg);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showDialog("오류", "알 수 없는 오류가 발생했습니다.");
    }
  }

  // ── 다이얼로그 ────────────────────────────────────────────────────

  void _showDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _elevated, width: 1),
        ),
        title: Text(title,
            style: const TextStyle(
                color: _teal, fontSize: 14, fontWeight: FontWeight.w700)),
        content: Text(msg,
            style: const TextStyle(color: _text, fontSize: 13, height: 1.6)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (title == "요청 완료") Navigator.pop(context);
            },
            child: const Text("확인",
                style: TextStyle(color: _teal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── UI ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _appBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_regOuterPad),
          child: Container(
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(_regPanelRadius),
              border: Border.all(
                  color: _elevated.withValues(alpha: _regPanelBorderAlpha),
                  width: 1),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_regPanelRadius),
              child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── 상단 헤더 ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _elevated, width: 1),
                    ),
                    child: const Icon(Icons.person_add_outlined,
                        color: _teal, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("SwingTiger 회원가입",
                          style: TextStyle(
                              color: _text,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2)),
                      SizedBox(height: 3),
                      Text("모든 입력 항목은 필수입니다.",
                          style: TextStyle(color: _text2, fontSize: 11)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── 입력 필드들 (라벨 제거, 항목명을 칸 안 힌트로 표시) ──
              _buildField(Icons.person_outline_rounded,
                  _nameController, "이름", false),
              const SizedBox(height: 8),

              _buildField(Icons.phone_outlined,
                  _phoneController, "전화번호", false),
              const SizedBox(height: 8),

              _buildField(Icons.mail_outline_rounded,
                  _emailController, "이메일 (비밀번호 분실시 필요)", false),
              const SizedBox(height: 8),

              _buildPasswordField(Icons.lock_outline_rounded,
                  _passwordController, "비밀번호 (6자리 이상)",
                  _obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
              const SizedBox(height: 8),

              _buildPasswordField(Icons.lock_outline_rounded,
                  _confirmPasswordController, "비밀번호 확인",
                  _obscureConfirmPassword, () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),

              const SizedBox(height: 10),

              // ── 운송수단 / 유상운송보험 선택 ──
              _buildChoice("운송수단", const ["오토바이", "자동차"],
                  _vehicleType, (v) => setState(() => _vehicleType = v)),
              const SizedBox(height: 8),
              _buildChoice("유상운송보험 가입유무", const ["가입", "미가입"],
                  _paidInsurance, (v) => setState(() => _paidInsurance = v)),

              const SizedBox(height: 10),

              // ── 안내 박스 ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _elevated, width: 1),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified_user, color: _pink, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "입력하신 정보는 안전하게 보호되며,\n관리자 승인 후 이용하실 수 있습니다.",
                        style: TextStyle(
                            color: _pink, fontSize: 11, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── 회원가입 요청 버튼 (글래스 샤인) ──
              GlassShineButton(
                label: "회원가입 요청",
                onPressed: _handleRegisterRequest,
                accent: _teal,
                height: 48,
                fontSize: 15,
              ),

              const SizedBox(height: 12),

              // ── 로그인 링크 ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("이미 계정이 있으신가요?  ",
                      style: TextStyle(color: _text, fontSize: 12)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "로그인",
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

              const SizedBox(height: 20),
            ],
          ),
        ),
            ),
          ),
        ),
      ),
    );
  }

  // ── 일반 입력 필드 ─────────────────────────────────────────────────

  Widget _buildField(IconData icon,
      TextEditingController ctrl, String hint, bool obscure) {
    return TextField(
      controller:  ctrl,
      obscureText: obscure,
      style: const TextStyle(color: _text, fontSize: 13),
      cursorColor: _teal,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _text2, size: 18),
        filled:    true,
        fillColor: _surface,
        hintText:  hint,
        hintStyle: const TextStyle(color: _text2, fontSize: 12),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _elevated, width: 0.5),
            borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _teal, width: 1.0),
            borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
      ),
    );
  }

  // ── 선택 칩 (운송수단 / 유상운송보험 가입유무) ──────────────────────
  Widget _buildChoice(String label, List<String> options, String? selected,
      ValueChanged<String> onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: _text2, fontSize: 11, letterSpacing: 0.3)),
        const SizedBox(height: 6),
        Row(
          children: options.map((o) {
            final sel = selected == o;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(o),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? _teal.withValues(alpha: 0.15) : _surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: sel ? _teal : _borderDim,
                        width: sel ? 1.2 : 0.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(sel ? Icons.check_circle : Icons.circle_outlined,
                        size: 16, color: sel ? _teal : _text2),
                    const SizedBox(width: 6),
                    Text(o,
                        style: TextStyle(
                            color: sel ? _teal : _text2,
                            fontSize: 13,
                            fontWeight:
                                sel ? FontWeight.w700 : FontWeight.w500)),
                  ]),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── 비밀번호 전용 필드 (눈 토글) ──────────────────────────────────

  Widget _buildPasswordField(IconData icon,
      TextEditingController ctrl, String hint,
      bool obscure, VoidCallback onToggle) {
    return TextField(
      controller:  ctrl,
      obscureText: obscure,
      style: const TextStyle(color: _text, fontSize: 13),
      cursorColor: _teal,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _text2, size: 18),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _text2, size: 18,
          ),
        ),
        filled:    true,
        fillColor: _surface,
        hintText:  hint,
        hintStyle: const TextStyle(color: _text2, fontSize: 12),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _elevated, width: 0.5),
            borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _teal, width: 1.0),
            borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
      ),
    );
  }
}