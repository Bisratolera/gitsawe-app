import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../core/app_info.dart';
import '../core/l10n/strings.dart';
import '../services/home_widget_service.dart';
import '../services/missed_updates_service.dart';
import '../services/share_service.dart';
import '../widgets/screen_wrapper.dart';
import 'about_screen.dart';
import 'audio_library_screen.dart';
import 'bookmarks_screen.dart';
import 'calendar_screen.dart';
import 'feasts_screen.dart';
import 'privacy_screen.dart';
import 'settings_screen.dart';
import 'teachings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentIndex: 6,
      title: tr(context, 'title_more'),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(IconsaxPlusLinear.notification),
            title: Text(tr(context, 'missed_updates')),
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
            leading: const Icon(IconsaxPlusLinear.bookmark_2),
            title: Text(tr(context, 'title_bookmarks')),
            onTap: () => _open(context, const BookmarksScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.event_repeat_outlined),
            title: Text(tr(context, 'title_seasonal')),
            onTap: () => _open(context, const CalendarScreen(seasonal: true)),
          ),
          ListTile(
            leading: const Icon(Icons.celebration_outlined),
            title: Text(tr(context, 'title_feasts')),
            onTap: () => _open(context, const FeastsScreen()),
          ),
          ListTile(
            leading: const Icon(IconsaxPlusLinear.book),
            title: Text(tr(context, 'title_teachings')),
            onTap: () => _open(context, const TeachingsScreen()),
          ),
          ListTile(
            leading: const Icon(IconsaxPlusLinear.music),
            title: Text(tr(context, 'title_audio')),
            onTap: () => _open(context, const AudioLibraryScreen()),
          ),
          ListTile(
            leading: const Icon(IconsaxPlusLinear.box_1),
            title: Text(tr(context, 'more_widget')),
            subtitle: Text(tr(context, 'more_widget_sub')),
            onTap: () => _showWidgetPicker(context),
          ),
          ListTile(
            leading: const Icon(IconsaxPlusLinear.setting),
            title: Text(tr(context, 'title_settings')),
            onTap: () => _open(context, const SettingsScreen()),
          ),
          ListTile(
            leading: const Icon(IconsaxPlusLinear.share),
            title: Text(tr(context, 'share_app')),
            onTap: () => ShareService.shareText(
              context,
              '${tr(context, 'share_app_text')} ${AppInfo.repoUrl}',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(tr(context, 'title_privacy')),
            onTap: () => _open(context, const PrivacyScreen()),
          ),
          ListTile(
            leading: const Icon(IconsaxPlusLinear.info_circle),
            title: Text(tr(context, 'title_about')),
            onTap: () => _open(context, const AboutScreen()),
          ),
        ],
      ),
    );
  }

  static const List<({String android, IconData icon, String labelKey})> _widgets = [
    (android: 'GitsaweReadingWidgetProvider', icon: Icons.article, labelKey: 'widget_reading'),
    (android: 'GitsaweVerseWidgetProvider', icon: Icons.menu_book, labelKey: 'widget_verse'),
    (android: 'GitsaweWidgetMediumProvider', icon: Icons.widgets, labelKey: 'widget_medium'),
    (android: 'GitsaweWidgetCompactProvider', icon: Icons.view_compact, labelKey: 'widget_compact'),
  ];

  void _showWidgetPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  tr(sheetContext, 'widget_pick'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              for (final w in _widgets)
                ListTile(
                  leading: Icon(w.icon),
                  title: Text(tr(sheetContext, w.labelKey)),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final okText = tr(context, 'widget_requested');
                    final failText = tr(context, 'widget_failed');
                    Navigator.pop(sheetContext);
                    final added = await HomeWidgetService.instance.requestPinWidget(
                      androidName: w.android,
                    );
                    messenger.showSnackBar(SnackBar(content: Text(added ? okText : failText)));
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
