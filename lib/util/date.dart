class Date implements Comparable<Date> {
  Date(
    this.year,
    this.month,
    this.day,
  ) : weekDay = DateTime(year, month, day).weekday;

  factory Date.now() {
    final now = DateTime.now();
    return Date(now.year, now.month, now.day);
  }

  factory Date.parse(String iso8061String) {
    try {
      final parts = iso8061String.substring(0, 10).split('-');
      return Date(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } on Exception {
      throw FormatException('String is not in the ISO-8601 format');
    }
  }

  final int day;
  final int month;
  final int year;
  final int weekDay;

  String toIso8601String() => '${year.toString().padLeft(4, '0')}'
      '-${month.toString().padLeft(2, '0')}'
      '-${day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Date &&
          other.day == day &&
          other.month == month &&
          other.year == year);

  @override
  int get hashCode => day.hashCode ^ month.hashCode & year.hashCode;

  @override
  int compareTo(Date other) {
    return DateTime(year, month, day)
        .compareTo(DateTime(other.year, other.month, other.day));
  }
}

class DateFormatter {
  const DateFormatter(this.date);

  final Date date;

  String get weekDay {
    switch (date.weekDay) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
    }
  }

  String get month {
    switch (date.month) {
      case DateTime.january:
        return 'January';
      case DateTime.february:
        return 'February';
      case DateTime.march:
        return 'March';
      case DateTime.april:
        return 'April';
      case DateTime.may:
        return 'May';
      case DateTime.june:
        return 'June';
      case DateTime.july:
        return 'July';
      case DateTime.august:
        return 'August';
      case DateTime.september:
        return 'September';
      case DateTime.october:
        return 'October';
      case DateTime.november:
        return 'November';
      case DateTime.december:
        return 'December';
    }
  }

  String get oldness {
    final diff = DateTime.now()
        .difference(DateTime(date.year, date.month, date.day))
        .abs();

    if (diff.inDays == 1) {
      return 'Yesterday';
    }
    if (diff.inDays == 0) {
      return 'Today';
    }

    int magnitude;
    String unit;

    if (diff.inDays > 365) {
      magnitude = (diff.inDays / 365).floor();
      unit = 'year';
    } else if (diff.inDays > 30) {
      magnitude = (diff.inDays / 30).floor();
      unit = 'month';
    } else if (diff.inDays > 7) {
      magnitude = (diff.inDays / 7).floor();
      unit = 'week';
    } else {
      magnitude = diff.inDays;
      unit = 'day';
    }

    return '$magnitude $unit${magnitude > 1 ? 's' : ''} ago';
  }
}
