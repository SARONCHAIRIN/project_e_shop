import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';

import '../models/navigation_item.dart';

class MobileBottomBar extends StatelessWidget {
  final int currentIndex;

  final List<NavigationItem> items;

  final ValueChanged<int> onTap;

  const MobileBottomBar({
    super.key,

    required this.currentIndex,

    required this.items,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CrystalNavigationBar(
      currentIndex: currentIndex,

      backgroundColor: Colors.white.withOpacity(0.2),

      outlineBorderColor: Colors.grey.withOpacity(0.2),

      borderRadius: 35,

      boxShadow: [
        BoxShadow(
          color: Colors.blue.shade50,

          blurStyle: BlurStyle.outer,

          blurRadius: 1,
        ),
      ],

      selectedItemColor: Colors.blueAccent,

      unselectedItemColor: Colors.grey,

      onTap: onTap,

      items: items.map((item) {
        return CrystalNavigationBarItem(
          icon: item.icon,

          selectedColor: Colors.blueAccent,
        );
      }).toList(),
    );
  }
}
