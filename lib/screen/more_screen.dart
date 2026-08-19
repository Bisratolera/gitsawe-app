import 'package:flutter/material.dart';
import '../screen/bookmarks_screen.dart';
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _SettingsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              // TODO: wire share functionality
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share not implemented')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Gitsawe',
              applicationVersion: '1.0.0',
              children: const [Text('Ethiopian daily readings')],
            ),
          ),
          ListTile(
            leading:const Icon(Icons.bookmarks),
            title:const Text('Bookmarks'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookmarksScreen())),
          ),
        ],
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          ListTile(title: Text('Appearance')),
          ListTile(title: Text('Notifications')),
        ],
      ),
    );
  }
}
