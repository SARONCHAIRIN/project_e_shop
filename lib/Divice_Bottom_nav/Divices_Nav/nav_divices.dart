import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/adaptive_builder.dart';
import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/desktop/desktop_nav.dart';
import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/web/web_nav.dart';

import 'package:e_shop/Presentation/screen/Message_main_page/message_main.dart';
import 'package:e_shop/Presentation/screen/cart_main_page/cart_main.dart';
import 'package:e_shop/Presentation/screen/category_main_page/category_route_page.dart';
import 'package:e_shop/Presentation/screen/profile_main_page/profile_gate.dart';

import 'package:e_shop/data/repositories/user_auth_repository.dart';

import 'package:flutter/material.dart';

import ' tablet/tablet_nav.dart';
import '../../Presentation/screen/home_main_page/home_main.dart';
import 'mobiles/mobile_nav.dart';
import 'models/navigation_item.dart';

class DivicesNav extends StatefulWidget {
  final User_AuthRepository authRepository;

  final int initialIndex;

  const DivicesNav({
    super.key,
    required this.authRepository,
    this.initialIndex = 0,
  });

  static const routeName = '/divicenav';

  @override
  State<DivicesNav> createState() => _DivicesNavState();
}

class _DivicesNavState extends State<DivicesNav> {
  late int _currentIndex;

  late final List<Widget> _screens;

  final List<NavigationItem> navigationItems = const [
    NavigationItem(icon: Icons.home, label: "Home"),

    NavigationItem(icon: Icons.category, label: "Category"),

    NavigationItem(icon: Icons.message, label: "Message"),

    NavigationItem(icon: Icons.shopping_cart, label: "Cart"),

    NavigationItem(icon: Icons.person, label: "Profile"),
  ];

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    _screens = [
      HomeMainPage(authRepository: widget.authRepository),

      // CategoryMain(authRepository: widget.authRepository),
      CategoryMain(authRepository: widget.authRepository),

      MessageMain(),

      CartMain(repository: widget.authRepository),

      // DeviceProfileGate(repository: widget.authRepository),
      ProfileGate(repository: widget.authRepository),
    ];
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveBuilder(
      mobile: MobileNav(
        currentIndex: _currentIndex,

        screens: _screens,

        items: navigationItems,

        onTap: _onTabTapped,
      ),

      tablet: TabletNav(
        currentIndex: _currentIndex,

        screens: _screens,

        items: navigationItems,

        onTap: _onTabTapped,
      ),

      desktop: DesktopNav(
        currentIndex: _currentIndex,

        screens: _screens,

        items: navigationItems,

        onTap: _onTabTapped,
      ),

      web: WebNav(
        currentIndex: _currentIndex,

        screens: _screens,

        items: navigationItems,

        onTap: _onTabTapped,
      ),
    );
  }
}
