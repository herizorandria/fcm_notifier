import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/presentation/constants/couleur_palette.dart';
import 'package:wizi_learn/core/widgets/notification_icon_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final String? title;

  const CustomAppBar({
    super.key,
    this.actions,
    this.title,
    required Color backgroundColor,
    required Color foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1,
      backgroundColor: AppColors.primary,
      centerTitle: true,
      title:
          title != null
              ? Text(
                title!,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              )
              : null,
      iconTheme: const IconThemeData(color: Colors.black87),
      actions: [
        NotificationIconButton(
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
          icon: Icons.notifications,
        ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
