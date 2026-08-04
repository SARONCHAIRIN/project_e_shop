import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:e_shop/features/auth/presentation/screens/login_button_sheet.dart';
import 'package:e_shop/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/guest_hero.dart';
import '../widgets/guest_menu.dart';

class TabletGuestProfile extends StatefulWidget {
  final User_AuthRepository repository;

  const TabletGuestProfile({super.key, required this.repository});

  @override
  State<TabletGuestProfile> createState() => _TabletGuestProfileState();
}

class _TabletGuestProfileState extends State<TabletGuestProfile> {
  void _login() {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (_) => LoginBottomSheet1(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),

            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),

              child: Column(
                children: [
                  GuestHero(
                    onLogin: _login,

                    onRegister: () {
                      Navigator.pushNamed(context, '/register');
                    },
                  ),

                  GuestMenu(
                    onTrackOrder: () {
                      showDialog(
                        context: context,

                        builder: (_) => const AlertDialog(
                          title: Text("Track Order"),

                          content: Text("Please login first"),
                        ),
                      );
                    },

                    onHelp: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => ResetPasswordScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
