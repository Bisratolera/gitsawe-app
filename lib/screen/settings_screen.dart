import 'package:flutter/material.dart';

import '../services/app_settings.dart';
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
              const _SettingsSection(
                title: 'General',
                children: [
                  ListTile(
                    leading: Icon(Icons.language),
                    title: Text('Language'),
                    subtitle: Text('Default (Amharic)'),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Notifications'),
                    trailing: Switch(value: true, onChanged: null),
                  ),
                ],
              ),
              _SettingsSection(
                title: 'Appearance',
                children: [
                  ListTile(
                    leading: const Icon(Icons.text_format),
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
                          icon: const Icon(Icons.remove),
                        ),
                        IconButton(
                          tooltip: 'Increase text size',
                          onPressed: () => AppSettings.instance.setTextScale(
                            AppSettings.instance.textScale + 0.1,
                          ),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: AppSettings.instance.isDarkMode,
                      onChanged: AppSettings.instance.setDarkMode,
                    ),
                  ),
                ],
              ),
              _SettingsSection(
                title: 'Storage',
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Clear Cache'),
                    onTap: () {
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
