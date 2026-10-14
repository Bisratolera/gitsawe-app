// widgets/gitsawe_app_bar.dart
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../core/l10n/strings.dart';
import '../core/theme/app_theme.dart';
import '../services/missed_updates_service.dart';

class GitsaweAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  /// true → back arrow, false → menu button that opens the drawer.
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
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : Builder(
              builder: (context) => IconButton(
                icon: const Icon(IconsaxPlusLinear.menu, color: Colors.white, size: 28),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
        // Bell → readings missed since the last visit, with a count badge.
        ListenableBuilder(
          listenable: MissedUpdatesService.instance,
          builder: (context, _) {
            final count = MissedUpdatesService.instance.missedDates.length;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                tooltip: tr(context, 'title_missed'),
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(IconsaxPlusLinear.notification, color: Colors.white),
                ),
                onPressed: () => MissedUpdatesService.instance.showMissedSheet(context),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
