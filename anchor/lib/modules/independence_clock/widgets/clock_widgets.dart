import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/design/anchor_theme.dart';

class SpinningNumber extends ImplicitlyAnimatedWidget {
  final int number;
  final TextStyle textStyle;

  const SpinningNumber({
    super.key,
    required this.number,
    required this.textStyle,
    super.duration = const Duration(milliseconds: 600),
    super.curve = Curves.easeOutBack,
  });

  @override
  ImplicitlyAnimatedWidgetState<SpinningNumber> createState() => _SpinningNumberState();
}

class _SpinningNumberState extends AnimatedWidgetBaseState<SpinningNumber> {
  IntTween? _numberTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _numberTween = visitor(
      _numberTween,
      widget.number,
      (dynamic value) => IntTween(begin: value as int),
    ) as IntTween?;
  }

  @override
  Widget build(BuildContext context) {
    final value = _numberTween?.evaluate(animation) ?? widget.number;
    return Text(
      '$value',
      style: widget.textStyle,
    );
  }
}

class CountdownRing extends StatelessWidget {
  final Widget child;
  final double progress;

  const CountdownRing({
    super.key,
    required this.child,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AnchorTheme.accent.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 8,
                  backgroundColor: AnchorTheme.cardBorder,
                  color: AnchorTheme.accent,
                  strokeCap: StrokeCap.round,
                );
              },
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)),
          ),
          child,
        ],
      ),
    );
  }
}
