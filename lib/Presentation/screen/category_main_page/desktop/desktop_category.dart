import 'package:flutter/material.dart';
import 'desktop_category_body.dart';

class DesktopCategory extends StatelessWidget {
  final dynamic authRepository;

  const DesktopCategory({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DesktopCategoryBody(authRepository: authRepository),
    );
  }
}
