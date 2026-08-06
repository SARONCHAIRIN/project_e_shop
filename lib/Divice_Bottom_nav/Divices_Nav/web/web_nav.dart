import 'package:flutter/material.dart';

import '../ tablet/tablet_nav.dart';
import '../mobiles/mobile_nav.dart';
import '../models/navigation_item.dart';

import 'web_shell.dart';
import 'web_sidebar.dart';

class WebNav extends StatelessWidget {
  final int currentIndex;

  final List<Widget> screens;

  final List<NavigationItem> items;

  final ValueChanged<int> onTap;

  // Change dynamic to your actual repository type, or use Provider/InheritedWidget/context.read
  final dynamic authRepository;

  const WebNav({
    super.key,
    required this.currentIndex,
    required this.screens,
    required this.items,
    required this.onTap,
    this.authRepository,
  });
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Phone Browser
        if (width < 600) {
          return MobileNav(
            currentIndex: currentIndex,
            screens: screens,
            items: items,
            onTap: onTap,
          );
        }

        // Tablet Browser
        if (width < 1024) {
          return TabletNav(
            currentIndex: currentIndex,
            screens: screens,
            items: items,
            onTap: onTap,
          );
        }

        // Desktop Browser
        return WebShell(
          topBar: const SizedBox.shrink(),
          sidebar: WebSidebar(
            currentIndex: currentIndex,
            items: items,
            onTap: onTap,
          ),
          child: screens[currentIndex],
        );
      },
    );
  }
}