class Date {
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
}
