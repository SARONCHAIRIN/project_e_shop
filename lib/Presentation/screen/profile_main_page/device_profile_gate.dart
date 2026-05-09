/*
import 'package:e_shop/Presentation/screen/auth/login/login_screen.dart';
import 'package:e_shop/Presentation/screen/auth/signup/signup_screen.dart';
import 'package:e_shop/Presentation/screen/profile_main_page/profile_main.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:flutter/material.dart';

import '../../../core/storage/token_storage.dart';


class DeviceProfileGate extends StatefulWidget {
  final User_AuthRepository repository;
   DeviceProfileGate({
     super.key,
     required this.repository,
   });

  @override
  State<DeviceProfileGate> createState() => _DeviceProfileGateState();
}

class _DeviceProfileGateState extends State<DeviceProfileGate> {

  int? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {

    final id = await TokenStorage().readUserId();

    if (!mounted) return;

    setState(() {
      userId = id;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // NOT LOGIN
    if (userId == null || userId == 0) {

      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Icon(
                  Icons.person_outline,
                  size: 100,
                ),

                const SizedBox(height: 20),

                const Text(
                  'You are not logged in',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Login or create account to continue',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        LoginScreen.routeName,
                          (_) => false,
                      );
                    },
                    child: const Text('Login'),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        SignupScreen.routeNameRegister,
                          (route) => false,
                      );
                    },
                    child: const Text('Create Account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // LOGIN SUCCESS
    return ProfileMain(authRepository: widget.repository);
  }
}*/


import 'package:flutter/material.dart';
import 'package:e_shop/Presentation/screen/profile_main_page/profile_main.dart';
import 'package:e_shop/data/repositories/user_auth_repository.dart';
import 'package:e_shop/core/storage/token_storage.dart';

class DeviceProfileGate extends StatefulWidget {
  final User_AuthRepository repository;
  const DeviceProfileGate({super.key, required this.repository});

  @override
  State<DeviceProfileGate> createState() => _DeviceProfileGateState();
}

class _DeviceProfileGateState extends State<DeviceProfileGate> {
  int? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final id = await TokenStorage().readUserId();
    if (!mounted) return;
    setState(() {
      userId = id;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (userId == null || userId == 0) {
      return const _GuestProfilePage();
    }
    return ProfileMain(authRepository: widget.repository);
  }
}

// ─── Guest state ───────────────────────────────────────────────
class _GuestProfilePage extends StatelessWidget {
  const _GuestProfilePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF5F5F5),
      backgroundColor:  Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _GuestHero(context),
                    const SizedBox(height: 8),
                    _GuestMenuSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _TopBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
         Text(

            'Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        Icon(Icons.settings_outlined, color: Colors.grey[500]),
      ],
    ),
  );

  Widget _GuestHero(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,


    ),
    margin: EdgeInsets.symmetric(
      horizontal: 20
    ),
    padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
    child: Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: const Icon(Icons.person_outline, size: 38, color: Color(0xFFAAAAAA)),
        ),
        const SizedBox(height: 16),
        const Text('Sign in to your account',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(
          'Access your orders, wishlist,\nand exclusive deals',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text('Sign in',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text('Create account', style: TextStyle(fontSize: 15)),
          ),
        ),
      ],
    ),
  );

  Widget _GuestMenuSection() => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF5F5F5),
      // color: Colors.red,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade400,
          spreadRadius: 1,
          blurRadius: 1,
          blurStyle: BlurStyle.outer
        ),
      ],
    ),

    margin: EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 10,

    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text('Browse as guest',
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ),
        _MenuTile(
          icon: Icons.inventory_2_outlined,
          iconBg: const Color(0xFFE6F1FB),
          iconColor: const Color(0xFF185FA5),
          title: 'Track order',
          subtitle: 'Enter order ID to track',
          onTap: () {

          },
        ),
        _MenuTile(
          icon: Icons.headset_mic_outlined,
          iconBg: const Color(0xFFE1F5EE),
          iconColor: const Color(0xFF0F6E56),
          title: 'Help & support',
          subtitle: 'Chat, call or email us',
          onTap: () {

          },
        ),
      ],
    ),
  );
}

// ─── Shared menu tile ──────────────────────────────────────────
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft:Radius.circular(15),
            bottomRight:Radius.circular(15),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 14)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}