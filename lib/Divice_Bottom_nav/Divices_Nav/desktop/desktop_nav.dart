import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../Presentation/screen/order/order_history_screen.dart';
import '../../../Presentation/screen/order/web_guest_order.dart';
import '../../../Presentation/screen/profile_main_page/setting_page.dart';
import '../../../Presentation/screen/profile_main_page/web/web_guest_profile.dart';
import '../../../core/storage/token_storage.dart';
import '../../../data/datasources/order_service.dart';
import '../../../data/repositories/user_auth_repository.dart';
import '../models/navigation_item.dart';
import 'desktop_shell.dart';
import 'desktop_sidebar.dart';

class DesktopNav extends StatefulWidget {
  final int currentIndex;

  final List<Widget> screens;

  final List<NavigationItem> items;

  final ValueChanged<int> onTap;
  final dynamic authRepository;
  final User_AuthRepository repository;

  const DesktopNav({
    super.key,

    required this.currentIndex,

    required this.screens,

    required this.items,

    required this.onTap,
    this.authRepository,
    required this.repository,
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
          return const Center(
            child: SpinKitCircle(color: Colors.blue, size: 50.0),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('no_data'.tr()));
        }

        if (!snapshot.hasData) {
          return Center(child: Text('no_data'.tr()));
        }

        final int? userId = snapshot.data![0] as int?;
        final String? token = snapshot.data![1] as String?;

        // Guest user
        if (userId == null || token == null || token.isEmpty) {
          return WebGuestOrder(
            repository: widget.repository,
            onLoginSuccess: () {
              // Login successful

              // Refresh DesktopNav and select Order

              setState(() {
                _currentDesktopIndex = widget.items.length;
              });
            },
          );
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
          NavigationItem(icon: Icons.shopping_bag, label: "order".tr()),
          NavigationItem(icon: Icons.settings_outlined, label: "setting".tr()),
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
