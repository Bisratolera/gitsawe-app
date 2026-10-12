/// Converts Gregorian dates to the Ethiopian calendar.
///
/// This uses the standard Amete Mihret conversion algorithm.
/// It's accurate for everyday use, but calendar edge cases around
/// Ethiopian leap years (every 4th year, offset from Gregorian leap
/// years) are subtle. For production-grade accuracy, consider the
/// `ethiopian_datetime` package instead of hand-rolling this.
class EthiopianDate {
  final int year;
  final int month; // 1-13 (13th month = Pagume)
  final int day;

  EthiopianDate({required this.year, required this.month, required this.day});

  factory EthiopianDate.fromGregorian(DateTime gDate) {
    // Julian Day Number for the Gregorian date.
    final jdn = _gregorianToJdn(gDate.year, gDate.month, gDate.day);

    // Ethiopian epoch (start of Ethiopian calendar) in JDN.
    const ethiopianEpoch = 1723856;

    final r = (jdn - ethiopianEpoch) % 1461;
    final n = r % 365 + 365 * (r ~/ 1460);

    final eYear = 4 * ((jdn - ethiopianEpoch) ~/ 1461) + (r ~/ 365) - (r ~/ 1460);
    final eMonth = (n ~/ 30) + 1;
    final eDay = (n % 30) + 1;

    return EthiopianDate(year: eYear, month: eMonth, day: eDay);
  }

  static int _gregorianToJdn(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
  }

  /// Matches the "DD-MM" key format used in your JSON files.
  String get dateKey =>
      '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}';
}

const List<String> _geezOnes = ["", "፩", "፪", "፫", "፬", "፭", "፮", "፯", "፰", "፱"];
const List<String> _geezTens = ["", "፲", "፳", "፴", "፵", "፶", "፷", "፸", "፹", "፺"];

/// Converts a standard Hindu-Arabic numeral (1, 2, 3...) to a Ge'ez
/// numeral string for display.
String toGeezNumber(int n) {
  if (n <= 0) return n.toString();
  if (n >= 100) return n.toString(); // simplistic implementation for daily use
  return (_geezTens[n ~/ 10]) + (_geezOnes[n % 10]);
}
