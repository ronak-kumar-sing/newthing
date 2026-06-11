import 'package:flutter/material.dart';
import '../design/anchor_theme.dart';

class SegmentedProgressBar extends StatefulWidget {
  const SegmentedProgressBar({
    super.key,
    required this.progress,           // 0.0 → 1.0
    this.segments = 10,                // number of discrete segments
    this.height,                       // fallback: 8.0
    this.spacing,                      // fallback: 4.0
    this.activeColor,                  // fallback: Theme primary / AnchorTheme.accent
    this.backgroundColor,              // fallback: Colors.white.withOpacity(0.10)
    this.borderRadius,                 // fallback: BorderRadius.circular(4.0)
    this.animationDuration,            // fallback: 300ms
    this.curve,                        // fallback: Curves.easeInOut
    this.semanticLabel,                // accessibility label
  });

  final double progress;
  final int segments;
  final double? height;
  final double? spacing;
  final Color? activeColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Duration? animationDuration;
  final Curve? curve;
  final String? semanticLabel;

  @override
  State<SegmentedProgressBar> createState() => _SegmentedProgressBarState();
}

class _SegmentedProgressBarState extends State<SegmentedProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _prevProgress = 0.0;

  @override
  void initState() {
    super.initState();
    final duration = widget.animationDuration ?? const Duration(milliseconds: 300);
    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );
    
    final curve = widget.curve ?? Curves.easeInOut;
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    _controller.forward();
    _prevProgress = widget.progress;
  }

  @override
  void didUpdateWidget(covariant SegmentedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress ||
        oldWidget.animationDuration != widget.animationDuration ||
        oldWidget.curve != widget.curve) {
      
      final duration = widget.animationDuration ?? const Duration(milliseconds: 300);
      final curve = widget.curve ?? Curves.easeInOut;

      _controller.duration = duration;
      
      _animation = Tween<double>(
        begin: _prevProgress.clamp(0.0, 1.0),
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _controller, curve: curve));

      _controller.reset();
      _controller.forward();
      
      _prevProgress = widget.progress;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActiveColor = widget.activeColor ?? theme.colorScheme.primary;
    final effectiveBgColor = widget.backgroundColor ?? Colors.white.withOpacity(0.10);
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(4.0);
    final double effectiveHeight = widget.height ?? 8.0;
    final double effectiveSpacing = widget.spacing ?? 4.0;

    final label = widget.semanticLabel ?? "Progress: ${(widget.progress * 100).toInt()}%";
    final valueString = "${(widget.progress * 100).toInt()}%";

    return Semantics(
      label: label,
      value: valueString,
      enabled: true,
      child: RepaintBoundary(
        child: SizedBox(
          height: effectiveHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              // Total spacing width
              final totalSpacing = effectiveSpacing * (widget.segments - 1);
              // Width of a single segment
              final segmentWidth = (totalWidth - totalSpacing) / widget.segments;

              return AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final animVal = _animation.value;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(widget.segments, (index) {
                      // Calculate active/unactive fraction for this segment
                      final startThreshold = index / widget.segments;
                      final endThreshold = (index + 1) / widget.segments;

                      double fraction = 0.0;
                      if (animVal >= endThreshold) {
                        fraction = 1.0;
                      } else if (animVal > startThreshold) {
                        fraction = (animVal - startThreshold) / (endThreshold - startThreshold);
                      }

                      return SizedBox(
                        width: segmentWidth,
                        height: effectiveHeight,
                        child: Stack(
                          children: [
                            // Background Segment
                            Container(
                              decoration: BoxDecoration(
                                color: effectiveBgColor,
                                borderRadius: effectiveBorderRadius,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.03),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            // Foreground active segment (clipped)
                            if (fraction > 0.0)
                              FractionallySizedBox(
                                widthFactor: fraction,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: effectiveActiveColor,
                                    borderRadius: effectiveBorderRadius,
                                    boxShadow: [
                                      BoxShadow(
                                        color: effectiveActiveColor.withOpacity(0.25),
                                        blurRadius: 4,
                                        spreadRadius: 0.5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
