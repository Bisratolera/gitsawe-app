import 'package:flutter/material.dart';

import '../services/bookmark_service.dart';
import '../widgets/screen_wrapper.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context){
    return ListenableBuilder(
      listenable: BookmarkService.instance,
      builder: (context, child) {
        final bookmarks = BookmarkService.instance.bookmarks;
        return ScreenWrapper(
          currentIndex: -1,
          title: 'የእኔ (Bookmarks)',
          body: bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('No bookmarks yet', style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      const Text('Your saved readings will appear here'),
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
                      subtitle: Text(bookmark.date),
                      trailing: IconButton(
                        tooltip: 'Remove bookmark',
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
