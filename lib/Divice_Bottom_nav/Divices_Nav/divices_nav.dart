import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:e_shop/Presentation/screen/Message_main_page/message_main.dart';
import 'package:e_shop/Presentation/screen/cart_main_page/cart_main.dart';
import 'package:e_shop/Presentation/screen/home_main_page/home_main_page.dart';
import 'package:e_shop/Presentation/screen/profile_main_page/device_profile_gate.dart';
import 'package:flutter/material.dart';
import '../../Presentation/screen/category_main_page/category_main.dart';
import '../../data/repositories/user_auth_repository.dart';

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
  late int _currentIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens.addAll([
      HomeMainPage(authRepository: widget.authRepository),
      CategoryMain(authRepository: widget.authRepository),
      MessageMain(),
      CartMain(repository: widget.authRepository),

      // ProfileMain(authRepository: widget.authRepository),
      DeviceProfileGate(repository: widget.authRepository),
      // Profilepage(authRepository: widget.authRepository,),
    ]);
  }


  void _onTabTapped(int index) async {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // for floating/blur effect behind nav bar
      body: _screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 1),
        child: CrystalNavigationBar(
          currentIndex: _currentIndex,
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
          onTap: (index) async {
            _onTabTapped(index);
            // optional: check login before switching screens
            setState(() => _currentIndex = index);
          },
          items: [
            CrystalNavigationBarItem(
              icon: Icons.home,
              // You can omit unselectedIcon; it defaults to same icon
              selectedColor: Colors.blueAccent,
            ),
            CrystalNavigationBarItem(
              icon: Icons.category,
              selectedColor: Colors.blueAccent,
            ),
            CrystalNavigationBarItem(
              icon: Icons.message,
              selectedColor: Colors.blueAccent,
            ),
            CrystalNavigationBarItem(
              icon: Icons.shopping_cart,
              selectedColor: Colors.blueAccent,
            ),
            CrystalNavigationBarItem(
              icon: Icons.person,
              selectedColor: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}
