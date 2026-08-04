import 'package:flutter/material.dart';

import '../models/navigation_item.dart';
import 'desktop_shell.dart';
import 'desktop_sidebar.dart';

class DesktopNav extends StatelessWidget {
  final int currentIndex;

  final List<Widget> screens;

  final List<NavigationItem> items;

  final ValueChanged<int> onTap;

  const DesktopNav({
    super.key,

    required this.currentIndex,

    required this.screens,

    required this.items,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopShell(
      sidebar: DesktopSidebar(
        currentIndex: currentIndex,

        items: items,

        onTap: onTap,
      ),

      child: screens[currentIndex],
    );
  }
}
