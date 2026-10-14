import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_info.dart';
import '../core/l10n/strings.dart';
import '../widgets/screen_wrapper.dart';

/// In-app copy of the privacy policy (also published as PRIVACY_POLICY.md).
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ScreenWrapper(
      currentIndex: -1,
      title: tr(context, 'title_privacy'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(context, 'privacy_body'),
              style: const TextStyle(fontSize: 15, height: 1.7),
            ),
            const SizedBox(height: 20),
            Text(tr(context, 'privacy_full'),
                style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant)),
            const SizedBox(height: 6),
            SelectableText(
              AppInfo.privacyPolicyUrl,
              style: TextStyle(fontSize: 13, color: colors.primary),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final copied = tr(context, 'about_copied');
                await Clipboard.setData(const ClipboardData(text: AppInfo.privacyPolicyUrl));
                messenger.showSnackBar(SnackBar(content: Text(copied)));
              },
              icon: const Icon(Icons.copy, size: 16),
              label: Text(tr(context, 'about_copy')),
            ),
          ],
        ),
      ),
    );
  }
}
