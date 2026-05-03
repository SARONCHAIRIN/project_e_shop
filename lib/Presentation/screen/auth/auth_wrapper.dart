import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/divices_nav.dart';
import 'package:flutter/material.dart';
import 'login/login_screen.dart';

class AuthWrapper extends StatefulWidget {
  final authRepository;

  const AuthWrapper({super.key, required this.authRepository});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _loading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final token = await widget.authRepository.storage.readToken();
    if (!mounted) return;

    setState(() {
      _isLoggedIn = token != null && token.isNotEmpty;
      _loading = false;
    });

    print(" AuthWrapper - Token exists: $_isLoggedIn");
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _isLoggedIn
        ? DivicesNav(authRepository: widget.authRepository)  // មាន Bottom Nav
        : LoginScreen(authRepository: widget.authRepository); // គ្មាន Bottom Nav
  }
}