class StreakDay {
  final DateTime date;
  final bool isCompleted;
  final double? intensity;

  const StreakDay({
    required this.date,
    required this.isCompleted,
    this.intensity,
  });
}
