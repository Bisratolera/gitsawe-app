import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gitsawe/services/bookmark_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await BookmarkService.instance.load();
  });

  test('load notifies listeners after restoring bookmarks', () async {
    final service = BookmarkService.instance;
    var notified = false;
    service.addListener(() {
      notified = true;
    });

    SharedPreferences.setMockInitialValues({
      'bookmarks': [
        '{"date":"01-01","title":"Test reading"}',
      ],
    });

    await service.load();

    expect(notified, isTrue);
    expect(service.bookmarks.length, 1);
    expect(service.bookmarks.first.title, 'Test reading');
  });
}
