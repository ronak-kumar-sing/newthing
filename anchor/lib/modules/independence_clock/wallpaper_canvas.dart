import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WallpaperCanvas extends StatelessWidget {
  final int daysRemaining;
  final int totalDays;
  final List<bool> completedDays;
  final String goalTitle;
  final Color backgroundColor;
  final String mode; // 'color' or 'image'
  final String imagePath;
  final double gridScale;
  final double overlayOpacity;
  final String textAlignment; // 'top', 'center', 'bottom'

  const WallpaperCanvas({
    super.key,
    required this.daysRemaining,
    required this.totalDays,
    required this.completedDays,
    required this.goalTitle,
    this.backgroundColor = const Color(0xFF0A0A0A),
    this.mode = 'color',
    this.imagePath = '',
    this.gridScale = 1.0,
    this.overlayOpacity = 0.4,
    this.textAlignment = 'bottom',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      return Container(
        width: w,
        height: h,
        color: Colors.black,
        child: _WallpaperLayout(
          screenW: w,
          screenH: h,
          daysRemaining: daysRemaining,
          totalDays: totalDays,
          completedDays: completedDays,
          goalTitle: goalTitle,
          backgroundColor: backgroundColor,
          mode: mode,
          imagePath: imagePath,
          gridScale: gridScale,
          overlayOpacity: overlayOpacity,
          textAlignment: textAlignment,
        ),
      );
    });
  }
}

class _WallpaperLayout extends StatelessWidget {
  final double screenW, screenH;
  final int daysRemaining, totalDays;
  final List<bool> completedDays;
  final String goalTitle;
  final Color backgroundColor;
  final String mode;
  final String imagePath;
  final double gridScale;
  final double overlayOpacity;
  final String textAlignment;

  const _WallpaperLayout({
    required this.screenW,
    required this.screenH,
    required this.daysRemaining,
    required this.totalDays,
    required this.completedDays,
    required this.goalTitle,
    required this.backgroundColor,
    required this.mode,
    required this.imagePath,
    required this.gridScale,
    required this.overlayOpacity,
    required this.textAlignment,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Background Widget
    Widget bgWidget;
    if (mode == 'image' && imagePath.isNotEmpty && File(imagePath).existsSync()) {
      bgWidget = Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      bgWidget = Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.9,
            colors: [
              backgroundColor,
              Color.lerp(backgroundColor, Colors.black, 0.6)!,
              Colors.black,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
      );
    }

    // 2. Grid dimensions
    const int cols = 18;
    final int rows = totalDays > 0 ? (totalDays / cols).ceil() : 1;

    final double hMargin = screenW * 0.055;
    final double gridW = screenW - hMargin * 2;
    final double dotStep = gridW / cols;
    
    // Apply gridScale
    final double dotSize = (dotStep * 0.72) * gridScale;
    final double dotGap = (dotStep - dotStep * 0.72) * gridScale;
    
    final double actualGridW = cols * dotSize + (cols - 1) * dotGap;
    final double actualGridH = rows * dotSize + (rows - 1) * dotGap;

    // Centered Grid position
    final double gridY = (screenH - actualGridH) / 2;

    // 3. Text Position
    double textY;
    if (textAlignment == 'top') {
      textY = screenH * 0.08;
    } else if (textAlignment == 'center') {
      textY = gridY - 75;
    } else {
      textY = gridY + actualGridH + 35;
    }

    // Progress % calculation
    final double progressPct = totalDays > 0
        ? ((completedDays.where((c) => c).length / totalDays) * 100)
        : 0;

    final textBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          goalTitle.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: screenW * 0.046,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "${progressPct.round()}% COMPLETE  ·  $daysRemaining DAYS LEFT",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: screenW * 0.030,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFC6F52C),
            letterSpacing: 1.0,
          ),
        ),
      ],
    );

    return Stack(
      children: [
        Positioned.fill(child: bgWidget),
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: overlayOpacity),
          ),
        ),

        // Grid custom paint
        Positioned(
          top: gridY,
          left: 0,
          right: 0,
          height: actualGridH,
          child: CustomPaint(
            painter: _DotGridPainter(
              totalDays: totalDays,
              completedDays: completedDays,
              cols: cols,
              dotSize: dotSize,
              dotGap: dotGap,
              filledColor: const Color(0xFFC6F52C),
              emptyColor: Colors.white,
            ),
          ),
        ),

        // Text overlay block
        Positioned(
          top: textY,
          left: hMargin,
          right: hMargin,
          child: Center(child: textBlock),
        ),
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final int totalDays, cols;
  final List<bool> completedDays;
  final double dotSize, dotGap;
  final Color filledColor, emptyColor;

  const _DotGridPainter({
    required this.totalDays,
    required this.completedDays,
    required this.cols,
    required this.dotSize,
    required this.dotGap,
    required this.filledColor,
    required this.emptyColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double step = dotSize + dotGap;
    final double cornerR = dotSize * 0.28; // rounded square corners

    final Paint filledPaint = Paint()
      ..color = filledColor
      ..style = PaintingStyle.fill;

    final Paint emptyPaint = Paint()
      ..color = emptyColor.withValues(alpha: 0.12) // Subtle outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = dotSize * 0.10; // thin outline

    final Paint emptyFillPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    final double actualGridW = cols * dotSize + (cols - 1) * dotGap;
    final double startX = (size.width - actualGridW) / 2;

    for (int i = 0; i < totalDays; i++) {
      int col = i % cols;
      int row = i ~/ cols;
      double x = startX + col * step;
      double y = row * step;

      // Don't draw if outside canvas bounds
      if (y + dotSize > size.height) break;
      if (x + dotSize > size.width) continue;

      final RRect rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, dotSize, dotSize),
        Radius.circular(cornerR),
      );

      final isCompleted = i < completedDays.length && completedDays[i];
      if (isCompleted) {
        // GREEN filled square (completed day)
        canvas.drawRRect(rr, filledPaint);
      } else {
        // WHITE outlined square (remaining day)
        canvas.drawRRect(rr, emptyFillPaint);
        canvas.drawRRect(rr, emptyPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) =>
      old.completedDays != completedDays || old.dotSize != dotSize;
}
