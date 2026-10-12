import 'package:flutter_test/flutter_test.dart';

import 'package:gitsawe/services/gitsawe_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('GitsaweService loads local asset data by default', () async {
    await GitsaweService.instance.load(allowRemote: false);
    expect(GitsaweService.instance.isLoaded, isTrue);
    expect(GitsaweService.instance.allDaily, isNotEmpty);
  });
}
