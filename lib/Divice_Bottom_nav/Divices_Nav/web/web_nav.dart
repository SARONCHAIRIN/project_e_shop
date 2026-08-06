import 'package:e_shop/Presentation/screen/order/order_history_screen.dart';
import 'package:flutter/material.dart';

import '../ tablet/tablet_nav.dart';
import '../../../Presentation/screen/profile_main_page/setting_page.dart';
import '../../../core/storage/token_storage.dart';
import '../mobiles/mobile_nav.dart';
import '../models/navigation_item.dart';

import 'web_shell.dart';
import 'web_sidebar.dart';

class WebNav extends StatefulWidget {
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
  State<WebNav> createState() => _WebNavState();
}

class _WebNavState extends State<WebNav> {
  late int _currentWebIndex;

  @override
  void initState() {
    super.initState();

    _currentWebIndex = widget.currentIndex;
  }

  void _onWebTap(int index) {
    setState(() {
      _currentWebIndex = index;
    });
  }

  Widget _orderScreen() {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        TokenStorage().readUserId(),
        TokenStorage().readToken(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("No data"));
        }

        final int? userId = snapshot.data![0] as int?;
        final String? token = snapshot.data![1] as String?;

        if (userId == null || token == null) {
          return const Center(child: Text("Please login"));
        }

        return OrderHistoryScreen(userId: userId, token: token);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final webItems = [
          ...widget.items,
          const NavigationItem(icon: Icons.shopping_bag, label: "Order"),
          const NavigationItem(
            icon: Icons.settings_outlined,

            label: "Settings",
          ),
        ];

        final webScreens = [
          ...widget.screens,

          _orderScreen(),

          SettingPage(authRepository: widget.authRepository),
        ];

        // Phone Browser
        if (width < 600) {
          return MobileNav(
            currentIndex: widget.currentIndex,
            screens: widget.screens,
            items: widget.items,
            onTap: widget.onTap,
          );
        }

        // Tablet Browser
        if (width < 1024) {
          return TabletNav(
            currentIndex: widget.currentIndex,
            screens: widget.screens,
            items: widget.items,
            onTap: widget.onTap,
          );
        }

        // Desktop Browser
        return WebShell(
          topBar: const SizedBox.shrink(),
          sidebar: WebSidebar(
            currentIndex: _currentWebIndex,
            items: webItems,
            onTap: (index) {
              debugPrint("CLICK SIDEBAR INDEX: $index");

              _onWebTap(index);
            },
          ),
          child: webScreens[_currentWebIndex],
        );
      },
    );
  }
}
