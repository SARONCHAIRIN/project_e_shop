import 'package:flutter/material.dart';

import '../sub_profile.dart';

class WebProfile extends StatelessWidget {
  final dynamic authRepository;

  const WebProfile({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: Profilepage(authRepository: authRepository),
    );
  }
}
