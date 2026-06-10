import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

/// Focus Mode — lock into one task with a Pomodoro timer.
class FocusModeScreen extends StatefulWidget {
  final String? taskTitle;

  const FocusModeScreen({super.key, this.taskTitle});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;

  // Timer state
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  int _currentSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isBreak = false;
  int _sessionCount = 0;
  int _totalFocusMinutes = 0;

  Timer? _timer;

  // Task input
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.taskTitle != null) {
      _taskController.text = widget.taskTitle!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_taskController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a task to focus on')),
      );
      return;
    }

    setState(() {
      _isRunning = true;
    });
    _breathController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_currentSeconds > 0) {
          _currentSeconds--;
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _breathController.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _breathController.stop();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _currentSeconds = _focusMinutes * 60;
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _breathController.stop();

    if (!_isBreak) {
      _sessionCount++;
      _totalFocusMinutes += _focusMinutes;
      setState(() {
        _isBreak = true;
        _currentSeconds = _breakMinutes * 60;
        _isRunning = false;
      });
      // Show break notification
      _showCompletionDialog('Focus session complete!', 'Take a ${_breakMinutes}-minute break.');
    } else {
      setState(() {
        _isBreak = false;
        _currentSeconds = _focusMinutes * 60;
        _isRunning = false;
      });
      _showCompletionDialog('Break over!', 'Ready for another focus session?');
    }
  }

  void _showCompletionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _setDuration(int minutes) {
    if (_isRunning) return;
    setState(() {
      _focusMinutes = minutes;
      _currentSeconds = minutes * 60;
    });
  }

  String get _timerText {
    final mins = (_currentSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_currentSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  double get _progress {
    final total = _isBreak ? _breakMinutes * 60 : _focusMinutes * 60;
    return total > 0 ? (_currentSeconds / total) : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mode indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isBreak
                          ? AppColors.productive.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isBreak ? '☕ BREAK TIME' : '🎯 FOCUS MODE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: _isBreak ? AppColors.productive : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Task input
                  TextField(
                    controller: _taskController,
                    enabled: !_isRunning,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'What are you focusing on?',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Timer circle
                  AnimatedBuilder(
                    animation: _breathController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isRunning
                            ? 1.0 + (_breathController.value * 0.03)
                            : 1.0,
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background circle
                          CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 8,
                            backgroundColor: AppColors.surfaceLight,
                            valueColor: const AlwaysStoppedAnimation(Colors.transparent),
                          ),
                          // Progress arc
                          CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 8,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation(
                              _isBreak ? AppColors.productive : AppColors.primary,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                          // Timer text
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _timerText,
                                  style: TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w700,
                                    color: _isBreak
                                        ? AppColors.productive
                                        : AppColors.textPrimary,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isRunning
                                      ? _isBreak
                                          ? 'Rest your mind'
                                          : 'Stay focused'
                                      : 'Ready to start',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Duration presets
                  if (!_isRunning) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _DurationChip(
                          label: '15 min',
                          isSelected: _focusMinutes == 15,
                          onTap: () => _setDuration(15),
                        ),
                        const SizedBox(width: 8),
                        _DurationChip(
                          label: '25 min',
                          isSelected: _focusMinutes == 25,
                          onTap: () => _setDuration(25),
                        ),
                        const SizedBox(width: 8),
                        _DurationChip(
                          label: '45 min',
                          isSelected: _focusMinutes == 45,
                          onTap: () => _setDuration(45),
                        ),
                        const SizedBox(width: 8),
                        _DurationChip(
                          label: '60 min',
                          isSelected: _focusMinutes == 60,
                          onTap: () => _setDuration(60),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_isRunning) ...[
                        ElevatedButton.icon(
                          onPressed: _startTimer,
                          icon: const Icon(Icons.play_arrow, size: 24),
                          label: const Text(
                            'START FOCUS',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                          ),
                        ),
                        if (_currentSeconds != _focusMinutes * 60) ...[
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: _resetTimer,
                            icon: const Icon(Icons.refresh, size: 20),
                            label: const Text('Reset'),
                          ),
                        ],
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: _pauseTimer,
                          icon: const Icon(Icons.pause, size: 24),
                          label: const Text(
                            'PAUSE',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceLight,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: _resetTimer,
                          icon: const Icon(Icons.stop, size: 20),
                          label: const Text('Stop'),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Session stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatBox(
                        label: 'Sessions',
                        value: '$_sessionCount',
                      ),
                      const SizedBox(width: 24),
                      _StatBox(
                        label: 'Focus Time',
                        value: '${_totalFocusMinutes}m',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.2)
          : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
