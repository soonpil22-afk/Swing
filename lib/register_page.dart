import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'glass_shine_button.dart';
import 'tokens.dart';

// ═══════════════════════════════════════════════════════════════════════
// 공통 색 팔레트 (tokens.dart 단일 출처를 가리키는 별칭)
// ═══════════════════════════════════════════════════════════════════════
const _surface  = kSurface;  // 카드·입력칸 배경
const _elevated = kElevated; // 테두리
const _text  = kText;
const _text2 = kText2;
const _teal     = kTeal;     // 민트 (메인 액센트)
const _pink     = kPink;     // 핑크
const _amber    = kAmber;    // 노랑

// ═══════════════════════════════════════════════════════════════════════
// 1. 전체배경
// ═══════════════════════════════════════════════════════════════════════
const _appBg = kAppBg; // 전체 화면 Scaffold 배경색

// ═══════════════════════════════════════════════════════════════════════
// 2. 메인배경 (회원가입 패널)
// ═══════════════════════════════════════════════════════════════════════
const _panel = kPanel; // 패널 배경색
const double _regOuterPad         = 10;  // 패널 바깥 여백
const double _regPanelRadius      = 24;  // 패널 모서리
const Color  _regPanelBorderColor = _elevated; // 패널 테두리 색
const double _regPanelBorderAlpha = 1.0; // 패널 테두리 투명도(1.0=솔리드)
const double _regPanelBorderWidth = 1;   // 패널 테두리 두께
const double _regInnerHPad        = 20;  // 내용 좌우 여백
const List<BoxShadow> _panelShadow = kPanelShadow;

// ═══════════════════════════════════════════════════════════════════════
// 3. 상단 헤더 (아이콘 + 제목)
// ═══════════════════════════════════════════════════════════════════════
const double _hdrIconBoxSize   = 44;       // 아이콘 박스 크기
const Color  _hdrIconBoxColor  = _surface; // 아이콘 박스 배경
const Color  _hdrIconBoxBorder = _elevated;// 아이콘 박스 테두리
const double _hdrIconBoxRadius = 12;       // 아이콘 박스 모서리
const Color  _hdrIconColor     = _teal;    // 아이콘 색
const double _hdrIconSize      = 24;       // 아이콘 크기
const double _hdrIconGap       = 14;       // 아이콘 ↔ 제목 갭
const Color  _hdrTitleColor    = _text;    // 제목 색
const double _hdrTitleFontSize = 16;       // 제목 글씨 크기
const double _hdrTitleLetterSp = 0.2;      // 제목 자간
const double _hdrTitleSubGap   = 3;        // 제목 ↔ 부제 갭
const Color  _hdrSubColor      = _text2;   // 부제 색
const double _hdrSubFontSize   = 11;       // 부제 글씨 크기
const double _gapHeaderToFields = 16;      // 헤더 ↔ 입력칸 갭

// ═══════════════════════════════════════════════════════════════════════
// 4. 입력칸 (이름·전화·이메일·비밀번호)
// ═══════════════════════════════════════════════════════════════════════
const Color  _fieldTextColor    = _text;    // 입력 글씨 색
const double _fieldTextFontSize = 13;       // 입력 글씨 크기
const Color  _fieldIconColor    = _text2;   // 아이콘 색
const double _fieldIconSize     = 18;       // 아이콘 크기
const Color  _fieldFillColor    = _surface; // 입력칸 배경
const Color  _fieldHintColor    = _text2;   // 힌트 색
const double _fieldHintFontSize = 12;       // 힌트 글씨 크기
const Color  _fieldBorderColor  = _elevated;// 기본 테두리 색
const double _fieldBorderWidth  = 1;      // 기본 테두리 두께
const Color  _fieldFocusColor   = _teal;    // 포커스 테두리 색
const double _fieldFocusWidth   = 1.0;      // 포커스 테두리 두께
const double _fieldRadius       = 10;       // 입력칸 모서리
const double _fieldPadV         = 9;        // 안쪽 위아래 여백
const double _fieldPadH         = 14;       // 안쪽 좌우 여백
const double _gapField          = 8;        // 입력칸 사이 갭
const double _gapFieldsToChoice = 10;       // 입력칸 ↔ 선택칩 갭

