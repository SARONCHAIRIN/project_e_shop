import 'package:flutter/material.dart';

import '../desktop/desktop_cart.dart';

class WebCart extends StatelessWidget {
  final int userId;
  final String token;

  const WebCart({super.key, required this.userId, required this.token});

  @override
  Widget build(BuildContext context) {
    return DesktopCart(userId: userId, token: token);
  }
}
