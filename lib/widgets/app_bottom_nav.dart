import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../core/l10n/strings.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final safeIndex = currentIndex.clamp(0, 6);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BottomNavigationBar(
            currentIndex: safeIndex,
            onTap: onTap,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            unselectedLabelStyle: const TextStyle(fontSize: 10),
            elevation: 0,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: const Icon(IconsaxPlusLinear.calendar), activeIcon: const Icon(IconsaxPlusBold.calendar), label: tr(context, 'nav_today')),
              BottomNavigationBarItem(icon: const Icon(IconsaxPlusLinear.calendar_2), activeIcon: const Icon(IconsaxPlusBold.calendar_2), label: tr(context, 'nav_daily')),
              BottomNavigationBarItem(icon: const Icon(IconsaxPlusLinear.book), activeIcon: const Icon(IconsaxPlusBold.book), label: tr(context, 'nav_teachings')),
              BottomNavigationBarItem(icon: const Icon(IconsaxPlusLinear.calendar_search), activeIcon: const Icon(IconsaxPlusBold.calendar_search), label: tr(context, 'nav_monthly')),
              BottomNavigationBarItem(icon: const Icon(IconsaxPlusLinear.music), activeIcon: const Icon(IconsaxPlusBold.music), label: tr(context, 'nav_mahlet')),
              BottomNavigationBarItem(icon: const Icon(IconsaxPlusLinear.search_normal), activeIcon: const Icon(IconsaxPlusBold.search_normal), label: tr(context, 'nav_search')),
              BottomNavigationBarItem(icon: const Icon(IconsaxPlusLinear.more), activeIcon: const Icon(IconsaxPlusBold.more), label: tr(context, 'nav_more')),
            ],
          ),
        ),
      ),
    );
  }
}