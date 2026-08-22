import 'package:flutter/material.dart';
import '../core/navigation/main_tabs.dart';
import '../widgets/gitsawe_app_bar.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_bottom_nav.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

import '../widgets/screen_wrapper.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentIndex: 4,
      title: 'ተጨማሪ',
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.bookmarks),
            title: const Text('Bookmarks'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const BookmarksScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Share not implemented'))),
          ),
        ],
      ),
    );
  }
}
