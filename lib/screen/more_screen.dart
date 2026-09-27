import 'package:flutter/material.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'audio_library_screen.dart';
import 'teachings_screen.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
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
            leading: const Icon(IconsaxPlusLinear.notification),
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
            leading: Icon(IconsaxPlusLinear.bookmark_2),
            title: const Text('Bookmarks'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const BookmarksScreen())),
          ),
          ListTile(
            leading: const Icon(IconsaxPlusLinear.book),
            title: const Text('Teachings'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const TeachingsScreen())),
          ),
          ListTile(
            leading: const Icon(IconsaxPlusLinear.music),
            title: const Text('Audio Library'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AudioLibraryScreen())),
          ),
          ListTile(
            leading: const Icon(IconsaxPlusLinear.box_1),
            title: const Text('Add home screen widget'),
            subtitle: const Text('Choose from multiple Gitsawe widgets'),
            onTap: () async {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SafeArea(
                    child: Wrap(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'የ መግብያ (Widget) ዓይነት ይምረጡ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.article),
                          title: const Text('የዕለቱ ንባብ እና ስንክሳር (Reading Widget)'),
                          onTap: () async {
                            Navigator.pop(context);
                            final added = await HomeWidgetService.instance.requestPinWidget(
                              androidName: 'GitsaweReadingWidgetProvider',
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(added ? 'ንባብ መግብያ ተጠይቋል' : 'መግብያ መጠየቅ አልተቻለም')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.menu_book),
                          title: const Text('የዕለቱ ምስባክ እና ቃል (Verse Widget)'),
                          onTap: () async {
                            Navigator.pop(context);
                            final added = await HomeWidgetService.instance.requestPinWidget(
                              androidName: 'GitsaweVerseWidgetProvider',
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(added ? 'ምስባክ መግብያ ተጠይቋል' : 'መግብያ መጠየቅ አልተቻለም')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.widgets),
                          title: const Text('መካከለኛ ግጻዌ መግብያ (Medium Widget)'),
                          onTap: () async {
                            Navigator.pop(context);
                            final added = await HomeWidgetService.instance.requestPinWidget(
                              androidName: 'GitsaweWidgetMediumProvider',
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(added ? 'መካከለኛ መግብያ ተጠይቋል' : 'መግብያ መጠየቅ አልተቻለም')),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.view_compact),
                          title: const Text('ጥቅል ግጻዌ መግብያ (Compact Widget)'),
                          onTap: () async {
                            Navigator.pop(context);
                            final added = await HomeWidgetService.instance.requestPinWidget(
                              androidName: 'GitsaweWidgetCompactProvider',
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(added ? 'ጥቅል መግብያ ተጠይቋል' : 'መግብያ መጠየቅ አልተቻለም')),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(IconsaxPlusLinear.setting),
            title: const Text('Settings'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          ListTile(
            leading: const Icon(IconsaxPlusLinear.share),
            title: const Text('Share Gitsawe app'),
            onTap: () => ShareService.shareText(
              context,
              'Gitsawe — Ethiopian Orthodox daily readings, hymns, and liturgy. https://github.com/Bisratolera/gitsawe-app',
            ),
          ),
          ListTile(
            leading: const Icon(IconsaxPlusLinear.trash),
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
            leading: const Icon(IconsaxPlusLinear.info_circle),
            title: const Text('About'),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
        ],
      ),
    );
  }
}
