class LifeProgressPoint {
  final String label;      // e.g., "Mon", "Tue"
  final double study;      // hours
  final double coding;     // hours
  final double gym;        // hours

  const LifeProgressPoint({
    required this.label,
    required this.study,
    required this.coding,
    required this.gym,
  });
}
