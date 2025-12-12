import 'package:flutter/material.dart';
import 'package:jusel_app/core/utils/theme.dart';

class JuselAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;

  const JuselAppBar({
    super.key,
    required this.title,
    this.automaticallyImplyLeading = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: JuselTextStyles.headlineMedium(context),
      ),
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: JuselColors.background(context),
      foregroundColor: JuselColors.foreground(context),
      elevation: 0,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
