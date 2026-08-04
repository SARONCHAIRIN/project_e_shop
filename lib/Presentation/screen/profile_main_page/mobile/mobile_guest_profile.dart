import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:e_shop/features/auth/presentation/screens/login_button_sheet.dart';
import 'package:e_shop/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/guest_hero.dart';
import '../widgets/guest_menu.dart';
import '../widgets/profile_top_bar.dart';

class MobileGuestProfile extends StatefulWidget {
  final User_AuthRepository repository;

  const MobileGuestProfile({super.key, required this.repository});

  @override
  State<MobileGuestProfile> createState() => _MobileGuestProfileState();
}

class _MobileGuestProfileState extends State<MobileGuestProfile> {
  void _showLoginSheet() {
    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (_) {
        return LoginBottomSheet1();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),

          child: Column(
            children: [
              ProfileTopBar(title: "profile", onSettingPressed: () {}),

              GuestHero(
                onLogin: _showLoginSheet,

                onRegister: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),

              GuestMenu(
                onTrackOrder: () {
                  showDialog(
                    context: context,

                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Track Order"),

                        content: const Text("Please login to track your order"),

                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),

                            child: const Text("Close"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onHelp: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ResetPasswordScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
