import 'package:flutter/material.dart';
import 'app_sidebar.dart';
import 'app_bottom_nav.dart';
import 'mini_player_bar.dart';
import 'gitsawe_app_bar.dart';
import '../core/navigation/main_tabs.dart';
import '../core/theme/app_theme.dart';

class ScreenWrapper extends StatelessWidget {
  final Widget body;
  final String title;
  final int currentIndex;
  final bool showHeader;
  final bool useContainer;

  const ScreenWrapper({
    super.key,
    required this.body,
    required this.title,
    required this.currentIndex,
    this.showHeader = true,
    this.useContainer = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget mainContent = body;

    if (useContainer) {
      mainContent = Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: body,
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.maroon,
      appBar: showHeader ? GitsaweAppBar(title: title, showBackArrow: true,) : null,
      drawer: AppSidebar(currentIndex: currentIndex),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 88),
        child: mainContent,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayerBar(),
          if (currentIndex >= 0)
            AppBottomNav(
              currentIndex: currentIndex,
              onTap: (i) => goToMainTab(context, i),
            ),
        ],
      ),
    );
  }
}
