import 'package:flutter/material.dart';

import '../../../Presentation/screen/order/order_history_screen.dart';
import '../../../Presentation/screen/profile_main_page/setting_page.dart';
import '../../../core/storage/token_storage.dart';
import '../models/navigation_item.dart';
import 'tablet_navigation_rail.dart';

class TabletNav extends StatefulWidget {
  final int currentIndex;

  final List<Widget> screens;

  final List<NavigationItem> items;

  final ValueChanged<int> onTap;
  final dynamic authRepository;

  const TabletNav({
    super.key,

    required this.currentIndex,

    required this.screens,

    required this.items,

    required this.onTap,
    this.authRepository,
  });

  @override
  State<TabletNav> createState() => _TabletNavState();
}

class _TabletNavState extends State<TabletNav> {
  late int _currentTabletIndex;

  @override
  void initState() {
    super.initState();

    _currentTabletIndex = widget.currentIndex;
  }

  void _onTabletTap(int index) {
    setState(() {
      _currentTabletIndex = index;
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
        final tabletItem = [
          ...widget.items,
          const NavigationItem(icon: Icons.shopping_bag, label: "Order"),
          const NavigationItem(
            icon: Icons.settings_outlined,

            label: "Settings",
          ),
        ];

        final tabletscreen = [
          ...widget.screens,

          _orderScreen(),

          SettingPage(authRepository: widget.authRepository),
        ];
        return Scaffold(
          body: Row(
            children: [
              TabletNavigationRail(
                currentIndex: _currentTabletIndex,

                items: tabletItem,

                onTap: (index) {
                  debugPrint("CLICK SIDEBAR INDEX: $index");

                  _onTabletTap(index);
                },
              ),

              const VerticalDivider(width: 1),

              Expanded(child: tabletscreen[_currentTabletIndex]),
            ],
          ),
        );
      },
    );
  }
}
