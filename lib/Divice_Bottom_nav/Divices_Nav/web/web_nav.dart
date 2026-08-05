import 'package:flutter/material.dart';

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
    // Alternatively, if you use Provider/Riverbloc/etc., you can fetch it safely here:
    // final repository = authRepository ?? context.read<User_AuthRepository>();

    return WebShell(
      topBar: const SizedBox.shrink(),
      // topBar: WebTopBar(
      //   showBars: true,
      //   authRepository: authRepository, // Pass it down, or use the fetched one above
      // ),
      sidebar: WebSidebar(
        currentIndex: currentIndex,
        items: items,
        onTap: onTap,
      ),
      child: screens[currentIndex],
    );
  }
}