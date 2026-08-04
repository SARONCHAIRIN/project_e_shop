import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:e_shop/features/auth/presentation/screens/login_button_sheet.dart';
import 'package:e_shop/features/auth/presentation/screens/reset_password_screen.dart';

import 'package:flutter/material.dart';

import '../widgets/profile_top_bar.dart';
import '../widgets/guest_hero.dart';
import '../widgets/guest_menu.dart';

class DesktopGuestProfile extends StatefulWidget {
  final User_AuthRepository repository;

  const DesktopGuestProfile({super.key, required this.repository});

  @override
  State<DesktopGuestProfile> createState() => _DesktopGuestProfileState();
}

class _DesktopGuestProfileState extends State<DesktopGuestProfile> {
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
            constraints: const BoxConstraints(maxWidth: 1200),

            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),

              child: Column(
                children: [

                  const SizedBox(height: 30),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Expanded(
                        flex: 2,

                        child: GuestHero(
                          onLogin: _login,

                          onRegister: () {
                            Navigator.pushNamed(context, '/register');
                          },
                        ),
                      ),

                      const SizedBox(width: 30),

                      Expanded(
                        flex: 3,

                        child: GuestMenu(
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
                      ),
                    ],
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
