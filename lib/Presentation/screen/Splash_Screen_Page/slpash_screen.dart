import 'dart:async';
import 'package:e_shop/Divice_Bottom_nav/Divices_Nav/divices_nav.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/storage/token_storage.dart';
import '../../../data/repositories/user_auth_repository.dart';

class SplashScreen extends StatefulWidget {
  final User_AuthRepository authRepository;
  const SplashScreen({super.key, required this.authRepository});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isAnimationLoaded = false;

  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  void _navigateNext() async {
    // Wait for 3 seconds (can adjust based on animation length)
    await Future.delayed(const Duration(seconds: 5));

    // Check if user has a token
    final token = await TokenStorage().readToken();

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DivicesNav(authRepository: widget.authRepository),),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation with loader
            Expanded(
              flex: 3,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Show loader while animation not loaded
                    if (!_isAnimationLoaded)
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    // Lottie animation
                    Lottie.asset(
                      'assets/animations/splash_screen_animation.json',
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.6,
                      fit: BoxFit.contain,
                      repeat: false,
                      animate: true,
                      onLoaded: (composition) {
                        setState(() {
                          _isAnimationLoaded = true;
                        });
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.error_outline, size: 50, color: Colors.red),
                            SizedBox(height: 10),
                            Text(
                              'Failed to load animation',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Loading text and optional spinner
            const Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

            // Version number at bottom
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}