// ═══════════════════════════════════════════════════════════════════════
// 5. 선택칩 (운송수단 / 유상운송보험)
// ═══════════════════════════════════════════════════════════════════════
const Color  _choiceLabelColor    = _text2;    // 라벨 색
const double _choiceLabelFontSize = 11;        // 라벨 글씨 크기
const double _choiceLabelLetterSp = 0.3;       // 라벨 자간
const double _choiceLabelGap      = 6;         // 라벨 ↔ 칩 갭
const Color  _choiceSelColor      = _teal;     // 선택 색(글씨·테두리·아이콘)
const Color  _choiceUnselColor    = _text2;    // 미선택 색
const Color  _choiceUnselBg       = _surface;  // 미선택 배경
const Color  _choiceUnselBorder   = _elevated;// 미선택 테두리
const double _choiceFontSize      = 13;        // 칩 글씨 크기
const double _choiceIconSize      = 16;        // 칩 아이콘 크기
const double _gapChoice           = 8;         // 선택칩 줄 사이 갭

// ═══════════════════════════════════════════════════════════════════════
// 6. 안내 박스
// ═══════════════════════════════════════════════════════════════════════
const Color  _noticeBg       = _surface;  // 안내 박스 배경
const Color  _noticeBorder   = _elevated; // 안내 박스 테두리
const double _noticeRadius   = 10;        // 안내 박스 모서리
const Color  _noticeColor    = _pink;     // 아이콘·글씨 색
const double _noticeIconSize = 20;        // 아이콘 크기
const double _noticeFontSize = 11;        // 글씨 크기
const double _gapChoiceToNotice = 10;     // 선택칩 ↔ 안내 박스 갭
const double _gapNoticeToBtn    = 12;     // 안내 박스 ↔ 버튼 갭

// ═══════════════════════════════════════════════════════════════════════
// 7. 회원가입 요청 버튼 (GlassShineButton — 스타일은 위젯 내부)
// ═══════════════════════════════════════════════════════════════════════
const double _gapBtnToLogin = 12; // 버튼 ↔ 로그인 링크 갭

