import 'package:flutter/material.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

import '../services/share_service.dart';
import '../services/home_widget_service.dart';
import '../widgets/screen_wrapper.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentIndex: 6,
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
            onTap: () => ShareService.shareText(
              context,
              'Gitsawe - Ethiopian Orthodox daily readings',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.widgets_outlined),
            title: const Text('Add home screen widget'),
            onTap: () async {
              final added = await HomeWidgetService.instance.requestPinWidget();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    added
                        ? 'Choose a location for the Gitsawe widget.'
                        : 'This launcher does not support adding widgets from the app.',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
