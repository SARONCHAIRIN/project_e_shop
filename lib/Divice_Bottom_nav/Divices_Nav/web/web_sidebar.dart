import 'package:flutter/material.dart';

import '../models/navigation_item.dart';

class WebSidebar extends StatelessWidget {
  final int currentIndex;

  final List<NavigationItem> items;

  final ValueChanged<int> onTap;

  const WebSidebar({
    super.key,

    required this.currentIndex,

    required this.items,

    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,

      padding: const EdgeInsets.all(20),

      child: Column(
        children: [
          ...List.generate(items.length, (index) {
            final item = items[index];

            return ListTile(
              selected: currentIndex == index,

              leading: Icon(item.icon),

              title: Text(item.label),

              onTap: () => onTap(index),
            );
          }),
        ],
      ),
    );
  }
}
