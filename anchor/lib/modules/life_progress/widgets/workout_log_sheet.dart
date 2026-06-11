import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../providers/database_provider.dart';
import '../life_progress_screen.dart';

/// Workout type with its visual configuration.
class _WorkoutType {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> muscleGroups;

  const _WorkoutType({
    required this.name,
    required this.icon,
    required this.color,
    required this.muscleGroups,
  });
}

const _workoutTypes = [
  _WorkoutType(
    name: 'Upper Body',
    icon: Icons.fitness_center,
    color: Color(0xFFC6F52C),
    muscleGroups: ['Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps'],
  ),
  _WorkoutType(
    name: 'Lower Body',
    icon: Icons.directions_run,
    color: Color(0xFF5B8DEF),
    muscleGroups: ['Quads', 'Hamstrings', 'Glutes', 'Calves'],
  ),
  _WorkoutType(
    name: 'Cardio',
    icon: Icons.monitor_heart,
    color: Color(0xFFFF5252),
    muscleGroups: ['Heart', 'Endurance'],
  ),
  _WorkoutType(
    name: 'Rest Day',
    icon: Icons.self_improvement,
    color: Color(0xFF9E9E9E),
    muscleGroups: ['Recovery', 'Stretching'],
  ),
];

/// Interactive workout logger bottom sheet.
/// Opened when tapping "Gym Focus" insight card.
class WorkoutLogSheet extends ConsumerStatefulWidget {
  const WorkoutLogSheet({super.key});

  @override
  ConsumerState<WorkoutLogSheet> createState() => _WorkoutLogSheetState();
}

class _WorkoutLogSheetState extends ConsumerState<WorkoutLogSheet> {
  int? _selectedIndex;
  bool _isSaving = false;
  double _todayGymValue = 0.0;
  bool _loaded = false;

  // Track which muscle groups were targeted this week (simplified)
  final Map<String, int> _weeklyMuscleHits = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dao = ref.read(progressDaoProvider);
    final todayVal = await dao.getTodayValue('dim_gym_workouts');

    // Get this week's values to show activity
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final weekValues = await dao.getValuesForRange('dim_gym_workouts', monday, sunday);

    if (mounted) {
      setState(() {
        _todayGymValue = todayVal;
        _loaded = true;
        // Simple heuristic: distribute workout types across the week
        for (int i = 0; i < weekValues.length; i++) {
          final typeIdx = i % _workoutTypes.length;
          for (final muscle in _workoutTypes[typeIdx].muscleGroups) {
            _weeklyMuscleHits[muscle] = (_weeklyMuscleHits[muscle] ?? 0) + 1;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFFC6F52C);

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
      child: SingleChildScrollView(
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
          Row(
            children: [
              const Icon(Icons.fitness_center, color: Color(0xFFC6F52C), size: 22),
              const SizedBox(width: 10),
              Text(
                'Log Workout',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              // Today's status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _todayGymValue > 0
                      ? accentColor.withOpacity(0.15)
                      : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: _todayGymValue > 0
                        ? accentColor.withOpacity(0.3)
                        : Colors.white.withOpacity(0.10),
                    width: 1,
                  ),
                ),
                child: Text(
                  _todayGymValue > 0 ? '✓ LOGGED' : 'NOT YET',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: _todayGymValue > 0
                        ? accentColor
                        : Colors.white.withOpacity(0.40),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Workout type grid
          Text(
            'SELECT WORKOUT TYPE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemCount: _workoutTypes.length,
            itemBuilder: (context, index) {
              final type = _workoutTypes[index];
              final isSelected = _selectedIndex == index;

              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? type.color.withOpacity(0.15)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? type.color.withOpacity(0.5)
                          : Colors.white.withOpacity(0.08),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Icon(type.icon, color: type.color, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          type.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? type.color : Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: type.color, size: 18),
                    ],
                  ),
                ),
              ).animate(delay: (index * 60).ms).fadeIn(duration: 200.ms).slideX(
                    begin: 0.05,
                    end: 0,
                    duration: 200.ms,
                  );
            },
          ),
          const SizedBox(height: 20),

          // Weekly muscle heat map
          Text(
            'THIS WEEK\'S FOCUS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _buildMuscleChips(),
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedIndex == null || _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                disabledBackgroundColor: accentColor.withOpacity(0.3),
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
                      _selectedIndex != null
                          ? 'Log ${_workoutTypes[_selectedIndex!].name}'
                          : 'Select a Workout',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  List<Widget> _buildMuscleChips() {
    final allMuscles = <String>{};
    for (final type in _workoutTypes) {
      allMuscles.addAll(type.muscleGroups);
    }

    // Also add selected workout's muscles with higher intensity
    final selectedMuscles = _selectedIndex != null
        ? _workoutTypes[_selectedIndex!].muscleGroups.toSet()
        : <String>{};

    return allMuscles.map((muscle) {
      final hits = _weeklyMuscleHits[muscle] ?? 0;
      final isFromSelected = selectedMuscles.contains(muscle);
      final intensity = (hits / 3.0).clamp(0.0, 1.0);
      final accentColor = const Color(0xFFC6F52C);

      Color chipColor;
      if (isFromSelected) {
        chipColor = accentColor.withOpacity(0.3 + intensity * 0.4);
      } else if (hits > 0) {
        chipColor = accentColor.withOpacity(0.1 + intensity * 0.2);
      } else {
        chipColor = Colors.white.withOpacity(0.04);
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFromSelected
                ? accentColor.withOpacity(0.5)
                : Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: Text(
          muscle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isFromSelected || hits > 0
                ? Colors.white.withOpacity(0.8)
                : Colors.white.withOpacity(0.30),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _save() async {
    if (_selectedIndex == null) return;
    setState(() => _isSaving = true);

    final dao = ref.read(progressDaoProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isRestDay = _selectedIndex == 3; // Rest Day

    // Log 1 session (or 0 for rest day)
    await dao.recordValue('dim_gym_workouts', today, isRestDay ? 0.0 : 1.0);

    ref.invalidate(progressDataProvider);
    ref.invalidate(weeklyChartDataProvider);

    if (mounted) {
      Navigator.pop(context);
      final type = _workoutTypes[_selectedIndex!];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1A1A1A),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              Icon(type.icon, color: type.color, size: 16),
              const SizedBox(width: 8),
              Text(
                isRestDay
                    ? 'Rest day logged. Recovery is progress. 💪'
                    : '${type.name} workout logged!',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
