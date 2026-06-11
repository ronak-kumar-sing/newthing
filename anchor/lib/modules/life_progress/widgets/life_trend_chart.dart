import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/design/anchor_theme.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../models/life_progress_point.dart';

class LifeTrendChart extends StatefulWidget {
  const LifeTrendChart({
    super.key,
    required this.data,
    this.height,                       // fallback: 240.0
    this.animationDuration,            // fallback: 800ms
    this.curve,                        // fallback: Curves.easeOutCubic
    this.semanticLabel,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
  });

  final List<LifeProgressPoint> data;
  final double? height;
  final Duration? animationDuration;
  final Curve? curve;
  final String? semanticLabel;
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;

  @override
  State<LifeTrendChart> createState() => _LifeTrendChartState();
}

class _LifeTrendChartState extends State<LifeTrendChart> {
  int _touchedBarIndex = -1;

  @override
  Widget build(BuildContext context) {
    final semanticLabelStr = widget.semanticLabel ?? "Life Progress trends over time for Study, Coding, and Gym Workouts.";

    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return Semantics(
      label: semanticLabelStr,
      child: RepaintBoundary(
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: AnchorTheme.radiusCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chart Header / Title
              Text(
                'Weekly Performance Trends'.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AnchorTheme.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              
              // Legend Row
              _buildLegend(),
              const SizedBox(height: 24),

              // The Trend Line Chart
              SizedBox(
                height: widget.height ?? 220.0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: widget.animationDuration ?? const Duration(milliseconds: 800),
                  curve: widget.curve ?? Curves.easeOutCubic,
                  builder: (context, scale, child) {
                    return LineChart(
                      _buildChartData(scale),
                      duration: const Duration(milliseconds: 250),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Study Hours', AnchorTheme.accent),
        _buildLegendItem('Coding Practice', AnchorTheme.statusBlue),
        _buildLegendItem('Gym Workouts', AnchorTheme.statusOrange),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.60),
          ),
        ),
      ],
    );
  }

  LineChartData _buildChartData(double scale) {
    // Determine maximum Y value to scale the Y axis dynamically
    double maxVal = 1.0;
    for (final pt in widget.data) {
      maxVal = math.max(maxVal, pt.study);
      maxVal = math.max(maxVal, pt.coding);
      maxVal = math.max(maxVal, pt.gym);
    }
    final maxY = (maxVal * 1.15).ceilToDouble();

    // Map data points to FlSpots
    final studySpots = <FlSpot>[];
    final codingSpots = <FlSpot>[];
    final gymSpots = <FlSpot>[];

    for (int i = 0; i < widget.data.length; i++) {
      final pt = widget.data[i];
      studySpots.add(FlSpot(i.toDouble(), pt.study * scale));
      codingSpots.add(FlSpot(i.toDouble(), pt.coding * scale));
      gymSpots.add(FlSpot(i.toDouble(), pt.gym * scale));
    }

    return LineChartData(
      lineTouchData: LineTouchData(
        touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
          if (!event.isInterestedForInteractions || response == null || response.lineBarSpots == null) {
            setState(() {
              _touchedBarIndex = -1;
            });
            return;
          }
          final spots = response.lineBarSpots!;
          if (spots.isNotEmpty) {
            setState(() {
              _touchedBarIndex = spots.first.barIndex;
            });
          }
        },
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => const Color(0xFF161616),
          tooltipBorder: const BorderSide(color: Color(0xFF252525), width: 1),
          tooltipRoundedRadius: 12,
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          getTooltipItems: (touchedSpots) {
            if (touchedSpots.isEmpty) return [];

            final firstSpot = touchedSpots.first;
            final index = firstSpot.x.toInt();
            if (index < 0 || index >= widget.data.length) return [];

            final point = widget.data[index];

            return touchedSpots.map((spot) {
              // Only return text for the first spot in list to prevent duplicate overlays
              if (spot.barIndex != firstSpot.barIndex) return null;

              return LineTooltipItem(
                '${point.label.toUpperCase()}\n\n'
                'Study: ${point.study.toStringAsFixed(1)} hrs\n'
                'Coding: ${point.coding.toStringAsFixed(1)} hrs\n'
                'Gym: ${point.gym.toStringAsFixed(1)} sess',
                GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.4,
                ),
              );
            }).toList();
          },
        ),
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((index) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: barData.color?.withOpacity(0.25) ?? Colors.white.withOpacity(0.2),
                strokeWidth: 2,
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: barData.color ?? Colors.white,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            );
          }).toList();
        },
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white.withOpacity(0.04),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 4 > 0 ? maxY / 4 : 1.0,
            getTitlesWidget: (value, meta) {
              if (value == 0 || value == maxY) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  value.toStringAsFixed(0),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.30),
                  ),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < widget.data.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    widget.data[index].label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (widget.data.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        _buildLineData(studySpots, AnchorTheme.accent, 0),
        _buildLineData(codingSpots, AnchorTheme.statusBlue, 1),
        _buildLineData(gymSpots, AnchorTheme.statusOrange, 2),
      ],
    );
  }

  LineChartBarData _buildLineData(List<FlSpot> spots, Color color, int barIndex) {
    final bool isAnyLineTouched = _touchedBarIndex != -1;
    final bool isThisLineTouched = _touchedBarIndex == barIndex;
    
    // Apply opacity depending on selection state
    final double opacity = isAnyLineTouched ? (isThisLineTouched ? 1.0 : 0.2) : 0.8;
    final double fillOpacity = isAnyLineTouched ? (isThisLineTouched ? 0.05 : 0.01) : 0.03;

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color.withOpacity(opacity),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            color.withOpacity(fillOpacity),
            color.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final title = widget.emptyStateTitle ?? "No progress data available";
    final subtitle = widget.emptyStateSubtitle ?? "Start tracking activities to see trends";

    return GlassCard(
      padding: const EdgeInsets.all(32),
      borderRadius: AnchorTheme.radiusCard,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.show_chart,
              size: 48,
              color: AnchorTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.white.withOpacity(0.40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
