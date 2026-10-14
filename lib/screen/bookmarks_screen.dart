import 'package:flutter/material.dart';

import '../core/l10n/strings.dart';
import '../core/utils/ethiopian_calendar.dart';
import '../services/bookmark_service.dart';
import '../services/gitsawe_service.dart';
import '../widgets/screen_wrapper.dart';
import 'daily_gitsawe_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BookmarkService.instance,
      builder: (context, child) {
        final bookmarks = BookmarkService.instance.bookmarks;
        final english = LangScope.of(context) == 'en';
        return ScreenWrapper(
          currentIndex: -1,
          title: tr(context, 'title_bookmarks'),
          body: bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(tr(context, 'no_bookmarks'), style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(tr(context, 'no_bookmarks_hint')),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: bookmarks.length,
                  separatorBuilder: (_, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final bookmark = bookmarks[index];
                    return ListTile(
                      leading: const Icon(Icons.bookmark),
                      title: Text(bookmark.title),
                      subtitle: Text(formatDateKey(bookmark.date, english: english)),
                      onTap: () {
                        final entry = GitsaweService.instance
                            .findByDateAndTitle(bookmark.date, bookmark.title);
                        if (entry == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(tr(context, 'bookmark_missing'))),
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DailyGitsaweDetailScreen(entry: entry),
                          ),
                        );
                      },
                      trailing: IconButton(
                        tooltip: tr(context, 'remove_bookmark'),
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => BookmarkService.instance.toggle(bookmark),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
