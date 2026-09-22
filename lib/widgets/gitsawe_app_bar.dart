// widgets/gitsawe_app_bar.dart
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GitsaweAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackArrow;

  const GitsaweAppBar({
    super.key,
    this.title = 'ግጻዌ',
    this.showBackArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.maroon,
      elevation: 0,
      centerTitle: true,
      leading: showBackArrow
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_open_rounded, color: Colors.white, size: 28),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}