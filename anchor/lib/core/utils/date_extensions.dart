/// DateTime extensions for Anchor's date formatting needs.
extension DateTimeExtensions on DateTime {
  /// Returns a friendly date string like "Monday, June 7".
  String get friendlyDate {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final dayName = days[weekday - 1];
    final monthName = months[month - 1];
    return '$dayName, $monthName $day';
  }

  /// Returns time like "7:00 AM".
  String get friendlyTime {
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = hour >= 12 ? 'PM' : 'AM';
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }

  /// Returns days until this date from now.
  int get daysUntil {
    final now = DateTime.now();
    final diff = difference(DateTime(now.year, now.month, now.day));
    return diff.inDays;
  }

  /// Returns true if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns the start of the day (midnight).
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Returns the start of the week (Monday).
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }

  /// Returns true if this date is a Sunday.
  bool get isSunday => weekday == DateTime.sunday;

  /// Formats as ISO date string (YYYY-MM-DD).
  String get toIsoDate => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

/// Duration extensions for time display.
extension DurationExtensions on Duration {
  /// Returns "2h 14m" or "45m" depending on duration.
  String get shortFormat {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Returns "2 hours 14 minutes".
  String get longFormat {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final parts = <String>[];
    if (hours > 0) parts.add('$hours hour${hours > 1 ? 's' : ''}');
    if (minutes > 0) parts.add('$minutes minute${minutes > 1 ? 's' : ''}');
    return parts.join(' ');
  }

  /// Returns "02:14:30" style format.
  String get clockFormat {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
