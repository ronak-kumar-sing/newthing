import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WallpaperCanvas extends StatelessWidget {
  final int daysRemaining;
  final int totalDays;
  final String goalTitle;
  final Color backgroundColor;

  const WallpaperCanvas({
    super.key,
    required this.daysRemaining,
    required this.totalDays,
    required this.goalTitle,
    this.backgroundColor = const Color(0xFF0A0A0A),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      return Container(
        width: w,
        height: h,
        color: backgroundColor,
        child: _WallpaperLayout(
          screenW: w,
          screenH: h,
          daysRemaining: daysRemaining,
          totalDays: totalDays,
          goalTitle: goalTitle,
        ),
      );
    });
  }
}

class _WallpaperLayout extends StatelessWidget {
  final double screenW, screenH;
  final int daysRemaining, totalDays;
  final String goalTitle;

  const _WallpaperLayout({
    required this.screenW,
    required this.screenH,
    required this.daysRemaining,
    required this.totalDays,
    required this.goalTitle,
  });

  @override
  Widget build(BuildContext context) {
    // ── LAYOUT CONSTANTS ──────────────────────────────────────
    final double hMargin = screenW * 0.055; // ~20px on 375w screen
    final double topPad = screenH * 0.08; // 8% from top
    final double bottomPad = screenH * 0.04; // 4% from bottom
    final double headerH = screenH * 0.20; // time + pct text area
    final double gridGapTop = screenH * 0.025; // gap between header and grid

    // Grid fills: height = screenH - topPad - headerH - gridGapTop - bottomPad
    final double gridH = screenH - topPad - headerH - gridGapTop - bottomPad;
    final double gridW = screenW - hMargin * 2;

    // ── AUTO DOT SIZE CALCULATION ─────────────────────────────
    const int cols = 6;
    final int rows = totalDays > 0 ? (totalDays / cols).ceil() : 1;

    final double dotStep = gridW / cols; // step per column
    final double dotSize = dotStep * 0.72; // dot is 72% of step
    final double dotGap = dotStep - dotSize;

    final double rowStep = min(dotStep, gridH / rows);
    final double finalDotSz = rowStep * 0.72;
    final double finalDotGap = rowStep - finalDotSz;

    // ── ELAPSED DOTS ─────────────────────────────────────────
    final int elapsedDays = totalDays - daysRemaining;
    final double progressPct = totalDays > 0 ? (elapsedDays / totalDays * 100) : 0;

    // ── MONTHS : DAYS FORMAT ─────────────────────────────────
    final int monthsLeft = daysRemaining ~/ 30;
    final int daysLeft = daysRemaining % 30;

    return Stack(children: [
      // ── TOP SECTION: time display + progress text ─────────
      Positioned(
        top: topPad,
        left: hMargin,
        right: hMargin,
        height: headerH,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // BIG "1 : 30" time display
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(monthsLeft.toString(),
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: screenW * 0.20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -3,
                        height: 1.0)),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenW * 0.030),
                    child: Text(":",
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: screenW * 0.14,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withOpacity(0.35),
                            height: 1.0))),
                Text(daysLeft.toString().padLeft(2, '0'),
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: screenW * 0.20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -3,
                        height: 1.0)),
                SizedBox(width: screenW * 0.03),
                // Small label column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("mo",
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: screenW * 0.030,
                            color: Colors.white.withOpacity(0.35),
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text("days",
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: screenW * 0.030,
                            color: Colors.white.withOpacity(0.35),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),

            SizedBox(height: screenH * 0.012),

            // "22% / 364" progress line
            Row(children: [
              Text("${progressPct.round()}%",
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: screenW * 0.048,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFC6F52C))),
              Text("  /  $totalDays days",
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: screenW * 0.038,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.40))),
            ]),
          ],
        ),
      ),

      // ── DOT GRID ─────────────────────────────────────────
      Positioned(
        top: topPad + headerH + gridGapTop,
        left: hMargin,
        right: hMargin,
        bottom: bottomPad,
        child: CustomPaint(
          painter: _DotGridPainter(
            totalDays: totalDays,
            elapsedDays: elapsedDays,
            cols: cols,
            dotSize: finalDotSz,
            dotGap: finalDotGap,
            filledColor: const Color(0xFF4CAF50), // green (like sketch)
            emptyColor: Colors.white,
          ),
        ),
      ),
    ]);
  }
}

class _DotGridPainter extends CustomPainter {
  final int totalDays, elapsedDays, cols;
  final double dotSize, dotGap;
  final Color filledColor, emptyColor;

  const _DotGridPainter({
    required this.totalDays,
    required this.elapsedDays,
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
      ..color = emptyColor.withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = dotSize * 0.10; // thin outline

    final Paint emptyFillPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    for (int i = 0; i < totalDays; i++) {
      int col = i % cols;
      int row = i ~/ cols;
      double x = col * step;
      double y = row * step;

      // Don't draw if outside canvas bounds
      if (y + dotSize > size.height) break;
      if (x + dotSize > size.width) continue;

      final RRect rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, dotSize, dotSize),
        Radius.circular(cornerR),
      );

      if (i < elapsedDays) {
        // GREEN filled square (elapsed day)
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
      old.elapsedDays != elapsedDays || old.dotSize != dotSize;
}
