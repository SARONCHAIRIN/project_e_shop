import 'package:flutter/material.dart';

import '../sub_profile.dart';

class MobileProfile extends StatelessWidget {
  final dynamic authRepository;

  const MobileProfile({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return Profilepage(authRepository: authRepository);
  }
}
