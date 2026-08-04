import 'package:flutter/material.dart';

import '../models/navigation_item.dart';

import 'web_shell.dart';
import 'web_sidebar.dart';
import 'web_topbar.dart';

class WebNav extends StatelessWidget {
  final int currentIndex;

  final List<Widget> screens;

  final List<NavigationItem> items;

  final ValueChanged<int> onTap;

  const WebNav({
    super.key,

    required this.currentIndex,

    required this.screens,

    required this.items,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WebShell(
      topBar: WebTopBar(),

      sidebar: WebSidebar(
        currentIndex: currentIndex,

        items: items,

        onTap: onTap,
      ),

      child: screens[currentIndex],
    );
  }
}
