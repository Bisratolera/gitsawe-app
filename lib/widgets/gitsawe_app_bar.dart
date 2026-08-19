import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GitsaweAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GitsaweAppBar({
    super.key,
    // Set a meaningful default fallback string instead of an empty one
    this.title = 'ግጻዌ',
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.maroon,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/images/splash.png'),
      ),
      title: Text(
        title, 
        style: const TextStyle(
          fontSize: 18, 
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white), 
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white), 
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
