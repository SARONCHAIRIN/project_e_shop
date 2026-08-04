import 'package:flutter/material.dart';

import '../models/navigation_item.dart';
import 'mobile_bottom_bar.dart';

class MobileNav extends StatelessWidget {
  final int currentIndex;

  final List<Widget> screens;

  final List<NavigationItem> items;

  final ValueChanged<int> onTap;

  const MobileNav({
    super.key,

    required this.currentIndex,

    required this.screens,

    required this.items,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: screens[currentIndex],

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 1),

        child: MobileBottomBar(
          currentIndex: currentIndex,

          items: items,

          onTap: onTap,
        ),
      ),
    );
  }
}
