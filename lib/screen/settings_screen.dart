import 'package:flutter/material.dart';
import '../widgets/gitsawe_app_bar.dart';
import '../widgets/app_sidebar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GitsaweAppBar(title: 'Settings'),
      drawer: const AppSidebar(currentIndex: -1),
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
          const _SettingsSection(
            title: 'Appearance',
            children: [
              ListTile(
                leading: Icon(Icons.text_format),
                title: Text('Font Size'),
                subtitle: Text('Medium'),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                leading: Icon(Icons.dark_mode),
                title: Text('Dark Mode'),
                trailing: Switch(value: false, onChanged: null),
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
