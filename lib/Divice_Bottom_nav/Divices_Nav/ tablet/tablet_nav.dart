import 'package:flutter/material.dart';

import '../models/navigation_item.dart';
import 'tablet_navigation_rail.dart';

class TabletNav extends StatelessWidget {
  final int currentIndex;

  final List<Widget> screens;

  final List<NavigationItem> items;

  final ValueChanged<int> onTap;

  const TabletNav({
    super.key,

    required this.currentIndex,

    required this.screens,

    required this.items,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          TabletNavigationRail(
            currentIndex: currentIndex,

            items: items,

            onTap: onTap,
          ),

          const VerticalDivider(width: 1),

          Expanded(child: screens[currentIndex]),
        ],
      ),
    );
  }
}
