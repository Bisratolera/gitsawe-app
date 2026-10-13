import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import '../services/app_settings.dart';
import '../services/gitsawe_service.dart';
import '../widgets/screen_wrapper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, child) {
        return ScreenWrapper(
          currentIndex: -1,
          title: 'Settings',
          body: ListView(
            children: [
              _SettingsSection(
                title: 'General',
                children: [
                  ListTile(
                    leading: const Icon(IconsaxPlusLinear.language_square),
                    title: const Text('Language'),
                    subtitle: Text(AppSettings.instance.language == 'am' ? 'አማርኛ' : 'English'),
                    trailing: const Icon(IconsaxPlusLinear.arrow_right_3),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => SimpleDialog(
                        title: const Text('Language'),
                        children: [
                          SimpleDialogOption(
                            onPressed: () {
                              AppSettings.instance.setLanguage('am');
                              Navigator.pop(context);
                            },
                            child: const Text('አማርኛ (Amharic)'),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              AppSettings.instance.setLanguage('en');
                              Navigator.pop(context);
                            },
                            child: const Text('English'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(IconsaxPlusLinear.notification),
                    title: const Text('Notifications'),
                    subtitle: Text(AppSettings.instance.notificationsEnabled ? 'On' : 'Off'),
                    trailing: Switch(
                      value: AppSettings.instance.notificationsEnabled,
                      onChanged: AppSettings.instance.setNotificationsEnabled,
                    ),
                  ),
                ],
              ),
              _SettingsSection(
                title: 'Appearance',
                children: [
                  ListTile(
                    leading: const Icon(IconsaxPlusLinear.text),
                    title: const Text('Font Size'),
                    subtitle: Text(_fontSizeLabel(AppSettings.instance.textScale)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Decrease text size',
                          onPressed: () => AppSettings.instance.setTextScale(
                            AppSettings.instance.textScale - 0.1,
                          ),
                          icon: const Icon(IconsaxPlusLinear.minus),
                        ),
                        IconButton(
                          tooltip: 'Increase text size',
                          onPressed: () => AppSettings.instance.setTextScale(
                            AppSettings.instance.textScale + 0.1,
                          ),
                          icon: const Icon(IconsaxPlusLinear.add),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(IconsaxPlusLinear.moon),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: AppSettings.instance.isDarkMode,
                      onChanged: AppSettings.instance.setDarkMode,
                    ),
                  ),
                ],
              ),
              _SettingsSection(
                title: 'App Updates',
                children: const [
                  _OtaUpdateTile(),
                ],
              ),
              _SettingsSection(
                title: 'Storage',
                children: [
                  ListTile(
                    leading: const Icon(IconsaxPlusLinear.trash),
                    title: const Text('Clear Cache'),
                    onTap: () async {
                      await GitsaweService.instance.clearCache();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cache cleared')),
                      );
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

  static String _fontSizeLabel(double scale) {
    if (scale < 0.95) return 'Small';
    if (scale > 1.15) return 'Large';
    if (scale > 1.05) return 'Medium large';
    return 'Medium';
  }
}

class _OtaUpdateTile extends StatefulWidget {
  const _OtaUpdateTile();

  @override
  State<_OtaUpdateTile> createState() => _OtaUpdateTileState();
}

class _OtaUpdateTileState extends State<_OtaUpdateTile> {
  final ShorebirdUpdater _updater = ShorebirdUpdater();
  bool _checking = false;

  Future<void> _checkForUpdates() async {
    if (_checking) return;
    setState(() => _checking = true);

    var message = 'Gitsawe is up to date.';
    try {
      if (!_updater.isAvailable) {
        message = 'OTA updates are available only in Shorebird release builds.';
      } else {
        final status = await _updater.checkForUpdate();
        if (status == UpdateStatus.outdated) {
          await _updater.update();
          message = 'Update downloaded. Restart Gitsawe to apply it.';
        } else if (status == UpdateStatus.restartRequired) {
          message = 'An update is ready. Restart Gitsawe to apply it.';
        } else if (status == UpdateStatus.unavailable) {
          message = 'OTA updates are unavailable in this build.';
        }
      }
    } catch (error) {
      message = 'Could not check for updates: $error';
    } finally {
      if (!mounted) return;
      setState(() => _checking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(IconsaxPlusLinear.refresh),
      title: const Text('Check for updates'),
      subtitle: const Text('Download the latest app patch'),
      trailing: _checking
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(IconsaxPlusLinear.arrow_right_3),
      onTap: _checking ? null : _checkForUpdates,
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
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
              color: Colors.grey[600],
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
