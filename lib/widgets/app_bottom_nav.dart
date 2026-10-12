import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
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
            items: const [
              BottomNavigationBarItem(icon: Icon(IconsaxPlusLinear.calendar), activeIcon: Icon(IconsaxPlusBold.calendar), label: 'የዛሬ'),
              BottomNavigationBarItem(icon: Icon(IconsaxPlusLinear.calendar_2), activeIcon: Icon(IconsaxPlusBold.calendar_2), label: 'የየእለት'),
              BottomNavigationBarItem(icon: Icon(IconsaxPlusLinear.book), activeIcon: Icon(IconsaxPlusBold.book), label: 'ትምህርቶች'),
              BottomNavigationBarItem(icon: Icon(IconsaxPlusLinear.calendar_search), activeIcon: Icon(IconsaxPlusBold.calendar_search), label: 'የወር'),
              BottomNavigationBarItem(icon: Icon(IconsaxPlusLinear.music), activeIcon: Icon(IconsaxPlusBold.music), label: 'ማኅሌት'),
              BottomNavigationBarItem(icon: Icon(IconsaxPlusLinear.search_normal), activeIcon: Icon(IconsaxPlusBold.search_normal), label: 'ፍለጋ'),
              BottomNavigationBarItem(icon: Icon(IconsaxPlusLinear.more), activeIcon: Icon(IconsaxPlusBold.more), label: 'ተጨማሪ'),
            ],
          ),
        ),
      ),
    );
  }
}