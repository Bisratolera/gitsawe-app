import 'package:flutter/material.dart';
import '../core/app_info.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../screen/audio_library_screen.dart';
import '../screen/bookmarks_screen.dart';
import '../screen/calendar_screen.dart';
import '../screen/daily_gitsawe_screen.dart';
import '../screen/feasts_screen.dart';
import '../screen/mahlet_screen.dart';
import '../screen/more_screen.dart';
import '../screen/search_screen.dart';
import '../screen/settings_screen.dart';
import '../screen/teachings_screen.dart';
import '../screen/today_screen.dart';

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
              image: DecorationImage(
                image: AssetImage('assets/images/splash.png'),
                opacity: 0.1,
                alignment: Alignment.centerRight,
                scale: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/splash.png',
                    height: 40,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ግጻዌ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  tr(context, 'drawer_subtitle'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.today_outlined,
                  label: tr(context, 'today'),
                  index: 0,
                  destination: const TodayScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.calendar_view_day_outlined,
                  label: tr(context, 'nav_daily'),
                  index: 1,
                  destination: const DailyGitsaweScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.menu_book_rounded,
                  label: tr(context, 'nav_teachings'),
                  index: 2,
                  destination: const TeachingsScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.calendar_month_outlined,
                  label: tr(context, 'nav_monthly'),
                  index: 3,
                  destination: const CalendarScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.event_repeat_outlined,
                  label: tr(context, 'nav_seasonal'),
                  destination: const CalendarScreen(seasonal: true),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.celebration_outlined,
                  label: tr(context, 'nav_feasts'),
                  destination: const FeastsScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.music_note_outlined,
                  label: tr(context, 'nav_mahlet'),
                  index: 4,
                  destination: const MahletScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.search_outlined,
                  label: tr(context, 'nav_search'),
                  index: 5,
                  destination: const SearchScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.library_music_outlined,
                  label: tr(context, 'nav_audio'),
                  destination: const AudioLibraryScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.bookmark_border,
                  label: tr(context, 'title_bookmarks'),
                  destination: const BookmarksScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.settings_outlined,
                  label: tr(context, 'title_settings'),
                  destination: const SettingsScreen(),
                ),
                _buildNavItem(
                  context,
                  icon: Icons.more_horiz_outlined,
                  label: tr(context, 'nav_more'),
                  index: 6,
                  destination: const MoreScreen(),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'v${AppInfo.version}',
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
    final colors = Theme.of(context).colorScheme;
    final isSelected = index != null && currentIndex == index;

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? colors.primary : colors.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => destination),
          );
        }
      },
    );
  }
}
