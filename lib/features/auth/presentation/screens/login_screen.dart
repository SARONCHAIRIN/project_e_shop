import 'package:e_shop/data/repositories/auth/auth_repository.dart';
import 'package:e_shop/features/auth/presentation/screens/login_button_sheet.dart'
    show LoginBottomSheet1;
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final AuthRepository repository;

  static const routelogin = '/login1';

  const LoginScreen({required this.repository, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openLoginSheet();
    });
  }

  void _openLoginSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => LoginBottomSheet1(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
