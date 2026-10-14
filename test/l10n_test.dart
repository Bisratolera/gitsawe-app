import 'package:flutter_test/flutter_test.dart';
import 'package:gitsawe/core/l10n/strings.dart';

void main() {
  test('trLang returns the requested language and falls back to the key', () {
    expect(trLang('en', 'nav_today'), 'Today');
    expect(trLang('am', 'nav_today'), 'የዛሬ');
    expect(trLang('en', 'does_not_exist'), 'does_not_exist');
  });
}
