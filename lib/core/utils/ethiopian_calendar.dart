/// Converts Gregorian dates to the Ethiopian calendar.
///
/// This uses the standard Amete Mihret conversion (Julian Day Number based),
/// the same algorithm used by the Android widget code in
/// `MainActivity.kt` — keep both in sync if you ever change it.
class EthiopianDate {
  final int year;
  final int month; // 1-13 (13th month = Pagume)
  final int day;

  const EthiopianDate({required this.year, required this.month, required this.day});

  /// Ethiopian calendar epoch expressed as a Julian Day Number.
  static const int _epoch = 1723856;

  factory EthiopianDate.fromGregorian(DateTime gDate) {
    final jdn = _gregorianToJdn(gDate.year, gDate.month, gDate.day);

    final diff = jdn - _epoch;
    final r = diff % 1461; // Dart's % is always non-negative for a positive divisor
    final n = r % 365 + 365 * (r ~/ 1460);

    final eYear = 4 * (diff ~/ 1461) + (r ~/ 365) - (r ~/ 1460);
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

  /// Matches the "DD-MM" key format used in the JSON data files.
  String get dateKey =>
      '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}';

  /// "12/6/2018" — the label used on the Today screen and widgets.
  String get shortLabel => '$day/$month/$year';

  @override
  String toString() => 'EthiopianDate($year-$month-$day)';
}

const List<String> ethiopianMonthsAm = [
  'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታኅሣሥ', 'ጥር', 'የካቲት', 'መጋቢት',
  'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜን',
];

const List<String> ethiopianMonthsEn = [
  'Meskerem', 'Tikimt', 'Hidar', 'Tahsas', 'Tir', 'Yekatit', 'Megabit',
  'Miazia', 'Ginbot', 'Sene', 'Hamle', 'Nehase', 'Pagume',
];

/// 1-based month number → name. Out-of-range numbers are clamped.
String ethiopianMonthName(int month, {bool english = false}) {
  final list = english ? ethiopianMonthsEn : ethiopianMonthsAm;
  return list[(month - 1).clamp(0, list.length - 1)];
}

/// Turns a "DD-MM" data key into a human label, e.g. "05-02" → "ጥቅምት ፭".
/// Anything that is not a valid "DD-MM" key is returned unchanged.
String formatDateKey(String key, {bool english = false}) {
  final parts = key.split('-');
  if (parts.length != 2) return key;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  if (day == null || month == null || month < 1 || month > 13 || day < 1 || day > 30) {
    return key;
  }
  final monthName = ethiopianMonthName(month, english: english);
  return english ? '$monthName $day' : '$monthName ${toGeezNumber(day)}';
}

const List<String> _geezOnes = ["", "፩", "፪", "፫", "፬", "፭", "፮", "፯", "፰", "፱"];
const List<String> _geezTens = ["", "፲", "፳", "፴", "፵", "፶", "፷", "፸", "፹", "፺"];

/// Converts a standard Hindu-Arabic numeral (1, 2, 3...) to a Ge'ez
/// numeral string for display. Numbers of 100 or more are left as digits.
String toGeezNumber(int n) {
  if (n <= 0) return n.toString();
  if (n >= 100) return n.toString();
  return (_geezTens[n ~/ 10]) + (_geezOnes[n % 10]);
}
