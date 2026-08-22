import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../screen/today_screen.dart';
import '../screen/calendar_screen.dart';
import '../screen/mahlet_screen.dart';
import '../screen/search_screen.dart';
import '../screen/more_screen.dart';
import '../screen/bookmarks_screen.dart';
import '../screen/settings_screen.dart';
import '../screen/about_screen.dart';

class AppSidebar extends StatelessWidget {
  final int currentIndex;

  const AppSidebar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.maroon,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/splash.png',
                    height: 60,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ግጻዌ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Gitsawe Lectionary',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.today,
                  label: 'ዛሬ',
                  index: 0,
                  destination: const TodayScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.calendar_month,
                  label: 'የወር',
                  index: 1,
                  destination: const CalendarScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.music_note,
                  label: 'ማኅሌት',
                  index: 2,
                  destination: const MahletScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.search,
                  label: 'ፍለጋ',
                  index: 3,
                  destination: const SearchScreen(),
                ),
                const Divider(),
                _buildNavItem(
                  context,
                  icon: Icons.bookmarks,
                  label: 'የእኔ (Bookmarks)',
                  destination: const BookmarksScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings,
                  label: 'Settings',
                  destination: const SettingsScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.info_outline,
                  label: 'About',
                  destination: const AboutScreen(),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    int? index,
    required Widget destination,
  }) {
    final isSelected = index != null && currentIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.maroon : Colors.grey[700],
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.maroon : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.maroon.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (!isSelected) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => destination),
          );
        }
      },
    );
  }
}
