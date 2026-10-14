import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_info.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../widgets/gitsawe_app_bar.dart';
import 'privacy_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _copy(BuildContext context, String text) async {
    final messenger = ScaffoldMessenger.of(context);
    final copied = tr(context, 'about_copied');
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(SnackBar(content: Text(copied)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maroonDark,
      appBar: GitsaweAppBar(title: tr(context, 'title_about'), showBackArrow: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Image.asset('assets/images/splash.png', color: Colors.white),
              ),
              const SizedBox(height: 28),
              Text(
                tr(context, 'about_heading'),
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                tr(context, 'about_p1'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 20),
              Text(
                tr(context, 'about_p2'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 40),
              const Divider(color: Colors.white24),
              ListTile(
                title: Text(tr(context, 'about_version'), style: const TextStyle(color: Colors.white70)),
                trailing: const Text(
                  '${AppInfo.version} (${AppInfo.buildNumber})',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: Colors.white70),
                title: Text(tr(context, 'about_privacy'), style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                onTap: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const PrivacyScreen())),
              ),
              ListTile(
                leading: const Icon(Icons.code, color: Colors.white70),
                title: Text(tr(context, 'about_source'), style: const TextStyle(color: Colors.white)),
                subtitle: const Text(AppInfo.repoUrl, style: TextStyle(color: Colors.white54, fontSize: 12)),
                trailing: const Icon(Icons.copy, color: Colors.white54, size: 18),
                onTap: () => _copy(context, AppInfo.repoUrl),
              ),
              ListTile(
                leading: const Icon(Icons.bug_report_outlined, color: Colors.white70),
                title: Text(tr(context, 'about_report'), style: const TextStyle(color: Colors.white)),
                subtitle: const Text(AppInfo.issuesUrl, style: TextStyle(color: Colors.white54, fontSize: 12)),
                trailing: const Icon(Icons.copy, color: Colors.white54, size: 18),
                onTap: () => _copy(context, AppInfo.issuesUrl),
              ),
              const SizedBox(height: 32),
              const Text(
                'developed in love by @thesudoguy',
                style: TextStyle(color: Colors.white38, fontFamily: 'monospace', fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
