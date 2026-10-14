import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../core/l10n/strings.dart';
import '../services/app_settings.dart';
import '../services/daily_refresh.dart';
import '../services/gitsawe_service.dart';
import '../services/notification_service.dart';
import '../widgets/screen_wrapper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _toggleNotifications(BuildContext context, bool value) async {
    final settings = AppSettings.instance;
    final messenger = ScaffoldMessenger.of(context);
    final deniedMessage = tr(context, 'notif_permission_denied');

    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted && NotificationService.instance.supportsRuntimePermission) {
        // The user refused: keep the switch off so it reflects reality.
        await settings.setNotificationsEnabled(false);
        messenger.showSnackBar(SnackBar(content: Text(deniedMessage)));
        return;
      }
    }
    await settings.setNotificationsEnabled(value);
    await DailyRefresh.instance.syncReminders();
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final settings = AppSettings.instance;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.reminderHour, minute: settings.reminderMinute),
    );
    if (picked == null) return;
    await settings.setReminderTime(picked.hour, picked.minute);
    await DailyRefresh.instance.syncReminders();
  }

  Future<void> _setLanguage(BuildContext context, String lang) async {
    await AppSettings.instance.setLanguage(lang);
    // Reminder text and widget placeholders are language dependent.
    await DailyRefresh.instance.run();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, child) {
        final settings = AppSettings.instance;
        final reminderTime = TimeOfDay(
          hour: settings.reminderHour,
          minute: settings.reminderMinute,
        ).format(context);

        return ScreenWrapper(
          currentIndex: -1,
          title: tr(context, 'title_settings'),
          body: ListView(
            children: [
              _SettingsSection(
                title: tr(context, 'settings_general'),
                children: [
                  ListTile(
                    leading: const Icon(IconsaxPlusLinear.language_square),
                    title: Text(tr(context, 'settings_language')),
                    subtitle: Text(settings.language == 'am' ? 'አማርኛ' : 'English'),
                    trailing: const Icon(IconsaxPlusLinear.arrow_right_3),
                    onTap: () => showDialog(
                      context: context,
                      builder: (dialogContext) => SimpleDialog(
                        title: Text(tr(context, 'settings_language')),
                        children: [
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _setLanguage(context, 'am');
                            },
                            child: const Text('አማርኛ (Amharic)'),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _setLanguage(context, 'en');
                            },
                            child: const Text('English'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(IconsaxPlusLinear.notification),
                    title: Text(tr(context, 'settings_notifications')),
                    subtitle: Text(
                      tr(context, settings.notificationsEnabled ? 'settings_on' : 'settings_off'),
                    ),
                    trailing: Switch(
                      value: settings.notificationsEnabled,
                      onChanged: (v) => _toggleNotifications(context, v),
                    ),
                  ),
                  ListTile(
                    enabled: settings.notificationsEnabled,
                    leading: const Icon(Icons.access_time),
                    title: Text(tr(context, 'settings_reminder_time')),
                    subtitle: Text(reminderTime),
                    trailing: const Icon(IconsaxPlusLinear.arrow_right_3),
                    onTap: settings.notificationsEnabled ? () => _pickReminderTime(context) : null,
                  ),
                ],
              ),
              _SettingsSection(
                title: tr(context, 'settings_appearance'),
                children: [
                  ListTile(
                    leading: const Icon(IconsaxPlusLinear.text),
                    title: Text(tr(context, 'settings_font')),
                    subtitle: Text(_fontSizeLabel(context, settings.textScale)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: tr(context, 'font_decrease'),
                          onPressed: settings.textScale <= AppSettings.minTextScale + 0.001
                              ? null
                              : () => settings.setTextScale(settings.textScale - 0.1),
                          icon: const Icon(IconsaxPlusLinear.minus),
                        ),
                        IconButton(
                          tooltip: tr(context, 'font_increase'),
                          onPressed: settings.textScale >= AppSettings.maxTextScale - 0.001
                              ? null
                              : () => settings.setTextScale(settings.textScale + 0.1),
                          icon: const Icon(IconsaxPlusLinear.add),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(IconsaxPlusLinear.moon),
                    title: Text(tr(context, 'settings_dark')),
                    trailing: Switch(
                      value: settings.isDarkMode,
                      onChanged: settings.setDarkMode,
                    ),
                  ),
                ],
              ),
              _SettingsSection(
                title: tr(context, 'settings_storage'),
                children: [
                  ListTile(
                    leading: const Icon(Icons.refresh),
                    title: Text(tr(context, 'clear_cache')),
                    subtitle: Text(tr(context, 'clear_cache_sub')),
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final done = tr(context, 'cache_cleared');
                      await GitsaweService.instance.clearCache();
                      messenger.showSnackBar(SnackBar(content: Text(done)));
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static String _fontSizeLabel(BuildContext context, double scale) {
    if (scale < 0.95) return tr(context, 'font_small');
    if (scale > 1.15) return tr(context, 'font_large');
    if (scale > 1.05) return tr(context, 'font_medium_large');
    return tr(context, 'font_medium');
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}
