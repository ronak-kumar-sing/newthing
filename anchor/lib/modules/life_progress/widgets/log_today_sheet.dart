import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/progress_model.dart';
import '../../../providers/database_provider.dart';
import '../life_progress_screen.dart';

/// Bottom sheet to log today's value for a progress dimension.
class LogTodaySheet extends ConsumerStatefulWidget {
  final WeeklyProgress progress;

  const LogTodaySheet({super.key, required this.progress});

  @override
  ConsumerState<LogTodaySheet> createState() => _LogTodaySheetState();
}

class _LogTodaySheetState extends ConsumerState<LogTodaySheet> {
  double _value = 0.0;
  bool _isSaving = false;
  bool _loaded = false;

  double get _maxValue {
    final unit = widget.progress.unit.toLowerCase();
    if (unit.contains('hr') || unit.contains('hour')) return 12.0;
    if (unit.contains('session')) return 5.0;
    if (unit.contains('prob') || unit.contains('count')) return 20.0;
    return 10.0;
  }

  double get _step {
    final unit = widget.progress.unit.toLowerCase();
    if (unit.contains('hr') || unit.contains('hour')) return 0.5;
    if (unit.contains('session')) return 1.0;
    if (unit.contains('prob')) return 1.0;
    return 0.5;
  }

  int get _divisions => (_maxValue / _step).round();

  @override
  void initState() {
    super.initState();
    _loadTodayValue();
  }

  Future<void> _loadTodayValue() async {
    final dao = ref.read(progressDaoProvider);
    final todayVal = await dao.getTodayValue(widget.progress.dimensionId);
    if (mounted) {
      setState(() {
        _value = todayVal.clamp(0.0, _maxValue);
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(
      int.parse(widget.progress.colorHex.replaceFirst('#', '0xFF')),
    );
    final today = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF252525), width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Log ${widget.progress.dimensionName}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            today,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.white.withOpacity(0.40),
            ),
          ),
          const SizedBox(height: 28),

          // Current value display
          Center(
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _value % 1 == 0
                        ? _value.toInt().toString()
                        : _value.toStringAsFixed(1),
                    key: ValueKey(_value),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 64,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.progress.unit,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.0, 1.0),
                duration: 300.ms,
              ),
          const SizedBox(height: 24),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: accentColor,
              inactiveTrackColor: Colors.white.withOpacity(0.08),
              thumbColor: accentColor,
              overlayColor: accentColor.withOpacity(0.15),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _value,
              min: 0,
              max: _maxValue,
              divisions: _divisions,
              onChanged: (v) => setState(() => _value = v),
            ),
          ),

          // Min/Max labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.30),
                  ),
                ),
                Text(
                  '${_maxValue % 1 == 0 ? _maxValue.toInt() : _maxValue} ${widget.progress.unit}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.30),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor: accentColor.withOpacity(0.5),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      'Save',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final dao = ref.read(progressDaoProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await dao.recordValue(widget.progress.dimensionId, today, _value);

    // Invalidate providers to refresh UI
    ref.invalidate(progressDataProvider);
    ref.invalidate(weeklyChartDataProvider);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1A1A1A),
          duration: const Duration(seconds: 2),
          content: Text(
            '${widget.progress.dimensionName} logged: ${_value % 1 == 0 ? _value.toInt() : _value.toStringAsFixed(1)} ${widget.progress.unit}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }
}
