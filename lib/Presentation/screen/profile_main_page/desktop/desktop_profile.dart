import 'package:flutter/material.dart';

import '../sub_profile.dart';

class DesktopProfile extends StatelessWidget {
  final dynamic authRepository;

  const DesktopProfile({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: Profilepage(authRepository: authRepository),
    );
  }
}
