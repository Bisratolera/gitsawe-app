import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

import '../widgets/screen_wrapper.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      currentIndex: -1,
      title: 'About',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/splash.png',
              height: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              'ግጻዌ',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.maroon,
              ),
            ),
            const Text(
              'Gitsawe Lectionary',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'የኢትዮጵያ ኦርቶዶክስ ተዋሕዶ ቤተ ክርስቲያን ግጻዌ፦ የዕለት፣ የወር፣ የዘመንና የበዓላት ንባባት፣ ምስባክ፣ ወንጌል፣ ስንክሳርና ማኅሌት።',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const ListTile(
              title: Text('Version'),
              trailing: Text('1.0.0'),
            ),
            const ListTile(
              title: Text('Developer'),
              trailing: Text('Gitsawe Team'),
            ),
            const ListTile(
              title: Text('Website'),
              trailing: Text('lovable.app'),
            ),
            const SizedBox(height: 40),
            const Text(
              '© 2026 Gitsawe. All rights reserved.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
