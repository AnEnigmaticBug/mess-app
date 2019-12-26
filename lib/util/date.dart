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
    if (year > other.year || month > other.month || day > other.day) {
      return 1;
    }
    if (year < other.year || month < other.month || day < other.day) {
      return -1;
    }
    return 0;
  }
}

class DateFormatter {
  const DateFormatter(this.date);

  final Date date;

  String get weekDay {
    switch(date.weekDay) {
      case DateTime.monday: return 'Monday';
      case DateTime.tuesday: return 'Tuesday';
      case DateTime.wednesday: return 'Wednesday';
      case DateTime.thursday: return 'Thursday';
      case DateTime.friday: return 'Friday';
      case DateTime.saturday: return 'Saturday';
      case DateTime.sunday: return 'Sunday';
    }
  }

  String get month {
    switch(date.month) {
      case DateTime.january: return 'January';
      case DateTime.february: return 'February';
      case DateTime.march: return 'March';
      case DateTime.april: return 'April';
      case DateTime.may: return 'May';
      case DateTime.june: return 'June';
      case DateTime.july: return 'July';
      case DateTime.august: return 'August';
      case DateTime.september: return 'September';
      case DateTime.october: return 'October';
      case DateTime.november: return 'November';
      case DateTime.december: return 'December';
    }
  }

  String get oldness {
    final now = Date.now();

    int diff = now.year - date.year;
    String unit = 'year';

    if (now.year > date.year) {
      diff = now.year - date.year;
      unit = 'year';
    } else if (now.month > date.month) {
      diff = now.month - date.month;
      unit = 'month';
    } else if (now.day - date.day > 1) {
      diff = now.day - date.day;
      unit = 'day';
    } else if (now.day - date.day == 1) {
      return 'Yesterday';
    } else {
      return 'Today';
    }

    return '$diff $unit${diff > 1 ? 's' : ''} ago';
  }
}
