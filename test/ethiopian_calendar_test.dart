import 'package:flutter_test/flutter_test.dart';
import 'package:gitsawe/core/utils/ethiopian_calendar.dart';

void main() {
  test('Ethiopian new year 2019 falls on 11 September 2026', () {
    final d = EthiopianDate.fromGregorian(DateTime(2026, 9, 11));
    expect((d.year, d.month, d.day), (2019, 1, 1));
  });

  test('day before is Pagume 5 of 2018', () {
    final d = EthiopianDate.fromGregorian(DateTime(2026, 9, 10));
    expect((d.year, d.month, d.day), (2018, 13, 5));
  });

  test('Genna (7 Jan 2024) is Tahsas 28', () {
    final d = EthiopianDate.fromGregorian(DateTime(2024, 1, 7));
    expect(d.dateKey, '28-04');
  });

  test('leap-year Pagume has a 6th day', () {
    final d = EthiopianDate.fromGregorian(DateTime(2027, 9, 11));
    expect((d.year, d.month, d.day), (2019, 13, 6));
  });

  test('formatDateKey', () {
    expect(formatDateKey('05-02'), 'ጥቅምት ፭');
    expect(formatDateKey('05-02', english: true), 'Tikimt 5');
    expect(formatDateKey('01-neneweTsom'), '01-neneweTsom');
    expect(formatDateKey('40-01'), '40-01');
  });

  test('toGeezNumber', () {
    expect(toGeezNumber(1), '፩');
    expect(toGeezNumber(30), '፴');
    expect(toGeezNumber(25), '፳፭');
  });
}
