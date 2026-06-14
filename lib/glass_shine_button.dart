// 글래스 샤인(반투명 유리 + 누를 때 빛줄기 sweep) 공통 버튼 위젯
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassShineButton extends StatefulWidget {
  final String? label;      // null이면 아이콘 전용
  final VoidCallback? onPressed;
  final Color accent;       // 강조색(테두리·sweep·로딩 인디케이터)
  final Color textColor;    // 라벨/아이콘 색
  final IconData? icon;
  final double? width;      // null이면 가로 꽉 채움
  final double height;
  final double radius;
  final double fontSize;
  final FontWeight fontWeight;
  final bool loading;
  final bool pill;          // true면 알약형(완전 둥근 모서리)

  const GlassShineButton({
    super.key,
    this.label,
    required this.onPressed,
    this.accent = const Color(0xFF4AE3ED),
    this.textColor = const Color(0xFFEAFFFB),
    this.icon,
    this.width,
    this.height = 52,
    this.radius = 15,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w400,
    this.loading = false,
    this.pill = false,
  });

  @override
  State<GlassShineButton> createState() => _GlassShineButtonState();
}

class _GlassShineButtonState extends State<GlassShineButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) {
    if (!_enabled) return;
    setState(() => _pressed = true);
    _sweep.forward(from: 0);
  }

  void _up(TapUpDetails _) => setState(() => _pressed = false);
  void _cancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final radius = widget.pill ? widget.height / 2 : widget.radius;
    final accent = widget.accent;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _cancel,
      onTap: _enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 27, 38, 70),
                    Color.fromARGB(255, 10, 15, 32),
                  ],
                ),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                    color: accent.withValues(alpha: _enabled ? 0.45 : 0.18),
                    width: 1),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: 18,
                      spreadRadius: -8,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // 누를 때 빛줄기 sweep
                      AnimatedBuilder(
                        animation: _sweep,
                        builder: (context, _) {
                          if (_sweep.value == 0 || _sweep.value == 1) {
                            return const SizedBox.shrink();
                          }
                          final dx = (-1.3 + 2.6 * _sweep.value) * w;
                          return Transform.translate(
                            offset: Offset(dx, 0),
                            child: Transform(
                              transform: Matrix4.skewX(-0.32),
                              alignment: Alignment.center,
                              child: Container(
                                width: w * 0.7,
                                height: widget.height,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      accent.withValues(alpha: 0.55),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // 라벨 / 아이콘 / 로딩
                      if (widget.loading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: accent),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null)
                              Icon(widget.icon,
                                  size: widget.fontSize + 3,
                                  color: widget.textColor),
                            if (widget.icon != null && widget.label != null)
                              const SizedBox(width: 8),
                            if (widget.label != null)
                              Text(widget.label!,
                                  style: TextStyle(
                                    color: widget.textColor,
                                    fontSize: widget.fontSize,
                                    fontWeight: widget.fontWeight,
                                    letterSpacing: 0.5,
                                  )),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
