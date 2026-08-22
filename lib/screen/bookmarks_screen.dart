import 'package:flutter/material.dart';
import '../widgets/gitsawe_app_bar.dart';
import '../widgets/app_sidebar.dart';

import '../widgets/screen_wrapper.dart';

class BookmarksScreen extends StatelessWidget{
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context){
    return ScreenWrapper(
      currentIndex: -1,
      title: 'የእኔ (Bookmarks)',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No bookmarks yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your saved readings will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