// ═══════════════════════════════════════════════════════════════════════
// 8. 로그인 링크
// ═══════════════════════════════════════════════════════════════════════
const Color  _loginQColor       = _text;  // "이미 계정이 있으신가요?" 색
const double _loginQFontSize    = 12;     // 안내 글씨 크기
const Color  _loginLinkColor    = _amber; // "로그인" 색
const double _loginLinkFontSize = 13;     // "로그인" 글씨 크기
const double _gapBottom         = 20;     // 하단 여백

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
                  color: _regPanelBorderColor.withValues(alpha: _regPanelBorderAlpha),
                  width: _regPanelBorderWidth),
              boxShadow: _panelShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_regPanelRadius),
              child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: _regInnerHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── 3. 상단 헤더 ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: _hdrIconBoxSize, height: _hdrIconBoxSize,
                    decoration: BoxDecoration(
                      color: _hdrIconBoxColor,
                      borderRadius: BorderRadius.circular(_hdrIconBoxRadius),
                      border: Border.all(color: _hdrIconBoxBorder, width: 1),
                    ),
                    child: const Icon(Icons.person_add_outlined,
                        color: _hdrIconColor, size: _hdrIconSize),
                  ),
                  const SizedBox(width: _hdrIconGap),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("SwingTiger 회원가입",
                          style: TextStyle(
                              color: _hdrTitleColor,
                              fontSize: _hdrTitleFontSize,
                              fontWeight: FontWeight.w700,
                              letterSpacing: _hdrTitleLetterSp)),
                      SizedBox(height: _hdrTitleSubGap),
                      Text("모든 입력 항목은 필수입니다.",
                          style: TextStyle(color: _hdrSubColor, fontSize: _hdrSubFontSize)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: _gapHeaderToFields),

              // ── 4. 입력칸 (라벨 제거, 항목명을 칸 안 힌트로 표시) ──
              _buildField(Icons.person_outline_rounded,
                  _nameController, "이름", false),
              const SizedBox(height: _gapField),

              _buildField(Icons.phone_outlined,
                  _phoneController, "전화번호", false),
              const SizedBox(height: _gapField),

              _buildField(Icons.mail_outline_rounded,
                  _emailController, "이메일 (비밀번호 분실시 필요)", false),
              const SizedBox(height: _gapField),

              _buildPasswordField(Icons.lock_outline_rounded,
                  _passwordController, "비밀번호 (6자리 이상)",
                  _obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
              const SizedBox(height: _gapField),

              _buildPasswordField(Icons.lock_outline_rounded,
                  _confirmPasswordController, "비밀번호 확인",
                  _obscureConfirmPassword, () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),

              const SizedBox(height: _gapFieldsToChoice),

              // ── 5. 선택칩 (운송수단 / 유상운송보험) ──
              _buildChoice("운송수단", const ["오토바이", "자동차"],
                  _vehicleType, (v) => setState(() => _vehicleType = v)),
              const SizedBox(height: _gapChoice),
              _buildChoice("유상운송보험 가입유무", const ["가입", "미가입"],
                  _paidInsurance, (v) => setState(() => _paidInsurance = v)),

              const SizedBox(height: _gapChoiceToNotice),

              // ── 6. 안내 박스 ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: _noticeBg,
                  borderRadius: BorderRadius.circular(_noticeRadius),
                  border: Border.all(color: _noticeBorder, width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user, color: _noticeColor, size: _noticeIconSize),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "입력하신 정보는 안전하게 보호되며,\n관리자 승인 후 이용하실 수 있습니다.",
                        style: TextStyle(
                            color: _noticeColor, fontSize: _noticeFontSize, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: _gapNoticeToBtn),

              // ── 7. 회원가입 요청 버튼 (글래스 샤인) ──
              GlassShineButton(
                label: "회원가입 요청",
                onPressed: _handleRegisterRequest,
                accent: _teal,
                height: 48,
                fontSize: 15,
              ),

              const SizedBox(height: _gapBtnToLogin),

              // ── 8. 로그인 링크 ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("이미 계정이 있으신가요?  ",
                      style: TextStyle(color: _loginQColor, fontSize: _loginQFontSize)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "로그인",
                      style: TextStyle(
                        color: _loginLinkColor,
                        fontSize: _loginLinkFontSize,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: _loginLinkColor,
                        decorationThickness: 1.2,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: _gapBottom),
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
      style: const TextStyle(color: _fieldTextColor, fontSize: _fieldTextFontSize),
      cursorColor: _teal,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _fieldIconColor, size: _fieldIconSize),
        filled:    true,
        fillColor: _fieldFillColor,
        hintText:  hint,
        hintStyle: const TextStyle(color: _fieldHintColor, fontSize: _fieldHintFontSize),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _fieldBorderColor, width: _fieldBorderWidth),
            borderRadius: BorderRadius.circular(_fieldRadius)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _fieldFocusColor, width: _fieldFocusWidth),
            borderRadius: BorderRadius.circular(_fieldRadius)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: _fieldPadV, horizontal: _fieldPadH),
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
                color: _choiceLabelColor, fontSize: _choiceLabelFontSize, letterSpacing: _choiceLabelLetterSp)),
        const SizedBox(height: _choiceLabelGap),
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
                    color: sel ? _choiceSelColor.withValues(alpha: 0.15) : _choiceUnselBg,
                    borderRadius: BorderRadius.circular(_fieldRadius),
                    border: Border.all(
                        color: sel ? _choiceSelColor : _choiceUnselBorder,
                        width: sel ? 1.2 : 0.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(sel ? Icons.check_circle : Icons.circle_outlined,
                        size: _choiceIconSize, color: sel ? _choiceSelColor : _choiceUnselColor),
                    const SizedBox(width: 6),
                    Text(o,
                        style: TextStyle(
                            color: sel ? _choiceSelColor : _choiceUnselColor,
                            fontSize: _choiceFontSize,
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
        prefixIcon: Icon(icon, color: _fieldIconColor, size: _fieldIconSize),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _fieldIconColor, size: _fieldIconSize,
          ),
        ),
        filled:    true,
        fillColor: _fieldFillColor,
        hintText:  hint,
        hintStyle: const TextStyle(color: _fieldHintColor, fontSize: _fieldHintFontSize),
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _fieldBorderColor, width: _fieldBorderWidth),
            borderRadius: BorderRadius.circular(_fieldRadius)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: _fieldFocusColor, width: _fieldFocusWidth),
            borderRadius: BorderRadius.circular(_fieldRadius)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: _fieldPadV, horizontal: _fieldPadH),
      ),
    );
  }
}