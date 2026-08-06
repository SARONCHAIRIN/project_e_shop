import 'package:flutter/material.dart';

import '../../../Presentation/screen/order/order_history_screen.dart';
import '../../../Presentation/screen/profile_main_page/setting_page.dart';
import '../../../core/storage/token_storage.dart';
import '../models/navigation_item.dart';
import 'desktop_shell.dart';
import 'desktop_sidebar.dart';

class DesktopNav extends StatefulWidget {
  final int currentIndex;

  final List<Widget> screens;

  final List<NavigationItem> items;

  final ValueChanged<int> onTap;
  final dynamic authRepository;

  const DesktopNav({
    super.key,

    required this.currentIndex,

    required this.screens,

    required this.items,

    required this.onTap,
    this.authRepository,
  });

  @override
  State<DesktopNav> createState() => _DesktopNavState();
}

class _DesktopNavState extends State<DesktopNav> {
  late int _currentDesktopIndex;

  @override
  void initState() {
    super.initState();

    _currentDesktopIndex = widget.currentIndex;
  }

  void _onDeskTopTap(int index) {
    setState(() {
      _currentDesktopIndex = index;
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
        final deskItem = [
          ...widget.items,
          const NavigationItem(icon: Icons.shopping_bag, label: "Order"),
          const NavigationItem(
            icon: Icons.settings_outlined,

            label: "Settings",
          ),
        ];

        final deskscreen = [
          ...widget.screens,

          _orderScreen(),

          SettingPage(authRepository: widget.authRepository),
        ];

        return DesktopShell(
          sidebar: DesktopSidebar(
            currentIndex: _currentDesktopIndex,

            items: deskItem,

            onTap: (index) {
              debugPrint("CLICK SIDEBAR INDEX: $index");

              _onDeskTopTap(index);
            },
          ),

          child: deskscreen[_currentDesktopIndex],
        );
      },
    );
  }
}
