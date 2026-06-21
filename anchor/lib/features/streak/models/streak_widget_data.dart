class StreakWidgetData {
  final String habitName;
  final int currentStreak;
  final int targetDays;
  final int daysLeft;
  final double percentage;
  final List<bool> last7Days;      // true/false for last 7 days
  final String accentColorHex;     // derived from theme, not hardcoded

  const StreakWidgetData({
    required this.habitName,
    required this.currentStreak,
    required this.targetDays,
    required this.daysLeft,
    required this.percentage,
    required this.last7Days,
    required this.accentColorHex,
  });

  Map<String, dynamic> toJson() => {
        'habitName': habitName,
        'currentStreak': currentStreak,
        'targetDays': targetDays,
        'daysLeft': daysLeft,
        'percentage': percentage,
        'last7Days': last7Days,
        'accentColorHex': accentColorHex,
      };
}
