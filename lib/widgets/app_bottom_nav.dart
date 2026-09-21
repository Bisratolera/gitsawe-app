import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final safeIndex = currentIndex.clamp(0, 6);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: onTap,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 0,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today_outlined), activeIcon: Icon(Icons.today), label: 'የዛሬ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_view_day_outlined), activeIcon: Icon(Icons.calendar_view_day), label: 'የየእለት'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), activeIcon: Icon(Icons.menu_book_rounded), label: 'ትምህርቶች'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month), label: 'የወር'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note_outlined), activeIcon: Icon(Icons.music_note), label: 'ማኅሌት'),
          BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'ፍለጋ'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz_outlined), activeIcon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}