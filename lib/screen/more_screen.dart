import 'package:flutter/material.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'audio_library_screen.dart';
import 'teachings_screen.dart';

import '../services/gitsawe_service.dart';
import '../services/home_widget_service.dart';
import '../services/missed_updates_service.dart';
import '../services/share_service.dart';
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
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Missed updates'),
            trailing: ListenableBuilder(
              listenable: MissedUpdatesService.instance,
              builder: (_, _) {
                final count = MissedUpdatesService.instance.missedDates.length;
                return count == 0
                    ? const SizedBox.shrink()
                    : CircleAvatar(
                        radius: 11,
                        backgroundColor: Colors.red,
                        child: Text(
                          '$count',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      );
              },
            ),
            onTap: () => MissedUpdatesService.instance.showMissedSheet(context),
          ),
          ListTile(
            leading: const Icon(Icons.bookmarks),
            title: const Text('Bookmarks'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const BookmarksScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: const Text('Teachings'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const TeachingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.library_music_outlined),
            title: const Text('Audio Library'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AudioLibraryScreen())),
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
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Gitsawe app'),
            onTap: () => ShareService.shareText(
              context,
              'Gitsawe — Ethiopian Orthodox daily readings, hymns, and liturgy. https://github.com/Bisratolera/gitsawe-app',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear cache'),
            subtitle: const Text('Refetches today\'s reading and audio index'),
            onTap: () async {
              await GitsaweService.instance.clearCache();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared — data will refetch.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
        ],
      ),
    );
  }
}
